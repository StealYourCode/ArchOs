2024-09-17 - 13:44

# Objective
Create an OS on a given device (dependent mostly on the size of the device).


## Key Points
- Computer hardware review
- Process Managements : User mode + Kernel mode
- System Call allow to switch between user mode & kernel mode
- System Call are an essential components in an OS
- Here we use glibC
- To know the version use of glibC 
```bash
ldd --version
``` 

---

## OS Core Functions / Kernel
- Memory Management
- Process Management (User mode OR Kernel Mode which change with system call)
- I/O Management
- File System Management

---

## System Call
- They are in essential components of the system (Library)
- For Gentoo it is in glibc

---
## VM Implementation (Lab)

- A VM operates as follows: VM → OS → Virtualization → OS → Hardware.

### Network Modes in VMs
- **BRIDGE**: Shares the Wi-Fi card with the host.
- **NAT**: Shares IP with the host.
- **HOST-ONLY**: Creates a network shared only with the host.
- **PRIVATE NETWORK**: Creates a virtualized network between devices.

---

## VM Configuration
- **Hard Drive**: 25GB
- **Firmware**: UEFI
- **RAM**: 4GB
- **CPU**: 2 Cores
- **Network Mode**: NAT

---

## Disk Partitioning (BIOS/UEFI)

### BIOS Partition
- **Kernel** → Boot (200MB)
- **Swap** → 2GB
- **Toolbox** → Gentoo (20GB)
- **My Linux** → Gentoo compiled utilities and a Linux system for ease of copy/paste (~100MB minimum; use remaining space).

### UEFI Partition
- **Kernel**
- **Boot**
- **Swap**
- **Gentoo**
- **My Linux**

---

## VM Installation Steps

1. **Create New VM**: 
   - OS Type: Other Linux 6, 64-bit
   - Name: Kinet2024
   - Hard drive: Multiple partitions, 25GB
   - Switch to UEFI in advanced options.

2. **Add Hardware**: 
   -  Create VM without OS
   - Boot from Gentoo ISO.

3. **Initial Commands After Boot**:
   - Change keyboard layout:
     ```bash
     loadkeys be-latin1
     ```
   - Set root password:
     ```bash
     passwd # Kinet@nt
     ```
   - Create user `antoine`:
     ```bash
     useradd -m -G users,wheel antoine
     passwd antoine # Kinet@ant
     ```
   - Start SSH service:
     ```bash
     /etc/init.d/sshd start
     ip addr
     ```

   - From the host, attempt to ping the VM for connection verification:
     ```bash
     systemctl start service.sshd
     ssh antoine@VM_IP
     ```

4. **Checksum Verification**:
   - Verify file integrity:
     ```bash
     sha256sum FILE
     ```

---

## Disk Partitioning with fdisk

### UEFI Disk Creation
1. **GPT Disk Creation**:
   ```bash
  su - # Kinet@nt	
  fdisk /dev/sda
  g # Create a GPT partition
   ```

2.**Partition Setup**:

- **UEFI Partition**:
```bash 
n # New partition
+100M
t 1 # Set type to UEFI/EFI
``` 

- **Boot Partition** 
```bash
n # New partition 
+200M
``` 

- **Swap Partition**
```bash
n # New partition
+2G
t 3 19 # Set type to Linux swap
``` 

- **Gentoo Partition**
```bash
n # New partition 
+20G 
t 
4 
23 # Set type to Linux root
``` 

- **MyLinux Partition**
```bash
n # New partition
(Remaining space)
``` 

### **Save and View Changes**:

```bash
p # Show partition table (take a screenshot)
w # Write changes
fdisk -l /dev/sda # Confirm changes
``` 

![[Pasted image 20240918132409.png]]
## Filesystem Creation and Mounting

### Filesystem Creation

1. **Create Filesystems**:

```bash
mkfs.vfat -F32 /dev/sda1 # UEFI
mkfs.vfat -F32 /dev/sda2 # UEFI
mkfs.ext4 /dev/sda4 # Gentoo, use -T small for many files
mkfs.ext4 /dev/sda5 # My Linux
mkswap /dev/sda3 # Swap
``` 

### Mounting Partitions

1. **Mount the Partitions**:
```bash
mount /dev/sda4 /mnt/gentoo # Gentoo root
mkdir /mnt/gentoo/boot
mount /dev/sda2 /mnt/gentoo/boot # Boot
mkdir /mnt/gentoo/efi
mount /dev/sda1 /mnt/gentoo/efi # UEFI
swapon /dev/sda3 # Enable swap
``` 

## Installing Gentoo Base System

1. **Stage File Transfer** (From Host):
```bash
scp stage3 antoine@VM_IP:/home/antoine
mv /home/antoine/stage3 /mnt/gentoo
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
rm stage3
```

2. **Prepare System for chroot**
```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
``` 

# OS Architecture

## Types of OS

- Multitask , MultiUser
- Single Task

## OS Core Components

- Task Manager
- Memory Manager
- File Manager
- I/O Manager

### OS Functions

- Program Loader
- Virtual Machine (Hides hardware complexity)
- Resource allocation for processes

---

## MINIX Layers Overview

|Layer|Description|
|---|---|
|1|Interrupt handling (ASM) & messaging upper layers (C)|
|2|Device drivers & system tasks|
|1 & 2|Compiled as one binary program|
|3|Memory management|
|4|User processes, Shell|

---

## Linux Kernel Architecture

- **arch**: CPU architecture support.
- **drivers**: Hardware drivers.
- **init**: System initialization.
- **kernel**: Core Linux kernel.
- **block**: Block device layer.
- **fs**: Filesystem layer.
- **mm**: Memory management.
- **net**: Network stack.

### CPU Characteristics

- Each CPU has its own instruction set (e.g., SPARC, Pentium, ARM).
- **Pipeline Mode**: Fetch, decode, execute.
- **Registers & Flags**: Status and control registers (e.g., CR3).
- **Program Counter**: Instruction pointer (IP), Stack pointer.
- **System Calls**: The only way to transition from user mode to kernel mode is via system calls.

### Key Component

- The most important part of Linux is the **`task_struct`**.

```csharp

This structure organizes the content and improves readability for technical users working with virtual machines, operating systems, and Linux installations.

``` 

