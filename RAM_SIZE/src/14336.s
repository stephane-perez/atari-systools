| RAM_SIZE: limit to 14336 KB
	.equ	LIMIT,0xe00000
	.macro	SIZE_TXT
	.ascii	"14 MB"
	.endm
	.include	"ram_size.s"
