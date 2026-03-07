#!/bin/bash

# --- Gum Installation & OS Detection ---
if ! command -v gum &> /dev/null; then
    echo "'gum' is not installed, but it's required for this script."
    if [ -f /etc/os-release ]; then . /etc/os-release; OS=$ID; else OS=$(uname -s | tr '[:upper:]' '[:lower:]'); fi
    case $OS in
        ubuntu|debian|kali|linuxmint) INSTALL_CMD='sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg && echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list && sudo apt update && sudo apt install -y gum' ;;
        arch|manjaro|artix) INSTALL_CMD="sudo pacman -S --noconfirm gum" ;;
        fedora|rhel|centos) INSTALL_CMD='echo "[charm]\nname=Charm\nbaseurl=https://repo.charm.sh/yum/\nenabled=1\ngpgcheck=1\ngpgkey=https://repo.charm.sh/yum/gpg.key" | sudo tee /etc/yum.repos.d/charm.repo && sudo rpm --import https://repo.charm.sh/yum/gpg.key && sudo dnf install -y gum' ;;
        opensuse*|suse) INSTALL_CMD='echo "[charm]\nname=Charm\nbaseurl=https://repo.charm.sh/yum/\nenabled=1\ngpgcheck=1\ngpgkey=https://repo.charm.sh/yum/gpg.key" | sudo tee /etc/yum.repos.d/charm.repo && sudo rpm --import https://repo.charm.sh/yum/gpg.key && sudo zypper refresh && sudo zypper install -y gum' ;;
        darwin) INSTALL_CMD="brew install gum" ;;
        *) echo "Unsupported OS: $OS. Please install 'gum' manually."; exit 1 ;;
    esac
    echo "Detected OS: $OS"
    read -p "Would you like to install 'gum' now? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        eval "$INSTALL_CMD"
        if ! command -v gum &> /dev/null; then echo "Installation failed."; exit 1; fi
    else exit 0; fi
fi

# --- Logging Configuration ---
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
BACKUP_LOG="$SCRIPT_DIR/manager_backup.log"
RESTORE_LOG="$SCRIPT_DIR/manager_restore.log"
CURRENT_LOG=""

log_init() {
    CURRENT_LOG=$2
    { echo "================================================================"; echo " SESSION START: $1 ($(date))"; echo "================================================================"; } >> "$CURRENT_LOG"
}

log_summary() {
    { echo ""; echo "----------------------------------------------------------------"; echo " SESSION END: $1 ($(date))"; echo "================================================================"; echo ""; } >> "$CURRENT_LOG"
}

# Global variables to track container reuse
CONTAINER_DRAWN=0
LAST_HEIGHT=0

# Function to run a task with a fixed-position log window
run_task() {
    local label=$1; shift; local cmd=("$@")
    local log_file=$(mktemp); local max_height=12; local cols=$(tput cols)

    echo "[$(date +%T)] TASK: $label" >> "$CURRENT_LOG"
    if [ "$CONTAINER_DRAWN" -eq 1 ]; then
        tput cuu $((LAST_HEIGHT + 2))
        for i in $(seq 1 $((LAST_HEIGHT + 2))); do printf "\r\033[K\n"; done
        tput cuu $((LAST_HEIGHT + 2))
    fi

    gum style --foreground 212 --bold --margin "0 2" -- "┃ $label"
    echo ""; CONTAINER_DRAWN=1; tput civis

    # stdbuf fix: only use for external commands
    if declare -f "${cmd[0]}" > /dev/null; then
        ( "${cmd[@]}" ) > "$log_file" 2>&1 &
    else
        stdbuf -oL -eL "${cmd[@]}" > "$log_file" 2>&1 &
    fi
    local pid=$!

    local current_height=0
    while kill -0 $pid 2>/dev/null; do
        local total_lines=$(wc -l < "$log_file")
        local new_height=$(( total_lines > max_height ? max_height : total_lines ))
        [ "$new_height" -lt 1 ] && [ "$total_lines" -gt 0 ] && new_height=1
        if [ "$current_height" -gt 0 ]; then tput cuu "$current_height"; fi
        current_height=$new_height; LAST_HEIGHT=$new_height
        mapfile -t lines < <(tail -n "$current_height" "$log_file")
        for i in $(seq 0 $((current_height - 1))); do
            printf "\r\033[K   \033[38;5;212m┃\033[0m \033[2m%s\033[0m\n" "${lines[$i]:0:$((cols-7))}"
        done
        sleep 0.1
    done
    wait $pid; local exit_code=$?

    if [ "$current_height" -gt 0 ]; then tput cuu "$current_height"; fi
    local total_lines=$(wc -l < "$log_file")
    local final_height=$(( total_lines > max_height ? max_height : total_lines ))
    [ "$final_height" -lt 1 ] && final_height=1
    current_height=$final_height; LAST_HEIGHT=$final_height
    mapfile -t lines < <(tail -n "$current_height" "$log_file")
    for i in $(seq 0 $((current_height - 1))); do
        printf "\r\033[K   \033[38;5;212m┃\033[0m \033[2m%s\033[0m\n" "${lines[$i]:0:$((cols-7))}"
    done

    cat "$log_file" >> "$CURRENT_LOG"; echo "Exit Code: $exit_code" >> "$CURRENT_LOG"
    tput cnorm; rm "$log_file"; return $exit_code
}

TOOLS_MAPPING=("Gemini CLI|.gemini|GeminiCLI" "Antigravity|.antigravity" "Claude Code|.claude|.claude.json|.config/claude|.local/share/claude|claude" "OpenCode|.config/opencode|.local/share/opencode" "Codex CLI|.codex|codex")
PERSONAL_FOLDERS=("Documents" "Desktop" "Workspace" "Pictures" "Videos" "Downloads")

resolve_paths() {
    local selections=$1; local mode=$2; local base_dir=$3; local backup_file=$4; local final_paths=()
    IFS=$'\n' read -rd '' -a selected_list <<< "$selections"
    for selected in "${selected_list[@]}"; do
        if [[ "$selected" == "Docker Volume: "* ]]; then final_paths+=("docker_volumes/${selected#Docker Volume: }"); continue; fi
        if [ "$selected" == "System Package List" ]; then final_paths+=("package_lists"); continue; fi
        local found_tool=false
        for tool_entry in "${TOOLS_MAPPING[@]}"; do
            IFS='|' read -r tool_name paths <<< "$tool_entry"
            if [ "$selected" == "$tool_name" ]; then
                found_tool=true; IFS='|' read -ra path_array <<< "$paths"
                for p in "${path_array[@]}"; do
                    if [ "$mode" == "source" ]; then [ -e "$base_dir/$p" ] && final_paths+=("$p")
                    else p_clean="${p#/}"; tar --zstd -tf "$backup_file" | grep -qx "$p_clean/.*\|$p_clean" && final_paths+=("$p_clean"); fi
                done
                break
            fi
        done
        if [ "$found_tool" == "false" ]; then
            local p_clean="${selected#/}"
            if [ "$mode" == "source" ]; then
                if [[ "$selected" = /* ]]; then [ -e "$selected" ] && final_paths+=("$selected")
                else [ -e "$base_dir/$selected" ] && final_paths+=("$selected"); fi
            else tar --zstd -tf "$backup_file" | grep -qx "$p_clean/.*\|$p_clean" && final_paths+=("$p_clean"); fi
        fi
    done
    printf "%s\n" "${final_paths[@]}" | sort -u
}

ACTION=$(gum choose "Backup" "Restore" "Exit"); [ $? -ne 0 ] && exit 0; echo ""
[ "$ACTION" == "Exit" ] && exit 0

if [ "$ACTION" == "Backup" ]; then
    log_init "BACKUP" "$BACKUP_LOG"
    gum format "### SOURCE: Folders to Backup"; echo ""
    SOURCE_DIR=$(gum input --placeholder "Path to home folder" --value "$HOME"); [ -z "$SOURCE_DIR" ] && exit 0
    gum format "### DESTINATION: Backup Storage"; echo ""
    SAVE_DIR=$(gum input --placeholder "Path to store archive" --value "$HOME"); [ -z "$SAVE_DIR" ] && exit 0

    AVAILABLE_S=(); AI_TOOLS_ONLY=(); AVAILABLE_S+=("System Package List"); AI_TOOLS_ONLY+=("System Package List")
    for tool_entry in "${TOOLS_MAPPING[@]}"; do
        IFS='|' read -r tool_name paths <<< "$tool_entry"; IFS='|' read -ra path_array <<< "$paths"
        for p in "${path_array[@]}"; do if [ -e "$SOURCE_DIR/$p" ]; then AVAILABLE_S+=("$tool_name"); AI_TOOLS_ONLY+=("$tool_name"); break; fi; done
    done
    for f in "${PERSONAL_FOLDERS[@]}"; do [ -e "$SOURCE_DIR/$f" ] && AVAILABLE_S+=("$f"); done

    if gum confirm "Load extra folder paths from a text file?"; then
        echo ""; EXTRA_FILE=$(gum input --placeholder "Path to text file" --value "$HOME/extra_paths.txt")
        if [[ -f "$EXTRA_FILE" ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                line=$(echo "$line" | xargs); if [[ -n "$line" && "$line" != \#* ]]; then
                    path_add=""; if [[ "$line" = /* ]]; then [ -e "$line" ] && path_add="$line"; else [ -e "$SOURCE_DIR/$line" ] && path_add="$line"; fi
                    if [ -n "$path_add" ]; then AVAILABLE_S+=("$path_add"); AI_TOOLS_ONLY+=("$path_add"); fi
                fi
            done < "$EXTRA_FILE"
        fi
    fi

    if command -v docker &> /dev/null; then
        DOCKER_VOLS=($(docker volume ls --format '{{.Name}}'))
        if [ ${#DOCKER_VOLS[@]} -gt 0 ] && gum confirm "Include Docker volumes?"; then
            VOL_LIST=$(printf "%s\n" "${DOCKER_VOLS[@]}" | gum choose --no-limit --header "Select Volumes")
            if [ -n "$VOL_LIST" ]; then mapfile -t SV < <(echo "$VOL_LIST"); for v in "${SV[@]}"; do AVAILABLE_S+=("Docker Volume: $v"); AI_TOOLS_ONLY+=("Docker Volume: $v"); done; fi
        fi
    fi

    SELECTIONS=$(printf "%s\n" "${AVAILABLE_S[@]}" | gum choose --no-limit --selected="$(IFS=,; echo "${AI_TOOLS_ONLY[*]}")")
    [ -z "$SELECTIONS" ] && exit 0
    FINAL_PATH_LIST=($(resolve_paths "$SELECTIONS" "source" "$SOURCE_DIR"))
    echo ""; gum format "### Selected for backup:"; mapfile -t dl <<< "$SELECTIONS"; for item in "${dl[@]}"; do echo " - $item"; done | gum format; echo ""
    if ! gum confirm "Proceed with backup?"; then exit 0; fi
    
    TMP_WORKSPACE=$(mktemp -d); USER_ID=$(id -u); GROUP_ID=$(id -g)
    if [[ " ${dl[*]} " == *"System Package List"* ]]; then
        generate_package_lists() {
            mkdir -p "$TMP_WORKSPACE/package_lists"
            if [ -f /etc/arch-release ]; then pacman -Qqe > "$TMP_WORKSPACE/package_lists/system_packages.txt"
            elif command -v apt &>/dev/null; then apt list --installed > "$TMP_WORKSPACE/package_lists/system_packages.txt"; fi
            command -v flatpak &>/dev/null && flatpak list --columns=application > "$TMP_WORKSPACE/package_lists/flatpaks.txt"
        }
        run_task "Generating Package Lists" generate_package_lists
    fi
    export_docker_vols() {
        for v_entry in "${dl[@]}"; do if [[ "$v_entry" == "Docker Volume: "* ]]; then
            v_name="${v_entry#Docker Volume: }"; echo "Processing: $v_name"; mkdir -p "$TMP_WORKSPACE/docker_volumes/$v_name"
            docker run --rm -v "$v_name":/from -v "$TMP_WORKSPACE/docker_volumes/$v_name":/to busybox sh -c "cp -a /from/. /to/ && chown -R $USER_ID:$GROUP_ID /to"; fi; done
    }
    [[ " ${dl[*]} " == *"Docker Volume: "* ]] && run_task "Exporting Docker Volumes" export_docker_vols

    BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.zst"; BACKUP_PATH="$SAVE_DIR/$BACKUP_NAME"
    mkdir -p "$(dirname "$BACKUP_PATH")"; REL_PATHS=(); ABS_PATHS=()
    for p in "${FINAL_PATH_LIST[@]}"; do if [[ "$p" != docker_volumes/* && "$p" != package_lists ]]; then if [[ "$p" = /* ]]; then ABS_PATHS+=("${p#/}"); else REL_PATHS+=("$p"); fi; fi; done
    TAR_ARGS=("--zstd" "--ignore-failed-read" "--warning=no-file-changed" "-cvf" "$BACKUP_PATH")
    [ ${#REL_PATHS[@]} -gt 0 ] && TAR_ARGS+=("-C" "$SOURCE_DIR" "${REL_PATHS[@]}")
    [ ${#ABS_PATHS[@]} -gt 0 ] && TAR_ARGS+=("-C" "/" "${ABS_PATHS[@]}")
    [ -d "$TMP_WORKSPACE/docker_volumes" ] && TAR_ARGS+=("-C" "$TMP_WORKSPACE" "docker_volumes")
    [ -d "$TMP_WORKSPACE/package_lists" ] && TAR_ARGS+=("-C" "$TMP_WORKSPACE" "package_lists")
    run_task "Compressing Backup" tar "${TAR_ARGS[@]}"
    rm -rf "$TMP_WORKSPACE"
    if [ $? -eq 0 ]; then echo ""; gum style --foreground "#00af87" --bold --margin "0 2" -- "┃ Backup Successful!"; log_summary "SUCCESS"
    else echo ""; gum style --foreground 196 --bold --margin "0 2" -- "┃ Backup Failed."; log_summary "FAILED"; fi

elif [ "$ACTION" == "Restore" ]; then
    log_init "RESTORE" "$RESTORE_LOG"
    gum format "### DESTINATION: Extraction Target"; echo ""
    SOURCE_DIR=$(gum input --placeholder "Path to extract to" --value "$HOME"); [ -z "$SOURCE_DIR" ] && exit 0
    gum format "### SOURCE: Backup Archives"; echo ""
    SAVE_DIR=$(gum input --placeholder "Path containing backups" --value "$HOME"); [ -z "$SAVE_DIR" ] && exit 0

    while true; do
        gum format "### Select the backup file (.tar.zst)"; echo ""
        mapfile -t FILES < <(ls "$SAVE_DIR"/*.tar.zst 2>/dev/null)
        if [ ${#FILES[@]} -eq 0 ]; then
            gum style --foreground 196 --bold --margin "0 2" -- "┃ No .tar.zst files found";
            if gum confirm "Select a different source folder?"; then SAVE_DIR=$(gum input --placeholder "New Source Path" --value "$SAVE_DIR"); [ -z "$SAVE_DIR" ] && exit 0; continue; else exit 0; fi
        fi
        BACKUP_FILE=$(printf "%s\n" "${FILES[@]}" | gum choose --header "Pick a backup archive" --height 10); [ $? -ne 0 ] && exit 0; echo ""
        FAC=$(gum spin --spinner dot --title "Analyzing archive..." -- tar --zstd -tf "$BACKUP_FILE" | sed 's|/$||')
        
        A_T=(); P_F=(); D_V=(); C_P=()
        echo "$FAC" | grep -qx "package_lists/.*\|package_lists" && { A_T+=("System Package List"); C_P+=("package_lists"); }
        for tool_entry in "${TOOLS_MAPPING[@]}"; do
            IFS='|' read -r tool_name paths <<< "$tool_entry"; IFS='|' read -ra path_array <<< "$paths"; found=false
            for p in "${path_array[@]}"; do p_clean="${p#/}"; if echo "$FAC" | grep -qx "$p_clean/.*\|$p_clean"; then found=true; C_P+=("$p_clean"); fi; done
            [ "$found" == "true" ] && A_T+=("$tool_name")
        done
        for f in "${PERSONAL_FOLDERS[@]}"; do if echo "$FAC" | grep -qx "$f/.*\|$f"; then P_F+=("$f"); C_P+=("$f"); fi; done
        mapfile -t D_VOLS < <(echo "$FAC" | grep "^docker_volumes/" | cut -d'/' -f2 | sort -u)
        for dv in "${D_VOLS[@]}"; do [ -n "$dv" ] && { D_V+=("Docker Volume: $dv"); C_P+=("docker_volumes/$dv"); }; done

        cpf=$(mktemp); printf "%s\n" "${C_P[@]}" > "$cpf"
        mapfile -t EXTRAS < <(echo "$FAC" | awk -v cp_file="$cpf" '
            BEGIN { while ((getline line < cp_file) > 0) { covered[line] = 1 } }
            {
                n = split($0, segments, "/"); path = ""; is_covered = 0;
                for (i=1; i<=n; i++) {
                    path = (path == "" ? segments[i] : path "/" segments[i])
                    if (covered[path]) { is_covered = 1; break }
                }
                if (!is_covered) {
                    if (segments[1] == "home") {
                        res = segments[1]; max = (n > 4) ? 4 : n; for (i=2; i<=max; i++) { res = res "/" segments[i] }; print "/" res
                    } else if (segments[1] != "docker_volumes" && segments[1] != "package_lists") {
                        res = segments[1]; max = (n > 2) ? 2 : n; for (i=2; i<=max; i++) { res = res "/" segments[i] }; print res
                    }
                }
            }
        ' | sort -u); rm "$cpf"

        mapfile -t AVAILABLE < <(printf "%s\n" "${A_T[@]}" "${P_F[@]}" "${D_V[@]}" "${EXTRAS[@]}")
        SELECTIONS=$(printf "%s\n" "${AVAILABLE[@]}" | gum choose --no-limit --selected="*"); [ -z "$SELECTIONS" ] && exit 0
        mapfile -t sl <<< "$SELECTIONS"; FINAL_RESTORE_LIST=($(resolve_paths "$SELECTIONS" "backup" "" "$BACKUP_FILE"))

        HOME_RESTORE=(); SYSTEM_RESTORE=()
        for p in "${FINAL_RESTORE_LIST[@]}"; do
            if [[ "$p" == home/* || "$p" == etc/* || "$p" == usr/* || "$p" == var/* ]]; then SYSTEM_RESTORE+=("$p")
            elif [[ "$p" != docker_volumes/* && "$p" != package_lists ]]; then HOME_RESTORE+=("$p"); fi
        done

        gum format "### Restoration Plan"; echo ""
        [ ${#HOME_RESTORE[@]} -gt 0 ] && { echo "  ┃ Restore to Home: $HOME"; for p in "${HOME_RESTORE[@]}"; do echo "    - $p"; done; }
        [ ${#SYSTEM_RESTORE[@]} -gt 0 ] && { echo "  ┃ Restore to Root: /"; for p in "${SYSTEM_RESTORE[@]}"; do echo "    - $p"; done; }
        [[ " ${SELECTIONS[*]} " == *"System Package List"* ]] && echo "  ┃ Extract Package Lists to $HOME"
        echo ""

        CHOICE=$(gum choose "Proceed with Plan" "Custom Destination" "Cancel")
        [ "$CHOICE" == "Cancel" ] && exit 0
        if [ "$CHOICE" == "Custom Destination" ]; then
            CUST_DEST=$(gum input --placeholder "Custom folder" --value "$HOME"); [ -z "$CUST_DEST" ] && exit 0
            run_task "Extracting Backup" tar --zstd -xvf "$BACKUP_FILE" -C "$CUST_DEST" "${FINAL_RESTORE_LIST[@]}"
        else
            [ ${#HOME_RESTORE[@]} -gt 0 ] && run_task "Restoring Home Data" tar --zstd -xvf "$BACKUP_FILE" -C "$HOME" "${HOME_RESTORE[@]}"
            [ ${#SYSTEM_RESTORE[@]} -gt 0 ] && run_task "Restoring System Data" tar --zstd -xvf "$BACKUP_FILE" -C "/" "${SYSTEM_RESTORE[@]}"
            [[ " ${SELECTIONS[*]} " == *"System Package List"* ]] && run_task "Extracting Package Lists" tar --zstd -xvf "$BACKUP_FILE" -C "$HOME" "package_lists"
        fi

        restore_docker_vols() {
            local ep="/tmp"; tar --zstd -xvf "$BACKUP_FILE" -C "$ep" "docker_volumes" >/dev/null 2>&1
            for sel in "${sl[@]}"; do if [[ "$sel" == "Docker Volume: "* ]]; then
                v_name="${sel#Docker Volume: }"; echo "Restoring: $v_name"
                docker volume create "$v_name" >/dev/null
                docker run --rm -v "$v_name":/to -v "$ep/docker_volumes/$v_name":/from busybox cp -a /from/. /to/; fi; done
            rm -rf "$ep/docker_volumes"
        }
        [[ " ${SELECTIONS[*]} " == *"Docker Volume: "* ]] && run_task "Importing Docker Volumes" restore_docker_vols

        echo ""; gum style --foreground "#00af87" --bold --margin "0 2" -- "┃ Restore Successful!"; log_summary "SUCCESS"; break
    done
fi
