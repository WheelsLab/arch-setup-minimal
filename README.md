# Arch Linux Minimal Setup

Automated installation scripts for a minimal Arch Linux system with Btrfs, LUKS encryption, and Niri window manager.

## Project Structure

```
arch-setup-minimal/
├── SPEC.md                          # Project specification
├── setup.sh                         # Main entry script
├── lib/                             # Shared library
│   ├── logging.sh                   # Logging functions
│   ├── utils.sh                     # Utility functions
│   └── constants.sh                 # Constants definition
├── minimal-install/                 # Minimal install phase
│   ├── 00-disk.sh                   # Disk partition + LUKS + Btrfs
│   ├── 01-mount.sh                  # Mount filesystems
│   ├── 02-base-pkg.sh                # Install base/linux/firmware
│   ├── 03-config-base-system.sh      # Timezone/language/network
│   ├── 04-bootloader.sh              # Install Limine
│   ├── 05-users.sh                   # Create user/sudo
│   ├── 06-aur-helper.sh               # Install paru
│   ├── 07-chroot.sh                  # Chroot configuration
│   └── cleanup.sh                    # Cleanup/umount scripts
├── post-install/                    # Post-install phase
│   ├── 01-system-packages.sh        # Desktop/tools packages
│   ├── 02-desktop-env.sh             # Configure Niri + DMS
│   ├── 03-snapper.sh                 # Configure Snapper snapshots
│   └── 04-automate-boot.sh           # Automate bootloader config
└── dotfiles/                        # Configuration files
    ├── niri/                        # Niri WM config
    ├── dms/                         # DankMaterialShell config
    ├── alacritty/                   # Terminal config
    ├── starship.toml                # Shell prompt
    └── setup.sh                     # Dotfiles deployment script
```

## Three Phases

1. **minimal-install**: Install base system (disk, encryption, bootloader, users)
2. **post-install**: Install AUR packages, Chinese localization
3. **dotfiles**: Install DankMaterialShell (Niri) and daily software with config

## Usage

```bash
# Interactive menu
./setup.sh

# Specific phase
./setup.sh minimal
./setup.sh post
./setup.sh dotfiles

# Individual script
./minimal-install/00-disk.sh
```

## Features

- Btrfs with subvolumes (/@,/@home,/@log,/@cache)
- LUKS full disk encryption
- Limine bootloader
- Niri window manager (Wayland)
- DankMaterialShell (DMS)
- Snapper automatic snapshots
- Chinese localization support
