#!/bin/bash

### Before using this script you need to have finish multiples things: 
### 1. Everything before "Disk Partitioning with fdisk"
### 2. Move stage3xxx.tar.xz to your /home/$USER directory 

### To transfer this script you should use scp partition.sh $USER@VM_IP:/home/$USER
### Where $USER is the new user you create previously
### Don't forget to chmod +x partition.sh

### This script will do the rest of the Lesson 1 for you,
### When it has finish running you should be able to switch to "chroot user" with theses commands
## chroot /mnt/gentoo /bin/bash
## source /etc/profile
## export PS1="(chroot) ${PS1}"


# Ensure we are running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


# Check if the username is provided as an argument
if [ -z "$1" ]; then
  echo "Error: No username provided."
  echo "Usage: sudo ./install.sh <username>"
  exit 1
fi

# Assign the first argument to USER variable
USER="$1"

# Check if stage3 tarball exists in /home/$USER directory
STAGE3_TARBALL=$(find /home/$USER -name "stage3*.tar.xz" -print -quit)


DISK="/dev/sda"


# Disk partitioning with sgdisk
echo "Partitioning the disk with sgdisk..."

sgdisk --zap-all /dev/sda
sgdisk --new=1:0:+100M --typecode=1:ef00 /dev/sda 
sgdisk --new=2:0:+200M --typecode=2:8300 /dev/sda
sgdisk --new=3:0:+2G --typecode=3:8200 /dev/sda
sgdisk --new=4:0:+20G --typecode=4:8304 /dev/sda
sgdisk --new=5:0:0 --typecode=5:8300 /dev/sda

sgdisk --print /dev/sda

# Create filesystems
echo "Creating filesystems..."

mkfs.vfat -F32 ${DISK}1 # UEFI partition
mkfs.vfat -F32 ${DISK}2 # Boot partition
mkswap ${DISK}3          # Swap partition
mkfs.ext4 ${DISK}4       # Gentoo root partition
mkfs.ext4 ${DISK}5       # MyLinux partition

echo "Filesystems created."

# Mount partitions
echo "Mounting partitions..."

mount ${DISK}4 /mnt/gentoo # Mount Gentoo root partition
mkdir /mnt/gentoo/boot
mount ${DISK}2 /mnt/gentoo/boot # Mount Boot partition
mkdir /mnt/gentoo/efi
mount ${DISK}1 /mnt/gentoo/efi  # Mount UEFI partition
swapon ${DISK}3 # Enable swap

echo "Partitions mounted and swap enabled."

# Prepare for Gentoo base installation
echo "Preparing for Gentoo installation..."

if [ -z "$STAGE3_TARBALL" ]; then
  echo "Error: stage3 tarball not found in /home/$USER."
  exit 1
else
  echo "Found stage3 tarball: $STAGE3_TARBALL"
  # Move the tarball to /mnt/gentoo
  mv "$STAGE3_TARBALL" /mnt/gentoo/
fi

# Extract stage3 tarball (ensure the correct path for the stage3 tarball)
cd /mnt/gentoo
tar xpvf /mnt/gentoo/stage3*.tar.xz --xattrs-include='*.*' --numeric-owner
rm /mnt/gentoo/stage3*.tar.xz # Remove stage3 tarball after extraction

# Prepare system for chroot
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run

echo "System ready for chroot."
