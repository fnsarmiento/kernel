/* linker.ld */
/* OUTPUT_FORMAT(elf64-x86-64) */
ENTRY(_start)

SECTIONS {
  . = 0x0;

  .text : {
    *(.text)
  }

  .rodata : {
    *(.rodata)
  }

  .data : {
    *(.data)
  }

  .bss : {
    *(.bss COMMON)
  }
}
