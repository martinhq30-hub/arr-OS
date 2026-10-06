[BITS 32]
global gdt_flush

; void gdt_flush(u32 direccion_gdt_ptr);
gdt_flush:
    mov eax, [esp+4]    ; el único argumento: puntero a la estructura gdt_puntero
    lgdt [eax]

    mov ax, 0x10        ; selector del segmento de datos (entrada 2 de la GDT: 2*8=0x10)
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x08:.recargar_cs   ; selector del segmento de código (entrada 1: 1*8=0x08)
.recargar_cs:
    ret
