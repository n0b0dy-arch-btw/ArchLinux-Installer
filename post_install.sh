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

# Spinner function
spinner() {
    local pid=$1
    local message="$2"
    local delay=0.1
    local spin_chars='| / - \'
    echo -n "$message "
    while kill -0 "$pid" 2>/dev/null; do
        for char in $spin_chars; do
            printf "\b$char"
            sleep $delay
        done
    done
    echo -e "\bDone!"
}

# Function to run a command silently with spinner
run_step() {
    local message="$1"
    shift
    (
        "$@" >/dev/null 2>&1
    ) &
    spinner $! "$message"
}

# Steps
run_step "Installing sudo..." pacman --noconfirm -S sudo

run_step "Creating user '$USERNAME'..." bash -c "
    useradd -m -G wheel -s /bin/bash \"$USERNAME\" &&
    echo \"$USERNAME:$USER_PASSWORD\" | chpasswd
"

echo "Opening sudoers file with nano..."
EDITOR=nano visudo

case "$DESKTOP" in
    gnome)
        run_step "Installing GNOME desktop..." pacman --noconfirm -S gnome gnome-extra gdm
        run_step "Enabling GDM..." systemctl enable gdm
        ;;
    kde|plasma)
        run_step "Installing KDE Plasma desktop..." pacman --noconfirm -S plasma kde-applications sddm
        run_step "Enabling SDDM..." systemctl enable sddm
        ;;
    xfce)
        run_step "Installing XFCE desktop..." pacman --noconfirm -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
        run_step "Enabling LightDM..." systemctl enable lightdm
        ;;
    cinnamon)
        run_step "Installing Cinnamon desktop..." pacman --noconfirm -S cinnamon lightdm lightdm-gtk-greeter
        run_step "Enabling LightDM..." systemctl enable lightdm
        ;;
    mate)
        run_step "Installing MATE desktop..." pacman --noconfirm -S mate mate-extra lightdm lightdm-gtk-greeter
        run_step "Enabling LightDM..." systemctl enable lightdm
        ;;
    lxqt)
        run_step "Installing LXQt desktop..." pacman --noconfirm -S lxqt sddm
        run_step "Enabling SDDM..." systemctl enable sddm
        ;;
    i3)
        run_step "Installing i3 window manager..." pacman --noconfirm -S i3 dmenu xorg-xinit
        bash -c "
            echo \"exec i3\" > /home/$USERNAME/.xinitrc &&
            chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc
        " >/dev/null 2>&1
        ;;
    *)
        echo "Unknown desktop environment: $DESKTOP"
        exit 1
        ;;
esac

run_step "Installing essential applications..." pacman --noconfirm -S xorg network-manager-applet firefox
run_step "Enabling NetworkManager..." systemctl enable NetworkManager

echo "Post-installation complete! You can now reboot into your new desktop environment."
