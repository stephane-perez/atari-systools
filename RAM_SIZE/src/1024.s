| RAM_SIZE : limite a 1024 Ko
	.equ	LIMIT,0x100000
	.macro	SIZE_TXT
	.ascii	"1Mo"
	.endm
	.include	"ram_size.s"
