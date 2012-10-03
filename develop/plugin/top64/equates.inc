  
  ;#-------------------------------------------------ß
  ;|          top64  MPL 2.0 License                 |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

struct THEADER
	flags db 0
	iderr	db 0
				dw 0
	lines	dd 0
	items	dd 0
	dsize	dd 0
	psrc		dq 0
	pmem		dq 0
	pstack	dq 0
					dq 0
ends

	struct TITEM
		type		db 0
		level		db 0
		len			dw 0

		parent	dd 0
		child		dd 0	;--- item
		next		dd 0	;--- item
		hash		dd 0	;--- item
		attrib	dd 0
		param		dq 0	;--- TPARAM

		union
			qword_val	dd 0
			lo_dword	dd 0	;--- number
			tmpcat		dd 0	;--- tmpcat for strings
		ends
		union
			hi_dword	dd 0	;--- number
			value			dd 0	;--- comment/string
		ends
		;--- follow value
	ends

;display_decimal sizeof.TITEM

	TAB_UTF8			equ 00000009h
	CR_UTF8				equ 0000000Dh
	LF_UTF8 			equ 0000000Ah
	SPACE_UTF8		equ 00000020h
	DQUOTE_UTF8		equ 00000022h	; <">
	SQUOTE_UTF8		equ 00000027h	; <">
	OPAR_UTF8			equ 00000028h	; <(>
	CPAR_UTF8			equ 00000029h	; <)>
	COMMA_UTF8		equ 0000002Ch	; <,>
	DDOT_UTF8			equ 0000003Ah	; <:>
	COMMENT_UTF8 	equ 0000003Bh	; <;>
	EQUALS_UTF8		equ 0000003Dh	; <=>
	BSLASH_UTF8		equ 0000005Ch	; <\>
	ESCAPE_UTF8		equ 0000005Ch	; <\>
	DOT_HASH			equ 2FD7E285h

	TLABEL		equ 1
	TQUOTED		equ 2
	TNUMBER		equ 4
	TCOMMENT	equ 8
	TOBJECT		equ 10h

	;--- user post parsing flags that apply
	;--- to mark items AFTER parsing. not involved
	;--- during parsing

	TDELETED	equ 20h
	TPARAM		equ 40h


	;--- by TNUMBER/TOBJECT: keep symple dqword storage
	;--- by TLABEL/TQUOTED storage pointer qword_val points
  ;--- to new substituting item


	F_NAME		equ 1
	F_VALUE		equ 2
	F_OBJECT	equ 4
	F_EOF			equ 8
	F_LINE		equ 10h
	F_COMMA		equ 20h

	COUNT_CHILDREN	equ 200h
