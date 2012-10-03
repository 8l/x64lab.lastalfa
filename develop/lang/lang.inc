  
  ;#-------------------------------------------------ß
  ;|          lang MPL 2.0 License                   |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

	UR	equ 1	;--- read only
	UW	equ 2	;--- can write
	U8	equ 8	;--- utf8
	U16	equ 16	;--- utf16

	struct RESTABLE
		lang db 16 dup (0)
		lcid dw 0 ;--- culture name
		ids	 dw 0
		tlen dw 0 ;--- total len inclusive RESDEF struc
		ulen dw 0 ;--- total len only zero-string
			 dw 4 dup (9090h)
	ends

	struct RESDEF
		id		dw 0
		next	dw 0	;--- offset from res_r/-1
		set		db 0
		type	db 0
					dw 0
		len		dw 0	;--- essential
		;--- follow utf8+0+0 aligned 2 string
	ends

	macro @make_lang argidname,arglcid{
	align 16
		label res_h		;--- header
		.lang db argidname,0
		@align 16,0
		.lcid	dw arglcid
		.ids	dw 0
		.tlen	dw 0
		.ulen	dw 0
					dw 4 dup (9090h)
		label res_i		;--- indexes
			dw 256 dup (-1)
		label res_r		;--- resource utf8 str
		ids=0
		tlen=0
		ulen=0
	}
	
	macro @make_uz	[argid,argset,argtype,argstr]{
			local ..tmp,..tmq,..tmz
			label ..tmq
			dw argid
			dw 0			;--- next
			db argset	;--- string set
			db argtype
			dw 0
			dw ..tmp-$-2
			label ..tmz
			argstr
			label ..tmp
			dw 0
			@align 2,0
			ids = ids + 1
			tlen = tlen + $-..tmq
			ulen = ulen + (..tmp-..tmz)+2

			load ref WORD from res_i+((argid and 0FFh)*2)
			store WORD ..tmq-res_r at res_i+((argid and 0FFh)*2)
			store WORD ref at ..tmq+2

		common
			store WORD ids at res_h.ids
			store WORD tlen at res_h.tlen
			store WORD ulen at res_h.ulen

		match =TRUE,VERBOSE\{
			display "(AVE.) TLEN = "
			display_decimal tlen/ids
			display 13,10
			display "(AVE.) ULEN = "
			display_decimal (ulen)/ids
			display 13,10
		\}
	}

