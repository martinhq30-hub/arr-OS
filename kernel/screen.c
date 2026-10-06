#include "screen.h"
#include "types.h"

#define VIDEO_MEM   ((u16*)0xB8000)
#define COLUMNAS    80
#define FILAS       25
#define ATRIBUTO    0x0F   /* blanco brillante sobre negro */

static int cursor_fila = 0;
static int cursor_col  = 0;

static void desplazar_pantalla(void)
{
    u16 *video = VIDEO_MEM;
    int i;

    /* Mueve cada fila una posición hacia arriba */
    for (i = 0; i < (FILAS - 1) * COLUMNAS; i++)
        video[i] = video[i + COLUMNAS];

    /* Limpia la última fila */
    for (i = (FILAS - 1) * COLUMNAS; i < FILAS * COLUMNAS; i++)
        video[i] = (ATRIBUTO << 8) | ' ';

    cursor_fila = FILAS - 1;
}

void screen_clear(void)
{
    u16 *video = VIDEO_MEM;
    int i;
    for (i = 0; i < COLUMNAS * FILAS; i++)
        video[i] = (ATRIBUTO << 8) | ' ';
    cursor_fila = 0;
    cursor_col = 0;
}

void screen_putc(char c)
{
    u16 *video = VIDEO_MEM;

    if (c == '\n') {
        cursor_col = 0;
        cursor_fila++;
    } else if (c == '\r') {
        cursor_col = 0;
    } else if (c == '\b') {
        if (cursor_col > 0) {
            cursor_col--;
            video[cursor_fila * COLUMNAS + cursor_col] = (ATRIBUTO << 8) | ' ';
        }
    } else {
        video[cursor_fila * COLUMNAS + cursor_col] = (ATRIBUTO << 8) | (u8)c;
        cursor_col++;
        if (cursor_col >= COLUMNAS) {
            cursor_col = 0;
            cursor_fila++;
        }
    }

    if (cursor_fila >= FILAS)
        desplazar_pantalla();
}

void screen_puts(const char *s)
{
    while (*s)
        screen_putc(*s++);
}

void screen_put_hex(u32 valor)
{
    const char *hexd = "0123456789ABCDEF";
    int i;
    screen_puts("0x");
    for (i = 28; i >= 0; i -= 4)
        screen_putc(hexd[(valor >> i) & 0xF]);
}
