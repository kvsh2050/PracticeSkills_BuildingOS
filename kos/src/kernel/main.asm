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
    mov si, msg_kernel    ; Move the offset address to si and call the puts_string label or routine
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

;Section Data
msg_kernel: db "Hello World! Kernel", ENDOL, 0

;Inorder to get 512 Bytes of bootloader we add zero padding and at last we add the boot signature
times 510 - ($ -$$) db 0
;dw 0AA55h
