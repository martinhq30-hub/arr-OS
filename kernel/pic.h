#ifndef PIC_H
#define PIC_H

#define PIC1_OFFSET 0x20   /* IRQ 0-7  -> interrupciones 0x20-0x27 */
#define PIC2_OFFSET 0x28   /* IRQ 8-15 -> interrupciones 0x28-0x2F */

void pic_remap(void);
void pic_enviar_eoi(unsigned char irq);

#endif
