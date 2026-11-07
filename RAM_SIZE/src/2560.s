| RAM_SIZE : limite a 2560 Ko
	.equ	LIMIT,0x280000
	.macro	SIZE_TXT
	.ascii	"2,5Mo"
	.endm
	.include	"ram_size.s"
