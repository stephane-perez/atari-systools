| RAM_SIZE: limit to 2048 KB
	.equ	LIMIT,0x200000
	.macro	SIZE_TXT
	.ascii	"2 MB"
	.endm
	.include	"ram_size.s"
