org 0x7C00
bits 16

;Define 
%define ENDOL 0x0D, 0x0A

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

    ; Print the message at start
    mov si, msg_boot    ; Move the offset address to si and call the puts_string label or routine
    call puts_string
    mov si, msg_load
    call puts_string

    ; Do nothing till interrupt occurs
    hlt 

.halt:
    ; Infinite loop
    jmp .halt



; Routines 

puts_string:
    ; Push to stack which contents that you modified to be pushed to stack 
    push ax
    push bx
    push si 

    ;Put a loop in order to print the string, the string loops till it encounters "\0" NULL at the end 
.loop:
    lodsb
    or al, al             ; Checks if the ZF is set to 1 , if yes go to done (checks end of string "\0")
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

;Section Data
msg_boot: db "Bootloader is loaded successfully, Hello! by Kavya", ENDOL, 0
msg_load: db "Kernel Loading...", ENDOL, 0

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