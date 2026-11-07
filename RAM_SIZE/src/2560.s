| RAM_SIZE: limit to 2560 KB
	.equ	LIMIT,0x280000
	.macro	SIZE_TXT
	.ascii	"2.5 MB"
	.endm
	.include	"ram_size.s"
