  
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

sci:

;--- hash for classes and styles
@szhash lexer,\
	multisel,\
	stylebits,\
	tabwidth,\
	selback,\
	keyword,\
	style,\
	back,\
	bold,\
	fore,\
	font,\
	fontsize,\
	italic,\
	clearall,\
	commline,\
	commstart,\
	commend

	;#---------------------------------------------------ö
	;|                CREATE                             |
	;ö---------------------------------------------------ü
.create:
	;--- in RCX parent
	push rbp
	mov rbp,rsp
	and rsp,-16
	xor eax,eax
	sub rsp,60h
	lea rdx,[rsp+20h]

	mov r8,[hInst]
	mov [rdx+38h],rax
	mov [rdx+30h],r8
	mov [rdx+28h],rax
	mov [rdx+20h],rcx
	mov [rdx+18h],rax
	mov [rdx+10h],rax
	mov [rdx+8h],rax
	mov [rdx],rax
	mov r9,WS_CHILD or \
		WS_TABSTOP or \
		WS_VISIBLE
	xor r8,r8
	mov rdx,uzSciClass
	mov ecx,WS_EX_STATICEDGE
	call [CreateWindowExW]
	mov rsp,rbp
	pop rbp
	ret 0

;display_hex 32,WS_EX_STATICEDGE or WS_CHILD or \
;		WS_TABSTOP or \
;		WS_VISIBLE
;		WS_CLIPCHILDREN or \

	;#---------------------------------------------------ö
	;|                  SET_DEFPROP                      |
	;ö---------------------------------------------------ü

.set_defprop:
	;--- in rcx hText
	push rbx
	mov rbx,rcx

	mov r9,SC_MARGIN_SYMBOL
	mov r8,0
	mov rcx,rbx
	call .set_margtype

	mov r9,SC_MARGIN_NUMBER
	mov r8,1
	mov rcx,rbx
	call .set_margtype

	mov r9,SC_MARGIN_SYMBOL
	mov r8,2
	mov rcx,rbx
	call .set_margtype

	mov r9,16
	mov r8,2
	mov rcx,rbx
	call .set_margwi

	mov r9,szCharExt
	mov r8,STYLE_LINENUMBER
	mov rcx,rbx
	call .set_txtwi

	mov r9,rax
	mov r8,SC_MARGIN_NUMBER
	mov rcx,rbx
	call .set_margwi

	mov r9,8
	mov rcx,rbx
	call .set_marglx

	mov r9,8
	mov rcx,rbx
	call .set_margrx

	mov r9,00AABBCCh
	mov r8,STYLE_LINENUMBER
	mov rcx,rbx
	call .set_backcolor

;	mov r9,0FFFFFFh
;	mov r8,STYLE_LINENUMBER
;	mov rcx,rbx
;	call .set_forecolor

	mov r9,uzCourierN
	mov r8,STYLE_LINENUMBER
	mov rcx,rbx
	call .set_font

	mov r9,9
	mov r8,STYLE_LINENUMBER
	mov rcx,rbx
	call .set_fontsize

	mov r8,SC_CP_UTF8
	mov rcx,rbx
	call .set_cp

	mov r9,uzCourierN
	mov r8,STYLE_DEFAULT
	mov rcx,rbx
	call .set_font

	mov r9,12
	mov r8,STYLE_DEFAULT
	mov rcx,rbx
	call .set_fontsize

	mov r8,2
	mov rcx,rbx
	call .set_tabwidth

	pop rbx
	ret 0


	;#---------------------------------------------------ö
	;|                WRAPS                              |
	;ö---------------------------------------------------ü
.goto_pos:
	xor r9,r9
	mov edx,SCI_GOTOPOS
	jmp	apiw.sms

.set_savepoint:
	xor r8,r8
	xor r9,r9
	mov edx,SCI_SETSAVEPOINT
	jmp	apiw.sms

.set_emptyundobuf:
	xor r9,r9
	xor r8,r8
	mov edx,SCI_EMPTYUNDOBUFFER
	jmp	apiw.sms

.set_undocoll:
	xor r9,r9
	mov edx,SCI_SETUNDOCOLLECTION
	jmp	apiw.sms

.set_cp:
	;--- in r8 codepage
	xor r9,r9
	mov edx,SCI_SETCODEPAGE
	jmp	apiw.sms

.set_margrx:
	;--- in r9 size
	;--- in R8 idx margin
	mov edx,SCI_SETMARGINRIGHT
	jmp	apiw.sms

.set_marglx:
	;--- in r9 size
	;--- in R8 idx margin
	mov edx,SCI_SETMARGINLEFT
	jmp	apiw.sms

.set_margwi:
	;--- in R9 size
	;--- in R8 idx margin
	mov edx,SCI_SETMARGINWIDTHN
	jmp	apiw.sms

.set_txtwi:
	;--- in R9 sample
	;--- in R8 style
	mov edx,SCI_TEXTWIDTH
	jmp	apiw.sms

.set_margtype:
	;--- in RCX hwnd
	;--- in R8 type
	;--- in R9 id
	mov edx,SCI_SETMARGINTYPEN
	jmp	apiw.sms

.add_txt:
	;--- in R8 len
	;--- in R9 text
	mov edx,SCI_ADDTEXT
	jmp	apiw.sms


;.get_docp:
;	mov edx,SCI_GETDOCPOINTER
;	jmp	apiw.sms

;.set_docp:
;	;--- in R9 pDoc
;	mov edx,SCI_SETDOCPOINTER
;	jmp	apiw.sms

;.add_refdoc:
;	;--- in R9 pDoc
;	mov edx,SCI_ADDREFDOCUMENT
;	jmp	apiw.sms

;.create_doc:
;	mov edx,SCI_CREATEDOCUMENT
;	jmp	apiw.sms

;.rel_doc:
;	;--- in R9 pDoc
;	mov edx,SCI_RELEASEDOCUMENT
;	jmp	apiw.sms
	

.get_txtl:
	xor r8,r8
	xor r9,r9
	mov edx,SCI_GETLENGTH
	jmp	apiw.sms

.get_txtr:
	xor r8,r8
	mov edx,SCI_GETTEXTRANGE
	jmp	apiw.sms

	;#---------------------------------------------------ö
	;|                DISCARD                            |
	;ö---------------------------------------------------ü

.discard:
	mov rcx,[hSciDll]
 	jmp apiw.freelib

	;#---------------------------------------------------ö
	;|                SETUP                              |
	;ö---------------------------------------------------ü

.setup:
	;--- in RCX plugdir
	lea rcx,[rcx+DIR.dir]

.setupA:
	sub rsp,FILE_BUFLEN
	xor eax,eax
	mov rdx,rsp
	
	push rax
	push uzSciDll
	push uzSlash
	push rcx
	push rdx
	push rax
	call art.catstrw

	mov rdx,\
		LOAD_WITH_ALTERED_SEARCH_PATH
	mov rcx,rsp
 	call apiw.loadlib
	add rsp,FILE_BUFLEN
	ret 0
	
	;#---------------------------------------------------ö
	;|               .DEF_FLAGS                          |
	;ö---------------------------------------------------ü

.def_flags:
	;--- in RCX hSci
	push rbx
	mov rbx,rcx
	xor r8,r8
	inc r8
	call .set_undocoll

	mov rcx,rbx
	call .set_emptyundobuf

	mov rcx,rbx
	call apiw.set_focus

	mov rcx,rbx
	call .set_savepoint

	mov rcx,rbx
	xor r8,r8
	call .goto_pos

	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|                  SAVE                             |
	;ö---------------------------------------------------ü

.save:
	;--- in RCX hSci
	;--- in RDX path+file
	;--- in R8 encoding
	;--- RET RAX 0/1
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14

	xor r12,r12
	xor r14,r14
	sub rsp,\
		sizeof.TEXTRANGEW

	;--- zero textrange = 16
	mov [rsp],r12
	mov [rsp+8],r12

	mov rbx,rcx
	mov rsi,rdx
	mov r13,r8

	;--- get text len
	mov rcx,rbx
	call .get_txtl

	;--- TODO: warning on zero len
	test rax,rax
	jz	.saveA

	;--- allocate buffer
	mov rcx,rax
	inc rcx
	inc rcx
	call art.valloc
	test rax,rax
	jz	.saveE
	mov rdi,rax
	
	;--- read buffer
	or ecx,-1
	mov [rsp+\
		TEXTRANGEW.chrg.cpMax],ecx
	inc ecx
	mov [rsp+\
		TEXTRANGEW.lpstrText],rax
	mov [rsp+\
		TEXTRANGEW.chrg.cpMin],ecx
	mov r9,rsp
	mov rcx,rbx
	call .get_txtr
	test rax,rax
	jz	.saveE
	mov r14,rax
	
.saveA:
	;--- create always dest file
	mov rcx,rsi
	call art.fcreate_rw
	test rax,rax
	jz	.saveE
	mov rbp,rax

	;--- write to dest file
	mov r8,r14
	mov rdx,[rsp+\
		TEXTRANGEW.lpstrText]
	mov rcx,rax
	call art.fwrite

	mov rcx,rbp
	call art.fend

	mov rcx,rbp
	call art.fclose

	mov rcx,rdi
	call art.vfree

	mov rcx,rbx
	call .set_savepoint
	
	inc r12

.saveE:
	add rsp,\
		sizeof.TEXTRANGEW
	xchg rax,r12
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

.set_selback:
	;--- R8
	mov edx,\
		SCI_SETSELBACK
	jmp	apiw.sms

.set_fontsize:
	mov edx,\
		SCI_STYLESETSIZE
	jmp	apiw.sms

.set_font:
	mov edx,\
		SCI_STYLESETFONT
	jmp	apiw.sms

.set_keyword:
	mov edx,\
		SCI_SETKEYWORDS
	jmp	apiw.sms

.set_backcolor:
	mov edx,\
		SCI_STYLESETBACK
	jmp	apiw.sms

.set_forecolor:
	mov edx,\
		SCI_STYLESETFORE
	jmp	apiw.sms

.set_tabwidth:
	;--- in R8 value
	mov edx,\
		SCI_SETTABWIDTH
	jmp	apiw.sms

.set_multisel:
	;--- in R8 value
	mov edx,\
		SCI_SETMULTIPLESELECTION
	jmp	apiw.sms

.set_stylebits:
	mov edx,\
		SCI_SETSTYLEBITS
	jmp	apiw.sms

.set_lexer:
	;--- in R8 lexer
	mov edx,\
		SCI_SETLEXER
	jmp	apiw.sms

.get_lexer:
	mov edx,\
		SCI_GETLEXER
	jmp	apiw.sms

.style_clearall:
	mov edx,\
		SCI_STYLECLEARALL
	jmp	apiw.sms

.set_bold:
	mov edx,\
		SCI_STYLESETBOLD
	jmp	apiw.sms

.set_italic:
	mov edx,\
		SCI_STYLESETITALIC
	jmp	apiw.sms

.is_selrect:
	mov edx,\
		SCI_SELECTIONISRECTANGLE
	jmp	apiw.sms

.get_sels:
	mov edx,\
		SCI_GETSELECTIONS
	jmp	apiw.sms

.get_mainsel:
	mov edx,\
		SCI_GETMAINSELECTION
	jmp	apiw.sms

.get_selnstart:
	mov edx,\
		SCI_GETSELECTIONNSTART
	jmp	apiw.sms

.get_selnend:
	mov edx,\
		SCI_GETSELECTIONNEND
	jmp	apiw.sms

.get_seltxt:
	mov edx,\
		SCI_GETSELTEXT
	jmp	apiw.sms

.repl_sel:
	mov edx,\
		SCI_REPLACESEL
	jmp	apiw.sms

.set_mpaste:
	mov edx,\
	SCI_SETMULTIPASTE
	jmp	apiw.sms


.tgtfromsel:
	mov edx,\
		SCI_TARGETFROMSELECTION
	jmp	apiw.sms

.set_sflags:
	mov edx,\
		SCI_SETSEARCHFLAGS
	jmp	apiw.sms

.set_tgtstart:
	mov edx,\
		SCI_SETTARGETSTART
	jmp	apiw.sms

.set_tgtend:
	mov edx,\
		SCI_SETTARGETEND
	jmp	apiw.sms

.search_tgt:
	mov edx,\
		SCI_SEARCHINTARGET
	jmp	apiw.sms

.repl_tgtre:
	mov edx,\
		SCI_REPLACETARGETRE
	jmp	apiw.sms

.repl_tgt:
	mov edx,\
		SCI_REPLACETARGET
	jmp	apiw.sms

.linefrompos:
	mov edx,\
		SCI_LINEFROMPOSITION
	jmp	apiw.sms

.get_lineendpos:
	mov edx,\
		SCI_GETLINEENDPOSITION
	jmp	apiw.sms

.beg_undo:
	mov edx,\
		SCI_BEGINUNDOACTION
	jmp	apiw.sms

.end_undo:
	mov edx,\
		SCI_ENDUNDOACTION
	jmp	apiw.sms

;	;#---------------------------------------------------ö
;	;|                helper wraps                       |
;	;ö---------------------------------------------------ü


;	;------------------------
;.sci_param2:
;	xor ecx,ecx
;	xor edx,edx
;	jmp .sci_message0
;	;------------------------

;.get_selnstart:
;	xor edx,edx
;	mov eax,SCI_GETSELECTIONNSTART
;	jmp .sci_message0

;.linelen:
;	xor edx,edx
;	mov eax,SCI_LINELENGTH
;	jmp .sci_message0


;.get_selnend:
;	xor edx,edx
;	mov eax,SCI_GETSELECTIONNEND
;	jmp .sci_message0

;.setsel:
;	mov eax,SCI_SETSEL
;	jmp .sci_message0


;.set_charset:
;	mov eax,SCI_STYLESETCHARACTERSET
;	jmp	.sci_message0

;.replsel:
;	xor ecx,ecx
;	mov eax,SCI_REPLACESEL
;	jmp	.sci_message0

;.inserttxt:
;	mov eax,SCI_INSERTTEXT
;	jmp	.sci_message0

;.posfromline:
;	xor edx,edx
;	mov eax,SCI_POSITIONFROMLINE
;	jmp	.sci_message0


	;#---------------------------------------------------ö
	;|                  COMMENT                          |
	;ö---------------------------------------------------ü
.comment:
	;--- in RCX hSci
	;--- in RDX class
	;--- in R8 command procedure
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15

	mov rbp,rsp
	and rsp,-16

	sub rsp,2+10h+\
		MAX_COMMLINE_LEN	

	mov r15,rsp	;--- buf format regexp
	xor r12,r12	;--- num selections

	mov rbx,rcx
	mov rdi,rdx
	mov rsi,r8

	mov rcx,rbx
	call .beg_undo

	mov rcx,rbx
	call .is_selrect
	test eax,eax
	jnz	.commentE

	mov rax,[rdi+\
		EXT_CLASS.top]
	test rax,rax
	jz	.commentE

	mov ecx,[rdi+\
		EXT_CLASS.top_comml]
	test ecx,ecx
	jz	.commentE
	mov r13,rcx
	add r13,rax

	mov r8,\
		SCFIND_REGEXP
	mov rcx,rbx
	call .set_sflags
	
	mov rcx,rbx
	call .get_sels
	dec eax
	js	.commentE
	mov r12,rax

	movzx edx,[r13+\
		TITEM.len] 	;--- len needle ";--- "

	push rdi
	push rsi

	cmp rsi,\
		.commline
	jz	.commentLL
	cmp rsi,\
		.uncommline
	jz	.commentUL

	pop rsi
	pop rdi
	jnz	.commentE

.commentUL:
	;--- format for uncomment line
	mov rdi,r15
	mov ecx,\
		rexpSOL2a.size
	mov rsi,rexpSOL2a
	push r15	;--- find start
	push rcx	;--- len 2a
	rep movsb
	
	mov rdx,rdi
	lea rcx,[r13+\
		TITEM.value]
	call utf8.copyz

	push rax		;--- len needle
	add rdi,rax

	mov ecx,\
		rexpSOL2b.size
	mov rsi,rexpSOL2b
	push rcx		;--- len 2b
	rep movsb
	
	mov r15,rdi
	mov ecx,\
		rexpTAG2.size
	mov rsi,rexpTAG2
	rep movsb

	pop rax
	mov r14,rax
	pop rax
	add r14,rax
	pop rax
	add r14,rax
	ror r14,8
	pop rax
	or r14,rax
	jmp	.commentF

.commentLL:
	;--- format for comment line	
	mov rdi,r15
	mov rsi,rexpSOL1
	mov ecx,\
		rexpSOL1.size
	mov r14,rcx
	ror r14,8
	or r14,rdi
	rep movsb
	mov r15,rdi

	lea rcx,[r13+\
		TITEM.value]
	mov rdx,rdi
	call utf8.copyz

.commentF:
	pop rsi
	pop rdi
	call rsi

.commentE:
	mov rcx,rbx
	call .end_undo

	mov rsp,rbp
	pop r15
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|                  COMMLINE                         |
	;ö---------------------------------------------------ü

.commline:
	;--- (uses RBX hSci)
	;--- (uses R12 num selections)
	;--- (uses R14 buff find R14 msb = len)
	;--- (uses r15 buffer replace)
	push rbp
	mov rbp,rsp

.commlineA7:
	mov r8,[pMp]
	mov rdi,\
		[r8+MPURP.hPrg]
	
.commlineA3:
	;--- get sel start end
	mov rcx,r12
	call .get_selstartend
	mov r13,rdx
	call .get_lines

	push rax
	push rdx

	mov r9,rcx
	xor r8,r8
	mov rcx,rdi
	call pbar.setrange

	xor r8,r8
	mov rcx,rdi
	call pbar.pos

	xor r8,r8
	inc r8
	mov rcx,rdi
	call pbar.setstep
	
	pop rdx
	pop rax

;@break
	or ecx,-1
	sub rsp,4
	mov esi,\
		STACK_LIMIT
	mov [rsp],ecx

.commlineA2:
	cmp rsp,rsi
	ja	.commlineA4

	;--- notify out of stack:
	jmp	.commlineA6

.commlineA4:
	mov rdx,r13
	call .set_tgtstartend

	mov r9,r14
	and r9d,r9d
	mov r8,r14
	rol r8,8
	and r8d,0FFh
	mov rcx,rbx
	call .search_tgt

	sub rsp,8
	mov [rsp],eax
	mov [rsp+4],eax

	mov rcx,rdi
	call pbar.step
	mov eax,[rsp]
	add rsp,4
	inc eax
	jnz	.commlineA2
	add rsp,4

.commlineA6:
	mov r9,rbp
	sub r9,rsp
	shr r9,2
	xor r8,r8
	mov rcx,rdi
	call pbar.setrange

	xor r8,r8
	mov rcx,rdi
	call pbar.pos

.commlineA1:
	mov eax,[rsp]
	add rsp,4
	inc eax
	jz	.commlineA5

	dec eax
	mov edx,eax
	call .set_tgtstartend

	mov r9,r15
	mov r8,-1
	mov rcx,rbx
	call .repl_tgt	

	mov rcx,rdi
	call pbar.step
	jmp	.commlineA1

.commlineA5:
	mov rsp,rbp
	dec r12
	jns	.commlineA3

	xor r8,r8
	mov rcx,rdi
	call pbar.pos

	pop rbp
	ret 0


	;#---------------------------------------------------ö
	;|                UNCOMMLINE                         |
	;ö---------------------------------------------------ü

.uncommline:
	;--- in RDX len of needle
	;--- (uses RBX hSci)
	;--- (uses R12 num selections)
	;--- (uses r14 buffer find)
	
	push rbp
	mov rbp,rsp

	mov r8,[pMp]
	mov rdi,\
		[r8+MPURP.hPrg]

.uncommlineA3:
	;--- get sel start end
	mov rcx,r12
	call .get_selstartend
	mov r13,rdx
	call .get_lines

	push rax
	push rdx

	mov r9,rcx
	xor r8,r8
	mov rcx,rdi
	call pbar.setrange

	xor r8,r8
	mov rcx,rdi
	call pbar.pos

	xor r8,r8
	inc r8
	mov rcx,rdi
	call pbar.setstep
	
	pop rdx
	pop rax
;@break

.uncommlineA2:
	mov rdx,r13
	call .set_tgtstartend

	mov r9,r14
	and r9d,r9d
	mov r8,r14
	rol r8,8
	and r8d,0FFh
	mov rcx,rbx
	call .search_tgt

	inc eax
	jz .uncommlineA5
	dec eax

	push rax
	push rax

	mov r8,rax
	mov rcx,rbx
	call .linefrompos

	mov r8,rax
	mov rcx,rbx
	call .get_lineendpos
	mov r15,rax
	mov edx,eax
	pop rax
	sub r15,rax
	call .set_tgtstartend
	
	mov r9,r14
	mov rax,r14
	rol rax,8
	and eax,0FFh
	and r9d,r9d
	add r9,rax

	mov r8,-1
	mov rcx,rbx
	call .repl_tgtre
	sub r15,rax
	sub r13,r15

	mov rcx,rdi
	call pbar.step
	pop rax
	inc eax
	jz	.uncommlineA5
	dec eax
	add rax,r15
	jmp	.uncommlineA2

.uncommlineA5:
	mov rsp,rbp
	dec r12
	jns	.uncommlineA3

	xor r8,r8
	mov rcx,rdi
	call pbar.pos

	pop rbp
	ret 0


.get_lines:
	;--- IN EAX start pos
	;--- IN EDX end pos
	;--- (uses RBX hSci)
	;--- RET RCX lines
	;--- RAX,RDX untouched
	push rax
	push rdx
	push rax

	mov r8,rdx
	mov rcx,rbx
	call .linefrompos
	xchg rax,[rsp]

	mov rcx,rbx
	mov r8,rax
	call .linefrompos
	pop rcx
	sub rcx,rax
	pop rdx
	pop rax
	ret 0


.set_tgtstartend:
	;--- IN EAX start
	;--- IN EDX end
	;--- (uses RBX hSci)
	mov rcx,rbx
	push rax
	mov r8,rdx
	call .set_tgtend
	pop r8
	mov rcx,rbx
	push rax
	call .set_tgtstart
	pop rdx
	ret 0

	
	
.get_selstartend:
	;--- in RCX line/block
	;--- (uses RBX hSci)
	;--- RET ECX len of line/block
	;--- RET EAX start
	;--- RET EDX end
	push rcx
	mov r8,rcx
	mov rcx,rbx
	call .get_selnend
	xchg rax,[rsp]
	mov rcx,rbx
	mov r8,rax
	call .get_selnstart
	pop rdx
	mov rcx,rdx
	sub rcx,rax
	ret 0

;proc .comment\
;	_hsci,\
;	_flags
;	local .num_chars:DWORD
;	local .line_beg:DWORD
;	local	.line_end:DWORD
;	local .sel_beg:DWORD
;	local .sel_end:DWORD
;	local .len_line:DWORD
;	local .len_block:DWORD
;	local .esp_stack:DWORD
;	local .beg_last:DWORD
;	local .end_last:DWORD
;	local .tr:TEXTRANGE

;	push ebx
;	push edi
;	push esi

;	mov ebx,[_hsci]
;	call .is_selrect
;	test eax,eax
;	jnz	.vert_comment

;	;#---------------------------------------------------ö
;	;|                  HORZ_COMMENT                     |
;	;ö---------------------------------------------------ü

;.horz_comment:
;	call .get_sels
;	mov edi,eax
;	test eax,eax
;	jz .exit_c
;	dec eax
;	jz .next_hcA
;	mov edi,eax

;	xor eax,eax
;	call .get_selstartend
;	mov [.beg_last],eax
;	mov [.end_last],edx

;.next_hc:
;	mov eax,edi
;	call .commblock
;	dec edi
;	jnz	.next_hc

;	mov ecx,[.beg_last]
;	mov edx,[.end_last]
;	call .setsel
;	call .get_mainsel

;.next_hcA:
;	call .commblock
;	jmp	.exit_c


;	;#---------------------------------------------------ö
;	;|                  VERT_COMMENT                     |
;	;ö---------------------------------------------------ü
;.vert_comment:
;;@break
;	xor edi,edi
;	call sci.get_sels
;	test eax,eax
;	jz .exit_c
;	dec eax
;	jz .next_vcA
;	mov edi,eax

;	xor eax,eax
;	call .get_selstartend
;	mov [.sel_beg],eax
;	mov [.len_line],ecx
;	mov [.sel_end],edx

;.next_vc:
;;	xor eax,eax
;;	sub eax,edi
;;	neg eax
;	mov eax,edi
;	call .commline
;	dec edi
;	jns	.next_vc

;	mov ecx,[.sel_beg]
;	mov edx,ecx
;	add edx,[.len_line]
;	call .setsel

;.next_vcA:
;	call .commline
;	jmp	.exit_c
;	

;.exit_c:
;	pop esi
;	pop edi
;	pop ebx
;	ret

;.get_selstartend:
;	;IN EAX=line/block
;	;RET ECX= len of line
;	;RET EAX,start
;	;RET EDX,end
;	mov ecx,eax
;	push ecx
;	call .get_selnend
;	pop ecx
;	push eax
;	call .get_selnstart
;	pop edx
;	mov ecx,edx
;	sub ecx,eax
;	ret 0

;	;#---------------------------------------------------ö
;	;|                  BLOCK COMMENT (horz)             |
;	;ö---------------------------------------------------ü

;.commblock:
;;@break
;	push edi
;	push esi
;	;IN EAX=block
;	;IN ECX=len
;	call .get_selstartend
;	mov [.sel_beg],eax
;	mov [.len_block],ecx
;	mov [.sel_end],edx
;	mov [.line_beg],eax

;.comm_blA:
;	mov ecx,[.line_beg]
;	call .linefrompos
;	mov esi,eax

;.comm_blE:
;	mov ecx,esi
;	call .get_lineendpos
;	mov [.line_end],eax

;	mov eax,[.line_beg]
;	mov edx,[.line_end]
;	mov ecx,edx
;	sub ecx,eax			
;	jge @f				;---- patched: to review
;	xor ecx,ecx
;@@:
;	call .comm_glC
;	push eax

;	mov ecx,esi
;	call .linelen
;	pop ecx

;.comm_blC:
;	mov edx,[_flags]
;	test dl,LINE_COMMENT
;	jnz	.comm_blD
;	sub [.sel_end],ecx
;	jmp	.comm_blF

;.comm_blD:
;	add [.sel_end],ecx

;.comm_blF:
;	add eax,[.line_beg]
;	cmp eax,[.sel_end]
;	jae .comm_bl
;	mov [.line_beg],eax
;	jmp	.comm_blA

;.comm_bl:
;	pop esi
;	pop edi
;	ret 0

;	;#---------------------------------------------------ö
;	;|                  LINE COMMENT  (vert)             |
;	;ö---------------------------------------------------ü
;.commline:
;	;IN EAX=line
;	;IN ECX=len
;	;RET EAX=+/-numchars
;	push edi
;	push esi
;	
;	call .get_selstartend
;	test ecx,ecx
;	jz	.comm_glA
;	jmp	.comm_glB

;.comm_glC:
;	push edi
;	push esi

;.comm_glB:
;	test ecx,ecx
;	jz	.comm_glA		;jle
;	
;	mov [.line_beg],eax
;	mov [.line_end],edx
;	mov [.tr.chrg.cpMin],eax
;	mov [.tr.chrg.cpMax],edx

;	mov eax,[_flags]
;	test al,LINE_COMMENT
;	jnz	.comm_comm
;	test al,LINE_DECOMMENT
;	jnz	.comm_decomm
;	; example Alt+X cat first char
;	; test al LINE_CATCOLUMN
;	jz	.comm_glA

;.comm_decomm:
;	mov eax,ecx						;<----num chars
;	add eax,2Fh
;	and eax,not 0Fh
;	mov [.esp_stack],eax	;<---------------------
;	sub esp,eax
;	mov edi,esp
;	xor eax,eax
;	mov edx,esp
;	shr ecx,2
;	mov [.tr.lpstrText],edx
;	rep stosd

;	lea edx,[.tr]
;	call .get_txtrange
;	mov eax,[.tr.lpstrText]
;;@break
;	xor ecx,ecx
;	mov dl,byte[eax]
;	cmp dl,";"
;	jnz	.comm_decommA
;	
;	mov ecx,[.line_beg]
;	mov edx,ecx
;	inc edx
;	call .setsel

;	mov edx,szNull
;	call .replsel
;	xor ecx,ecx
;	inc ecx

;.comm_decommA:
;	add esp,[.esp_stack]
;	jmp .comm_gl

;.comm_comm:
;	mov ecx,[.line_beg]
;	mov edx,szComment
;	call .inserttxt
;	xor ecx,ecx
;	inc ecx
;	jmp	.comm_gl

;.comm_glA:		;len is zero
;	xor ecx,ecx

;.comm_gl:
;	xchg eax,ecx
;	pop esi
;	pop edi
;	ret 0
;endp




