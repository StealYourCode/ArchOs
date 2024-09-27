# Objective

Implement and manage kernel drivers and processes within an operating system.

---

## Drivers

- **Kernel Interaction**: The kernel directly interacts with drivers, which can be either built-in or loadable as modules.

### Driver Management Commands

To manage kernel modules, use the following commands:

```bash
lsmod # List currently loaded modules 
insmod # Install a module 
rmmod # Remove a module
```


### Example Kernel Module (C)

This example demonstrates a simple kernel module written in C.
```C
#include <linux/module.h> 
#include <linux/kernel.h> 

int init_module(){ 
	printk(KERN_INFO "Kernel module initialized"); 
	return 0; 
} 
	
void cleanup_module(){ 
	printk(KERN_INFO "Kernel module removed"); 
}
```

### Makefile:

``` ḿakefile
obj-m += monkernelmodule.ko # Compiles to monkernelmodule.o
```

### Compiling the Driver

```bash
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
# OR if the kernel module is known:
make -C /lib/modules/6.6.1/build M=$(pwd) modules
```

### Testing and Verification

```bash
sudo insmod monkernelmodule.ko 
lsmod | grep monkernelmodule 
sudo dmesg | grep "Kernel module initialized" # Shows the initialization message
```

## Process Types

- **I/O Bound**: Spends most of its time waiting for I/O operations (e.g., text applications). Solution: **Multi-threading**.
- **Compute Bound**: Utilizes the CPU intensively for long computations. Solution: **Multiprocessing**.

### Multi-Process vs Multi-Thread

- Processes compete with the scheduler for CPU time.
- Threads use their scheduling to distribute workload among themselves.

To show thread count for a given process:
``` bash
firefox & ps -o nlwp PROCESS_ID
```

To explore the internal workings of an OS:

``` bash
cd /proc cat cmdline
```

## Scheduling Algorithms

To display processes and their priority numbers:
```bash
top # OR htop
```

1. **PR**: Priority number.
2. **Round Robin**: Used when PR is the same.

Processes are managed by the scheduler, which:

- Chooses a process and allocates CPU time.
- Linux scheduling is preemptive, with dynamic priority and round-robin methods. Note: The Linux kernel was not preemptive before version 2.4.

# LAB

## Verifying Chroot Success

To check if the chroot environment is functioning correctly:

1. Create an SSH connection:
```bash
ssh $USER@IP_GENTOO
```

2. Verify the environment:
```bash
cd /mnt/gentoo 
ls # Should not be empty 
cd /mnt/gentoo # Should fail as it exists only in RAM
```

If you can still access it:
```bash
chroot /mnt/gentoo /bin/bash 
source /etc/profile 
export PS1="(chroot) ${PS1}"
```

### DNS Configuration

To check DNS configuration:
```bash
cd /etc 
cat resolv.conf
```

### Choosing the Right Profile

To select the appropriate profile:
```bash
emerge-webrsync
eselect profile list 
eselect profile set XX # Use the preferred profile number (e.g., 22 for systemd)
```


### Time Zone Configuration

To set the time zone:
```bash
ls -l /usr/share/zoneinfo/Europe/ 
ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime 
cat /etc/localtime # Should show the file in binary
```

## Configure Keyboard

Update locale settings:
```bash
nano /etc/locale.gen # Edit locale file 
# Uncomment 'en' and add 'fr' 
en_US.UTF-8 UTF-8 
fr_BE.UTF-8 UTF-8
```

Verify available locales:
``` bash
eselect locale list # List available locales
```

### Update Environment

```bash
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

### Install Required Packages

```bash
emerge --ask sys-apps/pciutils # Install PCI utilities
emerge --ask sys-apps/usbutils # Install USB utilities
```

## Discover System Information

To discover hardware and required drivers:
```bash
lspci # List PCI devices 
lspci -k # List devices and their kernel drivers 
lsmod # Show loaded modules
```

### Install Kernel Sources

```bash 
emerge --ask sys-kernel/gentoo-sources # Install Gentoo kernel sources
```

#### Installing Software on Linux

1. **Package Manager**: Handles dependencies automatically.
2. **Manual Installation**:
    1. Download sources (e.g., tar.gz).
    2. Extract sources to `/usr/src`.
    3. Create a Makefile with `./configure`.
    4. Compile with `make`.
    5. Install with `sudo make install`.

To compile the kernel:

``` bash
cd /usr/src 
ls # Ensure the Linux source directory is present 
cd linux-xxxx # Navigate to the Linux source directory 
make menuconfig # Configure kernel options
```

**Kernel Configuration Options**

- `y`: Compile directly into the kernel.
- `m`: Compile as a module.

### Example Configuration

Use the Gentoo Handbook for guidance on enabling necessary options in `menuconfig`:

### Compilation Commands

```bash
make -j2 # Use 2 cores for compilation 
make && make modules_install # Compile and install the modules 
date ; make -j2 && make modules install; date # Show time before and after compilation
```

