[BITS 32]
global idt_flush

; void idt_flush(u32 direccion_idt_ptr);
idt_flush:
    mov eax, [esp+4]
    lidt [eax]
    ret
