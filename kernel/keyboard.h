#ifndef KEYBOARD_H
#define KEYBOARD_H

/* Llamada desde irq1_stub (ensamblador) cada vez que llega una
 * interrupción de teclado */
void teclado_interrupcion(void);

#endif
