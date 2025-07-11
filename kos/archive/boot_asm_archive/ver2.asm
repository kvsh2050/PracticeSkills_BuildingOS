org 0x7C00
bits 16


%define ENDL 0x0D, 0x0A


start:
    jmp main


;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret
    
    
disp_heart:
    mov ah, 0x00    ; Set video mode
    mov al, 0x03    ; Mode 3 = 80x25 text mode
    int 0x10
    ret


disp_heart_text:
	;setup the data segments
	mov al , 0x03
	mov ah, 0x0E
	mov bh,0
	int 0x10
    	; i am not gonna do a loop , as it is not printing any string just display
    	ret

disp_graphics:
	;setup video mode 
	push ax
	mov ah, 0x00
	mov al , 0x13
	int 0x10
	;pixel coordinates
	mov al, 0x0F ; colour white
	mov cx, 100
	mov dx, 100
	call draw_pixel
	pop ax
	ret
	
draw_pixel:
	push ax
	mov ah, 0x0C
	int 0x10
	pop ax
	ret 
	

main:
    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downwards from where we are loaded in memory

    ; print hello world message
    mov si, msg_hello
    
    ; pixel puts 
    call puts
    mov si, msg_done
    call puts
    ;call disp_heart
    call disp_graphics
    hlt

.halt:
    jmp .halt



msg_hello: db 'Hello world! Are you ready for it?', ENDL, 0

msg_done: db "Hello, It's me Kavya: Welcome to the OS", ENDL, 0

times 510-($-$$) db 0
dw 0AA55h
