| RAM_SIZE : limite a 4096 Ko
	.equ	LIMIT,0x400000
	.macro	SIZE_TXT
	.ascii	"4Mo"
	.endm
	.include	"ram_size.s"
