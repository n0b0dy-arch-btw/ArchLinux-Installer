#!/usr/bin/env bash
set -euo pipefail

# Load configuration
source postinstall.conf

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root inside your installed Arch system."
    echo "Example: sudo ./post_install.sh"
    exit 1
fi

echo "=== Installing sudo ==="
pacman --noconfirm -S sudo

echo "=== Creating user '$USERNAME' ==="
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd

echo "=== Opening sudoers file with nano ==="
EDITOR=nano visudo

echo "=== Installing desktop environment: $DESKTOP ==="

case "$DESKTOP" in
    gnome)
        pacman --noconfirm -S gnome gnome-extra gdm
        systemctl enable gdm
        ;;
    kde|plasma)
        pacman --noconfirm -S plasma kde-applications sddm
        systemctl enable sddm
        ;;
    xfce)
        pacman --noconfirm -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    cinnamon)
        pacman --noconfirm -S cinnamon lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    mate)
        pacman --noconfirm -S mate mate-extra lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    lxqt)
        pacman --noconfirm -S lxqt sddm
        systemctl enable sddm
        ;;
    i3)
        pacman --noconfirm -S i3 dmenu xorg-xinit
        echo "exec i3" > /home/$USERNAME/.xinitrc
        chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc
        ;;
    *)
        echo "Unknown desktop environment: $DESKTOP"
        exit 1
        ;;
esac

echo "=== Installing essential applications ==="
pacman --noconfirm -S xorg network-manager-applet firefox

echo "=== Enabling NetworkManager ==="
systemctl enable NetworkManager

echo "=== Post-installation complete! ==="
echo "You can now reboot into your new desktop environment."
