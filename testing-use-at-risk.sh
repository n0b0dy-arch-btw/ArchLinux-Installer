#!/usr/bin/env bash
set -euo pipefail

# Load configuration
source install.conf

# Confirm before proceeding
echo "!!! WARNING !!!"
echo "This will install Arch Linux on /dev/$DRIVE"
echo "BOOT: /dev/${DRIVE}${BOOT_PART}"
echo "SWAP: /dev/${DRIVE}${SWAP_PART}"
echo "ROOT: /dev/${DRIVE}${ROOT_PART}"
read -p "Type 'yes' to continue: " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { echo "Aborted."; exit 1; }

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spin_chars='| / - \\'
    echo -n "Installing Arch Linux "
    while kill -0 "$pid" 2>/dev/null; do
        for char in $spin_chars; do
            printf "\b$char"
            sleep $delay
        done
    done
    echo -e "\bDone!"
}

# Run the whole installation silently in the background
(
    # 1. Keyboard layout
    loadkeys "$KEYMAP" >/dev/null 2>&1

    # 2. Enable NTP
    timedatectl set-ntp true >/dev/null 2>&1

    # 3. Format partitions
    mkfs.ext4 /dev/${DRIVE}${ROOT_PART} >/dev/null 2>&1
    mkswap /dev/${DRIVE}${SWAP_PART} >/dev/null 2>&1
    mkfs.fat -F 32 /dev/${DRIVE}${BOOT_PART} >/dev/null 2>&1

    # 4. Mount partitions
    mount /dev/${DRIVE}${ROOT_PART} /mnt >/dev/null 2>&1
    mount --mkdir /dev/${DRIVE}${BOOT_PART} /mnt/boot >/dev/null 2>&1
    swapon /dev/${DRIVE}${SWAP_PART} >/dev/null 2>&1

    # 5. Install base packages
    pacstrap -K /mnt base linux linux-firmware nano >/dev/null 2>&1

    # 6. Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab 2>/dev/null

    # 7. Chroot and configure the system
    arch-chroot /mnt /bin/bash <<EOF >/dev/null 2>&1
# Timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Locale
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname

# Root password
echo "root:$ROOT_PASSWORD" | chpasswd

# Install essential packages
pacman --noconfirm -S networkmanager grub

# Enable NetworkManager
systemctl enable NetworkManager

# Install and configure GRUB
grub-install /dev/$DRIVE
grub-mkconfig -o /boot/grub/grub.cfg
EOF
) &
installer_pid=$!

# Show spinner until process finishes
spinner $installer_pid

echo "Installation complete! You can now reboot into your new Arch Linux system."
