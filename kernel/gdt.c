#include "gdt.h"

#define NUM_ENTRADAS_GDT 3

static struct gdt_entry gdt[NUM_ENTRADAS_GDT];
static struct gdt_puntero gdt_ptr;

/* Definida en gdt_flush.asm: carga la GDT con LGDT y recarga
 * todos los registros de segmento (incluido CS, con un salto). */
extern void gdt_flush(u32 direccion_gdt_ptr);

static void gdt_set_entry(int indice, u32 base, u32 limite, u8 acceso, u8 flags)
{
    gdt[indice].base_baja        = (base & 0xFFFF);
    gdt[indice].base_media       = (base >> 16) & 0xFF;
    gdt[indice].base_alta        = (base >> 24) & 0xFF;

    gdt[indice].limite_bajo      = (limite & 0xFFFF);
    gdt[indice].flags_limite_alto = ((limite >> 16) & 0x0F) | (flags & 0xF0);

    gdt[indice].acceso = acceso;
}

void init_gdt(void)
{
    gdt_ptr.limite = (sizeof(struct gdt_entry) * NUM_ENTRADAS_GDT) - 1;
    gdt_ptr.base   = (u32)&gdt;

    gdt_set_entry(0, 0, 0, 0, 0);                       /* descriptor nulo, obligatorio */
    gdt_set_entry(1, 0, 0xFFFFFFFF, 0x9A, 0xC0);         /* segmento de código, plano */
    gdt_set_entry(2, 0, 0xFFFFFFFF, 0x92, 0xC0);         /* segmento de datos, plano */

    gdt_flush((u32)&gdt_ptr);
}
