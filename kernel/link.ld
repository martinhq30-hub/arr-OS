ENTRY(_start)

SECTIONS
{
    . = 0x20000;

    .text : {
        *(.text.entry)
        *(.text*)
    }

    .rodata : { *(.rodata*) }
    .data   : { *(.data*) }
    .bss    : { *(COMMON) *(.bss*) }
}
