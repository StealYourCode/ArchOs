
2024-10-01 - 08:31

# Objective
Theory : Memory Managements
Labs :  Configuring booting

---

### **Summary of Key Concepts**

1. **Task State Segment (TSS)**: Used for storing process states during task switches.
2. **CR3 Register**: Holds the physical address of the page directory base.
3. **Paging**: Divides memory into pages and uses page tables to map virtual memory to physical memory.
4. **Segmentation**: Although less used, segmentation is still crucial for memory protection and task management.
5. **Page Replacement Algorithms**: NRU and WSClock are common strategies used to manage page faults and memory allocation.
6. **Memory Allocation**: First Fit, Next Fit, and Best Fit are strategies for managing memory blocks.
7. **Virtual Memory**: Allows processes to use more memory than is physically available through swapping and paging.

### Process Management (from last lesson)

In the `task_struct` structure of a process, there is the notion of a **Task State Segment (TSS)**.

- **TSS**: A memory area in the kernel that stores information critical for managing context switching between processes.
    - When a process is scheduled to run, the information stored in the TSS helps the OS restore the environment of that process.
    - The TSS includes registers, flags, the instruction pointer (EIP), and the stack pointer.

### Virtual Addressing of a Process

Virtual addressing is the method used to access memory in modern operating systems. It allows each process to have its own virtual memory space, isolating it from other processes and enhancing security and stability.

- When a **fork** system call is made, it creates a new process. The new process is a copy of the calling process but has its own address space.

---

![[Pasted image 20241001100403.png]]

### Memory Management

#### **Key Concepts of Pagination**:

**Pagination** is a memory management technique that translates logical (virtual) memory addresses into physical memory addresses by dividing memory into fixed-size blocks called **pages** and **frames**.

1. **Pages and Frames**:
    
    - **Pages**: Fixed-size blocks that make up the virtual memory address space.
    - **Frames**: Fixed-size blocks that make up physical memory.
2. **Page Table**:
    
    - A data structure that maps virtual pages to physical frames. The OS consults this table to translate virtual addresses into physical ones.
3. **Virtual Memory**:
    
    - This is the abstraction where processes can use more memory than is physically available by paging sections of memory in and out of the disk.
4. **Translation Lookaside Buffer (TLB)**:
    
    - A special cache used to store recent translations from virtual addresses to physical addresses, speeding up memory access.
5. **Page Fault**:
    
    - A page fault occurs when a process tries to access a page that is not currently in memory. The OS will then load the required page from disk into memory.

---

### **CR3 and Page Tables**

- The **CR3 register** in Intel architectures holds the physical address of the **page directory base**. It is crucial for paging, as it allows the operating system to find the page tables.
- When a process is scheduled, the OS loads the page directory base address into CR3, enabling memory access for that specific process. CR3 is also involved in **TLB flushing** during context switches.

---

### **Segmentation**

**Segmentation** divides memory into different segments such as code, data, and stack, each of which can grow independently. While segmentation is less common in modern systems that rely more on paging, it's still used in task management.

1. **Task State Segment (TSS)**:
    
    - Saves the environment during a task switch (CS, EIP, Eflags, etc.).
    - The **TR register** identifies the active TSS.
2. **Segment Descriptor**:
    
    - Contains information about the segment, such as base address, limit, and access rights (code or data).

---

### Memory Management Techniques

#### **Free Space Memory Management**

1. **Bitmap**:
    
    - A bitmap is a continuous list of `1`s and `0`s, where `1` means that the space is used and `0` means it's free. The OS can quickly check the bitmap to find available memory blocks, though it can be slow for large memory spaces.
2. **Linked List**:
    
    - In a linked list-based memory management system, each memory block points to the next, allowing dynamic allocation and deallocation of memory. However, this approach can suffer from fragmentation.

---

### **Memory Allocation Strategies**

- **First Fit**: Scans memory and allocates the first free block large enough for the process.
- **Next Fit**: Similar to First Fit, but starts from the last allocated block.
- **Best Fit**: Searches for the smallest block that is large enough, minimizing wasted space.

---

### **Page Replacement Algorithms**

In virtual memory, when physical memory is full, the OS needs to decide which page to replace. Common algorithms include:

1. **Not Recently Used (NRU)**:
    
    - Uses reference and modification bits to classify pages into four categories:
        1. Not referenced, not modified.
        2. Not referenced, modified.
        3. Referenced, not modified.
        4. Referenced, modified.
2. **WSClock (Working Set Clock)**:
    
    - Combines the **working set** concept with a **clock** replacement mechanism. It uses a circular list of pages and selects pages based on reference and modification history.
3. **Optimal Page Replacement**:
    
    - Theoretically, removes the page that will not be used for the longest time in the future. Though impossible to implement, it serves as a benchmark for other algorithms.

---

### **Intel Paging**

Paging in Intel systems is essential for efficient memory management. Memory is divided into 4KB pages, and the system keeps track of pages through **page tables**.

1. **Page Tables and Page Directories**:
    
    - The CR3 register stores the base address of the page directory, which contains pointers to page tables.
    - Each page table entry contains the physical address of a page, access permissions, and a "present" bit indicating whether the page is in memory or on disk.
2. **Multilevel Page Tables**:
    
    - To manage large memory efficiently, Intel uses **multilevel page tables**. For example, in 32-bit systems, virtual addresses are split into **directory, middle, page, and offset** fields.

---

### **Virtual Memory**

Virtual memory provides the illusion of a large address space by using both RAM and disk storage. Each process has its own **page table** that maps virtual addresses to physical memory or the swap space.

1. **Address Translation**:
    
    - The **MMU (Memory Management Unit)** translates virtual addresses to physical addresses using the page tables.
    - If a page is not in memory, a **page fault** occurs, and the OS loads the page from disk.
2. **Page Fault Handling**:
    
    - The OS responds to page faults by:
        - Determining the virtual address that caused the fault.
        - Finding the needed page on disk.
        - Using a page replacement algorithm to decide which page to remove if memory is full.
## LABOS


#### CMD:
1. ssh
2. chroot
3. cd /usr/src/linux*

NEED TO CHANGE 3 OPTIONS IN MAKE MENUCONFIG:

-> EFI_STUB -> EFI_STUB_SUPPORT (Remove \*)
-> Handover (Remove \*)
-> GraphicSupport -> Frame_BUFFER () -> EFI-based FrameBuffer (support) (\*)

Exit and then make -j2

install kernel from gentoo handbook

`emerge sys-kernel/installkernel`

`emerge dracut`

nano /usr/lib/kernel/install.conf
```
laytout=grub
initrd_generator=dracut
uki_generator=none
```

make install

cd /boot
ls # Allow to check if the boot was configured properly

cd  /etc
nano fstab
```txt
/dev/sda4     /    ext4       defaults,noatime 0,1
/dev/sda3     none swap       sw               0,0

```

hostnamectl $NAME
echo $NAME > /etc/hostname

emerge dhcpcd
passwd \#PASSWORD
cat /etc/shadow => To check if root has password now

echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
`emerge sys-boot/grub`


`grub-install --target=x86_64-efi --efi-directory=/efi --removable`
cd /boot/grub
ls => To check if everything works
`grub-mkconfig -o /boot/grub/grub.cfg`

IF PREVIOUS CMD DIDN'T DETECT THE KERNEL :
cp /usr/src/linux-6.6.52-gentoo/arch/x86/boot/bzimage /boot/kernel-6.6.52-$NAME
uname -a => Version

cat /boot/grub/grub.cfg => Should have an entry "linux /kernel-6.6.52-gentoo root=UUID=312ea640-b1f5-4a99-bc3d-3da431d48fc9 "

`exit` from chroot
`cd`
`umount -l /mnt/gentoo/dev{/shm,/pts,}`
`umount -R /mnt/gentoo`
`reboot`

Boot should allow to choose gentoo

## Projet

Install busybox & kernel with right version

Create FHS with mkdir

Extract file .gz for GlibC
Extract files for busybox

Create file passwd
Create file for fstab

busybox to configure keyboard

Create a script to boot
Create a file inittab

For Kernel:
Create .config file

Use Grub to configure boot
