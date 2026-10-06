#include "idt.h"
#include "pic.h"

#define NUM_ENTRADAS_IDT 256

static struct idt_entry idt[NUM_ENTRADAS_IDT];
static struct idt_puntero idt_ptr;

/* Carga la IDT con LIDT (definida en idt_flush.asm) */
extern void idt_flush(u32 direccion_idt_ptr);

/* Stub de ensamblador para la interrupción de teclado (IRQ1 ->
 * vector 0x21 tras el remapeo del PIC). Definida en isr_stubs.asm */
extern void irq1_stub(void);

void idt_set_entry(int indice, u32 offset, u16 selector, u8 flags)
{
    idt[indice].offset_bajo = offset & 0xFFFF;
    idt[indice].offset_alto = (offset >> 16) & 0xFFFF;
    idt[indice].selector    = selector;
    idt[indice].cero        = 0;
    idt[indice].flags       = flags;
}

void init_idt(void)
{
    int i;

    idt_ptr.limite = (sizeof(struct idt_entry) * NUM_ENTRADAS_IDT) - 1;
    idt_ptr.base   = (u32)&idt;

    /* Primero, todas las entradas en cero (vacías / no presentes) */
    for (i = 0; i < NUM_ENTRADAS_IDT; i++)
        idt_set_entry(i, 0, 0, 0);

    pic_remap();

    /* 0x21 = IRQ1 tras el remapeo. 0x08 = selector de código de
     * nuestra GDT. 0x8E = presente, anillo 0, interrupt gate de 32 bits. */
    idt_set_entry(0x21, (u32)irq1_stub, 0x08, 0x8E);

    idt_flush((u32)&idt_ptr);
}
