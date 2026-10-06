# ============================================================
#  ArrOS - Makefile maestro
#  Compila boot.asm, loader.asm y todo el kernel en C,
#  y arma la imagen de disco final (disk.img)
# ============================================================

CC      = gcc
CFLAGS  = -m32 -ffreestanding -fno-pie -fno-stack-protector -fno-builtin -Wall -Wextra
LD      = ld
NASM    = nasm
QEMU    = qemu-system-i386

KERNEL_SRCS_C   = kernel/kernel.c kernel/screen.c kernel/gdt.c kernel/idt.c \
                  kernel/pic.c kernel/keyboard.c kernel/serial.c
KERNEL_SRCS_ASM = kernel/entry.asm kernel/gdt_flush.asm kernel/idt_flush.asm kernel/isr_stubs.asm

KERNEL_OBJS = $(KERNEL_SRCS_C:.c=.o) $(KERNEL_SRCS_ASM:.asm=.o)

KERNEL_SECTORS = 64   # debe coincidir con KERNEL_SECTORS en boot/boot.asm

all: disk.img

# --- Boot sector y loader (ensamblador puro) ---
boot/boot.bin: boot/boot.asm
	$(NASM) -f bin boot/boot.asm -o boot/boot.bin

boot/loader.bin: boot/loader.asm
	$(NASM) -f bin boot/loader.asm -o boot/loader.bin

# --- Objetos del kernel en C ---
kernel/%.o: kernel/%.c
	$(CC) $(CFLAGS) -c $< -o $@

kernel/%.o: kernel/%.asm
	$(NASM) -f elf32 $< -o $@

# --- Enlazado + extracción a binario plano ---
kernel/kernel.elf: $(KERNEL_OBJS) kernel/link.ld
	$(LD) -m elf_i386 -T kernel/link.ld -o kernel/kernel.elf $(KERNEL_OBJS)

kernel/kernel.bin: kernel/kernel.elf
	objcopy -O binary kernel/kernel.elf kernel/kernel.bin

# --- Imagen de disco final: boot + loader + kernel (relleno a tamaño fijo) ---
disk.img: boot/boot.bin boot/loader.bin kernel/kernel.bin
	python3 -c "\
data = open('kernel/kernel.bin','rb').read(); \
pad = $(KERNEL_SECTORS)*512 - len(data); \
assert pad >= 0, 'el kernel creció más de lo reservado, sube KERNEL_SECTORS'; \
open('kernel/kernel_padded.bin','wb').write(data + b'\x00'*pad)"
	cat boot/boot.bin boot/loader.bin kernel/kernel_padded.bin > disk.img

run: disk.img
	$(QEMU) -fda disk.img

clean:
	rm -f boot/*.bin kernel/*.o kernel/*.elf kernel/*.bin kernel/kernel_padded.bin disk.img

.PHONY: all run clean
