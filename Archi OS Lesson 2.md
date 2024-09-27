
2024-09-24 - 08:28


# Kernel Version
6.6.7

	Get Kernel Version
``` bash 
ldd --version
``` 
# Busy-box Version
1.33.1

# Objective


---

## Drivers
Kernel -> Drivers (Drivers directly in the kernel) > Load either way
Kernel     -> Needed Drivers import ????
		-> Modules

To get list of driver
```bash
lsmod  
``` 

```bash
lsmod => List of module
insmod => To install module
rmmod => To remove module
``` 

Driver done in C

	monkernelmodule.c
``` C
#include <linux/modele.h>
#include <linux/kernel.h>

int init_module(){
	printk(KERN_INFO "test ecriture module kernel");
	return 0;
}

void cleanup_module(){
	printk(KERN_INFO "Supression module kernel");
}
```

	Makefile
```makefile
obj-m += monkernelmodule.ko # Potentially monkernelmodule.o
```

	Compiling
```bash
make -C /lib/modules/§(uname -r)/build M=$(pwd) modules
OR if kernel module is known
make -C /lib/modules/6.6.1/build M=$(pwd) modules
``` 

	Testing and verifications
```  bash
sudo insmod monkernelmodule.ko
lsmod | grep monkernelmodule.ko
sudo dmesg | grep "test" # Will show the message writen in the kernel modul
```

## Process
- IO BOUND
=> Spend most of it's time idling (text application)
=> Solution Multi Threading

- Compute Bound
=> CPU active most time (Long calculation)
=> Solution is to use multiprocessing


## Multi Process vs Multi Threads
Each process fight with the scheduler to get CPU times

NEED MORE EXPLANATION

Multi Thread will use it's own scheduling to separate the work between all the thread

[More info about thread](https://geeksforgeeks.org)

	Show thread number for a giver process
```bash
firefox &
ps -o nlwp PROCESSID
```

	Show the inner working of an OS in /proc 
```bash
cd /proc
cmdline 
```

## Scheduling Algo

	Show process and priority number
```bash
top
OR
htop
```

1. PR (Priority number)
2. Round Robin (If PR is same)

Process are handle by *schedule*
- Chose a process & give this process the cpu
- Linux choice (Preemptive, Dynamic Priority, Round Robin)
- Linux kernel wasn't Preemptive before 2.4
- Time is divided in *Periods*


Schema : Scheduling in Linux 0.01 (2/3)
Need to be able to explain it without the comment

---
# LABO

## Verify if Chroot was done successfully

	Create ssh connection
``` bash
ssh antoine@IPGENTOO
```

	Verify if everything is good
``` bash
cd /mnt/gentoo
ls # If not empty than it's good and chroot was good
cd mnt/gentoo # It should fail because it only exist in ram and should'nt be accessible because we are chroot
# IF STILL ACCESSIBLE
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```

	check for dhcp configuration
``` bash
nano /etc/resolve.conf
```

	Choose the profile
``` bash
emerge-webrsync
eselect profile list
# Choose Systemd (normaly default)
eselect profile set 22 # If previous step is not systemd
```

	Change Time Zone
``` bash
ls -l usr/share/zoneinfo
ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
cat /etc/localtime
```

	Configure Keyboard
``` bash
nano /etc/locale.gen
```

	Uncomment en and add fr
``` nano
en_US.UTF8 UTF8
fr_BE.UTF8 UTF8
``` 

	Verify if everything is detected
``` bash
eselect locale list
```

``` bash
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

	Install needed packages
``` bash
emerge --ask sys-apps/pciutils
emerge --ask sys-apps/usbutils
```

	Show discoverd info and what drivers are needed for kernem
``` bash
lspci
lspci -k
lsmod
```

	Get Kernel/"noyau" source
``` bash
emerge --ask sys-kernel/gentoo-sources
```


#### Install app on linux
1. Packet manager: manage the dependancy
2. Manually:
	1. Download sources (tar.gz)
	2. Extract sources (/usr/src)
	3. Create a makefile (./configure)
	4. Compile with make (Executables, libs, config, file)
	5. Install with sudo make install (HFS will be updated)


``` bash
cd /usr/src
ls # There should be a linux directory
cd linux-xxxx
make menuconfig
```

menuconfig will ask us to choose between install in kernel, as module or not needed.
The objectif is to create a makefile that will be run after and install the needed drivers


	* Mean the driver will be installed in the kernel
	m Mean it will be install as a modul
``` menuconfig
# GENTOO Handbook give important info about what to enable
GENTOO LINUX => Gentoo drivers options =>  Gentoo linux support
											linux dynamic
										=> Support for init... => Remove opensd
															   => ADD Systemd
				
Device Drivers => Generic Drivers options => Maintain
										  => Automount

			   => SCSI Device support => SCSI Device support
									  => SCSI disk support
				=> Serial ATA and => ATA ACPI Support
									=> SATA Port Multipl
									X
									X
				
				=> SCSI device support => SCSI low level drivers => VMware PVSCI
				
				=> Misc Device => VMWARE VMCI



File Systems => Second extented fs
			=> EXT2
			=> EXT3
			=> EXT4
			=> DOS/FAT/ => NTFS.Read-Write
						=> Vfat 
			=> Pseudo file System => UEFI (from M to *)
								  => /proc file system
								  => Tmpfs Virtual
								  
enable block layer => Partition types => Advance partition selection => EFI GUID


=> Device Drivers => Firmware Drivers => EFI Support => Boot loader control
													=>	EFI Capsule loader
													=>	EFI Run time support
													=>	EFI Run time config


					=> Fusion MPT => Fusion MPT driver for SPI

					=> Graphics support => Frame buffer devices => Support for frame buffer devices drivers => EFI based
```

nano .config will show the result of menuconfig (y => Compile, m => Module).
If that file is copy paste then the config is reproducable


**NEED TO DO SOMETHING WITH THESES CMD**
make -j 2 => Give 2 core for the works
make && make module install => Install config
date | date; make ?? Or something to see the time before and after the cmd

date ; make -j 2 && make module install ; date


after compilation we should have:
bzimage => Which is executable