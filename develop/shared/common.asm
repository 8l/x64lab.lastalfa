  
  ;#-------------------------------------------------ß
  ;|          x64lab  MPL 2.0 License                |
  ;|   Copyright (c) 2009-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä


	;#---------------------------------------------ü
	;| Common Stub Dll Module                      |
	;ä---------------------------------------------ö

	;PACKVERSION equ 0

	define status 0
	match =bin,OUTEXT	{
		define status 1
	}
	match =0,status {
		define OUTEXT dll
		define status 1
	}

	match ext,OUTEXT {
		format PE64 DLL as `ext
	}

	entry entrydll
	heap 200'000h
	stack 100'000h

	include "%x64devdir%\macro\mrk_macrow.inc"

	include '..\macro/struct.inc'
	include '..\macro/import64.inc'
	include '..\macro/export.inc'
	include '..\macro/resource.inc'

	struc TCHAR [val] { 
		common 
		match any, val \{ 
			. du val \}
   match , val \{ 
			. du ? \}
	}

	macro @sizea16 argstruc {
		sizea16.#argstruc = \
		(sizeof.#argstruc + 15) and (-16)
	}

	include '..\equates/kernel64.inc'
	include '..\equates/user64.inc'
	include '..\equates/gdi64.inc'
	include "..\equates\comctl64.inc"
	include '..\equates/comdlg64.inc'
	include '..\equates/shell64.inc'

	;ü------------------------------------------ö
	;|     RSRC.INC                             |
	;#------------------------------------------ä
	
	match items,INC_RC {
		macro ii [value] \{	include value	\} ii items	
		common purge ii	
	}

	;ü------------------------------------------ö
	;|     EQUATES                              |
	;#------------------------------------------ä

	match items,INC_EQU 
		{	macro ii [value] \{	include value	\} ii items	
		common purge ii	}


	;ü------------------------------------------ö
	;|     MISC INCLUDE FILES                   |
	;#------------------------------------------ä

	match items,INC_INC 
		{	macro ii [value] \{	include value	\} ii items	
		common purge ii	}


	;ü------------------------------------------ö
	;|     SHARED                               |
	;#------------------------------------------ä

	match items,INC_SDATA {	
		section '.shared' data readable writeable shareable
		local sdata_start
		label sdata_start

		macro ii [value] \{	
			include value	
			\} ii items	
			common purge ii

		match =TRUE,VERBOSE \{
			display ";--- SDATA segment size "
			display_decimal $-sdata_start
			display 13,10
		\}
	}
			
	;ü------------------------------------------ö
	;|     INCLUDE USER DATA                    |
	;#------------------------------------------ä

	match items,INC_DATA {	
		common
		section '.data' data readable writeable
		forward
		macro ii [value] \{	
				include value	
		\} ii items	
		common purge ii
		}

	;ü------------------------------------------ö
	;|     MISC OTHER REQUIRED ASM FILES        |
	;#------------------------------------------ä
	section '.code' code readable executable
	code_start:
		match items,APIBRIDGE {@e_rva items}
		dd 0
	include "%x64devdir%\shared\api.asm"
	include "%x64devdir%\shared\art.asm"

	match items,INC_ASM
		{	macro ii [value] \{	include value	\} ii items	
		common purge ii	}

;	define status 0
;	match =0,PACKVERSION	{
;		PACKVERSION equ VERSION
;		define status 1
;	}
	;--- get_version
	;--- RET RAX hashname(HI) OR tstamp (LO)
	;--- RET RCX packvers(HI) OR version
	;--- RET RDX POPCOUNT(HI) OR CRC
	;--- RET R8,R9 0 not used

;	match m,RAWMOD {
;		@make_version \
;		m#.dll,\
;		PACKVERSION,\
;		VERSION }

entrydll:
	push rbp
	push rbx
	push rdi
	push rsi
	mov rbp,rsp
	and rsp,-16
;	.hInstance rcx,\
;	.fdwReason rdx,\
;	.reserved r8
	mov rax,entrydll	;--- forces .reloc fixups to be valid
	cmp	rdx,DLL_PROCESS_ATTACH
	jnz	@f

.attach:
	match ac,ATTACH_CODE { call ac	}
	jmp	.exit

@@:
	cmp	rdx,DLL_PROCESS_DETACH
	jnz	.exit

.detach:		
	match dc,DETACH_CODE { call dc }

.exit:
	mov rsp,rbp
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	  
	;ü------------------------------------------ö
	;|     PROJECT MAIN ASM FILE                |
	;#------------------------------------------ä

	match items,INC_CODE
	 { macro ii [value] \{	include value	\} ii items	
		common purge ii	}

	
		match =TRUE,VERBOSE {
			display ";--- CODE segment size "
			display_decimal $-code_start
			display 13,10
		}

	;ü------------------------------------------ö
	;|     IMPORT                               |
	;#------------------------------------------ä
	match items,INC_IMP
		{	macro ii [value] \{	include value	\} ii items	
		common purge ii	}

	;ü------------------------------------------ö
	;|     EXPORT SECTION (dont touch!!!)       |
	;#------------------------------------------ä

	match items,APIEXPORT {
		section '.edata' export data readable
		match m,MODULE \{
			export \`m\#'.dll',items
			\}
	}
	
	;ü------------------------------------------ö
	;|     RESOURCE BINARY COMPILED             |
	;#------------------------------------------ä

	match items,INC_RES	{	
		section '.rsrc' resource from items data readable }
	
	match =TRUE,INC_FIX	{	
		section '.reloc' fixups data discardable }

