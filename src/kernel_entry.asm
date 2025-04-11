; kernel_entry.asm
; Carga en kernel.c

[BITS 64]
section .text
[global _start]

_start:
        mov rsp, stack_top
        xor rbp, rbp

        mov rsi, msg
        call print

        ; main() del kernel.c
        extern kernel
        call kernel

.hang:
        hlt
        jmp $

print:
        mov rdi, 0xB8000
        mov ah, 0x0F
.loop:
        lodsb
        or al, al
        jz .end
        stosw
        jmp .loop
.end:
        ret

section .data
msg db "Hola xd", 0

section .bss
align 16
stack_bottom:
        resb 4096
stack_top:
