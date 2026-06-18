#!/usr/bin/env bash
# ==========================================================================
# CachyOS personal setup script
# Installs packages, configures Niri/Ly/Kitty/Zsh/Yazi/Neovim, services.
# Run as your NORMAL user (not root). Sudo is used where needed.
# ==========================================================================
set -Eeuo pipefail

# --------------------------------------------------------------------------
# Colors & progress helpers
# --------------------------------------------------------------------------
if [ -t 1 ]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[1;33m'
  BLUE=$'\033[0;34m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  BOLD=''
  RESET=''
fi

TOTAL_STEPS=21
CURRENT_STEP=0

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo -e "\n${BLUE}${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} ${BOLD}$1${RESET}"
}
info() { echo -e "  ${BLUE}→${RESET} $1"; }
ok() { echo -e "  ${GREEN}✓${RESET} $1"; }
warn() { echo -e "  ${YELLOW}!${RESET} $1"; }
die() {
  echo -e "\n${RED}${BOLD}✗ ERROR:${RESET} $1" >&2
  exit 1
}

trap 'die "Failed at line ${LINENO}: ${BASH_COMMAND}"' ERR

# --------------------------------------------------------------------------
# Pre-flight
# --------------------------------------------------------------------------
[ "$(id -u)" -eq 0 ] && die "Run this as your normal user, not root. Sudo is invoked where required."
command -v sudo >/dev/null || die "sudo is not installed."

# --------------------------------------------------------------------------
# 1. Passwordless sudo
# --------------------------------------------------------------------------
setup_sudo() {
  step "Configuring passwordless sudo for $USER"
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$USER" >/dev/null
  sudo chmod 0440 "/etc/sudoers.d/$USER"
  sudo visudo -cf "/etc/sudoers.d/$USER" >/dev/null || die "sudoers file failed validation — not applied"
  ok "Passwordless sudo enabled and validated"
}

# --------------------------------------------------------------------------
# 2. Chaotic-AUR repository (run before installing packages)
# --------------------------------------------------------------------------
setup_chaotic_aur() {
  step "Setting up Chaotic-AUR repository"

  # Already configured? Skip so re-runs don't duplicate the repo block.
  if grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
    info "Chaotic-AUR already configured, skipping"
    return 0
  fi

  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

  # tee -a runs the write under sudo (plain >> would run as your user and be denied)
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" |
    sudo tee -a /etc/pacman.conf >/dev/null
  sudo pacman -Syu --noconfirm
  ok "Chaotic-AUR enabled"
}

# --------------------------------------------------------------------------
# 2. Official repo packages (pacman)
# --------------------------------------------------------------------------
install_packages() {
  step "Installing official packages"
  local packages=(
    # Wayland desktop
    niri dms-shell ly cava dgop matugen fuzzel
    qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
    # Terminal & CLI tools
    kitty uv brightnessctl neovim eza yazi starship zoxide viu expac
    wl-clipboard ncdu htop btop nvtop tmux github-cli lazygit ollama yay
    sbctl
    # Fonts & theming
    ttf-cascadia-code-nerd ttf-cascadia-mono-nerd inter-font nwg-look
    # Apps
    obsidian thunderbird nautilus visual-studio-code-bin
    # Wine / gaming runtime libraries
    wine-staging winetricks wine-mono vkd3d lib32-vkd3d
    giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap
    gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal
    v4l-utils lib32-v4l-utils libpulse lib32-libpulse
    alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib
    libjpeg-turbo lib32-libjpeg-turbo libxcomposite lib32-libxcomposite
    libxinerama lib32-libxinerama ncurses lib32-ncurses
    libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3
    gst-plugins-base-libs
    # Gaming apps
    steam lutris mangohud lib32-mangohud goverlay gamemode lib32-gamemode gamescope
    # System services
    cups samba flatpak screen network-manager-applet udiskie udisks2
    # Docker
    docker docker-buildx docker-compose
    # Extras
    pokego-git bibata-cursor-theme bibata-rainbow-cursor-theme
    upscayl-desktop-git nano-syntax-highlighting gnome-keyring
  )
  sudo pacman -Syu --needed --noconfirm "${packages[@]}"
  ok "Official packages installed"
}

# --------------------------------------------------------------------------
# 3. AUR packages (yay)
# --------------------------------------------------------------------------
# Run as the normal user — yay calls sudo itself and refuses to run as root.
# --needed skips already-installed pkgs; --noconfirm keeps it non-interactive.
install_aur() {
  step "Installing AUR packages"
  yay -S --needed --noconfirm \
    colloid-gtk-theme-git adw-gtk-theme-git \
    tela-circle-icon-theme-all-git ttf-apple-emoji ||
    warn "One or more AUR packages failed to build"
  ok "AUR packages processed"
}

# --------------------------------------------------------------------------
# 4. Flatpaks (flathub is pre-configured on CachyOS)
# --------------------------------------------------------------------------
install_flatpaks() {
  step "Installing Flatpaks"
  sudo flatpak install -y flathub \
    com.vysp3r.ProtonPlus \
    io.missioncenter.MissionCenter \
    me.iepure.devtoolbox \
    io.github.kolunmi.Bazaar \
    com.github.tchx84.Flatseal \
    org.telegram.desktop \
    com.obsproject.Studio \
    org.gimp.GIMP \
    org.localsend.localsend_app \
    org.kde.filelight \
    org.kde.gwenview \
    io.github.peazip.PeaZip \
    org.gnome.Totem \
    com.github.zocker_160.SyncThingy \
    org.gnome.Firmware \
    app.zen_browser.zen ||
    warn "One or more Flatpaks failed to install"
  ok "Flatpaks processed"
}

# --------------------------------------------------------------------------
# 5. Node (nvm) + Bun
# --------------------------------------------------------------------------
install_runtimes() {
  step "Installing Node (nvm) and Bun"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -d "$NVM_DIR" ]; then
    # PROFILE=/dev/null keeps the installer from touching our generated rc files
    PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash' ||
      warn "nvm install failed"
  fi
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    set +u
    # shellcheck disable=SC1091
    . "$NVM_DIR/nvm.sh"
    nvm install --lts && nvm alias default 'lts/*' && ok "Node LTS installed" || warn "Node install failed"
    set -u
  fi
  if [ ! -d "$HOME/.bun" ]; then
    curl -fsSL https://bun.sh/install | bash || warn "bun install failed"
  fi
  ok "Runtimes processed"
}

# --------------------------------------------------------------------------
# 6. Ly display manager (TUI) + blackhole dur animation
# --------------------------------------------------------------------------
setup_ly() {
  step "Configuring Ly display manager"

  # Custom durdraw .dur animation (gzip-compressed). Path matches dur_file_path below.
  sudo curl -fsSL "https://codeberg.org/attachments/f336d6ac-8331-4323-91fc-0e4619803401" \
    -o /etc/ly/blackhole-smooth.dur || warn "dur animation download failed"

  sudo tee /etc/ly/config.ini >/dev/null <<'LYCFG'
# Ly supports 24-bit true color with styling, which means each color is a 32-bit value.
# The format is 0xSSRRGGBB, where SS is the styling, RR is red, GG is green, and BB is blue.
# Here are the possible styling options:
# TB_BOLD      0x01000000
# TB_UNDERLINE 0x02000000
# TB_REVERSE   0x04000000
# TB_ITALIC    0x08000000
# TB_BLINK     0x10000000
# TB_HI_BLACK  0x20000000
# TB_BRIGHT    0x40000000
# TB_DIM       0x80000000
# Programmatically, you'd apply them using the bitwise OR operator (|), but because Ly's
# configuration doesn't support using it, you have to manually compute the color value.
# Note that, if you want to use the default color value of the terminal, you can use the
# special value 0x00000000. This means that, if you want to use black, you *must* use
# the styling option TB_HI_BLACK (the RGB values are ignored when using this option).

# Allow empty password or not when authenticating
allow_empty_password = true

# The active animation
# none     -> Nothing
# doom     -> PSX DOOM fire
# matrix   -> CMatrix
# colormix -> Color mixing shader
# gameoflife -> John Conway's Game of Life
# dur_file -> .dur file format (https://github.com/cmang/durdraw/tree/master)
animation = dur_file

# Delay between each animation frame in milliseconds
animation_frame_delay = 5

# Stop the animation after some time
# 0 -> Run forever
# 1..2e12 -> Stop the animation after this many seconds
animation_timeout_sec = 0

# The character used to mask the password
# You can either type it directly as a UTF-8 character (like *), or use a UTF-32
# codepoint (for example 0x2022 for a bullet point)
# If null, the password will be hidden
# Note: you can use a # by escaping it like so: \#
asterisk = *

# The number of failed authentications before a special animation is played... ;)
# If set to 0, the animation will never be played
auth_fails = 10

# Identifier for battery whose charge to display at top left
# Primary battery is usually BAT0 or BAT1
# If set to null, battery status won't be shown
battery_id = BAT1

# Automatic login configuration
# This feature allows Ly to automatically log in a user without password prompt.
# IMPORTANT: Both auto_login_user and auto_login_session must be set for this to work.
# Autologin only happens once at startup - it won't re-trigger after logout.

# PAM service name to use for automatic login
# The default service (ly-autologin) uses pam_permit to allow login without password
# The appropriate platform-specific PAM configuration (ly-autologin) will be used automatically
auto_login_service = ly-autologin

# Session name to launch automatically
# To find available session names, check the .desktop files in:
#   - /usr/share/xsessions/ (for X11 sessions)
#   - /usr/share/wayland-sessions/ (for Wayland sessions)
# Use the filename without .desktop extension, the Name field inside the file or the value of the DesktopNames field
# Examples: "i3", "sway", "gnome", "plasma", "xfce"
# If null, automatic login is disabled
auto_login_session = null

# Username to automatically log in
# Must be a valid user on the system
# If null, automatic login is disabled
auto_login_user = null

# Background color id
bg = 0x00000000

# Change the state and language of the big clock
# none -> Disabled (default)
# en   -> English
# fa   -> Farsi
bigclock = en

# Set bigclock to 12-hour notation.
bigclock_12hr = true

# Set bigclock to show the seconds.
bigclock_seconds = false

# Blank main box background
# Setting to false will make it transparent
blank_box = true

# Border foreground color id
border_fg = 0x00FFFFFF

# Title to show at the top of the main box
# If set to null, none will be shown
box_title = Hello, Nigga

# Brightness decrease command
brightness_down_cmd = /usr/bin/brightnessctl -q -n s 10%-

# Brightness decrease key combination, or null to disable
brightness_down_key = F5

# Brightness increase command
brightness_up_cmd = /usr/bin/brightnessctl -q -n s +10%

# Brightness increase key combination, or null to disable
brightness_up_key = F6

# Erase password input on failure
clear_password = false

# Format string for clock in top right corner (see strftime specification). Example: %c
# If null, the clock won't be shown
clock = null

# CMatrix animation foreground color id
cmatrix_fg = 0x0000FF00

# CMatrix animation character string head color id
cmatrix_head_col = 0x01FFFFFF

# CMatrix animation minimum codepoint. It uses a 16-bit integer
# For Japanese characters for example, you can use 0x3000 here
cmatrix_min_codepoint = 0x21

# CMatrix animation maximum codepoint. It uses a 16-bit integer
# For Japanese characters for example, you can use 0x30FF here
cmatrix_max_codepoint = 0x7B

# Color mixing animation first color id
colormix_col1 = 0x00FF0000

# Color mixing animation second color id
colormix_col2 = 0x000000FF

# Color mixing animation third color id
colormix_col3 = 0x20000000

# For custom binds: the horizontal limit in characters for each
# line of custom binds before moving on to the next.
# If null, defaults to the width of the terminal instead.
custom_bind_width = null

# Custom sessions directory
# You can specify multiple directories,
# e.g. /etc/ly/custom-sessions:/usr/share/custom-sessions
custom_sessions = /etc/ly/custom-sessions

# Input box active by default on startup
# Available inputs: info_line, session, login, password
default_input = login

# DOOM animation fire height (1 thru 9)
doom_fire_height = 6

# DOOM animation fire spread (0 thru 4)
doom_fire_spread = 2

# DOOM animation custom top color (low intensity flames)
doom_top_color = 0x009F2707

# DOOM animation custom middle color (medium intensity flames)
doom_middle_color = 0x00C78F17

# DOOM animation custom bottom color (high intensity flames)
doom_bottom_color = 0x00FFFFFF

# Dur file path
dur_file_path = /etc/ly/blackhole-smooth.dur

# Dur file alignment
# The dur file can be aligned with a direction and centered easily with the flags below
# Available inputs: topleft, topcenter, topright, centerleft, center, centerright, bottomleft, bottomcenter, bottomright
dur_offset_alignment = center

# Dur offset x direction (value is added to the current position determined by alignment, negatives are supported)
dur_x_offset = 0

# Dur offset y direction (value is added to the current position determined by alignment, negatives are supported)
dur_y_offset = 0

# Set margin to the edges of the DM (useful for curved monitors)
edge_margin = 0

# Error background color id
error_bg = 0x00000000

# Error foreground color id
# Default is red and bold
error_fg = 0x01FF0000

# Foreground color id
fg = 0x00FFFFFF

# Render true colors (if supported)
# If false, output will be in eight-color mode
# All eight-color mode color codes:
# TB_DEFAULT              0x0000
# TB_BLACK                0x0001
# TB_RED                  0x0002
# TB_GREEN                0x0003
# TB_YELLOW               0x0004
# TB_BLUE                 0x0005
# TB_MAGENTA              0x0006
# TB_CYAN                 0x0007
# TB_WHITE                0x0008
# If full color is off, the styling options still work. The colors are
# always 32-bit values with the styling in the most significant byte.
# Note: If using the dur_file animation option and the dur file's color range
# is saved as 256 with this option disabled, the file will not be drawn.
full_color = true

# Game of Life entropy interval (0 = disabled, >0 = add entropy every N generations)
# 0 -> Pure Conway's Game of Life (will eventually stabilize)
# 10 -> Add entropy every 10 generations (recommended for continuous activity)
# 50+ -> Less frequent entropy for more natural evolution
gameoflife_entropy_interval = 10

# Game of Life animation foreground color id
gameoflife_fg = 0x0000FF00

# Game of Life frame delay (lower = faster animation, higher = slower)
# 1-3 -> Very fast animation
# 6 -> Default smooth animation speed
# 10+ -> Slower, more contemplative speed
gameoflife_frame_delay = 6

# Game of Life initial cell density (0.0 to 1.0)
# 0.1 -> Sparse, minimal activity
# 0.4 -> Balanced activity (recommended)
# 0.7+ -> Dense, chaotic patterns
gameoflife_initial_density = 0.4

# Command executed when pressing hibernate key (can be null)
hibernate_cmd = null

# Specifies the key combination used for hibernate
hibernate_key = F4

# Remove main box borders
hide_borders = false

# Remove power management command hints
hide_key_hints = false

# Remove keyboard lock states from the top right corner
hide_keyboard_locks = false

# Remove version number from the top left corner
hide_version_string = false

# Command executed when no input is detected for a certain time
# If null, no command will be executed
inactivity_cmd = null

# Executes a command after a certain amount of seconds
inactivity_delay = 0

# Initial text to show on the info line
# If set to null, the info line defaults to the hostname
initial_info_text = null

# Input boxes length
input_len = 20

# Active language
# Available languages are found in /etc/ly/lang/
lang = en

# Command executed when logging in
# If null, no command will be executed
# Important: the code itself must end with `exec "$@"` in order to launch the session!
# You can also set environment variables in there, they'll persist until logout
login_cmd = null

# Path for login.defs file (used for listing all local users on the system on
# Linux)
login_defs_path = /etc/login.defs

# Command executed when logging out
# If null, no command will be executed
# Important: the session will already be terminated when this command is executed, so
# no need to add `exec "$@"` at the end
logout_cmd = null

# General log file path
ly_log = /var/log/ly.log

# Main box horizontal margin
margin_box_h = 2

# Main box vertical margin
margin_box_v = 1

# Set numlock on/off at startup
numlock = false

# Default path
# If null, ly doesn't set a path
path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Command executed when pressing restart_key
restart_cmd = /sbin/shutdown -r now

# Specifies the key combination used for restart
restart_key = F2

# Save the current desktop and login as defaults, and load them on startup
save = true

# Service name (set to ly to use the provided pam config file)
service_name = ly

# Session log file path
# This will contain stdout and stderr of Wayland sessions
# By default it's saved in the user's home directory
# Important: due to technical limitations, X11, shell sessions as well as
# launching session via KMSCON aren't supported, which means you won't get any
# logs from those sessions.
# If null, no session log will be created
session_log = .local/state/ly-session.log

# Setup command
setup_cmd = /etc/ly/setup.sh

# Show the shell session in the session list
# If false, the shell session will be hidden
shell = true

# Specifies the key combination used for showing the password
show_password_key = F7

# Display the active TTY number (e.g. tty3) to the right of the clock in the top right corner
# If the clock is disabled, the TTY label occupies the top right corner on its own
# If false, the TTY number will not be shown
show_tty = false

# Command executed when pressing shutdown_key
shutdown_cmd = /sbin/shutdown -a now

# Specifies the key combination used for shutdown
shutdown_key = F1

# Command executed when pressing sleep key (can be null)
sleep_cmd = null

# Specifies the key combination used for sleep
sleep_key = F3

# Command executed when starting Ly (before the TTY is taken control of)
# See file at path below for an example of changing the default TTY colors
start_cmd = /etc/ly/startup.sh

# Center the session name.
text_in_center = false

# Default vi mode
# normal   -> normal mode
# insert   -> insert mode
vi_default_mode = normal

# Enable vi keybindings
vi_mode = false

# Wayland desktop environments
# You can specify multiple directories,
# e.g. /usr/share/wayland-sessions:/usr/local/share/wayland-sessions
# If null, Wayland sessions will not be shown
waylandsessions = /usr/share/wayland-sessions

# Xorg server command
# Add the -quiet argument to hide startup logs from the server
x_cmd = /usr/bin/X

# Xorg virtual terminal number
# Mostly useful for FreeBSD where choosing the current TTY causes issues
# If null, the current TTY will be chosen
x_vt = null

# Xorg xauthority edition tool
xauth_cmd = /usr/bin/xauth

# xinitrc
# If null, the xinitrc session will be hidden
xinitrc = ~/.xinitrc

# Xorg desktop environments
# You can specify multiple directories,
# e.g. /usr/share/xsessions:/usr/local/share/xsessions
# If null, X11 sessions will not be shown
xsessions = /usr/share/xsessions

# Custom Commands and Labels:
# The following examples below give an outline for setting up custom commands and labels.
# Unless specified as optional, an option is mandatory.

# Comments preceding with '##' are for documentation.
# Comments preceding with '#' comment out the example INI.

## Declare a command with the F8 binding.
#[cmd:F8]
## The name of the command to show up in Ly.
## Note: "$" in "$brightness_up" fetches the appropriate string from the specified locale file
## and is replaced with the value representing "brightness_up".
## You can see the list of keys in any locale file in /etc/ly/lang.
#cmd = touch /tmp/ly.gaming
#name = custom command $brightness_up

## Declare a label with an ID. This ID should be unique across all labels.
#[lbl:kernel]
#cmd = uname -srn
## Optional, defaulting to 0.
## In frames, the time to re-run the command and update the label.
## If 0, only run once and do not refresh afterwards
#refresh = 0
LYCFG

  # Take over from any previous display manager; ly owns tty2.
  sudo systemctl disable --now sddm.service 2>/dev/null || true
  sudo systemctl disable getty@tty2.service 2>/dev/null || true
  sudo systemctl enable ly@tty2.service
  ok "Ly configured + enabled on tty2"
}

# --------------------------------------------------------------------------
# 7. systemd services (backlight on resume + iGPU min clock + ollama)
# --------------------------------------------------------------------------
setup_services() {
  step "Installing systemd services"

  info "Anti-flashbang: save/restore brightness across suspend"
  sudo tee /etc/systemd/system/backlight-resume.service >/dev/null <<'EOF'
[Unit]
Description=Save and Restore Brightness Across Suspend
Before=sleep.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes

# Save the exact brightness state right before sleep
ExecStart=/usr/bin/brightnessctl --save

# When waking up, wait 3 seconds for the GPU/Wayland drivers to initialize, then restore
ExecStop=/bin/bash -c "sleep 3 && /usr/bin/brightnessctl --restore"

[Install]
WantedBy=sleep.target
EOF

  info "Pin Intel iGPU minimum clock to its maximum"
  sudo tee /etc/systemd/system/igpu-clock.service >/dev/null <<'EOF'
[Unit]
Description=Set Intel iGPU minimum clock frequency

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for card in /sys/class/drm/card*/; do if [ -f "$card/gt_max_freq_mhz" ] && [ -w "$card/gt_min_freq_mhz" ]; then read freq < "$card/gt_max_freq_mhz"; echo "$freq" > "$card/gt_min_freq_mhz"; fi; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl enable backlight-resume.service
  sudo systemctl enable docker.service
  sudo systemctl enable igpu-clock.service
  sudo systemctl enable ollama.service || warn "Could not enable ollama.service"
  ok "Services installed and enabled"
}

# --------------------------------------------------------------------------
# 8. Kitty terminal
# --------------------------------------------------------------------------
configure_kitty() {
  step "Configuring Kitty (Dracula theme)"
  local kitty_dir="$HOME/.config/kitty"
  local themes_dir="$kitty_dir/kitty-themes"
  mkdir -p "$kitty_dir"

  if [ ! -d "$themes_dir" ]; then
    git clone --depth 1 https://github.com/dexpota/kitty-themes.git "$themes_dir"
  else
    (cd "$themes_dir" && git pull --quiet) || warn "kitty-themes update failed"
  fi
  ln -sf "$themes_dir/themes/Dracula.conf" "$kitty_dir/theme.conf"

  cat <<'EOF' >"$kitty_dir/kitty.conf"
# ==========================================
# FONTS & APPEARANCE
# ==========================================
font_family CaskaydiaCove Nerd Font Mono
bold_font auto
italic_font auto
bold_italic_font auto
font_size 10.0
window_padding_width 2
hide_window_decorations yes

# Cursor trails require frame buffering. Disabled for raw speed.
cursor_trail 0

# Cursor Configuration
cursor_shape block
cursor_blink_interval 1

# Scrollback
scrollback_lines 3000

# Terminal features
copy_on_select yes
strip_trailing_spaces smart

# Disable audio bell to prevent UI lockups
enable_audio_bell no

# Key bindings for common actions
map ctrl+shift+n new_window
map ctrl+t new_tab
map ctrl+plus change_font_size all +1.0
map ctrl+minus change_font_size all -1.0
map ctrl+0 change_font_size all 0

# Shell integration
shell_integration enabled

# ==========================================
# TAB BAR STYLING
# ==========================================
tab_bar_edge                bottom
tab_bar_align               left
tab_bar_style               powerline
tab_powerline_style         slanted
tab_title_template          {title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}
map ctrl+shift+t            new_tab_with_cwd

# ==========================================
# RAW PERFORMANCE TWEAKS (Beast Mode)
# ==========================================
# Forces immediate frame rendering and cuts out Wayland input overhead
input_delay 0
repaint_delay 0
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
  ok "Kitty configured"
}

# --------------------------------------------------------------------------
# 8a. Fuzzel (Wayland app launcher, Dracula theme)
# --------------------------------------------------------------------------
configure_fuzzel() {
  step "Configuring Fuzzel (Dracula theme)"
  mkdir -p "$HOME/.config/fuzzel"
  cat <<'EOF' >"$HOME/.config/fuzzel/fuzzel.ini"
[main]
font=SegoeUI Variable:size=13
layer=overlay
terminal=kitty
lines=10
width=43
horizontal-pad=10
vertical-pad=10
inner-pad=10
show-actions=no
image-size-ratio=0.5

[border]
width=2
radius=10

[colors]
background=282a36fa
text=f8f8f2ff
match=8be9fdff
selection-match=8be9fdff
selection=44475add
selection-text=f8f8f2ff
border=bd93f9ff
EOF
  ok "Fuzzel configured"
}

# --------------------------------------------------------------------------
# 8b. Niri (modular config: rainbow borders, springy animations, rules, binds)
# --------------------------------------------------------------------------
# niri reads a single config.kdl but supports `include`, so customisations live in
# ~/.config/niri/custom/*.kdl, kept separate from the DMS-managed ~/.config/niri/dms/.
# On a fresh install niri hasn't written config.kdl yet, so it is bootstrapped from
# niri's shipped default. niri won't overwrite an existing config on first launch, and
# DMS appends its own dms/* includes when the session starts. The custom includes go
# LAST so they win niri's last-wins merge (border on, focus-ring off, rainbow, etc.).
configure_niri() {
  step "Configuring niri (rainbow borders, springy animations, rules, binds)"
  local niri_dir="$HOME/.config/niri"
  mkdir -p "$niri_dir/custom"

  cat <<'APPEARANCE_KDL' >"$niri_dir/custom/appearance.kdl"
// =============================================================================
// Appearance — rainbow window borders
// Managed by setup-cachyos.sh. Included AFTER dms/* so it wins over DMS theming.
// =============================================================================
//
// niri gradients are 2-stop (from -> to). Setting in="oklch longer hue" makes the
// hue sweep the LONG way around the colour wheel, so a purple -> blue gradient
// passes through magenta, red, orange, yellow, green and cyan: a full rainbow that
// hits the requested colours (purple #c77dff, yellow #ffe66d, green #7dffb3,
// blue #6ec1ff). angle 35 tilts the sweep. Drop relative-to for a full rainbow on
// every window; add relative-to="workspace-view" for one rainbow across the screen.
layout {
    // Only the border should show the rainbow, so keep the focus-ring off.
    focus-ring {
        off
    }

    border {
        on
        width 3

        active-gradient from="#c77dffee" to="#6ec1ffee" angle=35 in="oklch longer hue"

        inactive-color "#45475a"
        urgent-color "#f38ba8"
    }
}
APPEARANCE_KDL

  cat <<'ANIMATIONS_KDL' >"$niri_dir/custom/animations.kdl"
// =============================================================================
// Animations — SPRINGY. Managed by setup-cachyos.sh.
//
// niri's defaults are critically damped (damping-ratio=1.0) → smooth but NO bounce.
// The springiness comes from UNDERDAMPING: damping-ratio < 1.0 overshoots and
// settles back, giving that bouncy feel. ~0.6 = clearly bouncy but still smooth.
// Lower damping = more bounce; lower stiffness = slower/looser; higher = snappier.
// =============================================================================
animations {
    slowdown 1.0

    // Column scrolling left/right — the signature niri motion. Make it bounce.
    horizontal-view-movement {
        spring damping-ratio=0.6 stiffness=500 epsilon=0.0001
    }

    // Switching workspaces up/down.
    workspace-switch {
        spring damping-ratio=0.6 stiffness=550 epsilon=0.0001
    }

    // Moving windows/columns around.
    window-movement {
        spring damping-ratio=0.62 stiffness=550 epsilon=0.0001
    }

    // Resizing — a touch more damped so it doesn't wobble too hard.
    window-resize {
        spring damping-ratio=0.72 stiffness=650 epsilon=0.0001
    }

    // Windows pop in with a springy overshoot.
    window-open {
        spring damping-ratio=0.6 stiffness=500 epsilon=0.0001
    }

    // Close stays quick and clean (no bounce on disappearing windows).
    window-close {
        duration-ms 150
        curve "ease-out-quad"
    }

    // Overview open/close bounce.
    overview-open-close {
        spring damping-ratio=0.68 stiffness=600 epsilon=0.0001
    }

    // The "config reloaded" toast — extra bouncy, it's fun to see.
    config-notification-open-close {
        spring damping-ratio=0.5 stiffness=700 epsilon=0.0005
    }

    screenshot-ui-open {
        duration-ms 200
        curve "ease-out-quad"
    }
}
ANIMATIONS_KDL

  cat <<'WINDOWRULES_KDL' >"$niri_dir/custom/window-rules.kdl"
// =============================================================================
// Window rules — translated from Hyprland windowrules. Managed by setup-cachyos.sh.
//
// Notes on the translation:
//  * Hyprland "class" -> niri "app-id"; "title" -> niri "title" (Rust regex).
//  * float yes        -> open-floating true
//  * size W H         -> default-column-width{ fixed W } + default-window-height{ fixed H }
//  * center true      -> niri opens floating windows centred by default, so it is
//                        implicit (there is no per-rule "center").
//  * Hyprland "tags"  -> niri has no tags, so tagged groups are flattened into
//                        direct matches with their final action.
//  * idle_inhibit rules are intentionally omitted: niri honours the Wayland
//    idle-inhibit protocol, which media players/browsers use themselves.
// =============================================================================

// --- Sized floating dialogs ---------------------------------------------------

// SyncThingy -> float, 800x600
window-rule {
    match app-id=r#"(?i)syncthingy"#
    open-floating true
    default-column-width { fixed 800; }
    default-window-height { fixed 600; }
}

// Totem -> float, 1000x600
window-rule {
    match app-id=r#"^org\.gnome\.Totem$"#
    open-floating true
    default-column-width { fixed 1000; }
    default-window-height { fixed 600; }
}

// --- Plain floating dialogs ---------------------------------------------------

// Steam "Special Offers" / "Friends List"
window-rule {
    match app-id=r#"^steam$"# title=r#"^(Special Offers|Friends List)$"#
    open-floating true
}

// Gwenview
window-rule {
    match app-id=r#"^org\.kde\.gwenview$"#
    open-floating true
}

// Lutris install/configure dialogs
window-rule {
    match app-id=r#"^net\.lutris\.Lutris$"# title=r#"^Install"#
    match app-id=r#"^net\.lutris\.Lutris$"# title=r#"^Configure"#
    open-floating true
}

// --- "beast" floating apps (control panels, tray apps, polkit agents, etc.) ---
window-rule {
    match app-id=r#"^(blueman-manager|pavucontrol-qt|com\.gabm\.satty|vlc|kvantummanager|qt[56]ct|nwg-(look|displays)|org\.kde\.ark|org\.pulseaudio\.pavucontrol|nm-(applet|connection-editor)|org\.kde\.polkit-kde-authentication-agent-1|console-dropdown)$"#
    open-floating true
}

// Dolphin progress / copy popups
window-rule {
    match app-id=r#"^org\.kde\.dolphin$"# title=r#"^(Progress Dialog|Copying) — Dolphin$"#
    open-floating true
}

// --- Common popups (by title) and portal/file dialogs -------------------------
// Broad on purpose (mirrors the Hyprland config): anything that looks like a
// dialog/settings/save/open window floats.
window-rule {
    match title=r#"^(New.*|.*[Ss]ettings.*|[Ww]elcome.*|.*Preferences.*|Choose Files|Save As|Confirm to replace files|File Operation Progress|Open|Authentication Required|Add Folder to Workspace|File Upload.*|Choose wallpaper.*|Library.*|.*dialog.*)$"#
    match title=r#"^(Open File|Volume Control|Save As.*)$"#
    match app-id=r#"^(.*dialog.*|[Xx]dg-desktop-portal-gtk)$"#
    match app-id=r#"^(org\.freedesktop\.impl\.portal\.desktop\.(hyprland|gtk)|[Xx]dg-desktop-portal-gtk)$"#
    open-floating true
}

// --- Picture-in-Picture: float, small, parked bottom-right --------------------
window-rule {
    match title=r#"(?i)^picture[-\s]?in[-\s]?picture"#
    open-floating true
    default-column-width { proportion 0.25; }
    default-window-height { proportion 0.25; }
    default-floating-position x=32 y=32 relative-to="bottom-right"
}

// --- Apps that should always float --------------------------------------------
window-rule {
    match app-id=r#"^Signal$"#
    match app-id=r#"^com\.github\.rafostar\.Clapper$"#
    match app-id=r#"^app\.drey\.Warp$"#
    match app-id=r#"^net\.davidotek\.pupgui2$"#
    match app-id=r#"^yad$"#
    match app-id=r#"^eog$"#
    match app-id=r#"^io\.github\.alainm23\.planify$"#
    match app-id=r#"^io\.gitlab\.theevilskeleton\.Upscaler$"#
    match app-id=r#"^com\.github\.unrud\.VideoDownloader$"#
    match app-id=r#"^io\.gitlab\.adhami3310\.Impression$"#
    match app-id=r#"^io\.missioncenter\.MissionCenter$"#
    open-floating true
}
WINDOWRULES_KDL

  cat <<'BINDS_KDL' >"$niri_dir/custom/binds.kdl"
// =============================================================================
// Custom keybinds — multi-monitor / projector. Managed by setup-cachyos.sh.
// niri merges this binds{} block with the others; later definitions win, so the
// projector binds below override the defaults on the same keys.
// =============================================================================
binds {
    Mod+T hotkey-overlay-title="Open a Terminal: Kitty" { spawn "kitty"; }
    Super+B hotkey-overlay-title="Open a browser: Zen" { spawn "flatpak" "run" "app.zen_browser.zen"; }
    Super+E hotkey-overlay-title="Open file browser: Nautilus" { spawn "nautilus"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"; }
    XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+ -l 1.0"; }
    XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+2%"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "2%-"; }

    // Teleport the current workspace to the external projector, and back.
    Mod+Shift+P hotkey-overlay-title="Send workspace to projector (HDMI-A-1)" { move-workspace-to-monitor "HDMI-A-1"; }
    Mod+Shift+O hotkey-overlay-title="Send workspace to laptop (eDP-1)" { move-workspace-to-monitor "eDP-1"; }

    // Turn the laptop panel OFF (projector-only), and back ON.
    Mod+F7       hotkey-overlay-title="Laptop screen OFF (projector only)" { spawn "niri" "msg" "output" "eDP-1" "off"; }
    Mod+Shift+F7 hotkey-overlay-title="Laptop screen ON" { spawn "niri" "msg" "output" "eDP-1" "on"; }

    // Mod+Shift+P used to power off all monitors; moved here since it now sends the
    // workspace to the projector.
    Mod+Ctrl+Shift+P { power-off-monitors; }
}
BINDS_KDL

  # Bootstrap config.kdl from niri's default if it does not exist yet (fresh install).
  if [ ! -f "$niri_dir/config.kdl" ]; then
    if [ -f /usr/share/doc/niri/default-config.kdl ]; then
      cp /usr/share/doc/niri/default-config.kdl "$niri_dir/config.kdl"
      info "Bootstrapped config.kdl from niri default"
    else
      : >"$niri_dir/config.kdl"
    fi
  fi

  # Include the custom modules (last, so they win) -- idempotent.
  if ! grep -q 'custom/appearance.kdl' "$niri_dir/config.kdl"; then
    cat <<'NIRI_INCLUDES' >>"$niri_dir/config.kdl"

// --- Custom modules (managed by setup-cachyos.sh) -- included last so they win ---
include "custom/appearance.kdl"
include "custom/animations.kdl"
include "custom/window-rules.kdl"
include "custom/binds.kdl"
NIRI_INCLUDES
  fi

  if niri validate -c "$niri_dir/config.kdl" >/dev/null 2>&1; then
    ok "niri configured (config valid)"
  else
    warn "niri config written but validation reported issues -- check $niri_dir/config.kdl"
  fi
}

# --------------------------------------------------------------------------
# 9. nano + vim
# --------------------------------------------------------------------------
configure_editors() {
  step "Configuring nano and vim"
  sudo tee /etc/nanorc >/dev/null <<'EOF'
include "/usr/share/nano/*.nanorc"
include "/usr/share/nano/extra/*.nanorc"
include "/usr/share/nano-syntax-highlighting/*.nanorc"
EOF

  sudo tee /etc/vimrc >/dev/null <<'EOF'
" Syntax highlighting
filetype plugin on
syntax on
filetype indent on
" Line numbers
set number
" Highlight the first match while typing the search
set incsearch
" Highlight all matches while typing and after the search
set hlsearch
EOF
  ok "nano and vim configured"
}

# --------------------------------------------------------------------------
# 10. Starship
# --------------------------------------------------------------------------
configure_starship() {
  step "Configuring Starship prompt"
  mkdir -p "$HOME/.config"
  cat <<'EOF' >"$HOME/.config/starship.toml"
"$schema" = 'https://starship.rs/config-schema.json'

add_newline = true

[aws]
symbol = " "

[azure]
symbol = " "

[battery]
full_symbol = "󰁹 "
charging_symbol = "󰂄 "
discharging_symbol = "󰂃 "
unknown_symbol = "󰂑 "
empty_symbol = "󰂎 "

[buf]
symbol = " "

[bun]
symbol = " "

[c]
symbol = " "

[cpp]
symbol = " "

[cmake]
symbol = " "

[cobol]
symbol = " "

[conda]
symbol = " "

[container]
symbol = " "

[crystal]
symbol = " "

[dart]
symbol = " "

[deno]
symbol = " "

[direnv]
symbol = " "

[directory]
read_only = " 󰌾"

[docker_context]
symbol = " "

[dotnet]
symbol = " "

[elixir]
symbol = " "

[elm]
symbol = " "

[erlang]
symbol = " "

[fennel]
symbol = " "

[fortran]
symbol = " "

[fossil_branch]
symbol = " "

[gcloud]
symbol = "󱇶 "

[gleam]
symbol = " "

[git_branch]
symbol = " "

[git_commit]
tag_symbol = '  '

[golang]
symbol = " "

[gradle]
symbol = " "

[guix_shell]
symbol = " "

[haskell]
symbol = " "

[haxe]
symbol = " "

[helm]
symbol = " "

[hg_branch]
symbol = " "

[hostname]
ssh_symbol = " "

[java]
symbol = " "

[julia]
symbol = " "

[kotlin]
symbol = " "

[kubernetes]
symbol = "󱃾 "

[lua]
symbol = " "

[maven]
symbol = " "

[memory_usage]
symbol = "󰍛 "

[meson]
symbol = "󰔷 "

[mojo]
symbol = "󰈸 "

[nats]
symbol = " "

[netns]
symbol = "󰛳 "

[nim]
symbol = " "

[nix_shell]
symbol = " "

[nodejs]
symbol = " "

[ocaml]
symbol = " "

[odin]
symbol = "󰟢 "

[opa]
symbol = " "

[openstack]
symbol = " "

[os.symbols]
AIX = " "
AlmaLinux = " "
Alpaquita = " "
Alpine = " "
ALTLinux = " "
Amazon = " "
Android = " "
AOSC = " "
Arch = " "
Artix = " "
Bluefin = " "
CachyOS = " "
CentOS = " "
Debian = " "
DragonFly = " "
Elementary = " "
Emscripten = " "
EndeavourOS = " "
Fedora = " "
FreeBSD = " "
Garuda = " "
Gentoo = " "
HardenedBSD = "󰞌 "
Illumos = " "
InstantOS = " "
Ios = "󰀷 "
Kali = " "
Linux = " "
Mabox = " "
Macos = " "
Manjaro = " "
Mariner = " "
MidnightBSD = " "
Mint = " "
NetBSD = " "
NixOS = " "
Nobara = " "
OpenBSD = " "
OpenCloudOS = " "
openEuler = " "
openSUSE = " "
OracleLinux = "󰺡 "
PikaOS = " "
Pop = " "
Raspbian = " "
Redhat = "󱄛 "
RedHatEnterprise = "󱄛 "
Redox = "󰀘 "
RockyLinux = " "
Solus = " "
SUSE = " "
Ubuntu = " "
Ultramarine = " "
Unknown = " "
Uos = " "
Void = " "
Windows = "󰍲 "
Zorin = " "

[package]
symbol = "󰏗 "

[perl]
symbol = " "

[php]
symbol = " "

[pijul_channel]
symbol = " "

[pixi]
symbol = "󰏗 "

[pulumi]
symbol = " "

[purescript]
symbol = " "

[python]
symbol = " "

[raku]
symbol = "󱖊 "

[red]
symbol = "󱍼 "

[rlang]
symbol = "󰟔 "

[ruby]
symbol = " "

[rust]
symbol = "󱘗 "

[scala]
symbol = " "

[shlvl]
symbol = "󰹍 "

[singularity]
symbol = " "

[solidity]
symbol = " "

[spack]
symbol = " "

[status]
symbol = " "

[sudo]
symbol = " "

[swift]
symbol = " "

[terraform]
symbol = " "

[vlang]
symbol = " "

[typst]
symbol = " "

[vagrant]
symbol = " "

[xmake]
symbol = " "

[zig]
symbol = " "

[character]
success_symbol = "[➜](bold green)"
EOF
  ok "Starship configured"
}

# --------------------------------------------------------------------------
# 11. Yazi
# --------------------------------------------------------------------------
configure_yazi() {
  step "Configuring Yazi (Dracula flavor)"
  mkdir -p "$HOME/.config/yazi"
  ya pkg add yazi-rs/flavors:dracula || warn "yazi flavor install failed"

  cat <<'EOF' >"$HOME/.config/yazi/theme.toml"
[flavor]
dark = "dracula"
EOF

  cat <<'EOF' >"$HOME/.config/yazi/yazi.toml"
[mgr]
show_hidden = true

[filetype]
rules = [
    # Hidden files
    { name = "*", is = "hidden", bg = "cyan" },

    # Special files
    { name = "*", is = "orphan", bg = "red" },
    { name = "*", is = "exec", fg = "green" },

    # Dummy files
    { name = "*", is = "dummy", bg = "red" },
    { name = "*/", is = "dummy", bg = "red" },

    # Fallback
    { name = "*/", fg = "blue" },
]

[opener]
edit = [
  { run = 'nvim "$@"', desc = "nvim", block = true, for = "unix" }
]

[open]
rules = [
  { mime = "text/*", use = "edit" }
]
EOF
  ok "Yazi configured"
}

# --------------------------------------------------------------------------
# 12. Neovim (LazyVim)
# --------------------------------------------------------------------------
configure_neovim() {
  step "Bootstrapping LazyVim"
  if [ -d "$HOME/.config/nvim" ]; then
    rm -rf "$HOME/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    info "Backed up existing config to ~/.config/nvim.bak"
  fi
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
  ok "LazyVim installed"
}

# --------------------------------------------------------------------------
# 13. Zsh (zshenv, zshrc, npmrc)
# --------------------------------------------------------------------------
configure_zsh() {
  step "Configuring Zsh, NVM PATH and npm"

  cat <<'EOF' >"$HOME/.zshenv"
# ==========================================
# NVM AI AGENT & NON-INTERACTIVE PATH FIX
# ==========================================
export NVM_DIR="$HOME/.nvm"

# Inject the default Node version into PATH so node/npm/yarn/pnpm/bun
# are visible to non-interactive shells and AI agents.
if [ -f "$NVM_DIR/alias/default" ]; then
    DEFAULT_NODE_VER=$(cat "$NVM_DIR/alias/default")
    export PATH="$NVM_DIR/versions/node/$DEFAULT_NODE_VER/bin:$PATH"
fi

# ==========================================
# SSH AGENT (gnome-keyring / gcr-ssh-agent)
# ==========================================
# Route ssh/git through the keyring-backed agent so key passphrases are cached and
# auto-unlocked at login. The socket is created by the gcr-ssh-agent.socket user unit.
# Guarded so an already-exported SSH_AUTH_SOCK (e.g. forwarded agent) wins.
if [ -n "$XDG_RUNTIME_DIR" ]; then
    export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/gcr/ssh}"
fi
EOF

  # npm global prefix + matching PATH entry (added in .zshrc below)
  echo "prefix=$HOME/.npm-global" >"$HOME/.npmrc"

  cat <<'EOF' >"$HOME/.zshrc"
# ==========================================
# Oh My Zsh Configuration
# ==========================================
export ZSH="/usr/share/oh-my-zsh"
plugins=(git python fzf extract npm gh)

# Uncomment if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"
# Command auto-correction.
ENABLE_CORRECTION="true"
# Red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

source $ZSH/oh-my-zsh.sh

# Fish-like syntax highlighting, autosuggestions, history substring search
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# ==========================================
# ENVIRONMENT VARIABLES & PATHS
# ==========================================
export EDITOR=nvim
export BAT_THEME="Dracula"
export OLLAMA_HOST="http://localhost:11434"
export OPENROUTER_API_KEY=""
# .npm-global/bin makes globally installed npm CLIs available
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.bun/bin:$HOME/.cache/.bun/bin:$PATH"

# Start pokego
pokego -r 1-8

# ==========================================
# NVM
# ==========================================
export NVM_DIR="$HOME/.nvm"
# Put the newest installed node on PATH so global binaries resolve
if [ -d "$NVM_DIR/versions/node" ]; then
  export PATH="$(ls -d $NVM_DIR/versions/node/*/bin | sort -V | tail -n1):$PATH"
fi

# Lazy-load the heavy NVM engine only when 'nvm' is actually invoked.
nvm() {
    unset -f nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    nvm "$@"
}

# ==========================================
# HISTORY & MAN PAGE COLORS
# ==========================================
export HISTCONTROL=ignoreboth
export HISTORY_IGNORE="(\&|[bf]g|c|clear|history|exit|q|pwd|* --help)"
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# ==========================================
# ALIASES
# ==========================================
# Parallel build helpers
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n="ninja"

# General
alias c='clear'
alias reload="source ~/.zshrc"
alias grep="grep --color=auto"
alias jctl="journalctl -p 3 -xb"
alias tb="nc termbin.com 9999"

# Package management (Arch / CachyOS)
alias update="sudo pacman -Syu"          # update official packages
alias in="sudo pacman -S"                # install repo package(s)
alias inaur="yay -S"                      # install AUR package(s) (yay calls sudo itself)
alias rmpkg="sudo pacman -Rns"           # remove package + deps
alias search="pacman -Ss"                # search repos
alias cleanch="sudo pacman -Scc"         # clear package cache
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Remove orphaned packages safely (no error when there are none)
cleanup() {
    local orphans
    orphans=$(pacman -Qtdq) || { echo "No orphaned packages to remove."; return 0; }
    sudo pacman -Rns $orphans
}

# Help people new to Arch
alias apt="man pacman"
alias apt-get="man pacman"
alias please="sudo"

# GPU offload (PRIME render offload onto the dGPU)
alias beast="prime-run"

# bat (better cat)
alias cat='bat --style=plain --paging=never'
alias catn='bat'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain --pager=builtin'

# Claude Code with Ollama cloud models
alias cc-kimi="ollama launch claude --model kimi-k2.5:cloud"
alias cc-nemo="ollama launch claude --model nemotron-3-super:cloud"
alias cc-qwen="ollama launch claude --model qwen3-coder:480b-cloud"
alias cc-gpt="ollama launch claude --model gpt-oss:120b-cloud"
alias cc-deepseek="ollama launch claude --model deepseek-v3:cloud"
alias cc-glm="ollama launch claude --model glm-5:cloud"

# Eza (modern ls)
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# ==========================================
# DYNAMIC KITTY PADDING WRAPPER
# ==========================================
# Removes Kitty padding for full-screen TUIs and restores it after exit.
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

# fzf history search
source /usr/share/fzf/key-bindings.zsh

# Prompt & smart cd
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
EOF
  ok "Zsh configured"
}

# --------------------------------------------------------------------------
# 14. udiskie automount (user service)
# --------------------------------------------------------------------------
setup_udiskie() {
  step "Setting up udiskie automount"
  mkdir -p "$HOME/.config/systemd/user"
  cat <<'EOF' >"$HOME/.config/systemd/user/udiskie.service"
[Unit]
Description=udiskie removable media automounter
PartOf=graphical-session.target
After=graphical-session.target

[Service]
# -a automount, -T no tray icon (notifications kept on for a daemon if present)
ExecStart=/usr/bin/udiskie -a
Restart=on-failure

[Install]
WantedBy=default.target
EOF
  systemctl --user enable udiskie.service || warn "Could not enable udiskie (start your graphical session first)"
  ok "udiskie automount configured"
}

# --------------------------------------------------------------------------
# 15. Secure Boot (sbctl) — own keys, optional Microsoft keys, sign binaries
# --------------------------------------------------------------------------
secure_boot() {
  step "Setting up Secure Boot (sbctl)"

  # Enrolling keys touches firmware NVRAM and requires the UEFI to be in
  # Setup Mode — it is hard to reverse, so confirm before proceeding.
  read -rp "  Set up Secure Boot keys now? Requires UEFI Setup Mode. [y/N] " ans || ans=""
  if [[ ! "$ans" =~ ^[Yy]$ ]]; then
    info "Skipping Secure Boot setup. Run later once firmware is in Setup Mode."
    return 0
  fi

  sudo sbctl status || true

  if ! sudo sbctl status 2>/dev/null | grep -qi "setup mode.*enabled"; then
    warn "Firmware is not in Setup Mode — cannot enroll keys. Clear Secure Boot keys in UEFI and re-run."
    return 0
  fi

  sudo sbctl create-keys || {
    warn "sbctl create-keys failed"
    return 0
  }
  # -m also enrolls Microsoft's keys (needed for most firmware / option ROMs)
  sudo sbctl enroll-keys -m || {
    warn "sbctl enroll-keys failed"
    return 0
  }

  # Sign every binary sbctl reports as unsigned (bootloader, kernels, etc.)
  sudo sbctl verify 2>/dev/null |
    grep 'is not signed' |
    sed -E 's|^.* (/.+) is not signed$|\1|' |
    while read -r efi; do
      sudo sbctl sign -s "$efi" || warn "Failed to sign $efi"
    done

  # Signing just changed the kernel bytes on the ESP, so the BLAKE2b hashes in
  # limine.conf are now stale. Re-sync them immediately so THIS install stays
  # bootable; future kernel updates are handled automatically by the pacman hook.
  if [ -x /usr/local/bin/limine-sbctl-rehash ]; then
    info "Re-syncing limine.conf BLAKE2b hashes for the freshly signed kernels"
    sudo /usr/local/bin/limine-sbctl-rehash ||
      warn "limine hash re-sync failed — run 'sudo limine-sbctl-rehash' before rebooting"
  fi

  ok "Secure Boot keys enrolled and binaries signed (enable Secure Boot in UEFI after reboot)"
}

# --------------------------------------------------------------------------
# 16. gnome-keyring (secrets store + SSH agent)
# --------------------------------------------------------------------------
# The gnome-keyring package only ships the daemon — it does nothing until PAM unlocks
# it at login and the SSH-agent socket is enabled. This:
#   * inserts pam_gnome_keyring into the SDDM PAM stack so the login password unlocks
#     the keyring, making secrets available to libsecret apps (gh, Thunderbird, …);
#   * enables gcr-ssh-agent so the keyring also acts as the SSH agent, caching key
#     passphrases. SSH_AUTH_SOCK is set in environment.d (GUI apps) and .zshenv (shells).
setup_gnome_keyring() {
  step "Configuring gnome-keyring (PAM auto-unlock + SSH agent)"

  # 1. PAM — unlock the keyring with the SDDM login password. Insert each module
  #    right after the matching 'include system-login' line (recommended placement).
  #    Idempotent: skip entirely if pam_gnome_keyring is already wired in.
  if grep -q 'pam_gnome_keyring' /etc/pam.d/ly; then
    info "pam_gnome_keyring already present in /etc/pam.d/ly, skipping"
  else
    sudo sed -i \
      -e '/^auth[[:space:]]\+include[[:space:]]\+system-login/a -auth       optional    pam_gnome_keyring.so' \
      -e '/^password[[:space:]]\+include[[:space:]]\+system-login/a -password   optional    pam_gnome_keyring.so    use_authtok' \
      -e '/^session[[:space:]]\+include[[:space:]]\+system-login/a -session    optional    pam_gnome_keyring.so    auto_start' \
      /etc/pam.d/ly
    grep -q 'pam_gnome_keyring' /etc/pam.d/ly &&
      ok "pam_gnome_keyring wired into /etc/pam.d/ly" ||
      warn "Could not insert pam_gnome_keyring lines — edit /etc/pam.d/ly manually"
  fi

  # 1a. Keep the keyring password in sync with your user password. use_authtok reuses
  #     the new password pam_unix just set during `passwd`, re-encrypting the login
  #     keyring so it stays auto-unlockable afterwards. Idempotent.
  if grep -q 'pam_gnome_keyring' /etc/pam.d/passwd; then
    info "pam_gnome_keyring already present in /etc/pam.d/passwd, skipping"
  else
    sudo sed -i '/^password[[:space:]]\+include[[:space:]]\+system-auth/a password    optional    pam_gnome_keyring.so    use_authtok' /etc/pam.d/passwd
    grep -q 'pam_gnome_keyring' /etc/pam.d/passwd &&
      ok "pam_gnome_keyring wired into /etc/pam.d/passwd (keyring follows passwd changes)" ||
      warn "Could not insert pam_gnome_keyring into /etc/pam.d/passwd"
  fi

  # 1b. Let PAM's keyring daemon own the Secret Service. gnome-keyring-daemon.socket
  #     is enabled by a global preset and socket-activates a *passwordless* daemon at
  #     sockets.target — it grabs org.freedesktop.secrets before pam_gnome_keyring's
  #     auto_start daemon can, so the login keyring never gets unlocked on the bus and
  #     apps like VS Code fail with "OS keyring not available" (writes hang on a prompt
  #     that can't display under a minimal Wayland WM). Mask it in user scope so the
  #     PAM-started, password-holding daemon is authoritative. Reversible with:
  #     systemctl --user unmask gnome-keyring-daemon.socket
  systemctl --user mask gnome-keyring-daemon.socket ||
    warn "Could not mask gnome-keyring-daemon.socket"

  # 2. SSH agent — gcr-ssh-agent (from gcr-4) replaces gnome-keyring's removed ssh
  #    component. Enabling the socket socket-activates the service and creates the
  #    agent socket at $XDG_RUNTIME_DIR/gcr/ssh on login.
  systemctl --user enable gcr-ssh-agent.socket ||
    warn "Could not enable gcr-ssh-agent.socket (start your graphical session first)"

  # Point GUI apps (systemd user session) at the agent. Shells are handled in .zshenv.
  mkdir -p "$HOME/.config/environment.d"
  cat <<'EOF' >"$HOME/.config/environment.d/gcr-ssh-agent.conf"
# Route SSH through gnome-keyring's gcr-ssh-agent (socket from gcr-ssh-agent.socket)
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/gcr/ssh
EOF
  ok "gnome-keyring SSH agent enabled (SSH_AUTH_SOCK → \$XDG_RUNTIME_DIR/gcr/ssh)"
}

# --------------------------------------------------------------------------
# 17. Limine ⇄ sbctl: keep BLAKE2b boot hashes in sync after signing
# --------------------------------------------------------------------------
# Limine verifies every kernel/initramfs on the ESP against a BLAKE2b hash stored in
# limine.conf (ENABLE_VERIFICATION=yes). limine-mkinitcpio-hook records those hashes
# from the UNSIGNED files, then sbctl's PostTransaction hook (zz-sbctl.hook) signs the
# kernel EFI stubs afterwards — changing their bytes and leaving every recorded kernel
# hash stale, so Limine aborts the next boot with a checksum mismatch.
#
# This installs a helper that recomputes b2sum for each hashed path/module_path entry
# and rewrites it to match the file's current (signed) content, plus a pacman hook
# whose filename sorts AFTER zz-sbctl.hook so it runs last on every transaction.
setup_limine_sbctl_rehash() {
  step "Installing Limine BLAKE2b re-hash hook (runs after sbctl signing)"

  sudo tee /usr/local/bin/limine-sbctl-rehash >/dev/null <<'SCRIPT'
#!/usr/bin/env bash
# limine-sbctl-rehash — re-sync limine.conf BLAKE2b hashes after sbctl signing.
#
# limine-mkinitcpio-hook copies each kernel + initramfs onto the ESP and records a
# BLAKE2b (b2sum) checksum of every file in limine.conf so Limine can verify boot
# integrity. The sbctl pacman hook (zz-sbctl.hook) then signs the kernel EFI stubs
# *after* those checksums were taken, which changes the files and makes Limine abort
# the boot with a hash mismatch.
#
# This recomputes b2sum for each "path:" / "module_path:" entry that carries a
# "#<hash>" and rewrites it to match the file's current (signed) bytes. It is meant to
# run from a PostTransaction pacman hook ordered AFTER zz-sbctl.hook, and is safe to
# run by hand at any time (it only rewrites hashes that no longer match).
set -euo pipefail
export LC_ALL=C

log() { printf 'limine-sbctl-rehash: %s\n' "$1" >&2; }

# --- Locate the ESP and limine.conf -----------------------------------------------
# Reuse Limine's own detection when present so we agree with the rest of the toolchain.
ESP_PATH="" ; LIMINE_CONFIG_PATH="" ; ENABLE_ENROLL_LIMINE_CONFIG=""
funcs=/usr/lib/limine/limine-common-functions
if [[ -r "$funcs" ]]; then
	set +e
	# shellcheck disable=SC1090
	source "$funcs"
	load_config &>/dev/null
	set -e
fi
if [[ -z "${ESP_PATH:-}" ]]; then
	command -v bootctl &>/dev/null && ESP_PATH="$(bootctl --print-esp-path 2>/dev/null | head -n1)"
	: "${ESP_PATH:=/boot}"
fi
conf="${LIMINE_CONFIG_PATH:-$ESP_PATH/limine.conf}"

[[ -f "$conf" ]]             || { log "$conf not found — nothing to do"; exit 0; }
command -v b2sum &>/dev/null || { log "b2sum not available — skipping"; exit 0; }

# --- Rewrite stale hashes ----------------------------------------------------------
# Matches e.g.:  "  path: boot():/<machine-id>/<kernel>/vmlinuz-linux#<128 hex>"
# Leaves image_path:, wallpaper:, guid()/efi entries and hash-less paths untouched.
re='^([[:space:]]*(module_)?path:[[:space:]]*)(boot\(\):/[^#]+)#([0-9a-fA-F]+)[[:space:]]*$'
tmp="$(mktemp)" ; trap 'rm -f "$tmp"' EXIT
changed=0

while IFS= read -r line || [[ -n "$line" ]]; do
	if [[ "$line" =~ $re ]]; then
		prefix="${BASH_REMATCH[1]}"
		uri="${BASH_REMATCH[3]}"          # boot():/<machine-id>/<kernel>/<file>
		oldhash="${BASH_REMATCH[4]}"
		file="$ESP_PATH/${uri#boot():/}"
		if [[ -f "$file" ]]; then
			newhash=""
			read -r newhash _ < <(b2sum -- "$file" 2>/dev/null) || true
			if [[ -n "$newhash" && "${newhash,,}" != "${oldhash,,}" ]]; then
				line="${prefix}${uri}#${newhash}"
				changed=1
				log "rehashed ${file##*/}"
			fi
		else
			log "referenced file missing, left unchanged: $file"
		fi
	fi
	printf '%s\n' "$line"
done < "$conf" > "$tmp"

if (( changed == 0 )); then
	log "all hashes already match — no changes"
	exit 0
fi

# Replace contents in place (ESP is FAT32: truncate + rewrite, keep the same file).
cat "$tmp" > "$conf"
sync -f "$conf" 2>/dev/null || sync
log "updated BLAKE2b hashes in $conf"

# If config-checksum enrollment is active, the edited config must be re-enrolled into
# the Limine binary (and the binary re-signed) or boot fails on a config mismatch.
if [[ "${ENABLE_ENROLL_LIMINE_CONFIG:-}" == "yes" ]] && command -v limine-enroll-config &>/dev/null; then
	log "re-enrolling limine.conf checksum into the Limine binary"
	limine-enroll-config || log "WARNING: limine-enroll-config failed — re-run it before rebooting"
fi
SCRIPT
  sudo chmod 0755 /usr/local/bin/limine-sbctl-rehash

  sudo mkdir -p /etc/pacman.d/hooks
  sudo tee /etc/pacman.d/hooks/zzz-limine-sbctl-rehash.hook >/dev/null <<'HOOK'
# Re-sync limine.conf BLAKE2b hashes AFTER sbctl signs the kernels.
# The filename sorts after zz-sbctl.hook, so this PostTransaction hook runs last —
# once the kernel EFI stubs already carry their Secure Boot signatures. Triggers
# mirror zz-sbctl.hook so the two always fire together. Depends=sbctl makes the hook
# auto-disable if sbctl is ever removed.
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Operation = Remove
Target = boot/*
Target = efi/*
Target = usr/lib/modules/*/vmlinuz
Target = usr/lib/modules/*/extramodules/*
Target = usr/lib/**/efi/*.efi*
Target = usr/share/**/*.efi*

[Action]
Description = Re-syncing Limine BLAKE2b hashes after Secure Boot signing...
When = PostTransaction
Depends = sbctl
Exec = /usr/local/bin/limine-sbctl-rehash
HOOK
  ok "Limine re-hash hook installed (zzz-limine-sbctl-rehash.hook runs after zz-sbctl.hook)"
}

# --------------------------------------------------------------------------
# 18. Finalize: default shell, user service, reboot
# --------------------------------------------------------------------------
finalize() {
  step "Finalizing"
  sudo chsh -s "$(which zsh)" "$(whoami)"
  systemctl --user enable dms || warn "Could not enable user dms service"
  ok "Default shell set to zsh; ly and dms enabled"

  echo -e "\n${GREEN}${BOLD}Setup complete!${RESET}"
  echo -e "${YELLOW}A reboot is required to apply the display manager, shell and services.${RESET}"
  read -rp "Reboot now? [y/N] " ans || ans=""
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo reboot
  else
    info "Reboot skipped. Run 'sudo reboot' when ready."
  fi
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
main() {
  echo -e "${BOLD}${BLUE}=== CachyOS personal setup ===${RESET}"
  setup_sudo
  setup_chaotic_aur
  install_packages
  install_aur
  install_flatpaks
  install_runtimes
  setup_ly
  setup_services
  configure_kitty
  configure_fuzzel
  configure_niri
  configure_editors
  configure_starship
  configure_yazi
  configure_neovim
  configure_zsh
  setup_udiskie
  setup_gnome_keyring
  setup_limine_sbctl_rehash
  secure_boot
  finalize
}

main "$@"

# If you ever want to tighten it down to only update commands (more secure, recommended once setup is
# done), replace the blanket rule with a command-scoped one:

# # /etc/sudoers.d/osiris
# osiris ALL=(ALL) NOPASSWD: /usr/bin/pacman -Syu, /usr/bin/pacman -Syyu, /usr/bin/shelly *
# osiris ALL=(ALL) PASSWD: ALL

# Key points if you go that route:
# - Use absolute paths (/usr/bin/pacman) — a bare pacman is rejected for safety.
# - Arguments must match exactly; pacman -Syu won't cover pacman -Syyu unless you list both (as above).
# - shelly * allows any shelly subcommand passwordless. Drop the * and pin exact args if you want it
# stricter.
# - Always end with sudo visudo -cf /etc/sudoers.d/osiris before trusting it.

# For now the script keeps the full NOPASSWD:ALL you asked for, just with correct permissions and
# validation.
