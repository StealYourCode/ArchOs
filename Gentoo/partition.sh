#!/bin/bash

# Prerequisites:
# 1. A user other than root: # useradd -m -G users,wheel <username>
# 2. A password set both for root and your user: # passwd
# 3. A running SSH service for QoL: # /etc/init.d/sshd start

# Usage:
# 1. Transfer this script to your virtual machine: 
## scp partition.sh $USER@VM_IP:/home/$USER (from host machine)
## OR
## curl -o /home/$USER https://raw.githubusercontent.com/StealYourCode/ArchOs/refs/heads/main/Gentoo/partition.sh
# 2. Give execute permissions : chmod +x partition.sh

# This script will then do the rest of Lesson 1 for you,
# When it has finished running you will be able to chroot to your gentoo installation:
## chroot /mnt/gentoo /bin/bash
## source /etc/profile
## export PS1="(chroot) ${PS1}"


# Ensure we are running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi


# Check if the username is provided as an argument
if [ -z "$1" ]; then
  echo "Error: No username provided."
  echo "Usage (as root): ./partition.sh <username>"
  exit 1
fi

USER="$1"
DISK="/dev/sda"

STAGE3_TARBALL=$(find /home/$USER -name "stage3*.tar.xz" -print -quit)

# Clean up function to unmount partitions and disable swap
cleanup() {
  echo "Cleaning up mounted partitions due to an error..."
  umount -R /mnt/gentoo 2>/dev/null || echo "Warning: Failed to unmount /mnt/gentoo"
  swapoff "${DISK}3" 2>/dev/null || echo "Warning: Failed to deactivate swap."
}

# Only call cleanup if the script encounters an error
trap cleanup ERR


# Step 1 : Partition the disk
echo "Partitioning the disk with sgdisk..."

if lsblk "$DISK" | grep -q "${DISK}[0-9]"; then
  echo "Warning: $DISK already has partitions."
  read -p "Do you want to repartition the disk? (y/n): " choice
  if [ "$choice" == "y" ]; then
    sgdisk --zap-all "$DISK"
    sgdisk --new=1:0:+100M --typecode=1:ef00 "$DISK"
    sgdisk --new=2:0:+200M --typecode=2:8300 "$DISK"
    sgdisk --new=3:0:+2G --typecode=3:8200 "$DISK"
    sgdisk --new=4:0:+20G --typecode=4:8304 "$DISK"
    sgdisk --new=5:0:0 --typecode=5:8300 "$DISK"
  else
    echo "Skipping partitioning."
  fi
else
  sgdisk --zap-all "$DISK"
  sgdisk --new=1:0:+100M --typecode=1:ef00 "$DISK"
  sgdisk --new=2:0:+200M --typecode=2:8300 "$DISK"
  sgdisk --new=3:0:+2G --typecode=3:8200 "$DISK"
  sgdisk --new=4:0:+20G --typecode=4:8304 "$DISK"
  sgdisk --new=5:0:0 --typecode=5:8300 "$DISK"
fi


# Step 2 : Create filesystems
echo "Creating filesystems..."

# UEFI partition
if blkid "${DISK}1" | grep -q "vfat"; then
  echo "Warning: ${DISK}1 already has a vfat filesystem."
  read -p "Do you want to reformat the UEFI partition? (y/n): " choice
  if [ "$choice" == "y" ]; then
    mkfs.vfat -F32 "${DISK}1"
  fi
else
  mkfs.vfat -F32 "${DISK}1"
fi

# Boot partition
if blkid "${DISK}2" | grep -q "vfat"; then
  echo "Warning: ${DISK}2 already has a vfat filesystem."
  read -p "Do you want to reformat the Boot partition? (y/n): " choice
  if [ "$choice" == "y" ]; then
    mkfs.vfat -F32 "${DISK}2"
  fi
else
  mkfs.vfat -F32 "${DISK}2"
fi

# Swap partition
mkswap "${DISK}3"

# Gentoo root partition
if blkid "${DISK}4" | grep -q "ext4"; then
  echo "Warning: ${DISK}4 already has an ext4 filesystem."
  read -p "Do you want to reformat the Root partition? (y/n): " choice
  if [ "$choice" == "y" ]; then
    mkfs.ext4 "${DISK}4"
  fi
else
  mkfs.ext4 "${DISK}4"
fi

# MyLinux partition
if blkid "${DISK}5" | grep -q "ext4"; then
  echo "Warning: ${DISK}5 already has an ext4 filesystem."
  read -p "Do you want to reformat the MyLinux partition? (y/n): " choice
  if [ "$choice" == "y" ]; then
    mkfs.ext4 "${DISK}5"
  fi
else
  mkfs.ext4 "${DISK}5"
fi

echo "Filesystems created."


# Step 3 : Mount partitions
echo "Mounting partitions..."

mount "${DISK}4" /mnt/gentoo
mkdir -p /mnt/gentoo/boot
mount "${DISK}2" /mnt/gentoo/boot
mkdir -p /mnt/gentoo/efi
mount "${DISK}1" /mnt/gentoo/efi

swapon "${DISK}3"

echo "Partitions mounted and swap enabled."


# Step 4: Download or move stage3 tarball
echo "Preparing for Gentoo installation..."

if [ -z "$STAGE3_TARBALL" ]; then
  echo "Stage3 tarball not found in /home/$USER. Downloading..."
  # Determine latest stage 3
  STAGE3_FILENAME=$(curl -s "https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/latest-stage3-amd64-systemd.txt" | grep stage3-amd64-systemd-* | cut -d " " -f 1)
  STAGE3_URL="https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/$STAGE3_FILENAME"
  curl -o "/mnt/gentoo/$STAGE3_FILENAME" "$STAGE3_URL"
  if [ $? -ne 0 ]; then
    echo "Error downloading stage3 tarball from $STAGE3_URL."
    exit 1
  else
    echo "Stage3 tarball downloaded successfully."
  fi
else
  echo "Found stage3 tarball: $STAGE3_TARBALL"
  mv "$STAGE3_TARBALL" /mnt/gentoo/
fi

# Extract stage3 tarball
cd /mnt/gentoo
tar xpvf /mnt/gentoo/stage3*.tar.xz --xattrs-include='*.*' --numeric-owner
rm /mnt/gentoo/stage3*.tar.xz

# Prepare system for chroot
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run

echo "System ready for chroot."