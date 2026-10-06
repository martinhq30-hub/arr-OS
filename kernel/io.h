#ifndef IO_H
#define IO_H

#include "types.h"

/* Lee un byte desde un puerto de E/S */
static inline u8 inb(u16 puerto)
{
    u8 valor;
    __asm__ volatile ("inb %1, %0" : "=a"(valor) : "Nd"(puerto));
    return valor;
}

/* Escribe un byte en un puerto de E/S */
static inline void outb(u16 puerto, u8 valor)
{
    __asm__ volatile ("outb %0, %1" : : "a"(valor), "Nd"(puerto));
}

#endif
