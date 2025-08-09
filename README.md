# Arch Linux Automated Installer named Arch Shelly installer

This repository contains two scripts for a fully automated Arch Linux installation:

1. **arch_install.sh** — installs a base Arch Linux system using a config file.
2. **post_install.sh** — installs a desktop environment, creates a user, enables sudo, and sets up a full desktop system.

With these scripts and their configuration files, you can install Arch Linux from scratch and get a working desktop with minimal manual input.

---

## Included Files

### install.conf (Base Install Config)
```bash
# Keyboard layout (e.g. us, uk, de)
KEYMAP=uk

# Timezone
TIMEZONE=Europe/London

# Drive label (without partition number, e.g. sda, nvme0n1)
DRIVE=sda

# Partition numbers
BOOT_PART=1
SWAP_PART=2
ROOT_PART=3

# Locale
LOCALE=en_US.UTF-8

# Hostname
HOSTNAME=Shelly

# Root password
ROOT_PASSWORD=changeme
