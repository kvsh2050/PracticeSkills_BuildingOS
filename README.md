# 🛠️ PracticeSkills_BuildingOS

## Building an Operating System (OS) on x86-64 Architecture Using QEMU

This project is a hands-on exercise to build a minimal OS and bootloader for the x86-64 architecture. It uses [QEMU](https://www.qemu.org/) as the emulator and `nasm` for assembly.


## Quick Start

### 1. Build the Bootloader

Use `make` to assemble and build:

```bash
$ make
````

This will generate the binary in the `build/` directory.

### 2. Run with QEMU manual 

Navigate into the `build/` directory and run:

```bash
$ cd build
$ qemu-system-x86_64 -fda main_floppy.img
```

This runs the bootloader code inside the QEMU virtual machine.

### 3. Run with Shell Script

1. Install QEMU (and NASM)
2. Clone this repo:

   ```bash
   git clone https://github.com/your-username/PracticeSkills_BuildingOS
   cd PracticeSkills_BuildingOS
   ```
3. Run the provided script:

   ```bash
   sh run.sh
   ```


## Screenshots

My custom bootloader messages:

![Screenshot from 2025-06-05 15-43-39](https://github.com/user-attachments/assets/cb482ac7-adb1-4048-ad9b-04322a59eafb)
![image](https://github.com/user-attachments/assets/676d6a9a-2fbf-4007-8b2c-74a40bae38ca)
![image](https://github.com/user-attachments/assets/43f836c7-9181-4a71-8aac-ed1bbe4cc456)


## Based On

This project is based on the tutorial by **nanobyte-dev**:
👉 [nanobyte\_os GitHub Repo](https://github.com/nanobyte-dev/nanobyte_os)


> ⚙️ Happy Hacking! Build your own bootloader, learn systems programming, and dive deep into the hardware-software boundary.


