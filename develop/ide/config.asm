  
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

config:
	virtual at rbx
		.dir DIR
	end virtual

	virtual at rdi
		.conf CONFIG
	end virtual

	;ü-----------------------------------------ö
	;|     setup_libs                          |
	;#-----------------------------------------ä

.setup_libs:
	push rdi
	push rsi

	mov rdi,\
		bridge.attach
	mov rsi,\
		uzPlugName

	mov rcx,\
		top64_bridge
	mov rdx,rsi
	call rdi
	test rax,rax
	jz	.setup_libsE

	mov rcx,\
		bk64_bridge
	mov rdx,rsi
	call rdi
	test rax,rax
	jz	.setup_libsE

	mov rcx,\
		dock64_bridge
	mov rdx,rsi
	call rdi	
	test rax,rax
	jz	.setup_libsE

	mov rcx,rsi
	call sci.setupA
	mov [hSciDll],rax

.setup_libsE:
	pop rsi
	pop rdi
	ret 0

	;ü-----------------------------------------ö
	;|     SETUP_DIRS                          |
	;#-----------------------------------------ä

.setup_dirs:
	;--- in RCX curdir
	push rbp
	push rbx
	push rdi
	mov rbx,rcx

	;--- may be X64LABD or X64LAB ----
	lea rdx,[.dir.dir]
	mov rcx,uzClass
	call apiw.set_env

	mov rdi,appDir
	mov rbp,-DEF_DIRS

	xor r8,r8
	push uzToolName
	push uzTmpName
	push uzTemplName
	push uzProjName
	push uzPlugName
	;push uzMountName
	;push uzLogName
	push uzHelpName
	push uzConfName
	push uzBackName
	push r8

.setup_dirsB:
	lea rcx,[.dir.dir]
	pop rdx
	call wspace.set_dir
	mov [rdi],rax
	mov [rax+\
		DIR.type],DIR_DEFDIR

	or r8,1
	add rdi,8
	inc rbp
	jnz .setup_dirsB

	pop rdi
	pop rbx
	pop rbp
	ret 0

	;ü-----------------------------------------ö
	;|     SETUP_GUI                           |
	;#-----------------------------------------ä

.setup_gui:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12

	mov rbp,rsp
	sub rsp,\
		FILE_BUFLEN*2

	;---	mov rcx,SM_CXSMICON
	;---	call apiw.get_sysmet

	;---	;--- cxFont = ((x/4) + (x/2) )/2
	;---	mov edx,eax
	;---	shr eax,2
	;---	shr edx,1
	;---	add eax,edx
	;---	shr eax,1
	;---	adc eax,0
	;---	mov [ptMnuSize.cx],eax
		;--- menuitem cy = SM_CYMENU + 4 * SM_CYEDGE

	;---	xor ecx,ecx
	;---	call apiw.get_dc
	;---	push rax
	;---	push rax

	;---	mov rdx,LOGPIXELSY
	;---	mov rcx,rax
	;---	call apiw.get_devcaps
	;---	mov r12,rax

	;---	pop rcx
	;---	shl r12,32
	;---	mov rdx,LOGPIXELSX
	;---	call apiw.get_devcaps
	;---	or r12,rax

	;---	pop rdx
	;---	xor ecx,ecx
	;---	call apiw.rel_dc

	xor r9,r9
	mov r8,rsp
	mov edx,\
		sizeof.NONCLIENTMETRICSW
	mov [rsp+\
		NONCLIENTMETRICSW.cbSize],edx
	mov rcx,\
		SPI_GETNONCLIENTMETRICS	
	call apiw.sysparinfo
	
	lea rcx,[rsp+\
		NONCLIENTMETRICSW.lfMenuFont]
	call apiw.cfonti
	mov [hMnuFont],rax

	xor ecx,ecx
	call apiw.get_dc
	mov rdi,rax

	mov rdx,[hMnuFont]
	mov rcx,rdi
	call apiw.selobj
	mov rsi,rax

	mov rdx,rsp
	mov rcx,rdi
	call apiw.get_txtmetr

	mov eax,[rsp+\
		TEXTMETRIC.tmHeight]
	add eax,[rsp+\
		TEXTMETRIC.tmExternalLeading]
	inc eax
	mov [tmMnuSize.cy],eax

	mov eax,[rsp+\
		TEXTMETRIC.tmAveCharWidth]
	
	;--- pt = -LU * 72 / capsY
	;--- LU = - (pt * capsY / 72)
	;--------------------------------------
	;--- pt = - nLU * 72 / CAPS
	;--------------------------------------
	;--- 1pt = (1 / 6) LU
	;--- 12 pt = 16 pix      at 96dpi
	;--- 1 pix = (3 / 4) pt  at 96dpi
	;--- 1 LU = 96 pix
	;--- size pt = num LU * (3 / 4)
  ;--- example: nPt = 11 * (3 / 4) = 8.25
	;--- 12 : 16 = xPix : nPt
	;--- nPix = (4 / 3) * nPt

	;---	mov edx,eax
	;---	shl eax,1
	;---	add eax,edx
	;---	mov ecx,3
	;---	xor edx,edx
	;---	div ecx			;--- 
	;---	inc eax
	mov [tmMnuSize.cx],eax

	mov rdx,rsi
	mov rcx,rdi
	call apiw.selobj
	mov rdx,rdi
	mov rcx,[hMain]
	call apiw.rel_dc

	xor edx,edx
	mov rax,rsp
	;--- check for config\menu.utf8 file 
	push rdx
	push uzBmpExt
	push uzAppName
	push uzSlash
	push uzConfName
	push rax
	push rdx
	call art.catstrw

;---	mov rax,[lfMnuSize]
;---	movzx ecx,al
;---	shr rax,32
;---	mov ch,al
;---	xor edx,edx
;---	mov r8,uzCourierN
;---	call apiw.cfonti
;---	mov [hMnuFont],rax

	mov r11,LR_LOADFROMFILE\
		or LR_LOADTRANSPARENT\
		or LR_CREATEDIBSECTION
	mov r10,CLR_DEFAULT
	mov r9,30
	mov r8,16
	mov rdx,rsp
	xor ecx,ecx
	call iml.load_bmp
	mov [hBmpIml],rax

	mov rsp,rbp
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;ü-----------------------------------------ö
	;|     unset_libs                          |
	;#-----------------------------------------ä

.unset_libs:
	push rdi
	mov rdi,\
		bridge.detach

	mov rcx,\
		top64_bridge
	call rdi

	mov rcx,\
		dock64_bridge
	call rdi
	
	mov rcx,\
		bk64_bridge
	call rdi

	call sci.discard
	pop rdi
	ret 0

	;ü-----------------------------------------ö
	;|     DEF_LANG                            |
	;#-----------------------------------------ä

.def_lang:
	;--- in RCX langname
	;--- ret RAX bridge
	push rbx
	push rdi

	xor edx,edx
	sub rsp,\
		FILE_BUFLEN
	mov rax,rsp
	xor ebx,ebx

	;--- make lang\CURLANG
	push rdx
	push rcx
	push uzSlash
	push uzLangName
	push rax
	push rdx
	call art.catstrw

	mov rdx,rsp
	mov rcx,\
		lang_bridge
	call bridge.attach
	test rax,rax
	jz .def_langE

	mov rdi,[pTime]
	mov rbx,rax

	lea r8,[rdi+\
		SYSTIME.uzTmFrm]
	mov edx,U16
	mov ecx,UZ_TIMEFRM 
	call [lang.get_uz] 	;--- "HH':'mm':'ss"
	
	lea r8,[rdi+\
		SYSTIME.uzDtFrm]
	mov edx,U16
	mov ecx,UZ_DATEFRM 
	call [lang.get_uz] 	;--- "dddd','dd'.'MMMM'.'yyyy"

	mov rdi,[pConf]
	lea r8,[.conf.owner]
	mov edx,U16
	mov ecx,UZ_DEFUSER
	call [lang.get_uz] 	;--- "Mr.Biberkopf"

.def_langE:
	add rsp,\
		FILE_BUFLEN

	mov rax,rbx
	pop rdi
	pop rbx
	ret 0

.unset_lang:
	mov rcx,[pOmni]
	call art.a16free
	mov rcx,lang_bridge
	call bridge.detach
	ret 0

	;#---------------------------------------------------ö
	;|                   OPEN CONFIG config.utf8         |
	;ö---------------------------------------------------ü
.open:
	push rbp
	push rbx
	push rsi
	push rdi	;--- pConf
	push r12
	push r13	;--- for lang.dll

	mov rbp,rsp
	and rsp,-16

	sub rsp,\
		FILE_BUFLEN*2

	mov rdi,[pConf]

	mov eax,\
		CFG_DEF_LCID
	mov [.conf.lcid],ax

	mov rsi,\
		uzDefLang
	mov ecx,\
		uzDefLang.size
	mov rdx,rdi
	lea rdi,[.conf.lang16]
	mov r8,rdi
	rep movsb

	xchg rcx,r8
	xchg rdi,rdx
	call .def_lang
	mov r13,rax

	mov rax,CFG_POS
	mov [.conf.pos],rax

	mov rsi,\
		szDefLang
	mov ecx,\
		szDefLang.size
	mov rdx,rdi
	lea rdi,[.conf.lang8]
	rep movsb
	xchg rdx,rdi

	mov [.conf.fshow],\
		CFG_FSHOW

	mov [.conf.flog],\
		CFG_FLOG

	mov [.conf.fsplash],\
		CFG_FSPLASH

	mov [.conf.update],\
		CFG_UPDATE

	mov [.conf.cons.bkcol],\
		CFG_CONS_BKCOL

	mov [.conf.wspace.bkcol],\
		CFG_TREE_BKCOL

	mov [.conf.docs.bkcol],\
		CFG_DOCS_BKCOL

	mov [.conf.mpurp.bkcol],\
		CFG_MPURP_BKCOL

	;-------------------------
	mov [.conf.cons.pos],\
		CFG_CONS_POS

	mov [.conf.wspace.pos],\
		CFG_WSPACE_POS

	mov [.conf.mpurp.pos],\
		CFG_MPURP_POS

	mov [.conf.docs.pos],\
		CFG_DOCS_POS

	mov [.conf.edit.pos],\
		CFG_EDIT_POS

	;-------------------------
	mov [.conf.cons.flags],\
		CFG_CONS_FLAGS

	mov [.conf.wspace.flags],\
		CFG_WSPACE_FLAGS

	mov [.conf.mpurp.flags],\
		CFG_MPURP_FLAGS

	mov [.conf.docs.flags],\
		CFG_DOCS_FLAGS

	mov [.conf.edit.flags],\
		CFG_EDIT_FLAGS

	;-------------------------

	xor eax,eax
	mov edx,uzConfName
	mov rcx,rsp

	;--- open config/config.utf8 ----
	push rax
	push uzUtf8Ext
	push rdx
	push uzSlash
	push rdx
	push rcx
	push rax
	call art.catstrw

	mov rcx,rsp
	call [top64.parse]
	test rax,rax
	jz	.openL

	mov rbx,rax
	mov rsi,rax

.openA:
	mov eax,[rsi+\
		TITEM.hash]

	mov ecx,[rsi+\
		TITEM.attrib]

	mov rdx,rbx
	test ecx,ecx
	jz	.openB

	add rdx,rcx
	;	cmp eax,hash_version
	;	jz	.openV
	cmp eax,hash_fshow
	jz	.open_fshow
	cmp eax,hash_pos
	jz	.open_pos
	cmp eax,hash_session
	jz	.open_sess
	cmp eax,hash_wspace
	jz	.open_wsp
	cmp eax,hash_language
	jz	.open_lang
	cmp eax,hash_owner
	jz	.open_owner
	jmp	.openB

.open_fshow:
	xor eax,eax
	cmp ax,[rdx+\
		TITEM.len]
	jz	.openB

	cmp [rdx+\
		TITEM.type],\
		TNUMBER
	jnz	.openB
	mov eax,[rdx+\
		TITEM.lo_dword]
	and eax,\
		SW_SHOWMAXIMIZED
	mov [.conf.fshow],al
	jmp	.openB
	
.open_sess:
	mov r8,rdx
	xor eax,eax
	cmp ax,[r8+\
		TITEM.len]
	jz	.openB

	cmp [r8+\
		TITEM.type],\
		TNUMBER
	jnz	.openB
	mov eax,[r8+\
		TITEM.lo_dword]
	mov [.conf.session],eax
	jmp	.openB

.open_owner:
	mov r8,rdx
	xor eax,eax
	test r13,r13
	jz	.openB

	cmp ax,[r8+\
		TITEM.len]
	jz	.openB

	cmp [r8+\
		TITEM.type],\
		TQUOTED
	jnz	.openB

	cmp [r8+\
		TITEM.len],\
		FILE_BUFLEN-10h
	ja	.openB

	lea rdx,[.conf.owner]
	lea rcx,[r8+\
		TITEM.value]
	call utf8.to16
	jmp	.openB	

.open_lang:
	mov r8,rdx
	xor eax,eax

	cmp ax,[r8+\
		TITEM.len]
	jz	.openB

	cmp [r8+\
		TITEM.len],7
	ja	.openB

	lea rcx,[r8+\
		TITEM.value]

	mov r10,szDefLang
	mov eax,[r10]
	cmp eax,[rcx]
	jnz	.open_langA
	movzx eax,word[r10+4]
	cmp ax,word[rcx+4]
	jz	.openB

	;--- TODO: exaustive check on user language
	;--- file exist/try load it ---------------

.open_langA:
	push rcx	;--- save utf8 value
	lea rdx,[.conf.lang16]
	call utf8.to16

	mov rcx,lang_bridge
	call bridge.detach

	xor r13,r13
	lea rcx,[.conf.lang16]
	call .def_lang
	pop rcx
	test rax,rax
	jz	.openB
	mov r13,rax
	
	lea rdx,[.conf.lang8]
	call utf8.copyz

	jmp	.openB

.open_wsp:
	lea rcx,[rdx+\
		TITEM.value]
	lea rdx,[rsp+\
		FILE_BUFLEN]
	call utf8.to16
	;mov r12,rax
	;--- CF error

	;	lea rcx,[rsp+FILE_BUFLEN]
	;	call art.is_file
	;	jz	.openB

	mov r8,rax
	lea rcx,[rsp+\
		FILE_BUFLEN]
	lea rdx,[.conf.wsp]
	call art.xmmcopy
	jmp	.openB

.open_pos:
	;--- pos ------
	mov rax,qword[rdx+\
		TITEM.qword_val]
	mov [.conf.pos],rax
	jmp	.openB

.openB:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,rbx
	cmp rsi,rbx
	jnz	.openA

.openF:
	mov rcx,rbx
	call [top64.free]

.openL:
	xor eax,eax
	test r13,r13
	jz .openE
	call [lang.info_uz]
	mov [.conf.lcid],r10w

	@nearest 16,eax			;<--- ave size 16 aligned
	add eax,sizeof.OMNI
	@nearest 16,eax			
	shl eax,2
	mul ecx

	mov rcx,rax
	call art.a16malloc
	mov [pOmni],rax
	test rax,rax
	jnz .openE

	mov rcx,lang_bridge
	call bridge.detach
	xor eax,eax
	
.openE:
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|                   WRITE CONFIG x64lab             |
	;ö---------------------------------------------------ü

.write:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	mov rbp,rsp

	xor rax,rax
	@frame 8192+\
		FILE_BUFLEN*2

	mov rbx,[pConf]
	lea rdi,[rsp+\
		FILE_BUFLEN*2]

	mov al,09
	stosb

	;--- insert utf8 warning -------
	xor edx,edx
	mov ecx,UZ_INFO_UTF8
	call [lang.get_uz]
	mov rsi,rax
	rep movsb
	@do_eol
	
	mov al,09
	stosb
	;--- insert top info -------
	xor edx,edx
	mov ecx,UZ_INFO_TOP
	call [lang.get_uz]
	mov rsi,rax
	rep movsb
	@do_eol

	mov al,09
	stosb
	;--- insert copyright -------
	xor edx,edx
	mov ecx,UZ_INFO_COPYR
	call [lang.get_uz]
	mov rsi,rax
	rep movsb
	@do_eol
	@do_eol

	;--- version -----------
	mov al,09
	stosb
	mov esi,sz_version
	mov ecx,sz_version.size-1
	rep movsb
	mov ax,':"'
	stosw

	mov ecx,uzVers
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov al,'"'
	stosb
	@do_eol

	;--- session -----------
	mov al,09
	stosb
	mov esi,sz_session
	mov rcx,sz_session.size-1
	rep movsb
	mov ax,":0"
	stosw

	sub rsp,32
	mov rdx,rsp
	mov ecx,[rbx+CONFIG.session]
	inc rcx
	call art.qword2a
	mov rsi,rdx
	add rsi,rcx
	mov rcx,rax
	rep movsb
	mov al,"h"
	stosb
	@do_eol
	add rsp,32

	;--- wspace -----------
	mov al,09
	stosb
	mov esi,sz_wspace
	mov rcx,sz_wspace.size-1
	rep movsb
	mov ax,':"'
	stosw

	;--- copy what found. does not correct error
	;--- on bad path+fname ---------------------

	lea rcx,[rbx+CONFIG.wsp]
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov al,'"'
	stosb
	@do_eol
	
	;--- language -----------
	mov al,09
	stosb
	mov esi,sz_language
	mov rcx,sz_language.size-1
	rep movsb
	mov ax,':"'
	stosw

	lea rcx,[rbx+CONFIG.lang8]
	mov rdx,rdi
	call utf8.copyz
	add rdi,rax
	mov al,'"'
	stosb
	@do_eol


	;--- owner -----------
	mov al,09
	stosb
	mov esi,sz_owner
	mov rcx,sz_owner.size-1
	rep movsb
	mov ax,':"'
	stosw

	lea rcx,[rbx+CONFIG.owner]
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov al,'"'
	stosb
	@do_eol

	
	;--- fshow ----------------
	mov al,09
	stosb
	mov esi,sz_fshow
	mov rcx,sz_fshow.size-1
	rep movsb
	mov al,':'
	stosb

	sub rsp,32+\
		sizeof.WINDOWPLACEMENT

	mov [rsp+\
		WINDOWPLACEMENT.length],\
		sizeof.WINDOWPLACEMENT

	mov rdx,rsp
	mov rcx,[hMain]
	call apiw.get_winplacem

	mov eax,[rsp+\
		WINDOWPLACEMENT.showCmd]

	; SW_MINIMIZE 			;6
	; SW_RESTORE				;9
	; SW_SHOWMAXIMIZED	;3
	; SW_SHOWMINIMIZED	;2
	; SW_SHOWNORMAL			;1

	and eax,\
		SW_SHOWMAXIMIZED
	call art.b2a
	stosw
	@do_eol

	;--- pos ----------------
	mov al,09
	stosb
	mov esi,sz_pos
	mov rcx,sz_pos.size-1
	rep movsb
	mov ax,':0'
	stosw

	lea rax,[rsp+\
		WINDOWPLACEMENT.rcNormalPosition]

	;--- TODO wraparound xmm
	mov r8,[rax+8]
	sub r8,[rax]
	mov [rax+8],r8

	@rect2reg rcx,rax
	lea rdx,[rsp+\
		sizeof.WINDOWPLACEMENT]
	call art.qword2a
	mov rsi,rdx
	add rsi,rcx
	mov rcx,rax
	rep movsb
	mov al,"h"
	stosb
	@do_eol

	add rsp,32+\
		sizeof.WINDOWPLACEMENT

.writeF:
	xor eax,eax
	mov rcx,rsp
	mov edx,uzConfName

	push rax
	push uzUtf8Ext
	push rdx
	push uzSlash
	push rdx
	push rcx
	push rax
	call art.catstrw
	
	mov rcx,rsp
	call art.fcreate_rw

	test rax,rax
	jle	.writeE
	mov rbx,rax				;--- file handle

	mov r8,rdi
	lea rdx,[rsp+\
		FILE_BUFLEN*2]
	mov rcx,rax
	sub r8,rdx
	call art.fwrite

	mov rcx,rbx
	call art.fclose

.writeE:
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0


