; long_mode.asm

org 0x7E00


[BITS 16]
start:
        mov si, real_msg
        call print16

        ; Kernel ya cargado a 0x8000
        ; Pasa a modo largo
        cli

        lgdt [gdt_descriptor16]

        mov eax, cr0
        or eax, 1
        mov cr0, eax
        
        jmp 0x08:protected_mode_entry

print16:
        mov ah, 0x0E
.loop:
        lodsb
        or al, al
        jz .end
        int 0x10
        jmp .loop
.end:
        ret

; |======================|
; |   PROTECTED MODE     |
; |======================|

[BITS 32]
protected_mode_entry:
        mov ax, 0x10
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax
        mov esp, 0x9000

        mov esi, prot_msg
        call print32
        
        ; todo en modo protegido
        ; cargamos gdt de 64 bits
        lgdt [gdt_descriptor]

        mov ax, 0x10
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax
        ; gdt de 64 bits cargado
        
        ; activamos el PAE
        mov eax, cr4
        or eax, 1 << 5
        mov cr4, eax

        mov ecx, 0xC0000080
        rdmsr
        or eax, 1 << 8
        wrmsr

        call setup_paging

        mov eax, pml4_table
        mov cr3, eax

        mov eax, cr0
        or eax, 0x80000001
        mov cr0, eax

        jmp 0x08:long_mode_entry

print32:
        mov edi, 0xB8000
        mov ah, 0x0F
.loop:
        lodsb
        or al, al
        jz .end
        stosw
        jmp .loop
.end:
        ret

print32_char:
        mov edi, 0xB8000
        mov ah, 0x0F
        stosw
        ret
                
setup_paging:
        mov eax, pdpt_table
        or eax, 0x03
        mov [pml4_table], eax

        mov eax, pd_table
        or eax, 0x03
        mov [pdpt_table], eax

        mov eax, 0x00000083
        mov [pd_table], eax

        ret

; |======================|
; |      LONG MODE       |
; |======================|

[BITS 64]
long_mode_entry:
        ; Salta al kernel en 0x8000

        mov rsi, long_msg
        call print64
        
        mov rax, 0x8100
        call rax
        ; jmp 0x8000
        ; hlt
        ; jmp $

print64:
        mov edi, 0xB8000
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
gdt_start16:
        dq 0
        dq 0x00CF9A000000FFFF
        dq 0x00CF92000000FFFF
gdt_end16:

gdt_descriptor16:
        dw gdt_end16 - gdt_start16 - 1
        dd gdt_start16

gdt_start:
        dq 0
        dq 0x00AF9A000000FFFF
        dq 0x00AF92000000FFFF
gdt_end:

gdt_descriptor:
        dw gdt_end - gdt_start - 1
        dq gdt_start

real_msg db "Mode Real.", 0
prot_msg db "Modo Protegido.", 0
long_msg db "Modo Largo.", 0

section .bss
align 4096
pml4_table:
        resq 512

align 4096
pdpt_table:
        resq 512

align 4096
pd_table:
        resq 512

