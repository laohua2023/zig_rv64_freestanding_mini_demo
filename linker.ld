
#include <Platform_def.h>

/*
OUTPUT_FORMAT("elf64-littleaarch64", "elf64-littleaarch64", "elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
*/

OUTPUT_ARCH( "riscv" )
OUTPUT_FORMAT("elf64-littleriscv")
ENTRY(_start)

SECTIONS {
	. = 0x80000000;
	. = ALIGN(8);
    __text_start = .;
    .text : 
	{ 
		KEEP(*(.text.boot))
		STARTOBJ(.text)
		*(.text) 
	}

	/* shell_cmd_item 保存在这个段 */
    . = ALIGN(8);
    __shell_cmd_list_start = .;
     .ShellCmdList   ALIGN(8)  : { KEEP(*(.ShellCmdList)) }
    __shell_cmd_list_end = .;

	/* resource_item 保存在这个段 */
    . = ALIGN(8);
    __resource_item_start = .;
     .resource_item   ALIGN(8)  : { *(.ResourceList) }
    __resource_item_end = .;

    .rodata ALIGN(8) : {*(.rodata*)} 
    .data   ALIGN(8) : { *(.data) }

    . = ALIGN(8);
    __bss_start = .;
     .bss   ALIGN(8)  : { *(.bss)  *(COMMON) }
    __bss_end = .;

	/* resource 实际保存在这个段 */
    . = ALIGN(8);
	.extdata  ALIGN(8): {*(.extdata*)}

    .got   ALIGN(8) : { *(.got) }

	/* 栈内存，一般放在最后面，不然如果编译器在最末尾添加了其它数据段，可能会导致编译器用0填充此预留空间，造成生成的bin文件体积过 */
	. = ALIGN(16);
	/*. = . + 1M;  4kB of stack memory => 1MB */
	. = . + 1k; /*  4kB of stack memory => 1MB */
	stack_top = .;

	/DISCARD/ : { *(.dynsym) }
	/DISCARD/ : { *(.dynstr*) }
	/DISCARD/ : { *(.dynamic*) }
	/DISCARD/ : { *(.plt*) }
	/DISCARD/ : { *(.interp*) }
	/DISCARD/ : { *(.gnu*) }
	/DISCARD/ : { *(.comment*) }
}

#ifdef TPL
	/* tpl 运行在64kb 的iRam 中，体积不能超了，况且iRam分出来4kb做栈内存了，实际可用的内存就更少了，所以定个58kb的可用内存 */
	ASSERT( (__bss_start - __text_start) < (58*1024), 
	"
	编译出来的 tpl.bin 太大，iRam 装不下了，请编译为 spl => make spl
	");
#endif
