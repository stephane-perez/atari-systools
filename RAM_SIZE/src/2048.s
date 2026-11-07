| RAM_SIZE : limite a 2048 Ko
	.equ	LIMIT,0x200000
	.macro	SIZE_TXT
	.ascii	"2Mo"
	.endm
	.include	"ram_size.s"
