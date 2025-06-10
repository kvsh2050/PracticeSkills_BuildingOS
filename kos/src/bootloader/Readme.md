## Registers and BIOS in floppy accessing 

```bash
| Register   | Used For                                            | Set By        | Description                                               |
| ---------- | --------------------------------------------------- | ------------- | --------------------------------------------------------- |
| **AH**     | `0x02` (function number)                            | You (caller)  | Tells BIOS to perform **read sector(s)**                  |
| **AL**     | Number of sectors to read (1–128)                   | You           | Taken from `CL` earlier in your code                      |
| **CH**     | Cylinder number (lower 8 bits)                      | You           | From `lba_to_chs` conversion                              |
| **CL**     | Sector number (bits 0–5) + Cylinder high bits (6–7) | You           | Lower 6 bits = sector number (starts from 1)              |
| **DH**     | Head number                                         | You           | From `lba_to_chs` conversion                              |
| **DL**     | Drive number (`0x00` for floppy, `0x80` HDD)        | BIOS (preset) | Passed through by your code (saved in `ebr_drive_number`) |
| **ES\:BX** | Segment\:Offset where data will be stored           | You           | Set to something like `es=0, bx=0x7E00`                   |


| BIOS `int 13h` Read Sector | Purpose                    | Set In Code? | How                               |
| -------------------------- | -------------------------- | ------------ | --------------------------------- |
| `AH = 0x02`                | Function: read             | ✅            | `mov ah, 0x02`                    |
| `AL = sector count`        | How many to read           | ✅            | `pop ax` (from earlier `push cx`) |
| `CH = cylinder low`        | Cylinder low 8 bits        | ✅            | In `lba_to_chs`                   |
| `CL = sector + cyl_high`   | 6 bits sector + 2 bits cyl | ✅            | In `lba_to_chs`                   |
| `DH = head`                | Head number                | ✅            | In `lba_to_chs`                   |
| `DL = drive`               | Drive number (0x00)        | ✅            | BIOS sets it; you save it         |
| `ES:BX = buffer`           | Where to read data         | ✅            | `mov bx, 0x7E00`; `es=0`          |


| Register | Role                        | Used in...          |
| -------- | --------------------------- | ------------------- |
| `DI`     | Retry counter (3 attempts)  | `disk_read`         |
| `AX`     | LBA address (input)         | Main & `lba_to_chs` |
| `DX`     | Temp for `div` ops          | `lba_to_chs`        |
| `CX`     | Final CHS (output to BIOS)  | `lba_to_chs`        |
| `SI`     | Pointer to strings (puts)   | `puts`              |
| `BX`     | Offset for disk data buffer | `main`, `disk_read` |

```

```bash
+-------------------------------+  0xFFFFF  (1 MB - 1)
|                               |
|       BIOS ROM Code           |  <- BIOS lives in ROM
|        (F0000 - FFFFF)        |
|                               |
+-------------------------------+
|   BIOS Reset Vector (0xFFFF0) |  <- Real mode starts here after reset
|   CS:IP = FFFF:0000           |  => Physical = FFFF0
+-------------------------------+
|       Option ROMs (e.g. VGA)  |  (C0000 - EFFFF, optional)
+-------------------------------+
|                               |
|       Reserved / Unused       |
|                               |
+-------------------------------+
|      Extended BIOS Data       |  (9FC00 - 9FFFF)
+-------------------------------+
|                               |
|        Conventional RAM       |
|      (00000 - 9FBFF, ~640 KB) |
|      -> Bootloader, Stack     |
|      -> Interrupt Vectors     |
|      -> BIOS Data Area (BDA)  |
+-------------------------------+
|      Real Mode IVT (0000:0000)|
|        256 x 4B = 1 KB        |
+-------------------------------+  0x00000
```


### BIOS, Bootloader AND FILESYSTEM

```css
    BIOS ──[raw sector 0]──▶ Bootloader ──[FAT12 file read]──▶ Kernel
```
A Bootloader understands the filesystem first and loads kernel into memory
Typical Boot Flow:

1.  BIOS loads bootloader from sector 0.

2.  Bootloader:

        Parses FAT12 (using hand-written routines or BIOS interrupts).

        Finds kernel.bin file in FAT12.

        Loads kernel.bin into memory at 0x1000 or 0x7E00.

3.  Bootloader jumps to kernel (e.g., jmp 0x1000).

4.  Kernel starts executing from that address.