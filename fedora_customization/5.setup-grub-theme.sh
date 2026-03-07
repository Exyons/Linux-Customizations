#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "======================================================="
echo "             GRUB2 Tela Theme Installer                "
echo "======================================================="

# 1. Pre-flight Cleanup
# Ensure no corrupted or old clones exist in the target directory
if [ -d "/tmp/grub2-themes" ]; then
    echo "---> Removing existing repository..."
    rm -rf /tmp/grub2-themes
fi

echo "---> [1/3] Cloning vinceliuice's grub2-themes repository..."
git clone https://github.com/vinceliuice/grub2-themes.git /tmp/grub2-themes

echo "---> [2/3] Executing the installer (Tela theme, 2K resolution)..."
cd /tmp/grub2-themes
# The script natively handles updating /etc/default/grub and regenerating grub.cfg
sudo ./install.sh -t tela -s 2k

echo "---> [3/3] Cleaning up temporary files..."
cd /tmp
rm -rf /tmp/grub2-themes

echo "======================================================="
echo "          GRUB THEME INSTALLED SUCCESSFULLY!           "
echo "======================================================="
echo "Your boot menu is now running the 2K Tela aesthetic."
