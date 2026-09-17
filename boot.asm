; ============================================================
;  ArrOS - boot.asm
;  Sector de arranque (MBR) - Capítulo 1: mostrar un mensaje
;
;  Basado en el tutorial de desarrollo de kernels de "Pépin"
;  (osdev / gaby), adaptado y comentado en español para ArrOS.
; ============================================================

[BITS 16]           ; le decimos a NASM que trabajamos en modo real, 16 bits
[ORG 0x0]            ; el offset se calcula manualmente al inicializar ds/es

; ------------------------------------------------------------
; Inicialización de segmentos
; La BIOS carga este sector en la dirección física 0x07C00.
; ------------------------------------------------------------
    mov ax, 0x07C0
    mov ds, ax        ; segmento de datos = 0x07C0 -> dirección física 0x07C00
    mov es, ax

    mov ax, 0x8000
    mov ss, ax         ; segmento de pila
    mov sp, 0xF000     ; la pila crece hacia abajo desde 0x8F000 hasta 0x80000

; ------------------------------------------------------------
; Mostrar el mensaje de bienvenida de ArrOS
; ------------------------------------------------------------
    mov si, msg_bienvenida
    call imprimir

; ------------------------------------------------------------
; Bucle infinito: por ahora no hacemos nada más
; ------------------------------------------------------------
fin:
    jmp fin

; --- Datos ---
msg_bienvenida db "ArrOS arrancando... bienvenido!", 13, 10, 0

; ------------------------------------------------------------
; Rutina: imprimir
; Entrada: DS:SI -> apunta a una cadena terminada en 0x0
; Usa el servicio 0x0E de la interrupción 0x10 de la BIOS
; (imprime un carácter en modo teletipo)
; ------------------------------------------------------------
imprimir:
    push ax
    push bx
.siguiente_char:
    lodsb              ; carga [ds:si] en al, e incrementa si
    cmp al, 0          ; ¿llegamos al fin de la cadena (byte 0)?
    jz .fin_imprimir
    mov ah, 0x0E       ; función 0x0E = escribir carácter en modo teletipo
    mov bx, 0x07       ; bx = atributo de color (0x07 = gris claro sobre negro)
    int 0x10
    jmp .siguiente_char
.fin_imprimir:
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; Relleno hasta 510 bytes + firma de sector de arranque
; La BIOS solo reconoce un disco como booteable si sus últimos
; 2 bytes son 0x55 0xAA (firma 0xAA55 en little-endian).
; ------------------------------------------------------------
    times 510-($-$$) db 0x90   ; rellena con NOPs (0x90) hasta el byte 510
    dw 0xAA55                  ; firma de arranque
