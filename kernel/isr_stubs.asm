[BITS 32]
global irq1_stub
extern teclado_interrupcion

; Cuando llega la interrupción 0x21 (IRQ1, teclado), el procesador
; salta aquí automáticamente (porque así lo registramos en la IDT).
irq1_stub:
    pusha                   ; guarda todos los registros de propósito general
    call teclado_interrupcion
    popa                    ; los restaura
    iretd                   ; retorno especial de interrupción (restaura CS,EIP,EFLAGS)
