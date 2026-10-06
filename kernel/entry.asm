[BITS 32]
section .text.entry
global _start
extern kmain

; Este es, literalmente, el primer byte del archivo kernel.bin.
; El loader hace "jmp dword 0x20000" directo hacia aquí.
_start:
    call kmain

.colgar:
    cli
    hlt
    jmp .colgar
