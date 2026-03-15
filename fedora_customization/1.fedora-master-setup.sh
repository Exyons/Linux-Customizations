#!/bin/bash
# Exit immediately if a command exits with a non-zero status to prevent cascading failures
set -e

echo "======================================================="
echo "   Fedora 43 Ultimate Base + AI + Nvidia Master Setup  "
echo "======================================================="

echo -e "\n---> [0/17] Bootstrapping Minimal Fedora Utilities..."
# We MUST install these first so curl scripts can extract and hardware can be detected.
# 'openssl' is injected here so kmodgenca can generate the Secure Boot keys later.
sudo dnf install -y tar unzip curl wget pciutils lshw findutils util-linux procps-ng openssl fontconfig

echo -e "\n---> [1/17] Installing NVM, Node.js, and Bun..."
# Install NVM for version management, source it immediately, and grab the latest Node.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install node
# Install Bun for lightning-fast JavaScript execution
curl -fsSL https://bun.sh/install | bash

echo -e "\n---> [2/17] Installing Ollama (Local LLM Runner) with DNF5 Fix..."
# Download the script locally to intercept and fix the broken DNF4 syntax
curl -fsSL https://ollama.com/install.sh -o ollama_install.sh
# Search and replace to inject the required --from-repofile= flag for DNF5 compatibility
sed -i 's/config-manager --add-repo /config-manager addrepo --from-repofile=/g' ollama_install.sh
# sh ollama_install.sh
# rm ollama_install.sh

echo -e "\n---> [3/17] Enabling COPRs, RPM Fusion, and 3rd-Party Repositories..."
# Enable bleeding-edge Hyprland, Wayland GTK shells, and necessary utilities
sudo dnf copr enable -y sdegler/hyprland
sudo dnf copr enable -y tofik/nwg-shell
sudo dnf copr enable -y heus-sueh/packages
sudo dnf copr enable -y atim/lazygit

# DNF5 Updated Syntax for setting repository priority
sudo dnf config-manager setopt "copr:copr.fedorainfracloud.org:heus-sueh:packages.priority=200"

# Enable RPM Fusion (Free and Non-Free) for Nvidia drivers and media codecs
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Visual Studio Code & Antigravity Custom Repositories
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

echo -e "\n---> [4/17] Installing Raw Nerd Fonts (v3.4.0)..."
# Pulling raw zip files because Fedora's package manager handles Nerd Fonts poorly
FONT_DIR="$HOME/.local/share/fonts/nerd-fonts"
mkdir -p "$FONT_DIR"
FONTS=("Agave" "FiraCode" "RobotoMono" "SpaceMono" "CodeNewRoman" "NerdFontsSymbolsOnly" "Hack" "JetBrainsMono" "CascadiaCode" "CascadiaMono")

for FONT in "${FONTS[@]}"; do
    echo "Downloading $FONT..."
    # Upgraded to wget to handle connection drops and timeouts gracefully
    wget -q --show-progress --tries=3 -O "/tmp/$FONT.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$FONT.zip"
    unzip -qo "/tmp/$FONT.zip" -d "$FONT_DIR"
    rm "/tmp/$FONT.zip"
done
fc-cache -vf "$FONT_DIR"

echo -e "\n---> [5/17] Installing Core System & Desktop Utilities..."
sudo dnf install -y \
    iwlwifi-mvm-firmware NetworkManager-wifi bat \
    flatpak upower libgtop2 bluez bluez-tools google-noto-color-emoji-fonts \
    grimblast hyprpicker btop NetworkManager wl-clipboard swww brightnessctl \
    gnome-bluetooth power-profiles-daemon gvfs gtksourceview3 libsoup3 \
    firefox kitty dolphin htop bmon fwupd acpid samba dosbox \
    zsh hyprland hyprpanel sddm cabextract fuse fuse-libs \
    efibootmgr xfsprogs ntfs-3g dosfstools exfatprogs udftools plymouth-theme-spinner \
    linux-firmware alsa-sof-firmware microcode_ctl \
    network-manager-applet net-tools esptool gamemode gamemode.i686

################## Installing eza #####################
echo -e "\n Installing eza..."
echo "---> [1/4] Creating local bin directory..."
mkdir -p ~/.local/bin

echo "---> [2/4] Downloading eza v0.23.4..."
wget -q --show-progress -O /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/v0.23.4/eza_x86_64-unknown-linux-gnu.tar.gz"

echo "---> [3/4] Extracting and installing to ~/.local/bin..."
tar -xzf /tmp/eza.tar.gz -C /tmp
mv /tmp/eza ~/.local/bin/
chmod +x ~/.local/bin/eza

echo "---> [4/4] Cleaning up..."
rm /tmp/eza.tar.gz

################### Installing Pokego #########################
echo -e "\n Installing pokego..."

echo "---> [2/4] Downloading pokego v0.5.2..."
wget -q --show-progress -O /tmp/pokego.tar.gz "https://github.com/rubiin/pokego/releases/download/v0.5.2/pokego_Linux_x86_64.tar.gz"

echo "---> [3/4] Extracting and installing to ~/.local/bin..."
tar -xzf /tmp/pokego.tar.gz -C /tmp
mv /tmp/pokego ~/.local/bin/
chmod +x ~/.local/bin/pokego

echo "---> [4/4] Cleaning up..."
rm /tmp/pokego.tar.gz

echo -e "\n---> [6/17] Installing Audio & Video Codecs..."
# Core PipeWire infrastructure and all GStreamer plugins for full media compatibility
sudo dnf install -y \
    pipewire pipewire.i686 wireplumber pipewire-pulseaudio pipewire-alsa \
    pipewire-jack-audio-connection-kit pipewire-jack-audio-connection-kit.i686 \
    alsa-utils pavucontrol \
    gstreamer1-plugins-base gstreamer1-plugins-base.i686 cups-libs cups-libs.i686 \
    gstreamer1-plugins-good gstreamer1-plugins-good.i686 \
    gstreamer1-plugins-ugly gstreamer1-plugins-ugly.i686 \
    gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free.i686 \
    gstreamer1-plugin-libav gstreamer1-plugin-libav.i686

echo -e "\n---> [7/17] Installing Steam, Lutris & 32-bit Gaming Infrastructure..."
# Installing packages only. DXVK and Wine overrides are handled automatically inside Lutris later.
sudo dnf install -y \
    steam lutris blender xrandr wine winetricks wine-mono libvkd3d libvkd3d.i686 giflib giflib.i686 \
    libpng libpng.i686 openldap openldap.i686 gnutls gnutls.i686 \
    mpg123-libs mpg123-libs.i686 openal-soft openal-soft.i686 \
    libv4l libv4l.i686 pulseaudio-libs pulseaudio-libs.i686 \
    alsa-plugins-pulseaudio alsa-plugins-pulseaudio.i686 alsa-lib alsa-lib.i686 \
    alsa-firmware libjpeg-turbo libjpeg-turbo.i686 libXcomposite libXcomposite.i686 \
    libXinerama libXinerama.i686 ncurses-libs ncurses-libs.i686 \
    libxslt libxslt.i686 libva libva.i686 gtk3 gtk3.i686 \
    vulkan-loader vulkan-loader.i686 vulkan-tools mesa-dri-drivers.i686 \
    mesa-vulkan-drivers mesa-vulkan-drivers.i686 mangohud mangohud.i686 goverlay

echo -e "\n---> [8/17] Installing Developer, Container & AI Tooling..."
# Podman stack replaces Docker cleanly using daemonless, rootless, SELinux-friendly architecture
sudo dnf install -y \
    git neovim gcc make ripgrep fd-find lazygit fzf \
    code antigravity torbrowser-launcher podman podman-compose podman-docker \
    https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Give podman more permissions
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo tee /etc/systemd/system/user@.service.d/delegate.conf > /dev/null << 'EOF'
[Service]
Delegate=cpu cpuset io memory pids
EOF

# Installing nvidia-container toolkit
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
    sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.18.2-1
sudo dnf install -y \
    nvidia-container-toolkit-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1-${NVIDIA_CONTAINER_TOOLKIT_VERSION}

echo -e "\n---> [9/17] Secure Boot MOK Setup & Nvidia Installation..."
# We MUST install akmods first so 'kmodgenca' becomes available for signing keys
sudo dnf install -y akmods

# Generate the MOK keys BEFORE the drivers are built so akmods can find them
sudo kmodgenca -a

# Stage the public key to be enrolled in the UEFI on next boot
echo "======================================================================"
echo "CRITICAL: Creating MOK Password for Secure Boot."
echo "Keep it simple (e.g., 12345678). You only type this ONCE upon reboot."
echo "======================================================================"
sudo mokutil --import /etc/pki/akmods/certs/public_key.der

# Disable the restricted repo and shatter the Fedora module shadow-ban 
sudo dnf config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=0 || true
sudo dnf module disable nvidia-driver -y || true

# Clean cache and install the unlocked Nvidia drivers
sudo dnf clean all
sudo dnf update --refresh -y
sudo dnf install -y --allowerasing \
    akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs.i686 \
    xorg-x11-drv-nvidia-cuda libva-nvidia-driver nvtop

echo -e "\n---> [10/17] Forcing Nvidia Kernel Module Build & Signing..."
# Because the MOK keys exist now, akmods will automatically sign the modules during compilation
sudo akmods --force
# Rebuild the initial ramdisk to permanently inject the signed driver and blacklist nouveau
sudo dracut --force

echo -e "\n---> [11/17] Setting up Flatpaks..."
# Running with sudo to bypass headless PolicyKit restrictions during minimal install
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub \
    io.github.flattool.Warehouse \
    com.vysp3r.ProtonPlus \
    io.missioncenter.MissionCenter \
    me.iepure.devtoolbox \
    io.github.kolunmi.Bazaar \
    com.github.tchx84.Flatseal \
    md.obsidian.Obsidian \
    org.libreoffice.LibreOffice \
    org.telegram.desktop \
    com.obsproject.Studio \
    org.gimp.GIMP \
    org.localsend.localsend_app \
    org.kde.filelight \
    org.mozilla.Thunderbird \
    org.kde.gwenview \
    io.podman_desktop.PodmanDesktop \
    io.github.peazip.PeaZip \
    org.gnome.Totem \
    com.github.zocker_160.SyncThingy \
    org.gnome.Firmware \
    org.upscayl.Upscayl
    # org.mozilla.firefox

echo -e"\n---> [12/17] Installing Homebrew..."
sudo dnf group install -y development-tools
NONINTERACTIVE=1 CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Add brew to shell env
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
brew install gcc
brew install yazi

echo -e "\n---> [13/17] Configuring Oh My Zsh, LazyVim & Dynamic TUI Padding..."
# Bootstrap LazyVim by removing existing config and pulling the starter template
if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"

# Install Oh My Zsh (Unattended mode)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Fetch necessary Zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Generate the minimal, high-performance .zshrc
cat << 'EOF' > "$HOME/.zshrc"
# ==========================================
# Minimal Oh My Zsh Configuration
# ==========================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="half-life" 
DISABLE_AUTO_UPDATE="true"
plugins=(git dnf python zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ==========================================
# ENVIRONMENT VARIABLES & PATHS
# ==========================================
export EDITOR=nvim
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

# Start pokego
pokego -r 1-8

# Lazy-load NVM for sub-millisecond shell startup
export NVM_DIR="$HOME/.nvm"

# add newest installed node to PATH, so globally installed binaries are on path
if [ -d "$NVM_DIR/versions/node" ]; then
  export PATH="$(ls -d $NVM_DIR/versions/node/*/bin | sort -V | tail -n1):$PATH"
fi

_lazy_nvm_load() {
    # remove shim functions
    unset -f node npm npx nvm yarn pnpm bun

    # load nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

    # run original command
    command "$@"
}

node() { _lazy_nvm_load node "$@"; }
npm()  { _lazy_nvm_load npm "$@"; }
npx()  { _lazy_nvm_load npx "$@"; }
nvm()  { _lazy_nvm_load nvm "$@"; }
yarn() { _lazy_nvm_load yarn "$@"; }
pnpm() { _lazy_nvm_load pnpm "$@"; }
bun()  { _lazy_nvm_load bun "$@"; }

# ==========================================
# ALIASES
# ==========================================
# The Beast Mode Toggle (Force dGPU usage for any command)
alias beast="__NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia"
alias grep="grep --color=auto"
alias reload="source ~/.zshrc"
alias c='clear'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# Eza (Modern ls replacements)
alias l='eza -lh --icons=auto'                                         
alias ls='eza -1 --icons=auto'                                         
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' 
alias ld='eza -lhD --icons=auto'                                       
alias lt='eza --icons=auto --tree'                                     

# Package Management (Fedora native)
alias in='sudo dnf install'                  # install package(s)
alias un='sudo dnf remove'                   # uninstall package
alias up='sudo dnf upgrade --refresh'        # update system
alias pl='dnf list installed'                # list installed package
alias pa='dnf search'                        # list available package
alias pc='sudo dnf clean all'                # remove unused cache
alias po='sudo dnf autoremove'               # remove unused dependencies

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# ==========================================
# DYNAMIC KITTY PADDING WRAPPER (THE ONE THAT WORKS)
# ==========================================
# Instantly removes Kitty padding for full-screen TUIs and restores it after exiting
wrap_tui() {
    if [[ "$TERM" == "xterm-kitty" ]]; then
        kitty @ set-spacing padding=0
        command "$@"
        kitty @ set-spacing padding=default
    else
        command "$@"
    fi
}

alias nvim="wrap_tui nvim"
alias btop="wrap_tui btop"
alias lazygit="wrap_tui lazygit"

# Nice looking command search history using fzf
source /usr/share/fzf/shell/key-bindings.zsh

# Add homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
EOF

# Change default shell to Zsh for the current user
sudo chsh -s $(which zsh) $(whoami)

# Force the shell to use NVM's node instead of the system node to install global AI tools
export NVM_DIR="$HOME/.nvm"
\. "$NVM_DIR/nvm.sh"
nvm use node
npm install -g @google/gemini-cli @openai/codex @anthropic-ai/claude-code opencode-ai

echo -e "\n---> [14/17] Configuring Kitty Terminal (Beast Mode & Dracula Theme)..."
KITTY_DIR="$HOME/.config/kitty"
THEMES_DIR="$KITTY_DIR/kitty-themes"
mkdir -p "$KITTY_DIR"

# Pull the Kitty themes repository for dynamic symlinking
if [ ! -d "$THEMES_DIR" ]; then
    git clone --depth 1 https://github.com/dexpota/kitty-themes.git "$THEMES_DIR"
else
    cd "$THEMES_DIR" && git pull && cd - > /dev/null
fi

# Symlink the requested Dracula theme
ln -sf "$THEMES_DIR/themes/Dracula.conf" "$KITTY_DIR/theme.conf"

# Build the fully uncapped, un-throttled Kitty configuration
cat << 'EOF' > "$KITTY_DIR/kitty.conf"
# ==========================================
# FONTS & APPEARANCE
# ==========================================
font_family CaskaydiaCove Nerd Font Mono
bold_font auto
italic_font auto
bold_italic_font auto
font_size 11
window_padding_width 5

# Cursor trails require frame buffering. Disabled for raw speed.
cursor_trail 0

# Disable audio bell to prevent UI lockups
enable_audio_bell no

# ==========================================
# TAB BAR STYLING
# ==========================================
tab_bar_edge                bottom
tab_bar_style               powerline
tab_powerline_style         slanted
tab_title_template          {title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}
map ctrl+shift+t            new_tab_with_cwd

# ==========================================
# RAW PERFORMANCE TWEAKS (Beast Mode)
# ==========================================
# Forces immediate frame rendering and cuts out Wayland input overhead
input_delay 0
repaint_delay 2
sync_to_monitor no
wayland_enable_ime no

# ==========================================
# ATOMIC IPC SOCKETS (For the Zsh Wrapper)
# ==========================================
allow_remote_control yes
listen_on unix:/tmp/kitty-{kitty_pid}

# ==========================================
# THEME INCLUSION
# ==========================================
include theme.conf
EOF

echo -e "\n---> [15/17] Setting up plymouth theme..."
sudo tee /etc/dracut.conf.d/plymouth.conf > /dev/null << 'EOF' # Only appends works when doing like this
add_dracutmodules+=" plymouth "
force_drivers+=" i915 "
EOF
# Regenrate initramfs and set theme
sudo plymouth-set-default-theme -R bgrt

# Decrease grub timeout
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub && \
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Installing anti-flashbang service to keep your retinas safe when system wakes after suspend..."
sudo tee /etc/systemd/system/backlight-resume.service > /dev/null << 'EOF'
[Unit]
Description=Save and Restore Brightness Across Suspend
Before=sleep.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes

# Save the exact brightness state right before sleep
ExecStart=/usr/bin/brightnessctl --save

# When waking up, wait 3 seconds for the NVIDIA/Wayland drivers to initialize, then restore
ExecStop=/bin/bash -c "sleep 3 && /usr/bin/brightnessctl --restore"

[Install]
WantedBy=sleep.target
EOF
sudo systemctl enable backlight-resume.service

echo -e "\n---> [15/17] Installing SDDM Astronaut Theme (Pixel Sakura)..."
# Install specific Qt6 dependencies required to render Astronaut correctly
sudo dnf install -y qt6-qtsvg qt6-qtvirtualkeyboard qt6-qtmultimedia

# Clone the theme directly into SDDM's theme directory
sudo rm -rf /usr/share/sddm/themes/sddm-astronaut-theme
sudo git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme

# Copy bundled theme fonts to the system
sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/

# Instruct SDDM to use the astronaut theme
echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf

# Configure the virtual keyboard extension
sudo mkdir -p /etc/sddm.conf.d
echo -e "[General]\nInputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf

# Swap the theme variant metadata to Pixel Sakura
sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/pixel_sakura.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop

echo -e "\n---> [17/17] Configuring Systemd Boot Targets and Display Manager..."
# Ensure the system boots into the graphical target and SDDM handles the login
sudo systemctl enable sddm.service
sudo systemctl set-default graphical.target

echo "======================================================="
echo "                  SETUP COMPLETE!                      "
echo "======================================================="
echo "CRITICAL NEXT STEPS UPON REBOOT:"
echo "1. The blue 'Perform MOK management' screen will appear."
echo "2. Select 'Enroll MOK' -> 'Continue' -> 'Yes'."
echo "3. Enter the password you created in Step 9."
echo "4. Reboot, hit your BIOS key to turn Secure Boot ON."
echo "5. Your Pixel Sakura SDDM login screen will load with full Nvidia acceleration."
