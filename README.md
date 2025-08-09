#!/usr/bin/env bash
set -euo pipefail

source postinstall.conf

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

pacman --noconfirm -S sudo

useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd

sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

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

pacman --noconfirm -S xorg network-manager-applet firefox

systemctl enable NetworkManager

echo "Post-install complete! Reboot and log in as $USERNAME."
