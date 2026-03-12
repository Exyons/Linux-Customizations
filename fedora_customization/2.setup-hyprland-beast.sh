#!/bin/bash
set -euo pipefail

TELA_FOLDER_COLOR="${TELA_FOLDER_COLOR:-cyan}"
GTK_THEME="${GTK_THEME:-Wallbash-Gtk}"
HYDE_ICON_DEFAULT="${HYDE_ICON_DEFAULT:-Tela-circle-dracula}"
HYDE_CURSOR_THEME="${HYDE_CURSOR_THEME:-Bibata-Modern-Ice}"
ICON_THEME_CANDIDATE="Tela-circle-dark-${TELA_FOLDER_COLOR}"
ICON_THEME_FALLBACK="Tela-circle-dark"
ICON_THEME="Adwaita"

echo "======================================================="
echo "     Hyprland All-in-One Setup (Current Config)       "
echo "======================================================="

# --- [1/7] Install required packages ---
echo "---> Installing required packages..."
sudo dnf install -y --skip-unavailable \
  uwsm \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  brightnessctl \
  playerctl \
  hypridle \
  hyprlock \
  hyprpanel \
  hyprland-guiutils \
  nwg-displays \
  nwg-look \
  socat \
  git \
  gsettings-desktop-schemas \
  dconf \
  qt5ct \
  qt6ct \
  kvantum \
  kvantum-qt5 \
  adw-gtk3-theme \
  breeze-gtk \
  breeze-icon-theme

# --- [2/7] Configure UWSM environment ---
echo "---> Configuring UWSM environment..."
# Create correct directory layout
mkdir -p "$HOME/.config/uwsm"
mkdir -p "$HOME/.config/uwsm/env.d"
mkdir -p "$HOME/.config/uwsm/env-hyprland.d"

# Create main env file (general variables)
cat <<'EOF' > "$HOME/.config/uwsm/env"
# --- Toolkit / Desktop environment variables ---
export MOZ_ENABLE_WAYLAND=1
export GDK_BACKEND=wayland,x11,*
export QT_QPA_PLATFORM=wayland;xcb
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
#export QT_SCALE_FACTOR=1.2
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export SDL_VIDEODRIVER=wayland,x11
export CLUTTER_BACKEND=wayland

# Cursor settings
export XCURSOR_SIZE=21
# export XCURSOR_THEME=Bibata-Modern-Ice
export HYPRCURSOR_SIZE=21
# export HYPRCURSOR_THEME=Bibata-Modern-Ice

# NVIDIA / acceleration
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_VRR_ALLOWED=1
export GBM_BACKEND=nvidia-drm
export LIBVA_DRIVER_NAME=nvidia
export NVD_BACKEND=direct

# Electron / misc
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export OZONE_PLATFORM=wayland
#export GDK_SCALE=1
#export GDK_DPI_SCALE=1.33

# Proton
export PROTON_USE_NTSYNC=1
export PROTON_ENABLE_WAYLAND=1

# Toolkit Backend Variables - https://wiki.hyprland.org/Configuring/Environment-variables/#toolkit-backend-variables
EOF

# Create Hyprland-specific env file
cat <<'EOF' > "$HOME/.config/uwsm/env-hyprland"
# Hyprland specific environment variables

# GPU ordering (iGPU first)
export AQ_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
export WLR_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"

# Disable sd_notify integration if needed
export HYPRLAND_NO_SD_NOTIFY=1
export HYPRLAND_NO_SD_VARS=1
EOF

# --- [3/7] Write Hyprland config files ---
echo "---> Writing Hyprland config files..."
mkdir -p "$HOME/.config/hypr"

cat << 'HYPREOF' > "$HOME/.config/hypr/hyprland.conf"
################
### MONITORS ###
################
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/border-colors.conf
monitor = ,preferred,auto,auto,bitdepth,10,vrr,1

###################
### MY PROGRAMS ###
###################
$terminal = kitty
$fileManager = dolphin
#$menu = wofi --show drun
$menu = hyprlauncher
$browser = firefox
$displayManager = nwg-displays -m ~/.config/hypr/monitors.conf -w ~/.config/hypr/workspaces.conf
# The Beast Mode launcher for GPU-heavy web tasks
$beastBrowser = __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia firefox

#################
### AUTOSTART ###
#################
exec-once = uwsm finalize
# Launch HyprPanel via UWSM resource management
exec-once = uwsm app -- hyprpanel
exec-once = hyprlauncher -d
exec-once = hypridle
exec-once = ~/.config/hypr/border-gradient-rotate.sh

#############################
### ENVIRONMENT VARIABLES ###
#############################
# UWSM handles the heavy lifting now
#env = XCURSOR_SIZE,24
#env = HYPRCURSOR_SIZE,24

#####################
### LOOK AND FEEL ###
#####################
general {
    gaps_in = 3
    gaps_out = 5
    border_size = 2
    resize_on_border = true
    allow_tearing = false
    layout = dwindle
}

decoration {
    rounding = 10
    rounding_power = 2
    active_opacity = 1.0
    inactive_opacity = 1.0
    shadow {
        enabled = false
        range = 4
        render_power = 3
        color = rgba(1a1a1aee)
    }
    blur {
        enabled = true
        size = 3
        passes = 1
        vibrancy = 0.1696
    }
}

animations {
    enabled = yes
    bezier = easeOutQuint, 0.23, 1, 0.32, 1
    bezier = almostLinear, 0.5, 0.5, 0.75, 1
    bezier = quick, 0.15, 0, 0.1, 1

    animation = global, 1, 10, default
    animation = windows, 1, 4.79, easeOutQuint
    animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
    animation = workspaces, 1, 1.94, almostLinear, fade
}

dwindle {
    pseudotile = true
    preserve_split = true
}

misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
    vrr = 1
    vfr = true
}

#############
### INPUT ###
#############
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0.1
    accel_profile = adaptive
    touchpad {
        tap-to-click = yes
        drag_lock = yes
        natural_scroll = true
        scroll_factor = 0.5
    }
}

device {
    name = e-signal-kreo-hawk
    sensitivity = -0.7
    scroll_factor = 0.8
}

###################
### KEYBINDINGS ###
###################
$mainMod = SUPER

bindm = $mainMod, Z, movewindow
bindm = $mainMod, X, resizewindow
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

bind = $mainMod, T, exec, $terminal
bind = SHIFT, F11, fullscreen, 0
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, W, togglefloating,
bind = $mainMod, A, exec, $menu
bind = $mainMod, B, exec, $browser
bind = $mainMod, P, exec, $displayManager
# NEW: Beast Mode Firefox (SUPER + SHIFT + B)
bind = $mainMod SHIFT, B, exec, $beastBrowser
bind = $mainMod, L, exec, loginctl lock-session

# Focus navigation
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
# ==========================================
# MOVE FOCUSED WINDOW TO WORKSPACE
# ==========================================
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9

# Turn the current window into a group, or add a window to an active group
bind = $mainMod, G, togglegroup
# Cycle through the tabs inside the group
bind = $mainMod, Tab, changegroupactive

bind = $mainMod, P, pin

bind = $mainMod, J, togglesplit

# Cycle forward through windows on the current workspace
bind = ALT, Tab, cyclenext,
bind = ALT, Tab, bringactivetotop,

# Cycle backward through windows (Shift + Alt + Tab)
bind = ALT SHIFT, Tab, cyclenext, prev
bind = ALT SHIFT, Tab, bringactivetotop,

# Summon or hide the scratchpad with SUPER + S
bind = $mainMod, S, togglespecialworkspace, magic

# Send the currently active window to the scratchpad with SUPER + SHIFT + S
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# ==========================================
# SCRATCHPAD SEND & RETRIEVE
# ==========================================
# 1. View the scratchpad overlay
bind = $mainMod, B, togglespecialworkspace, magic

# 2. Send the active window TO the scratchpad
bind = $mainMod SHIFT, B, movetoworkspace, special:magic

# 3. Pull a window OUT of the scratchpad to your current workspace
bind = $mainMod SHIFT, C, movetoworkspace, e+0

# Style the special workspace to look like a floating overlay
workspace = special:magic, gapsout:50, gapsin:10, bg:blur

# Instantly teleport the active workspace to the external projector
bind = $mainMod SHIFT, P, movecurrentworkspacetomonitor, HDMI-A-1

# Teleport it back to the laptop screen
bind = $mainMod SHIFT, O, movecurrentworkspacetomonitor, eDP-1

# Turn OFF laptop screen (Projector only)
bind = $mainMod, F7, exec, hyprctl keyword monitor eDP-1,disable

# Turn ON laptop screen (Normal mode)
bind = $mainMod SHIFT, F7, exec, hyprctl keyword monitor eDP-1,preferred,auto,1

# Multimedia keys
bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+
bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-

##############################
### WINDOWS AND WORKSPACES ###
##############################
source = ~/.config/hypr/workspaces.conf
windowrule {
    # Ignore maximize requests from all apps. You'll probably like this.
    name = suppress-maximize-events
    match:class = .*
    suppress_event = maximize
}

windowrule {
    # Fix some dragging issues with XWayland
    name = fix-xwayland-drags
    match:class = ^$
    match:title = ^$
    match:xwayland = true
    match:float = true
    match:fullscreen = false
    match:pin = false

    no_focus = true
}

# Hyprland-run windowrule
windowrule {
    name = move-hyprland-run
    match:class = hyprland-run
    move = 20 monitor_h-120
    float = yes
}

##########################################################################
########################### HyDE Window Rules ############################
##########################################################################

# Fix file chooser dialogs opening off-screen
windowrule = float true,match:tag portal-dialogs
windowrule = center on,match:tag portal-dialogs

# Only add the Core applications here
windowrule {
    name = beast_floating_apps
    tag = +beast_floating_apps
    match:class = ^(blueman-manager|pavucontrol-qt|com\.gabm\.satty|vlc|kvantummanager|qt[56]ct|nwg-(look|displays)|org\.kde\.ark|org\.pulseaudio\.pavucontrol|blueman-manager|nm-(applet|connection-editor)|org\.kde\.polkit-kde-authentication-agent-1|console-dropdown)$
}

windowrule {
    name = beast_dolphin_popups
    tag = +beast_floating_apps
    match:class = ^(org\.kde\.dolphin)$
    match:title = ^(Progress Dialog — Dolphin|Copying — Dolphin)$
}

# common popups
windowrule {
    name = beast_common_popups
    tag = +beast_common_popups
    match:title = ^(.*[Ss]ettings.*|[Ww]elcome.*|.*Preferences.*|Choose Files|Save As|Confirm to replace files|File Operation Progress|Open|Authentication Required|Add Folder to Workspace|File Upload.*|Choose wallpaper.*|Library.*|.*dialog.*)$
}

windowrule = match:initial_title ^(Open File|Volume Control|Save As.*)$, tag +beast_common_popups
windowrule = match:class ^(.*dialog.*|[Xx]dg-desktop-portal-gtk)$, tag +beast_common_popups

windowrule {
    name = beast_portal_dialogs
    tag = +beast_portal_dialogs
    match:class = ^(org\.freedesktop\.impl\.portal\.desktop\.(hyprland|gtk)|[Xx]dg-desktop-portal-gtk)$
}

# Picture-in-Picture
windowrule {
    name = beast_picture_in_picture
    match:title = ^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
    tag = +picture-in-picture
    tag = +beast_picture_in_picture
    float = true
    keep_aspect_ratio = true
    move = (monitor_w*0.73) (monitor_h*0.72)
    size = (monitor_w*0.25) (monitor_h*0.25)
    pin = true
}


windowrule = float true, match:tag beast_floating_apps
windowrule = float true, center true, match:tag beast_common_popups
windowrule = float true, center true, match:tag beast_portal_dialogs
windowrule = match:float true, match:class beast_floating_apps

# idle_inhibit rules
windowrule = idle_inhibit fullscreen true, match:class ^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$
windowrule = idle_inhibit fullscreen true, match:class ^(.*[Ss]potify.*)$
windowrule = idle_inhibit fullscreen true, match:class ^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$

# float rules
windowrule = float true,match:class ^(Signal)$ # Signal-Gtk
windowrule = float true,match:class ^(com.github.rafostar.Clapper)$ # Clapper-Gtk
windowrule = float true,match:class ^(app.drey.Warp)$ # Warp-Gtk
windowrule = float true,match:class ^(net.davidotek.pupgui2)$ # ProtonUp-Qt
windowrule = float true,match:class ^(yad)$ # Protontricks-Gtk
windowrule = float true,match:class ^(eog)$ # Imageviewer-Gtk
windowrule = float true,match:class ^(io.github.alainm23.planify)$ # planify-Gtk
windowrule = float true,match:class ^(io.gitlab.theevilskeleton.Upscaler)$ # Upscaler-Gtk
windowrule = float true,match:class ^(com.github.unrud.VideoDownloader)$ # VideoDownloader-Gkk
windowrule = float true,match:class ^(io.gitlab.adhami3310.Impression)$ # Impression-Gtk
windowrule = float true,match:class ^(io.missioncenter.MissionCenter)$ # MissionCenter-Gtk

# workaround for jetbrains IDEs dropdowns/popups cause flickering
windowrule = no_initial_focus true,match:class ^(.*jetbrains.*)$,match:title ^(win[0-9]+)$

##########################################################################
##########################################################################
##########################################################################

# Nvidia Specific Fixes
cursor {
    no_hardware_cursors = true
}

# Fix for apps that are blurry like steam, lutris, wine, etc.
xwayland {
    force_zero_scaling = true
}

# Hyprpanel config window rules
windowrule {
    name = hyprpanel-settings-float
    match:class = gjs
    match:title = hyprpanel-settings
    float = yes
    center = true
}

windowrule {
    name = hyprpanel-theme-selector-float
    match:class = gjs
    match:title = ^(Import Hyprpanel Theme|Select a File)$
    float = yes
    center = true
    size = 800 600
}

windowrule {
    name = syncthingy
    match:class = SyncThingy
    match:title = SyncThingy
    float = yes
    center = true
    size = 800 600
}
windowrule {
    name = steam-dialog-float
    match:class = steam
    match:title = ^(Special Offers|Friends List)$
    float = yes
    center = true
}

windowrule = float yes, center true, match:class org.kde.gwenview
windowrule = float yes, center true, size 1000 600, match:class org.gnome.Totem
windowrule = float yes, center true, match:class net.lutris.Lutris, match:title ^(Install.*)$
windowrule = float yes, center true, match:class net.lutris.Lutris, match:title ^(Configure.*)$
HYPREOF

# Set global mimetypes 
cat << 'MIMEEOF' > "$HOME/.config/mimeapps.list"
[Default Applications]
# Text and Code (Routes to your terminal editor)
text/plain=nvim.desktop
text/markdown=nvim.desktop
text/x-python=nvim.desktop

# Images (Gwenview)
image/png=org.kde.gwenview.desktop
image/jpeg=org.kde.gwenview.desktop
image/jpg=org.kde.gwenview.desktop
image/gif=org.kde.gwenview.desktop
image/webp=org.kde.gwenview.desktop
image/svg+xml=org.kde.gwenview.desktop
image/bmp=org.kde.gwenview.desktop
image/tiff=org.kde.gwenview.desktop

# Videos (GNOME video player)
video/mp4=org.gnome.Totem.desktop
video/x-matroska=org.gnome.Totem.desktop
video/webm=org.gnome.Totem.desktop
video/x-msvideo=org.gnome.Totem.desktop
video/quicktime=org.gnome.Totem.desktop
video/x-flv=org.gnome.Totem.desktop
video/mpeg=org.gnome.Totem.desktop

# PDFs and Documents
application/pdf=org.mozilla.firefox.desktop

# Web Links
x-scheme-handler/http=org.mozilla.firefox.desktop
x-scheme-handler/https=org.moziall.firefox.desktop
MIMEEOF

cat << 'IDLEEOF' > "$HOME/.config/hypr/hypridle.conf"
general {
    # Start the lockscreen when the session lock signal is received.
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
    ignore_dbus_inhibit = false
}

# Dim screen after 5 minutes.
listener {
    timeout = 300
    on-timeout = brightnessctl -s set 1%
    on-resume = brightnessctl -r
}

# Lock session after 7 minutes.
listener {
    timeout = 420
    on-timeout = loginctl lock-session
}

# Turn displays off after 10 minutes.
listener {
    timeout = 600
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
IDLEEOF

cat << 'LOCKEOF' > "$HOME/.config/hypr/hyprlock.conf"
background {
    monitor =
    path = screenshot
    blur_passes = 3
    blur_size = 8
    noise = 0.0117
    contrast = 1.2
    brightness = 0.85
    vibrancy = 0.1696
    vibrancy_darkness = 0.0
}

input-field {
    monitor =
    size = 260, 50
    outline_thickness = 3
    dots_size = 0.26
    dots_spacing = 0.64
    dots_center = true
    outer_color = rgb(151515)
    inner_color = rgb(200200200)
    font_color = rgb(10, 10, 10)
    fade_on_empty = false
    rounding = 12
    check_color = rgb(204, 136, 34)
    fail_color = rgb(204, 34, 34)
    fail_text = <i>$FAIL</i>
    placeholder_text = <i>Password...</i>
    hide_input = false
    position = 0, -80
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +'%A, %d %B %Y')"
    color = rgb(220, 220, 220)
    font_size = 22
    position = 0, 90
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +'%I:%M %p')"
    color = rgb(240, 240, 240)
    font_size = 64
    position = 0, 150
    halign = center
    valign = center
}
LOCKEOF

# Detect currently focused monitor when running inside Hyprland; otherwise use a safe fallback.
MONITOR_LINE="monitor=,preferred,auto,auto,bitdepth,10,vrr,1"
if command -v hyprctl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  DETECTED_MONITOR_LINE="$(hyprctl -j monitors 2>/dev/null | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    if not data:
        raise ValueError("no monitors")
    mon = next((m for m in data if m.get("focused")), data[0])
    name = mon.get("name")
    width = int(mon.get("width"))
    height = int(mon.get("height"))
    refresh = float(mon.get("refreshRate"))
    x = int(mon.get("x", 0))
    y = int(mon.get("y", 0))
    scale = mon.get("scale", 1)
    print(f"monitor={name},{width}x{height}@{refresh:.1f},{x}x{y},scale,bitdepth,10,vrr,1")
except Exception:
    pass
' || true)"
  if [ -n "${DETECTED_MONITOR_LINE}" ]; then
    MONITOR_LINE="${DETECTED_MONITOR_LINE}"
  fi
fi

cat > "$HOME/.config/hypr/monitors.conf" << MONEOF
# Generated by setup script. Auto-detected when possible.
${MONITOR_LINE}
MONEOF

cat << 'WORKEOF' > "$HOME/.config/hypr/workspaces.conf"
# Optional per-monitor workspace assignment.
# Example:
# workspace = 1, monitor:DP-1, default:true
WORKEOF

cat << 'BORDEREOF' > "$HOME/.config/hypr/border-colors.conf"
# Window border colors module
# Adjust these values to quickly theme active/inactive borders.
general {
    col.active_border = rgba(c77dffee) rgba(ffe66dee) rgba(7dffb3ee) rgba(6ec1ffee) 35deg
    col.inactive_border = rgba(595959aa)
}
BORDEREOF

cat << 'ROTEOF' > "$HOME/.config/hypr/border-gradient-rotate.sh"
#!/usr/bin/env sh

# Rotate active border gradient for 1s whenever a new window opens.

set -eu

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  exit 1
fi

SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
DEFAULT_ANGLE=35
STOPS="rgba(c77dffee) rgba(ffe66dee) rgba(7dffb3ee) rgba(6ec1ffee)"

animate_border() {
  i=0
  while [ "$i" -lt 12 ]; do
    angle=$(( (DEFAULT_ANGLE + i * 12) % 360 ))
    hyprctl keyword "general:col.active_border" "${STOPS} ${angle}deg" >/dev/null 2>&1 || true
    sleep 0.08
    i=$((i + 1))
  done
  hyprctl keyword "general:col.active_border" "${STOPS} ${DEFAULT_ANGLE}deg" >/dev/null 2>&1 || true
}

if command -v socat >/dev/null 2>&1; then
  EVENT_STREAM_CMD="socat -u UNIX-CONNECT:${SOCKET} -"
elif command -v nc >/dev/null 2>&1; then
  EVENT_STREAM_CMD="nc -U ${SOCKET}"
elif command -v python3 >/dev/null 2>&1; then
  EVENT_STREAM_CMD="python3 -c 'import socket; s=socket.socket(socket.AF_UNIX); s.connect(\"${SOCKET}\"); f=s.makefile(\"r\", encoding=\"utf-8\", errors=\"ignore\"); [print(line, end=\"\") for line in f]'"
else
  exit 1
fi

sh -c "${EVENT_STREAM_CMD}" | while IFS= read -r line; do
  case "$line" in
    openwindow* )
      animate_border &
      ;;
  esac
done
ROTEOF

chmod +x "$HOME/.config/hypr/border-gradient-rotate.sh"

# --- [4/7] Configure global dark theme (GTK/QT/KDE + Dolphin) ---
echo "---> Applying dark theme with Tela Circle icons..."

mkdir -p "$HOME/.local/share/icons"

# Install all Tela-circle variants.
TELA_TMP="$(mktemp -d /tmp/tela-circle.XXXXXX)"
if curl -fsSL https://codeload.github.com/vinceliuice/Tela-circle-icon-theme/tar.gz/refs/heads/master -o "${TELA_TMP}/tela-circle.tar.gz"; then
  tar -xzf "${TELA_TMP}/tela-circle.tar.gz" -C "${TELA_TMP}"
  TELA_SRC="$(find "${TELA_TMP}" -maxdepth 1 -type d -name 'Tela-circle-icon-theme-*' | head -n1)"
  if [ -n "${TELA_SRC}" ] && [ -x "${TELA_SRC}/install.sh" -o -f "${TELA_SRC}/install.sh" ]; then
    chmod +x "${TELA_SRC}/install.sh"
    "${TELA_SRC}/install.sh" -a -d "$HOME/.local/share/icons" >/dev/null 2>&1 || true
  fi
fi
rm -rf "${TELA_TMP}"

# Install HyDE icon/cursor assets exactly as shipped.
HYDE_TMP="$(mktemp -d /tmp/hyde-assets.XXXXXX)"
if curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Source/arcs/Gtk_Wallbash.tar.gz -o "${HYDE_TMP}/Gtk_Wallbash.tar.gz"; then
  mkdir -p "$HOME/.local/share/themes"
  tar -xzf "${HYDE_TMP}/Gtk_Wallbash.tar.gz" -C "$HOME/.local/share/themes" || true
fi
if curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Source/arcs/Icon_Wallbash.tar.gz -o "${HYDE_TMP}/Icon_Wallbash.tar.gz"; then
  tar -xzf "${HYDE_TMP}/Icon_Wallbash.tar.gz" -C "$HOME/.local/share/icons" || true
fi
if curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Source/arcs/Cursor_BibataIce.tar.gz -o "${HYDE_TMP}/Cursor_BibataIce.tar.gz"; then
  tar -xzf "${HYDE_TMP}/Cursor_BibataIce.tar.gz" -C "$HOME/.local/share/icons" || true
fi
rm -rf "${HYDE_TMP}"

if [ -d "$HOME/.local/share/icons/${HYDE_ICON_DEFAULT}" ] || [ -d "/usr/share/icons/${HYDE_ICON_DEFAULT}" ]; then
  ICON_THEME="${HYDE_ICON_DEFAULT}"
elif [ -d "$HOME/.local/share/icons/${ICON_THEME_CANDIDATE}" ] || [ -d "/usr/share/icons/${ICON_THEME_CANDIDATE}" ]; then
  ICON_THEME="$ICON_THEME_CANDIDATE"
elif [ -d "$HOME/.local/share/icons/${ICON_THEME_FALLBACK}" ] || [ -d "/usr/share/icons/${ICON_THEME_FALLBACK}" ]; then
  ICON_THEME="$ICON_THEME_FALLBACK"
fi

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
cat << EOF > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=${GTK_THEME}
gtk-icon-theme-name=${ICON_THEME}
gtk-cursor-theme-name=${HYDE_CURSOR_THEME}
gtk-application-prefer-dark-theme=1
EOF

cat << EOF > "$HOME/.config/gtk-4.0/settings.ini"
[Settings]
gtk-theme-name=${GTK_THEME}
gtk-icon-theme-name=${ICON_THEME}
gtk-cursor-theme-name=${HYDE_CURSOR_THEME}
gtk-application-prefer-dark-theme=1
EOF

mkdir -p "$HOME/.config/qt5ct" "$HOME/.config/qt6ct"
mkdir -p "$HOME/.config/qt5ct/colors" "$HOME/.config/qt6ct/colors" "$HOME/.config/Kvantum/wallbash"
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/Kvantum/kvantum.kvconfig -o "$HOME/.config/Kvantum/kvantum.kvconfig" || true
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/Kvantum/wallbash/wallbash.kvconfig -o "$HOME/.config/Kvantum/wallbash/wallbash.kvconfig" || true
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/Kvantum/wallbash/wallbash.svg -o "$HOME/.config/Kvantum/wallbash/wallbash.svg" || true

if ! curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/qt5ct/qt5ct.conf -o "$HOME/.config/qt5ct/qt5ct.conf"; then
cat << EOF > "$HOME/.config/qt5ct/qt5ct.conf"
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/darker.conf
custom_palette=true
icon_theme=${ICON_THEME}
standard_dialogs=default
style=Fusion

[Interface]
menus_have_icons=true
stylesheets=@Invalid()
toolbutton_style=4
show_shortcuts_in_context_menus=true
EOF
fi
if ! curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/qt6ct/qt6ct.conf -o "$HOME/.config/qt6ct/qt6ct.conf"; then
cat << EOF > "$HOME/.config/qt6ct/qt6ct.conf"
[Appearance]
color_scheme_path=/usr/share/qt6ct/colors/darker.conf
custom_palette=true
icon_theme=${ICON_THEME}
standard_dialogs=default
style=Fusion

[Interface]
menus_have_icons=true
stylesheets=@Invalid()
toolbutton_style=4
show_shortcuts_in_context_menus=true
EOF
fi
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/qt5ct/colors/wallbash.conf -o "$HOME/.config/qt5ct/colors/wallbash.conf" || true
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/qt6ct/colors/wallbash.conf -o "$HOME/.config/qt6ct/colors/wallbash.conf" || true

# Clean up leftovers from old theme experiments.
rm -f "$HOME/.local/share/color-schemes/HyprCyanDark.colors"
rm -f "$HOME/.config/qt5ct/colors/wallbash.conf.broken" "$HOME/.config/qt6ct/colors/wallbash.conf.broken"

cat << EOF > "$HOME/.config/kdeglobals"
[General]
ColorScheme=BreezeDark
Name=BreezeDark
TerminalApplication=kitty

[KDE]
ColorScheme=BreezeDark
widgetStyle=Breeze

[Icons]
Theme=${ICON_THEME}

[UiSettings]
ColorScheme=BreezeDark

[Wallet]
Enabled=false
EOF

mkdir -p "$HOME/.config"
cat << EOF > "$HOME/.config/kcminputrc"
[Mouse]
cursorTheme=${HYDE_CURSOR_THEME}
EOF

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
  gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}" || true
  gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}" || true
  gsettings set org.gnome.desktop.interface cursor-theme "${HYDE_CURSOR_THEME}" || true
fi

# HyDE Dolphin UI layout (exact files), then enforce stable theme keys.
mkdir -p "$HOME/.config" "$HOME/.local/share/kxmlgui5/dolphin" "$HOME/.local/share/dolphin/view_properties/global" "$HOME/.local/state"
if ! curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.config/dolphinrc -o "$HOME/.config/dolphinrc"; then
  cat << 'EOF' > "$HOME/.config/dolphinrc"
[General]
ShowSelectionToggle=false
ShowStatusBar=false
Version=202

[MainWindow]
MenuBar=Disabled
EOF
fi
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.local/share/kxmlgui5/dolphin/dolphinui.rc -o "$HOME/.local/share/kxmlgui5/dolphin/dolphinui.rc" || true
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.local/share/dolphin/view_properties/global/.directory -o "$HOME/.local/share/dolphin/view_properties/global/.directory" || true
curl -fsSL https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.local/state/dolphinstaterc -o "$HOME/.local/state/dolphinstaterc" || true
rm -rf "$HOME/.local/share/dolphin/view_properties/global/.stfolder"
cat << EOF >> "$HOME/.config/dolphinrc"

[UiSettings]
ColorScheme=BreezeDark
IconTheme=${ICON_THEME}
EOF

# --- [5/7] Flatpak apps scaling fix ---
flatpak override --user --env=GDK_SCALE=1
flatpak override --user --env=GDK_DPI_SCALE=1.33
flatpak override --user --env=QT_SCALE_FACTOR=1.2
flatpak override --user --env=QT_AUTO_SCREEN_SCALE_FACTOR=1

# --- [6/7] Enable wayloand onyl socket for flatpak apps ---
flatpak override --user md.obsidian.Obsidian --socket=wayland --nosocket=x11

# --- [7/7] Done ---
echo "======================================================="
echo "          HYPRLAND ALL-IN-ONE SETUP IS READY          "
echo "======================================================="
echo "Run this after setup/login:"
echo "  hyprctl reload"
echo "  pkill hypridle; hypridle &"
echo "Manual lock: SUPER + L"
echo "Theme: HyDE-style dark + ${ICON_THEME} + ${HYDE_CURSOR_THEME}"
echo "To change icon folder color, run with: TELA_FOLDER_COLOR=blue ./2.setup_hyprland.sh"
