| RAM_SIZE: limit to 1024 KB
	.equ	LIMIT,0x100000
	.macro	SIZE_TXT
	.ascii	"1 MB"
	.endm
	.include	"ram_size.s"
