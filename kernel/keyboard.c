#include "keyboard.h"
#include "io.h"
#include "pic.h"
#include "screen.h"
#include "serial.h"

#define PUERTO_DATOS_TECLADO 0x60

/* Tabla de traducción scancode -> ASCII (Set 1, distribución US,
 * solo minúsculas por simplicidad). El índice es el scancode que
 * entrega el controlador de teclado; 0 significa "tecla sin
 * carácter imprimible" (Shift, Ctrl, flechas, F1-F12, etc). */
static const char tabla_scancode[128] = {
    0,  27, '1','2','3','4','5','6','7','8','9','0','-','=','\b',
    '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',
    0, /* Ctrl izquierdo */
    'a','s','d','f','g','h','j','k','l',';','\'','`',
    0, /* Shift izquierdo */
    '\\','z','x','c','v','b','n','m',',','.','/',
    0, /* Shift derecho */
    '*',
    0, /* Alt */
    ' ', /* barra espaciadora */
    0 /* resto: Caps Lock, F1-F12, etc -- no los usamos */
};

void teclado_interrupcion(void)
{
    u8 scancode = inb(PUERTO_DATOS_TECLADO);

    /* El bit más alto (0x80) indica que la tecla se SOLTÓ, no que
     * se presionó. Por ahora solo nos interesa cuando se presiona. */
    if (!(scancode & 0x80)) {
        if (scancode < 128) {
            char c = tabla_scancode[scancode];
            if (c != 0) {
                screen_putc(c);
                serial_putc(c);   /* también la mandamos por COM1, útil para depurar */
            }
        }
    }

    pic_enviar_eoi(1);   /* avisarle al PIC que ya atendimos la IRQ1 */
}
