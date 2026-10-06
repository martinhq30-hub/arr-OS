#include "pic.h"
#include "io.h"

#define PIC1_COMANDO 0x20
#define PIC1_DATOS   0x21
#define PIC2_COMANDO 0xA0
#define PIC2_DATOS   0xA1

#define ICW1_INIT    0x10
#define ICW1_ICW4    0x01
#define ICW4_8086    0x01

/* Por defecto, el PIC manda las IRQ 0-7 en los vectores 0x08-0x0F,
 * que son EXACTAMENTE los mismos números que usa la CPU para sus
 * excepciones (0x08 = double fault, etc). Hay que "correrlas" a
 * otro rango (0x20-0x2F) para que no se mezclen. */
void pic_remap(void)
{
    outb(PIC1_COMANDO, ICW1_INIT | ICW1_ICW4);
    outb(PIC2_COMANDO, ICW1_INIT | ICW1_ICW4);

    outb(PIC1_DATOS, PIC1_OFFSET);   /* nuevo offset del PIC maestro */
    outb(PIC2_DATOS, PIC2_OFFSET);   /* nuevo offset del PIC esclavo */

    outb(PIC1_DATOS, 0x04);          /* le dice al maestro que hay un esclavo en IRQ2 */
    outb(PIC2_DATOS, 0x02);          /* le dice al esclavo su identidad (cascada en IRQ2) */

    outb(PIC1_DATOS, ICW4_8086);
    outb(PIC2_DATOS, ICW4_8086);

    /* Máscaras: habilitamos SOLO IRQ1 (teclado). Dejamos IRQ0 (el
     * timer) deshabilitada a propósito, porque todavía no escribimos
     * un manejador para ella -- si se habilitara sin manejador, la
     * CPU terminaría saltando a una entrada vacía de la IDT. */
    outb(PIC1_DATOS, 0xFD);          /* 11111101: solo el bit 1 (IRQ1) en cero = habilitada */
    outb(PIC2_DATOS, 0xFF);          /* todo deshabilitado en el esclavo */
}

void pic_enviar_eoi(unsigned char irq)
{
    if (irq >= 8)
        outb(PIC2_COMANDO, 0x20);    /* EOI (End Of Interrupt) al esclavo */
    outb(PIC1_COMANDO, 0x20);        /* EOI al maestro (siempre hace falta) */
}
