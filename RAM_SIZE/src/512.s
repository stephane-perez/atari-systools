| RAM_SIZE: limit to 512 KB
	.equ	LIMIT,0x080000
	.macro	SIZE_TXT
	.ascii	"512 KB"
	.endm
	.include	"ram_size.s"
