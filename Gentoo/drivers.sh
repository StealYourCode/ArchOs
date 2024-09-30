#!/bin/bash
set -e  

# Ensure we are running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Switch to chroot environment
chroot /mnt/gentoo /bin/bash 
source /etc/profile
export PS1="(chroot) ${PS1}"

# Sync the latest Gentoo repository
echo "Syncing Gentoo repository..."
emerge-webrsync

# TIME ZONE SETUP
echo "Setting timezone"
ln -sf "/usr/share/zoneinfo/Europe/Brussels" "/etc/localtime"

# KEYBOARD SETUP
echo "Configuring locale and keyboard..."
# Generate locales
sed -i '/^#en_US.UTF-8/s/^#//' /etc/locale.gen   # Uncomment 'en_US.UTF-8'
echo "fr_BE.UTF-8 UTF-8" >> /etc/locale.gen

# Update environments
echo "Updating environment..."
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# INSTALL REQUIRED PACKAGES
echo "Installing necessary system utilities..."
emerge --ask sys-apps/pciutils sys-apps/usbutils  # Install PCI and USB utilities

# INSTALL KERNEL MODULES
echo "Installing Gentoo kernel sources..."
emerge --ask sys-kernel/gentoo-sources 

# CONFIGURE AND COMPILE KERNEL
echo "Configuring and compiling the kernel..."
cd /usr/src/linux*
make menuconfig  # Opens menu for manual kernel configuration
curl https://github.com/StealYourCode/ArchOs/blob/main/gentoo/Files/config

# Compile kernel and install modules
echo "Starting kernel compilation..."
date > StartingDate.log
make -j2 && make modules_install
date > EndingDate.log
echo "Kernel compilation and module installation completed."


echo "Exiting chroot environment."

