| RAM_SIZE - limite la memoire ST-RAM d'un Atari ST/STE/TT/Falcon
|
| Inspire de MEMLIMIT (1997). Un executable par limite memoire.
|
| Principe :
|   1. affiche le message d'information ;
|   2. si phystop est deja <= LIMIT, on quitte (rien a faire, ou limite
|      impossible : on ne peut pas "ajouter" de memoire) ;
|   3. sinon affiche le message de reboot, vide le buffer clavier et attend
|      l'appui d'une touche ;
|   4. ecrit LIMIT dans phystop puis saute au vecteur de reset du TOS.
|      Comme memvalid/memval2 (et memval3 sur TOS >= 2) sont toujours valides,
|      le reset "a chaud" ne redimensionne pas la memoire : le TOS reprend
|      phystop tel quel et place l'ecran juste en dessous.
|
| Ce fichier n'est pas assemble seul : il est inclus par un fichier de
| configuration (512.s, 1024.s, ...) qui definit :
|   LIMIT       taille memoire en octets
|   SIZE_TXT    macro qui emet le texte de la taille (ex. "1Mo")
|
| Assembleur : GNU as (binutils m68k), syntaxe Motorola. Voir le Makefile.

	.equ	phystop,	0x42e		| fin de la ST-RAM
	.equ	memtop,		0x436		| fin de la TPA

	.text

| --- En-tete de programme GEMDOS (28 octets) ----------------------------
header:
	.word	0x601a				| ph_branch
	.long	text_end - text_start		| ph_tlen
	.long	0				| ph_dlen
	.long	0				| ph_blen
	.long	0				| ph_slen
	.long	0				| ph_res1
	.long	0				| ph_prgflags
	.word	0xffff				| ph_absflag : pas de relocation

| --- Code ---------------------------------------------------------------
text_start:
	pea	msg_info(pc)
	move.w	#9,-(sp)			| Cconws
	trap	#1
	addq.l	#6,sp

	pea	check(pc)
	move.w	#38,-(sp)			| Supexec(check)
	trap	#14
	addq.l	#6,sp

	move.w	need_reset(pc),d0
	beq.s	quit				| deja <= LIMIT : rien a faire

	pea	msg_reset(pc)
	move.w	#9,-(sp)			| Cconws
	trap	#1
	addq.l	#6,sp

flush:						| vide le buffer clavier
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
	move.w	#7,-(sp)			| Crawcin : attend une touche
	trap	#1
	addq.l	#2,sp

	pea	do_reset(pc)
	move.w	#38,-(sp)			| Supexec(do_reset), sans retour
	trap	#14

quit:
	clr.w	-(sp)				| Pterm0
	trap	#1

| --- Routines superviseur -----------------------------------------------

| need_reset = (phystop > LIMIT)
check:
	lea	need_reset(pc),a0
	clr.w	(a0)
	cmp.l	#LIMIT,(phystop).w
	bls.s	1f
	st	(a0)
1:	rts

do_reset:
	move.w	#0x2700,sr			| plus d'interruptions
	move.l	#LIMIT,(phystop).w
	move.l	#LIMIT-0x8000,(memtop).w	| recalcule par le TOS au boot
	move.l	(4).w,a0			| vecteur de reset (ROM)
	jmp	(a0)

need_reset:
	.word	0

| --- Textes (jeu de caracteres Atari) -----------------------------------
| \033E efface l'ecran, \033p / \033q video inverse on/off
| \210 = e circonflexe, \202 = e aigu, \212 = e grave, \253 = 1/2

msg_info:
	.ascii	"\033E\r\nVotre machine va \210tre configur\202e en "
	SIZE_TXT
	.ascii	"\r\net vous pourrez utiliser des disquettes\r\n"
	.ascii	"autoex\202cutables (d\202mos, etc.)\r\n"
	.byte	0

msg_reset:
	.ascii	"\033p\r\nVotre syst\212me va rebooter, ins\202rez\r\n"
	.ascii	"une disquette...\033q\r\n\r\n"
	.ascii	"Appuyez sur une touche.\r\n"
	.byte	0

	.balign	2
text_end:
