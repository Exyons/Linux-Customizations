#!/bin/bash
# Exit immediately if any underlying script fails
set -e

echo "======================================================="
echo "       PROJECT BEAST MODE: GRAND ORCHESTRATOR          "
echo "======================================================="
echo "This script will execute the OS Master Setup, deploy"
echo "your Wayland configurations, and inject custom themes."
echo "======================================================="
sleep 3

# 0. Granting no password requirement for user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER

# 1. Make everything executable in the current directory
echo -e "\n---> Granting execution permissions to all scripts..."
chmod +x *.sh

# 2. The Core OS, Nvidia, Fonts, and Terminal 
echo -e "\n---> [PHASE 1/5] Initiating Fedora Master Setup..."
./1.fedora-master-setup.sh

# 3. Hyprland & UWSM Configuration
echo -e "\n---> [PHASE 2/5] Initiating Hyprland Beast Mode Configuration..."
if [ -f "./2.setup-hyprland-beast.sh" ]; then
    ./2.setup-hyprland-beast.sh
else
    echo "Warning: 2.setup-hyprland-beast.sh not found. Skipping..."
fi

# 4. HyprPanel Module & Theme Injection
echo -e "\n---> [PHASE 3/5] Initiating HyprPanel Custom Injection..."
if [ -f "./3.setup-hyprpanel-config.sh" ]; then
    ./3.setup-hyprpanel-config.sh
else
    echo "Warning: 3.setup-hyprpanel-config.sh not found. Skipping..."
fi

echo -e "\n---> [PHASE 4/5] Initiating Hyprlauncher Custom Injection..."
if [ -f "./4.setup-hyprlauncher.sh" ]; then
    ./4.setup-hyprlauncher.sh
else
    echo "Warning: 4.setup-hyprlauncher.sh not found. Skipping..."
fi

echo -e "\n---> [PHASE 5/5] Intalling grub2 theme..."
if [ -f "./5.setup-grub-theme.sh" ]; then
    ./5.setup-grub-theme.sh
else
    echo "Warning: 5.setup-grub-theme.sh not found. Skipping..."
fi

# 5. Add user to groups
sudo usermod -aG gamemode,video,audio $USER

echo "======================================================="
echo "          SYSTEM FORGING COMPLETELY FINISHED!          "
echo "======================================================="
echo "Your entire environment has been built from scratch."
echo "CRITICAL REBOOT INSTRUCTIONS:"
echo "1. Type 'reboot' and hit enter."
echo "2. At the blue MOK screen, select 'Enroll MOK' -> 'Continue' -> 'Yes'."
echo "3. Enter the MOK password you created during Phase 1."
echo "4. Ensure Secure Boot is ON in your BIOS."
echo "5. Welcome to Beast Mode."