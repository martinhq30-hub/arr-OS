#ifndef IDT_H
#define IDT_H

#include "types.h"

struct idt_entry {
    u16 offset_bajo;
    u16 selector;
    u8  cero;
    u8  flags;
    u16 offset_alto;
} __attribute__((packed));

struct idt_puntero {
    u16 limite;
    u32 base;
} __attribute__((packed));

void init_idt(void);
void idt_set_entry(int indice, u32 offset, u16 selector, u8 flags);

#endif
