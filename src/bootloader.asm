; bootloader.asm
org 0x7C00

%define KERNEL_SECTORS 11

start:
        xor ax, ax
        mov es, ax
        mov ss, ax
        mov ds, ax
        mov sp, 0x7C00
        
        mov si, dap
        mov ah, 0x42
        mov dl, 0x80
        int 0x13
        jc error
        
        mov si, dap2
        mov dl, 0x80
        mov ah, 0x42
        int 0x13
        jc kernel_no_load

        jmp 0x0000:0x7E00

error:
        mov si, fallo
        call print
        
        cli
        hlt
        jmp $
        
kernel_no_load:
        mov si, kernel_error_msg
        call print

        cli
        hlt
        jmp $


print:
        mov ah, 0x0E
        lodsb
        or al, al
        jz .fin
        int 0x10
        jmp print
.fin:
        ret

fallo db "Error al leer disco.", 0
kernel_error_msg db "El kernel no se cargo.", 0

dap:
        db 0x10
        db 0
        dw 1
        dw 0x7E00
        dw 0x0000
        dq 1
        
dap2:
        db 0x10
        db 0
        dw KERNEL_SECTORS
        dw 0x8100
        dw 0x0000
        dq 3


times 510 - ($-$$) db 0
dw 0xAA55
