#ifndef GDT_H
#define GDT_H

#include "types.h"

/* Una entrada de la GDT ocupa 8 bytes, con los campos repartidos
 * de una forma históricamente rara (herencia del 80286) */
struct gdt_entry {
    u16 limite_bajo;
    u16 base_baja;
    u8  base_media;
    u8  acceso;
    u8  flags_limite_alto;
    u8  base_alta;
} __attribute__((packed));

/* Lo que se le pasa a la instrucción LGDT: tamaño + dirección */
struct gdt_puntero {
    u16 limite;
    u32 base;
} __attribute__((packed));

void init_gdt(void);

#endif
