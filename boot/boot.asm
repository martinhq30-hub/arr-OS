; ============================================================
;  ArrOS - boot.asm  (Capítulo V: arrancador final)
;
;  Ahora carga DOS programas desde el disco:
;    1) loader.bin -> 0x10000  (stub de paso a modo protegido)
;    2) kernel.bin -> 0x20000  (nucleo real, escrito en C)
;  y salta al loader, que luego saltará al kernel en C.
; ============================================================

[BITS 16]
[ORG 0x0]

LOADER_SEG      equ 0x1000
LOADER_OFF      equ 0x0000
LOADER_SECTORS  equ 4          ; sectores 2-5

KERNEL_SEG      equ 0x2000
KERNEL_OFF      equ 0x0000
KERNEL_SECTORS  equ 64         ; sectores 6-69 (32 KB, de sobra para el kernel en C)

    mov ax, 0x07C0
    mov ds, ax
    mov es, ax

    mov ax, 0x8000
    mov ss, ax
    mov sp, 0xF000

    mov [unidad_arranque], dl

    mov si, msg_cargando
    call imprimir

; ------------------------------------------------------------
; 1) Cargar el loader (stub de modo protegido) en 0x10000
; ------------------------------------------------------------
    mov ax, LOADER_SEG
    mov es, ax
    mov bx, LOADER_OFF

    mov ah, 0x02
    mov al, LOADER_SECTORS
    mov ch, 0
    mov cl, 2                  ; empieza justo después del boot sector
    mov dh, 0
    mov dl, [unidad_arranque]
    int 0x13
    jc disco_error

; ------------------------------------------------------------
; 2) Cargar el kernel en C en 0x20000
; ------------------------------------------------------------
    mov ax, KERNEL_SEG
    mov es, ax
    mov bx, KERNEL_OFF

    mov ah, 0x02
    mov al, KERNEL_SECTORS
    mov ch, 0
    mov cl, 2 + LOADER_SECTORS ; empieza justo después del loader
    mov dh, 0
    mov dl, [unidad_arranque]
    int 0x13
    jc disco_error

    mov si, msg_ok
    call imprimir

    jmp LOADER_SEG:LOADER_OFF   ; transferir el control al loader

disco_error:
    mov si, msg_error
    call imprimir
.detener:
    jmp .detener

; --- Datos ---
unidad_arranque db 0
msg_cargando    db "ArrOS: cargando loader y kernel desde disco...", 13, 10, 0
msg_ok          db "ArrOS: todo cargado. Iniciando...", 13, 10, 0
msg_error       db "ArrOS: ERROR al leer el disco!", 13, 10, 0

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

    times 510-($-$$) db 0x90
    dw 0xAA55
