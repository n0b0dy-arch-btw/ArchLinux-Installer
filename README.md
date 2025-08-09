# Arch Linux Automated Base Installer

This repository contains a **Bash script** and **configuration file** for automating a **base Arch Linux installation**.

Instead of manually typing every installation command, you just edit a small `install.conf` file with your preferences, and the script takes care of the rest.

---

## 📋 Features
- Automated base Arch Linux installation using your configuration
- User-editable `install.conf` for keyboard layout, timezone, drive, locale, hostname, and root password
- Safety check before writing to your disk
- Fully scripted chroot configuration (no manual typing in `arch-chroot`)
- Minimal base install with `base`, `linux`, `linux-firmware`, and `nano`
- GRUB bootloader and NetworkManager pre-installed and enabled

---

## ⚠️ Disclaimer
This script will **erase data** on the selected drive.  
Make sure you have backups of any important data before proceeding.

You are responsible for ensuring that your `install.conf` is correct.  
If you select the wrong drive, **it will be overwritten**.

---

## 🖥️ Requirements
- A bootable Arch Linux ISO (download from: https://archlinux.org/download/)
- Internet connection
- Some basic understanding of Linux partitions
- You have **manually partitioned** your drive beforehand (e.g., using `fdisk` or `cfdisk`)

---

## 📂 Files
- **`install.conf`** — User configuration file
- **`arch_install.sh`** — Installation script

---

## ⚙️ Configuration

Before running the script, edit `install.conf` with your preferences:

```bash
# Keyboard layout (e.g. us, uk, de)
KEYMAP=uk

# Timezone
TIMEZONE=Europe/London

# Drive label (no partition number, e.g. sda, nvme0n1)
DRIVE=sda

# Partition numbers (adjust to your partitioning scheme)
BOOT_PART=1
SWAP_PART=2
ROOT_PART=3

# Locale
LOCALE=en_US.UTF-8

# Hostname
HOSTNAME=myarch

# Root password
ROOT_PASSWORD=changeme
