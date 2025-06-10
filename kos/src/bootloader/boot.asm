org 0x7C00
bits 16

;Define 
%define ENDOL 0x0D, 0x0A

; Start of the floppy boot sector 
jmp short start
nop

;
; FAT12 header
; 

bdb_oem:                    db 'MSWIN4.1'           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
                            db 0                    ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:           db 'NANOBYTE OS'        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes


; Start of code
start:
    jmp main

main:
    ; Initialize 
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp , 0x7C00  ; Set stack pointer to the top of bootloader


    ; Floppy formatting and Read from floppy disk

    mov [ebr_drive_number], dl     ; BIOS stroes the drive number of the hdd or floppy in dl register 
    mov ax, 1                       ; LBA stored in ax
    mov cl , 1
    mov bx, 7E00h
    call disk_read

    ; Print the message at start => check if the floppy one works 
    mov si, msg_boot    ; Move the offset address to si and call the puts_string label or routine
    call puts_string
    mov si, msg_load
    call puts_string


    ; Do nothing till interrupt occurs
    cli
    hlt 


; Routines 

;Print String Routine

puts_string:
    ; Push to stack which contents that you modified to be pushed to stack 
    push ax
    push bx
    push si 

    ;Put a loop in order to print the string, the string loops till it encounters "\0" NULL at the end 
.loop:
    lodsb
    test al, al             ; Checks if the ZF is set to 1 , if yes go to done (checks end of string "\0")
    jz .done 
    ; If not zero then do the below
    mov ah, 0Eh
    mov bh, 0              ; Set page number to 0
    int 10h                ; Call BIOS interrupt to print character in AL
    jmp .loop              ; Jump to loop to print next character

.done:
    pop si
    pop bx
    pop ax
    ret                    ; Return from the puts_string routine

; Disk Read Routine 

lba_to_chs:
    ; Convert LBA to CHS 
    push ax
    push dx

    ; LBA is in ax register dividend = dx:ax : make sure that the dx is 0

    ;Sector = (LBA % (Sectors per Track)) + 1
    xor dx, dx             ; Clear dx to ensure it is 0
    div word [bdb_sectors_per_track]            ;  Temp = LBA / (Sectors per Track) =>  ax, Sector = (LBA % (Sectors per Track)) => dx
    inc dx 
    mov cx, dx                                   ; Store the number of sectors in bios recommeded :   al , but temporarily store it in cx

    ; Header = Temp % (Number of Heads)
    ; Cylinder = Temp / (Number of Heads)
    xor dx, dx
    div word [bdb_heads]                    ;  Temp = LBA / (Number of Heads) =>  ax(Cylinder), Header = Temp % (Number of Heads) => dx(Heads)

    ; Currently:
    ; ax = cylinder
    ; dx = heads
    ; cx = sector

    ; But i want my C,H,S to load into particular registers for BIOS to handle it
    mov dh, dl                        ; so i can clear my dl to load the drive number   ; dh is head!!!
    mov ch, al                        ; Store the lower 8 bit of cylinder number in the ch
    shl ah, 6                         ; Shift left by 6 bits to put upper 2 bits of cylinder in AH and we need to put in the cl ; Cynlinder 10-101010 => 11-000000 = ah
    or cl, ah                         ; Put upper 2 bits of cylinder in CL and add it with the lower 8 bit

    ; We need to store the drive number 
    pop ax              ; pop dx into ax 
    mov dl, al          ; stores the drive number
    pop ax              ; pops ax into ax

    ret

disk_read:
    ; Reads sectors from a disk
    ; Parameters:
    ;   - ax: LBA address
    ;   - cl: number of sectors to read (up to 128)
    ;   - dl: drive number
    ;   - es:bx: memory address where to store read data

    push ax
    push bx
    push cx
    push dx
    push di

    push cx            ; Temporarily save CL (number of sectors to read)
    call lba_to_chs   ; Convert LBA to CHS, modifies cx, dh, ch, cl
    pop ax             ; Restore CL (number of sectors to read) to ax

    mov ah, 02h   ; BIOS function to read sectors
    mov di , 3      ; Retry count (3 attempts)

.retry:
    pusha          ; Save all registers, as BIOS might modify them
    stc
    int 0x13      ; Call BIOS interrupt to read sectors
    jnc .done
    ; Make sure ex and bx is 0 and 7e00 

    ; read failed 
    popa
    call disk_reset  ; Reset the disk and try again
    dec di
    test di, di
    jnz .retry       ; If retry count is not zero, try again, if zero go to fail

.fail:
    jmp floppy_error  ; If all attempts failed, jump to error handling

.done:
    popa
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


disk_reset:
    ; Reset the disk
    pusha
    mov ah, 0x00      ; BIOS function to reset disk
    stc
    int 0x13         ; Call BIOS interrupt to reset disk
    jc floppy_error  ; If carry flag is set, jump to floppy error
    popa
    ret


; Error Routines
floppy_error:
    mov si, msg_read_failed
    call puts_string
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h                     ; wait for keypress
    jmp 0FFFFh:0                ; jump to beginning of BIOS, should reboot -> jumps to bios reboot 

.halt:
    cli                         ; disable interrupts, this way CPU can't get out of "halt" state, this makees device go to the safe state and never do looping.
    hlt                         ; Halt the CPU and wait for an interrupt that never comes as we have disabled the maskable interrupts. (cli + hlt)
    ; after this it halts the cpu and it does not mean it loads the kernel for now


;Section Data
msg_boot: db "Bootloader is loaded successfully, Hello! by Kavya", ENDOL, 0
msg_load: db "Kernel Loading...", ENDOL, 0
msg_read_failed: db "Disk read failed, please check the disk and try again.", ENDOL, 0

;Inorder to get 512 Bytes of bootloader we add zero padding and at last we add the boot signature
times 510 - ($ -$$) db 0
dw 0AA55h


; NOTE:
; 1. The bootloader is loaded at 0x7C00 in memory.
; 2. The bootloader must be exactly 512 bytes in size, including the boot signature at the end. And donot use section .text and .data in bootloader, as it might increase size as the .text and  .data are not placed in memory
; 3. The bootloader must end with the boot signature 0xAA55.
; 4. The bootloader is written in assembly language and uses BIOS interrupts to print messages to the screen.
; 5. The bootloader initializes the data segment and stack segment before executing any code.
; 6. The bootloader contains a simple message printing routine that prints strings to the screen using BIOS interrupt 0x10.
; 7. The bootloader enters an infinite loop after printing the messages, waiting for an interrupt to occur.
; 8. The bootloader is designed to be loaded by a BIOS and executed in real mode.
; 9. The bootloader is written in 16-bit real mode assembly language, which is compatible with the x86 architecture.
; 10. The bootloader is a simple example of how to write a bootloader in assembly language for educational purposes.
; 11. The bootloader does not perform any error handling or advanced features, as it is a basic example.

; FLOPPY DISK AS BOOTING MEDIA
; 1. The bootloader is designed to be loaded from a floppy disk, which is a common booting media for early computers.
; 2. The bootloader is written to the first sector of the floppy disk, which is the boot sector.
; 3. The bootloader is loaded into memory by the BIOS when the computer is powered on or reset.
; 4. The bootloader is executed by the CPU after it is loaded into memory, starting at the address 0x7C00.
; 5. The bootloader is responsible for initializing the system and loading the operating system kernel into memory.
; 6. The bootloader can be used to load other files or programs from the floppy disk, such as a kernel or a second-stage bootloader.
; 7. The floopy disk must be formatted with a file system that the BIOS can read, such as FAT12 or FAT16.
; 8. The flopy disk uses LBA (Logical Block Addressing) to access the sectors on the disk, which is a common method for accessing data on floppy disks.

; LBA is the input value convert to CHS (Cylinder, Head, Sector) format for floppy disks: As it is used in legacy booting OS
;   Temp = LBA / (Sectors per Track)
;   Sector = (LBA % (Sectors per Track)) + 1
;   Head = Temp % (Number of Heads)
;   Cylinder = Temp / (Number of Heads)

; 9. The bootloader can be used to load a kernel or other files from the floppy disk into memory, allowing the system to boot and run an operating system.