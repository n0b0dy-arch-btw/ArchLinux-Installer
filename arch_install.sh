#!/usr/bin/env bash
set -euo pipefail

# ======================================
# Load Configuration
# ======================================
source install.conf

# ======================================
# Confirmation Prompt
# ======================================
echo "=== Arch Linux Installation ==="
echo "Target Drive: /dev/$DRIVE"
echo "BOOT: /dev/${DRIVE}${BOOT_PART}"
echo "SWAP: /dev/${DRIVE}${SWAP_PART}"
echo "ROOT: /dev/${DRIVE}${ROOT_PART}"
echo
read -p "Type 'yes' to confirm installation: " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { echo "Aborted."; exit 1; }

# ======================================
# Installation Process
# ======================================
(
    # 1. Keyboard layout
    loadkeys "$KEYMAP"

    # 2. Enable NTP
    timedatectl set-ntp true

    # 3. Format partitions
    mkfs.ext4 -F /dev/${DRIVE}${ROOT_PART}
    mkswap /dev/${DRIVE}${SWAP_PART}
    mkfs.fat -F 32 /dev/${DRIVE}${BOOT_PART}

    # 4. Mount partitions
    mount /dev/${DRIVE}${ROOT_PART} /mnt
    mount --mkdir /dev/${DRIVE}${BOOT_PART} /mnt/boot
    swapon /dev/${DRIVE}${SWAP_PART}

    # 5. Install base packages
    pacstrap -K /mnt base linux linux-firmware nano ${BASE_PACKAGES}

    # 6. Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab

    # 7. System Configuration
    arch-chroot /mnt /bin/bash <<EOF
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

# Show spinner until installation finishes
spinner $installer_pid "Installing Arch Linux"

# ======================================
# Finish
# ======================================
echo "✅ Installation complete! You can now reboot into your new Arch Linux system."
