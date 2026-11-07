| RAM_SIZE : limite a 14336 Ko
	.equ	LIMIT,0xe00000
	.macro	SIZE_TXT
	.ascii	"14Mo"
	.endm
	.include	"ram_size.s"
