#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "======================================================="
echo "      Hyprlauncher: The Official App Launcher Setup    "
echo "======================================================="

HYPR_DIR="$HOME/.config/hypr"

# 1. Install Hyprlauncher
echo "---> [1/3] Installing Hyprlauncher from the COPR repository..."
# Available natively via the heus-sueh packages we enabled earlier
sudo dnf install -y hyprlauncher wl-clipboard papirus-icon-theme

# 2. Configure Hyprlauncher for UWSM
echo "---> [2/3] Writing Hyprlauncher configuration..."
cat << 'EOF' > "$HYPR_DIR/hyprlauncher.conf"
# ==========================================
# HYPRLAUNCHER CONFIGURATION
# ==========================================
# CRITICAL: Force all desktop apps to launch through UWSM
desktop_launch_prefix = uwsm app -- 

# UI & Features
desktop_icons = true
window_size = 800 400
default_finder = desktop

# Prefixes for different search modes
desktop_prefix = 
unicode_prefix = .
math_prefix = =
font_prefix = '
EOF

echo "---> [3/4] Injecting Hyprtoolkit Theme (Colors & Fonts)..."
# This file controls the colors and typography for ALL native Hyprtoolkit apps
cat << 'EOF' > "$HYPR_DIR/hyprtoolkit.conf"
# ==========================================
# HYPRTOOLKIT THEME (Catppuccin Mocha)
# ==========================================
# Format expects 0xAARRGGBB where AA is the hex alpha channel

background = 0xFF11111B
base = 0xFF1E1E2E
alternate_base = 0xFF313244
text = 0xFFCDD6F4
bright_text = 0xFFB4BEFE

# Pink / Mauve Accents
accent = 0xFFF5C2E7
accent_secondary = 0xFFCBA6F7

# ==========================================
# FONTS & TYPOGRAPHY
# ==========================================
font_family = CaskaydiaCove Nerd Font Mono
icon_theme = Papirus-Dark
font_size = 11
small_font_size = 10
h1_size = 19
h2_size = 15
h3_size = 13
EOF

echo "---> [2/2] Updating Hyprlauncher Window Size..."
# We append the UI block to your existing hyprlauncher.conf to expand its physical size
CONFIG_FILE="$HYPR_DIR/hyprlauncher.conf"

if ! grep -q "ui {" "$CONFIG_FILE"; then
cat << 'EOF' >> "$CONFIG_FILE"

# UI Scaling
ui {
    # Default is 400 260. Expanding for better readability.
    window_size = 600 400
}
EOF
else
    echo "UI block already exists in hyprlauncher.conf, skipping size update."
fi

# 3. Update Hyprland Config
# echo "---> [4/4] Updating hyprland.conf with Daemon and Keybinds..."

# Start the hyprlauncher daemon quietly in the background on startup
# if ! grep -q "exec-once = hyprlauncher -d" "$HOME/.config/hypr/hyprland.conf"; then
#     sed -i '/exec-once = uwsm app -- hyprpanel/a exec-once = hyprlauncher -d' "$HOME/.config/hypr/hyprland.conf"
# fi

# Replace Wofi with Hyprlauncher in your keybinds
# sed -i 's/$menu = wofi --show drun/$menu = hyprlauncher/g' "$HOME/.config/hypr/hyprland.conf"

echo "======================================================="
echo "             HYPRLAUNCHER DEPLOYED!                    "
echo "======================================================="
echo "To apply changes without rebooting, run: hyprlauncher -d &"
echo "Then press your app menu shortcut (SUPER + A)!"