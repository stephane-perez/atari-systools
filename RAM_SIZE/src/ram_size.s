| RAM_SIZE - limits the ST-RAM size of an Atari ST/STE/TT/Falcon
|
| Based on MEMLIMIT (1997). One executable per memory limit.
|
| How it works:
|   1. if phystop is already <= LIMIT, quit (nothing to do, or the limit is
|      impossible: memory cannot be "added");
|   2. otherwise display the message, flush the keyboard buffer and wait
|      for a key;
|   3. write LIMIT to phystop and jump to the TOS reset vector.
|      As memvalid/memval2 (and memval3 on TOS >= 2) are still valid, this
|      warm reset does not size the memory again: TOS keeps phystop as is
|      and puts the screen just below it.
|
| This file is not assembled on its own: it is included by a configuration
| file (512.s, 1024.s, ...) which defines:
|   LIMIT       memory size in bytes
|   SIZE_TXT    macro emitting the size text (e.g. "1 MB")
|
| Assembler: GNU as (m68k binutils), Motorola syntax. See the Makefile.

	.equ	phystop,	0x42e		| end of ST-RAM
	.equ	memtop,		0x436		| end of TPA

	.text

| --- GEMDOS program header (28 bytes) -----------------------------------
header:
	.word	0x601a				| ph_branch
	.long	text_end - text_start		| ph_tlen
	.long	0				| ph_dlen
	.long	0				| ph_blen
	.long	0				| ph_slen
	.long	0				| ph_res1
	.long	0				| ph_prgflags
	.word	0xffff				| ph_absflag: no relocation

| --- Code ---------------------------------------------------------------
text_start:
	pea	check(pc)
	move.w	#38,-(sp)			| Supexec(check)
	trap	#14
	addq.l	#6,sp

	move.w	need_reset(pc),d0
	beq.s	quit				| already <= LIMIT: nothing to do

	pea	msg_info_reset(pc)
	move.w	#9,-(sp)			| Cconws
	trap	#1
	addq.l	#6,sp

flush:						| flush the keyboard buffer
	move.w	#11,-(sp)			| Cconis
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	beq.s	wait_key
	move.w	#7,-(sp)			| Crawcin
	trap	#1
	addq.l	#2,sp
	bra.s	flush

wait_key:
	move.w	#7,-(sp)			| Crawcin: wait for a key
	trap	#1
	addq.l	#2,sp

	pea	do_reset(pc)
	move.w	#38,-(sp)			| Supexec(do_reset), never returns
	trap	#14

quit:
	clr.w	-(sp)				| Pterm0
	trap	#1

| --- Supervisor routines ------------------------------------------------

| need_reset = (phystop > LIMIT)
check:
	lea	need_reset(pc),a0
	clr.w	(a0)
	cmp.l	#LIMIT,(phystop).w
	bls.s	1f
	st	(a0)
1:	rts

do_reset:
	move.w	#0x2700,sr			| mask interrupts
	move.l	#LIMIT,(phystop).w
	move.l	#LIMIT-0x8000,(memtop).w	| recomputed by TOS at boot
	move.l	(4).w,a0			| reset vector (ROM)
	jmp	(a0)

need_reset:
	.word	0

| --- Text (Atari character set) -----------------------------------------
| \033E clears the screen

msg_info_reset:
	.ascii	"\033E\r\nYour machine will be limited to "
	SIZE_TXT
	.ascii	"\r\n\r\nPress any key to reboot\r\n"
	.byte	0

	.balign	2
text_end:
