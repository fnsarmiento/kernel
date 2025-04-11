org 0x8100

[BITS 64]

start:
        mov rsi, msg
        call print

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

msg db "Hola pe causa", 0
