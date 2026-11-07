| RAM_SIZE : limite a 512 Ko
	.equ	LIMIT,0x080000
	.macro	SIZE_TXT
	.ascii	"\253Mo"
	.endm
	.include	"ram_size.s"
