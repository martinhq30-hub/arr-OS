; ============================================================
;  ArrOS - loader.asm
;
;  Stub mínimo que hace la transición de modo real a modo
;  protegido, y luego transfiere el control al kernel en C
;  (ya cargado por boot.asm en la dirección física 0x20000).
; ============================================================

[BITS 16]
[ORG 0x0000]

KERNEL_PHYS equ 0x10000   ; dirección física donde boot.asm cargó ESTE archivo
KERNEL_C    equ 0x20000   ; dirección física donde boot.asm cargó el kernel en C

inicio:
    mov ax, cs
    mov ds, ax
    mov es, ax

    mov si, msg_loader
    call imprimir

    cli

    ; Habilitar línea A20 (método rápido, puerto 0x92)
    in al, 0x92
    or al, 2
    out 0x92, al

    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp dword CODE_SEG:(KERNEL_PHYS + modo_protegido_inicio)

imprimir:
    push ax
    push bx
.siguiente_char:
    lodsb
    cmp al, 0
    jz .fin_imprimir
    mov ah, 0x0E
    mov bx, 0x07
    int 0x10
    jmp .siguiente_char
.fin_imprimir:
    pop bx
    pop ax
    ret

msg_loader db 13, 10, "ArrOS: activando A20, GDT y modo protegido...", 13, 10, 0

gdt_inicio:
gdt_null:
    dq 0x0000000000000000
gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_fin:

gdt_descriptor:
    dw gdt_fin - gdt_inicio - 1
    dd KERNEL_PHYS + gdt_inicio

CODE_SEG equ gdt_code - gdt_inicio
DATA_SEG equ gdt_data - gdt_inicio

[BITS 32]
modo_protegido_inicio:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Transferir el control al kernel en C.
    ; OJO: "jmp KERNEL_C" a secas se ensamblaría como un salto
    ; RELATIVO (NASM calcularía el desplazamiento asumiendo que
    ; este archivo vive en la dirección 0, por el [ORG 0x0000]).
    ; Como KERNEL_C es una dirección física absoluta ya conocida,
    ; usamos un salto indirecto por registro: carga el valor exacto
    ; en EAX y salta ahí, sin ningún cálculo relativo de por medio.
    mov eax, KERNEL_C
    jmp eax

    times 2048-($-$$) db 0
