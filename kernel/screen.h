#ifndef SCREEN_H
#define SCREEN_H

#include "types.h"

void screen_clear(void);
void screen_putc(char c);
void screen_puts(const char *s);
void screen_put_hex(u32 valor);

#endif
