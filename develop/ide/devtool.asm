  
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

devtool:
	virtual at rsi
		.io	IODLG
	end virtual

	virtual at r12
		.hu	HU
	end virtual

	virtual at rbx
		.dir	DIR
	end virtual

.start:
	;--- in RCX 0,dir
	;--- in RDX param top pointer item
	;--- ret RAX 0,IDOK

	test ecx,ecx
	jz	.startA

	xor r11,r11
	mov rax,[pIo]
	add rax,IO_DEVTOOL
	mov [rax+IODLG.param],rdx
	mov [rax+IODLG.ldir],rcx
	mov qword[rax+\
		IODLG.buf],r11

.startA:	
	xor r10,r10
	mov r9,.proc
	mov r8,[hMain]
	mov rdx,IO_DLG
	mov rcx,[hInst]
	call apiw.dlgbp
	ret 0

.proc:
@wpro rbp,\
		rbx rsi rdi

	cmp edx,\
		WM_INITDIALOG
	jz	.wm_initd
	cmp edx,\
		WM_COMMAND
	jz	.wm_command
	jmp	.ret0


.wm_command:
	mov rax,r8
	and eax,0FFFFh
	mov [.wparam],rax
	cmp ax,IDCANCEL
	jz	.id_cancel
	cmp ax,IDOK
	jz	.id_ok
	cmp ax,IO_BTN
	jz	.io_btn
	jmp	.ret0

.wm_initd:
	mov rcx,[.hwnd]
	call iodlg.set_pos

	mov rcx,[.hwnd]
	call iodlg.get_hwnds

	push 0            ;--- terminator
	push UZ_OK        ;--- IDOK
	push UZ_CANCEL    ;--- IDCANCEL 
	push UZ_CPNOSEL   ;--- IO_EDI
	push UZ_TOOLCMD   ;--- IO_STC3
	push UZ_TOOLPICK  ;--- IO_BTN
	push -1           ;--- IO_CBX
	push UZ_IO_KDIR   ;--- IO_STC2
	push UZ_TOOLDESCR ;--- IO_STC1
	push MI_DEVT_ADD  ;--- IO_DLG
	mov rcx,rsp

	call iodlg.set_strings

	mov rdx,[pIo]
	add rdx,IO_DEVTOOL
	mov rcx,[pHu]
	call iodlg.set_kdirs

	xor edx,edx
	mov rax,[pHu]
	mov rcx,[rax+HU.hEdi]
	call apiw.en_win

	jmp	.ret1

.io_btn:
	mov rsi,[pIo]
	add rsi,IO_DEVTOOL
	mov rbx,[pHu]
	lea rdi,[.io.buf]

	mov r9,rdi
	mov r8,0\
		or FOS_NODEREFERENCELINKS\
		or FOS_ALLNONSTORAGEITEMS\
		or FOS_PATHMUSTEXIST
	mov rcx,rbx
	call iodlg.set_browsedir

	mov eax,[rdi]
	test eax,eax
	jz	.ret0

	mov rcx,rdi
	call art.is_file
	jz	.ret0

	mov rcx,rdi
	call art.get_fname

	;--- RET EAX 0,numchars
	;--- RET ECX total len
	;--- RET EDX pname "file.asm"
	;--- RET R8 string

	test eax,eax	;--- err get_fname
	jz	.ret0

	cmp eax,ecx
	jz	.ret0		;--- nopath

	mov r9,rdx
	mov rcx,[rbx+HU.hEdi]
	call win.set_text

	jmp	.ret0

.id_ok:
.id_cancel:	
	mov rcx,[.hwnd]
	call iodlg.store_pos

	mov rdx,[pIo]
	add rdx,IO_DEVTOOL
	mov rcx,[pHu]
	call iodlg.store_lastdir
	
	mov rdx,[.wparam]
	mov rcx,[.hwnd]
	call apiw.enddlg
	jmp	.ret1

.ret1:				;message processed
	xor rax,rax
	inc rax
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.exit:
	@wepi


.discard:
	xor ecx,ecx
	xor eax,eax
	xchg rcx,[pTopDevT]
	mov [pTopDevT.dsize],eax
	mov [pTopDevT.items],eax
	test ecx,ecx
	jnz	.discardA
	ret 0

.discardA:	
	call [top64.free]
	ret 0

.reload:
	mov rcx,.loadD
	jmp	.loadR

.load:
	mov rcx,.loadL

.loadR:
	sub rsp,128+\
	 FILE_BUFLEN*2
	
	mov rax,rsp
	xor edx,edx
	push rcx

	;--- check load for [config\devtool.utf8]
	push rdx
	push uzUtf8Ext
	push uzDevTName
	push uzSlash
	push uzConfName
	push rax
	push rdx
	call art.catstrw
	ret 0

.loadL:
	;--- check file exists 
	mov rcx,rsp
	call art.is_file
	jz .loadD
	
.loadA1:
	mov rcx,rsp
	call [top64.parse]
	test rax,rax
	jnz	.loadF

	;--- file may contain work. preserve it by
	;--- copying it to tmp\XXXXXXXX.devtool.utf8
	;--- where XXXXXXXX is a ftime

	call art.tstamp
	call art.stamp2ft

	lea rdx,[rsp+\
		FILE_BUFLEN*2]
	mov rcx,rax
	call art.qword2a

	add rcx,rdx
	lea rdx,[rsp+64+\
		FILE_BUFLEN*2]
	call utf8.to16
	
	lea rdx,[rsp+\
		FILE_BUFLEN]
	xor eax,eax
	lea rcx,[rsp+64+\
		FILE_BUFLEN*2]

	push rax
	push uzUtf8Ext
	push uzDevTName
	push uzDot
	push rcx
	push uzSlash
	push uzTmpName
	push rdx
	push rax
	call art.catstrw

	xor r8,r8
	lea rdx,[rsp+\
		FILE_BUFLEN]
	mov rcx,rsp
	call apiw.copyf

.loadD:
	;--- create a default file
	mov rcx,rsp
	call .write

	mov rax,[pTopDevT]
	test rax,rax
	jz	.loadA1

	call .discard
	jmp	.loadA1

.loadF:
	;--- RET RCX datasize
	;--- RET RDX numitems

	mov [pTopDevT],rax
	mov [pTopDevT.dsize],ecx
	mov [pTopDevT.items],edx
	test edx,edx
	jz	.loadD

.loadE:
	add rsp,128+\
		FILE_BUFLEN*2
	ret 0


.write:
	;--- in RCX config\devtool.utf8
	push rbp
	push rbx
	push rsi
	push rdi
	push r12
	push r13
	mov rbp,rsp

	mov r12,rcx
	mov eax,[pTopDevT.items]
	or  al,4
	shl eax,4
	@nearest 64,eax
	add eax,1024
	add eax,[pTopDevT.dsize]
	@nearest 16,eax

	@frame rax
	mov rdi,rsp

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

	mov eax,[pTopDevT.items]
	test eax,eax
	jnz	.writeA

	;--- insert General tools -------
	mov eax,'	.:"'
	stosd

	xor edx,edx
	mov ecx,UZ_TOOLGEN
	call [lang.get_uz]
	mov rsi,rax
	rep movsb
	mov ax,'"('
	stosw
	@do_eol

	mov al,09h
	stosb
	mov al,")"
	stosb
	@do_eol

.writeA:
	mov rbx,[pTopDevT]
	xor eax,eax
	mov rsi,rbx
	test ebx,ebx
	jz	.writeW

	;--- write items and groups --------
.writeG:
	test [rsi+\
		TITEM.type],TOBJECT
	jnz	.writeG1

.writeGN:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,rbx
	cmp rsi,rbx
	jnz	.writeG
	jmp	.writeW

.writeG1:
	;--- output group ---
	test [rsi+\
		TITEM.type],\
		TDELETED
	jnz	.writeGN

	mov r8d,[rsi+\
		TITEM.attrib]
	test r8,r8
	jz	.writeGN

	add r8,rbx
	mov eax,'	.:"'
	stosd

	push rsi
	movzx ecx,[r8+\
		TITEM.len]
	lea rsi,[r8+\
		TITEM.value]
	rep movsb
	pop rsi

	mov ax,'"('
	stosw
	@do_eol

	;--- check for carrier param for item 
	;--- inside object CL=0 for it

	mov rcx,[rsi+\
		TITEM.param]
	and cl,1
	test [rsi+\
		TITEM.type],TPARAM
	jz	.writeG3
	test cl,cl
	jnz	.writeG3

.writeG4:	
	call .writeC

.writeG3:
	mov ecx,[rsi+\
		TITEM.child]
	test ecx,ecx
	jz	.writeG2

	add rcx,rbx
	call .writeT

.writeG2:
	mov al,09h
	stosb
	mov al,")"
	stosb
	@do_eol

	test [rsi+\
		TITEM.type],TPARAM
	jz	.writeGN
	mov rcx,[rsi+\
		TITEM.param]
	test cl,1
	jz	.writeGN

	mov eax,'	.:"'
	stosd
	and cl,0FEh
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov ax,'"('
	stosw
	mov al,")"
	stosb
	@do_eol
	jmp	.writeGN

.writeT:
	;--- in RCX tool child ----
	push rsi
	mov rsi,rcx

.writeT2:
	test [rsi+\
		TITEM.type],TLABEL
	jnz	.writeT1

.writeTN:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,rbx
	cmp rsi,rbx
	jnz	.writeT2
	jmp	.writeTE

.writeT1:
	;--- output item ------
	test [rsi+\
		TITEM.type],TDELETED
	jnz	.writeTN

	mov r8d,[rsi+\
		TITEM.attrib]
	test r8,r8
	jz .writeTN
	
	add r8,rbx
	mov ax,0909h
	stosw
	mov ax,'.:'
	stosw
	mov al,'"'
	stosb

	push rsi
	movzx ecx,[r8+\
		TITEM.len]
	lea rsi,[r8+\
		TITEM.value]
	rep movsb
	mov al,'"'
	stosb

	;--- param and value
	mov eax,",0h,"
	stosd
	mov al,'"'
	stosb
	mov rsi,szParam
	mov ecx,szParam.size-1
	rep movsb
	mov al,'"'
	stosb
	;-------------------

	pop rsi
	@do_eol

	test [rsi+\
		TITEM.type],TPARAM
	jz	.writeTN
	call .writeC
	jmp	.writeTN

.writeTE:
	pop rsi
	ret 0

.writeC:
	;--- write from carrier of param
	;--- in RSI item carrier
	mov rcx,[rsi+\
		TITEM.param]
	test ecx,ecx
	jnz	.writeC1
	ret 0

.writeC1:
	mov ax,0909h
	stosw
	mov ax,'.:'
	stosw
	mov al,'"'
	stosb
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov al,'"'
	stosb
	push rsi

	;--- param and value
	mov eax,",0h,"
	stosd
	mov al,'"'
	stosb
	mov rsi,szParam
	mov ecx,szParam.size-1
	rep movsb
	mov al,'"'
	stosb
	;-------------------
	pop rsi
	@do_eol
	ret 0


.writeW:
	mov rcx,r12
	call art.fcreate_rw
	inc eax
	jz .writeE
	dec eax
	mov rbx,rax				;--- file handle

	mov r8,rdi
	mov rdx,rsp
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


	;ü------------------------------------------ö
	;|     .ADDGROUP                            |
	;#------------------------------------------ä

.addgroup:
	;--- in RCX text
	push rbx
	push rdi
	push rsi
	push r12

	mov rsi,rcx
	mov rbx,[pMp]

	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.get_cursel

	mov edx,eax
	sub eax,1
	adc edx,0
	
	mov r12,rdx
	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.get_param
	test edx,edx
	jz	.addgroupE

	mov rdi,rdx		;--- in RDI param
	or [rdi+\
		TITEM.type],TPARAM
	or rsi,1			;--- mark this as object
	mov [rdi+\
		TITEM.param],rsi

	call .reload

	mov ecx,iCAT_CBX_DEVT
	call mpurp.sel_icat

	mov rcx,r12
	inc ecx
	call mpurp.sel_ifilt

.addgroupE:
	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0


	;ü------------------------------------------ö
	;|     .ADDTOOL                             |
	;#------------------------------------------ä

.addtool:
	push rbx
	push rdi
	push rsi
	sub rsp,\
		sizeof.LVITEMW+\
		FILE_BUFLEN

	mov rbx,[pMp]
	xor esi,esi

	cmp [rbx+\
		MPURP.idCat],MP_DEVT
	jz .addtoolB

	mov ecx,iCAT_CBX_DEVT
	call mpurp.sel_icat

.addtoolB:
	movzx edi,[rbx+\
		MPURP.iFilt]
	test edi,edi
	jnz	.addtoolB1

	inc edi
	mov ecx,edi
	call mpurp.sel_ifilt

.addtoolB1:
	mov edx,edi
	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.get_param
	test edx,edx
	jz	.addtoolE

	mov rsi,rdx		;--- in RSI param
	xor edi,edi		;--- in RDI 0,dir

	mov rcx,[rbx+\
		MPURP.hLview]
	call apiw.set_focus

.addtoolA:
	mov r9,\
		LVNI_SELECTED
	or r8,-1
	mov rcx,[rbx+\
		MPURP.hLview]
	call lvw.get_next

	inc rax
	jz	.addtoolC ;--- allow no selected tool
	dec rax

	xor r10,r10
	mov r8,rax
	mov r9,rsp
	mov [r9+\
		LVITEMW.iItem],eax
	mov [r9+\
		LVITEMW.iSubItem],r10d
	mov rcx,[rbx+\
		MPURP.hLview]
	call lvw.get_param

	mov rax,[rsp+\
		LVITEMW.lParam]
	test rax,rax
	jz	.addtoolE
	
	mov rsi,rax

	mov r8d,[rsi+\
		TITEM.attrib]
	test r8,r8
	jz	.addtoolE

	add r8,[pTopDevT]
	mov rdx,rsp
	lea rcx,[r8+\
		TITEM.value]
	call utf8.to16

	mov rcx,rsp
	call art.get_fname

	;--- RET EAX 0,numchars
	;--- RET ECX total len
	;--- RET EDX pname "file.asm"
	;--- RET R8 string

	xor edi,edi
	xor r8,r8
	test eax,eax	;--- err get_fname
	jz	.addtoolC

	cmp eax,ecx
	jz	.addtoolC		;--- nopath
	mov [rdx-2],r8w

	mov rcx,rsp
	call wspace.dir2hash
	jnc	.addtoolC
	mov rdi,rax
	
.addtoolC:
	mov rdx,rsi
	mov rcx,rdi
	call .start
	cmp eax,IDCANCEL
	jz	.addtoolE

	mov rax,[pIo]
	add rax,IO_DEVTOOL
	lea rdi,[rax+IODLG.buf]
	
	mov rcx,rdi
	call art.is_file
	jz	.addtoolE

	;--- mark the item we will use as 
  ;--- carrier of new toolpath

	test rsi,rsi
	jz	.addtoolE

	or [rsi+\
		TITEM.type],TPARAM
	mov [rsi+\
		TITEM.param],rdi

	call .reload

	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.get_cursel
	mov rdi,rax

	mov ecx,iCAT_CBX_DEVT
	call mpurp.sel_icat
	mov ecx,edi
	call mpurp.sel_ifilt

.addtoolE:
	add rsp,\
		sizeof.LVITEMW+\
		FILE_BUFLEN
	pop rsi
	pop rdi
	pop rbx
	ret 0

	;ü------------------------------------------ö
	;|     .REMGROUP                            |
	;#------------------------------------------ä
.remgroup:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13

	mov rbp,rsp
	and rsp,-16

	sub rsp,\
		FILE_BUFLEN*3

	mov rbx,[pMp]
	movzx eax,[rbx+\
		MPURP.idCat]

	test eax,eax
	jz	.remgroupE

	cmp eax,MP_DEVT
	jnz	.remgroupE

	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.get_cursel
	inc eax
	jz .remgroupE
	dec eax
	mov r13,rax

	mov edx,eax
	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.get_param
	test edx,edx
	jz	.remgroupE
	mov rsi,rdx

	mov eax,[rsi+\
		TITEM.attrib]
	test eax,eax
	jz .remgroupE	
	add rax,[pTopDevT]

;@break
	mov rdx,rsp
	lea rcx,[rax+TITEM.value]
	call utf8.to16

	mov rdi,rsp
	add rdi,rax
	@nearest 16,rdi
	
	mov r8,rdi
	mov edx,U16
	mov ecx,UZ_MSG_U_TGREM
	call [lang.get_uz]

	mov r12,rdi
	add r12,rax
	@nearest 16,r12

 	mov r8,rsp
	mov rdx,rdi
	mov rcx,r12
	sub rsp,20h
	call [swprintf]
	add rsp,20h

	mov r8,uzTitle
	mov rdx,r12
	mov rcx,[hMain]
	call apiw.msg_yn
	cmp eax,IDNO
	jz .remgroupE

	or [rsi+\
		TITEM.type],\
		TDELETED

	call devtool.reload

	mov rcx,[rbx+\
		MPURP.hLview]
	call lvw.del_all

	mov r8,r13
	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.del_item

	xor ecx,ecx
	call mpurp.sel_ifilt

.remgroupE:
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0


	;ü------------------------------------------ö
	;|     .REMTOOL                             |
	;#------------------------------------------ä

.remtool:
	push rbx
	push rdi
	push rsi
	sub rsp,\
		sizeof.LVITEMW

	mov rbx,[pMp]
	movzx eax,[rbx+\
		MPURP.idCat]
	test eax,eax
	jz	.remtoolE
	movzx ecx,[rbx+\
		MPURP.iFilt]
	cmp eax,MP_DEVT
	jnz	.remtoolE
	test ecx,ecx
	jz	.remtoolE

	mov r9,\
		LVNI_SELECTED
	or r8,-1
	mov rcx,[rbx+\
		MPURP.hLview]
	call lvw.get_next
	inc rax
	jz	.remtoolE
	dec rax

	mov r8,rax
	mov r9,rsp
	xor r10,r10
	mov [r9+\
		LVITEMW.iItem],eax
	mov [r9+\
		LVITEMW.iSubItem],r10d
	mov rcx,[rbx+\
		MPURP.hLview]
	call lvw.get_param

	mov rax,[rsp+\
		LVITEMW.lParam]
	test rax,rax
	jz	.remtoolE

	or [rax+\
		TITEM.type],TDELETED

	;------------------------
.remtoolA:
	call devtool.reload

	mov rcx,[rbx+\
		MPURP.hCbxCat]
	call cbex.get_cursel
	mov rsi,rax

	mov rcx,[rbx+\
		MPURP.hCbxFilt]
	call cbex.get_cursel
	mov rdi,rax
	
	mov ecx,iCAT_CBX_DEVT
	call mpurp.sel_icat
	mov ecx,edi
	call mpurp.sel_ifilt

.remtoolE:
	add rsp,\
		sizeof.LVITEMW
	pop rsi
	pop rdi
	pop rbx
	ret 0


