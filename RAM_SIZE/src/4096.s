| RAM_SIZE: limit to 4096 KB
	.equ	LIMIT,0x400000
	.macro	SIZE_TXT
	.ascii	"4 MB"
	.endm
	.include	"ram_size.s"
