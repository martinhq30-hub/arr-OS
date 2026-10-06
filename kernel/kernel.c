#include "screen.h"
#include "gdt.h"
#include "idt.h"
#include "serial.h"

void kmain(void)
{
    screen_clear();
    serial_init();

    screen_puts("========================================\n");
    screen_puts("   ArrOS - Nucleo en C\n");
    screen_puts("========================================\n\n");

    screen_puts("[1/3] Cargando GDT propia...");
    init_gdt();
    screen_puts(" OK\n");

    screen_puts("[2/3] Cargando IDT y remapeando PIC...");
    init_idt();
    screen_puts(" OK\n");

    screen_puts("[3/3] Habilitando interrupciones...");
    __asm__ volatile ("sti");
    screen_puts(" OK\n\n");

    screen_puts("Listo! Escribe algo en el teclado:\n> ");
    serial_puts("ArrOS kernel iniciado correctamente.\n");

    for (;;) {
        __asm__ volatile ("hlt");
    }
}
