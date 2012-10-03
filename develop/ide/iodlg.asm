  
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
iodlg:
	virtual at rsi
		.io	IODLG
	end virtual

	virtual at r12
		.hu	HU
	end virtual

	virtual at rbx
		.dir	DIR
	end virtual

	;#---------------------------------------------ö
	;|                IODLG                        |
	;ö---------------------------------------------ü
.start:
	;--- in RCX pBufLen string set
	;--- in RDX param
	;--- ret RAX 0,IDOK
	push rsi
	push rdx

	mov rsi,[pIo]
	add rsi,rcx
	mov [.io.set],cx
	pop [.io.param]

.startA:
	mov r10,rsi		;--- param
	mov r9,.proc
	mov r8,[hMain]
	mov rdx,IO_DLG
	mov rcx,[hInst]
	call apiw.dlgbp

.startE:
	pop rsi
	ret 0

.proc:
@wpro rbp,\
		rbx rsi rdi r12 r13

	cmp rdx,\
		WM_INITDIALOG
	jz	.wm_initd
	cmp rdx,\
		WM_COMMAND
	jz	.wm_command
	jmp	.ret0

.wm_command:
	mov rax,r8
	and eax,0FFFFh
	cmp ax,IDCANCEL
	jz	.id_cancel
	cmp ax,IDOK
	jz	.id_ok
	cmp ax,IO_BTN
	jz	.io_btn
	jmp	.ret0

.io_btn:
	xor r9,r9
	mov r8,FOS_PICKFOLDERS\
	 or FOS_NODEREFERENCELINKS\
	 or FOS_PATHMUSTEXIST

	mov rcx,[pHu]
	call .set_browsedir
	jmp	.ret0

	
.id_ok:
.id_cancel:
	mov r12,[pHu]
	mov rbx,rax
	mov rdi,rcx

	call .store_pos

	mov rcx,rdi
	call apiw.get_wldata
	test rax,rax
	jz	.id_cancelA
	mov rsi,rax

	mov rcx,[pHu]
	mov rdx,rsi
	call .store_lastdir

	sub rsp,\
		FILE_BUFLEN

	xor r8,r8
	lea rdx,[.io.buf]
	mov [rdx],r8

	mov r9,rsp
	mov rcx,[.hu.hEdi]
	call win.get_text
	test eax,eax
	jz	.id_cancelA

	lea rdx,[.io.buf]
	mov rcx,rsp
	call utf16.copyz
	mov [.io.buflen],ax
	
.id_cancelA:	
	mov rdx,rbx
	mov rcx,rdi
	call apiw.enddlg
	jmp	.ret1

.wm_initd:
	mov r12,[pHu]
	mov eax,IDCANCEL
	mov rsi,r9
	mov rbx,rcx
	test r9,r9
	jz	.id_cancel

	mov r8,r9
	call apiw.set_wldata

	mov rcx,rbx
	call .get_hwnds

	movzx eax,[.io.set]

	sub rsp,\
		FILE_BUFLEN
	mov rdi,rsp

	cmp ax,IO_SAVECUR
	jz	.wm_initdIOSC
	cmp ax,IO_NEWNAME
	jz	.wm_initdIONN
	cmp ax,IO_SAVEWSP
	jz	.wm_initdWSPS
	cmp ax,IO_NEWLNK
	jz	.wm_initdNL
	jmp .wm_initdF

.wm_initdNL:
	;--- IO_NEWLNK set ---
	push 0
	push [.hu.hStc1]
	push UZ_LNK_DESC
	push [.hu.hStc2]
	push UZ_IO_KDIR
	push [.hu.hBtn]
	push MI_PA_BROWSE
	push [.hu.hStc3]
	push UZ_LNK_MAP
	push [.hu.hEdi]
	push UZ_LNK_NAME
	push rbx
	push UZ_INFO_LNK
	push [.hu.hOk]
	push UZ_OK
	push [.hu.hCanc]
	mov ecx,UZ_CANCEL
	jmp .wm_initdB
	
.wm_initdWSPS:
	;--- IO_SAVEWSP set ---
	push 0
	push [.hu.hStc1]
	push UZ_IO_SELDPF
	push [.hu.hStc2]
	push UZ_IO_DPATH
	push [.hu.hBtn]
	push MI_PA_BROWSE
	push [.hu.hStc3]
	push UZ_IO_DFNAME
	push [.hu.hEdi]
	push UZ_WSP_EXT
	push rbx
	push UZ_IO_SAVEWSP
	push [.hu.hOk]
	push UZ_OK
	push [.hu.hCanc]
	mov ecx,UZ_CANCEL
	jmp .wm_initdB
	
.wm_initdIONN:
	;--- IO_NEWNAME set ---
	push 0
	push [.hu.hStc1]
	push UZ_IO_SELDPF
	push [.hu.hStc2]
	push UZ_IO_DPATH
	push [.hu.hBtn]
	push MI_PA_BROWSE
	push [.hu.hStc3]
	push UZ_IO_DFNAME
	push [.hu.hEdi]
	push UZ_IO_EXT
	push rbx
	push MI_FI_NEWF
	push [.hu.hOk]
	push UZ_OK
	push [.hu.hCanc]
	mov ecx,UZ_CANCEL
	jmp .wm_initdB

.wm_initdIOSC:
	;--- IO_SAVECUR set ---
	push 0
	push [.hu.hStc1]
	push UZ_IO_SELDPF
	push [.hu.hStc2]
	push UZ_IO_DPATH
	push [.hu.hBtn]
	push MI_PA_BROWSE
	push [.hu.hStc3]
	push UZ_IO_DFNAME
	push [.hu.hEdi]
	push UZ_IO_EXT
	push rbx
	push MI_FI_SAVE
	push [.hu.hOk]
	push UZ_OK
	push [.hu.hCanc]
	mov ecx,UZ_NO

.wm_initdB:
	;--- set strings --------
	mov r8,rdi
	mov edx,U16
	call [lang.get_uz]

	mov r9,rdi
	pop rcx
	call win.set_text

	pop rcx
	test ecx,ecx
	jnz	.wm_initdB

	mov rsp,rdi
	mov rcx,rbx
	call .set_pos

	mov rdx,rsi
	mov rcx,[pHu]
	call .set_kdirs

	;--- try set edit
	mov rax,qword[.io.buf]
	test rax,rax
	jz	.wm_initdE1

	lea r9,[.io.buf]
	mov rcx,[.hu.hEdi]
	call win.set_text

.wm_initdE1:
	;--- try set param
	mov rax,[.io.param]
	test rax,rax
	jz	.wm_initdF

	cmp [.io.set],\
		IO_SAVECUR
	jnz	.wm_initdF

	;--- param is LABFILE for IO_SAVECUR
	lea r9,[rax+\
		sizeof.LABFILE]
	mov rcx,[.hu.hStc1]
	call win.set_text
	
.wm_initdF:	

.ret1:				;message processed
	xor rax,rax
	inc rax
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.exit:
	@wepi

	;#---------------------------------------------ö
	;|             .SET_POS                        |
	;ö---------------------------------------------ü

.set_pos:
	;--- in RCX hDlg
	push rbx
	push r12

	mov rbx,rcx
	mov r12,[pHu]

	mov rax,[.hu.rc]
	test rax,rax
	jnz	.set_posA
	mov rax,[.hu.rc+8]
	test rax,rax
	jnz	.set_posA
	call .store_pos

.set_posA:
	mov eax,SWP_NOZORDER
	mov r11d,[.hu.rc.bottom]
	sub r11d,[.hu.rc.top]
	mov r10d,[.hu.rc.right]
	sub r10d,[.hu.rc.left]
	mov r9d,[.hu.rc.top]
	mov r8d,[.hu.rc.left]
	mov rdx,HWND_TOP
	mov rcx,rbx
	call apiw.set_wpos

	pop r12
	pop rbx
	ret 0

	;#---------------------------------------------ö
	;|             .STORE_POS                      |
	;ö---------------------------------------------ü

.store_pos:
	;--- IN RCX hDialog
	sub rsp,\
		sizeof.RECT
	mov rdx,rsp
	call apiw.get_winrect

	mov rcx,[pHu]
	lea rdx,[rcx+HU.rc]

	mov rax,[rsp]
	mov [rdx],rax
	mov rax,[rsp+8]
	mov [rdx+8],rax
	add rsp,\
		sizeof.RECT
	ret 0


	;#---------------------------------------------ö
	;|             .SET_BROWSEDIR                  |
	;ö---------------------------------------------ü

.set_browsedir:
	;--- in RCX pHu
	;--- in R8 flags dialog
	;--- in R9 ret buffer
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	sub rsp,\
		FILE_BUFLEN

	mov rdi,rsp
	xor esi,esi
	mov r12,rcx
	xor eax,eax
	test r9,r9
	mov r13,r8


	cmovnz rdi,r9
	cmovnz rsi,r9
	stosq

	mov rcx,[.hu.hCbx]
	call cbex.get_cursel
	mov rdx,rax
	inc rax
	jz	.set_browsdirE

	mov rcx,[.hu.hCbx]
	mov r8,rsp
	call cbex.get_item
	test rdx,rdx
	jz	.set_browsdirE

	mov r10,[rdx+DIR.rdir]
	lea r9,[rdx+DIR.dir]
	test [rdx+DIR.type],\
		DIR_HASREF
	jz	.set_browsdirB
	lea r9,[r10+DIR.dir]

.set_browsdirB:
	mov r8,r13
	xor edx,edx
	xor ecx,ecx
	call [dlg.open]
	test rax,rax
	jz	.set_browsdirE
	mov rdi,rax

	test esi,esi
	jz	.set_browsdirB1

	mov rdx,rsi
	mov rcx,rax
	call utf16.copyz

.set_browsdirB1:
	test r13,FOS_PICKFOLDERS
	jnz	.set_browsdirC

	mov rcx,rdi
	call art.get_fname

	;--- RET EAX 0,numchars
	;--- RET ECX total len
	;--- RET EDX pname "file.asm"
	;--- RET R8 string

	xor r11,r11
	test eax,eax	;--- err get_fname
	jz	.set_browsdirF
	cmp eax,ecx
	jz	.set_browsdirF		;--- nopath
	mov [rdx-2],r11w

.set_browsdirC:
	xor r8,r8
	xor edx,edx
	mov rcx,rdi				;--- path+fname
	call wspace.set_dir
	test eax,eax
	jz	.set_browsdirF

	;--- bug: on no selection on Explorer's root (edit = "Computer") gets back
	;--- C:\Users\marc\AppData\Roaming\Microsoft\Windows\Network Shortcuts
	;--- but no Computer exists

	mov rbx,rax
	mov rdx,rax
	mov rcx,[.hu.hCbx]
	call cbex.is_param
	mov r8,rax
	inc rax
	jnz	.set_browsdirF

	mov rcx,rbx
	call .fill_kdirs
	mov r8,rcx

.set_browsdirA:
	mov rcx,[.hu.hCbx]
	call cbex.sel_item

.set_browsdirF:
	mov rcx,rdi
	call apiw.co_taskmf

.set_browsdirE:
	add rsp,\
		FILE_BUFLEN
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0

	;#---------------------------------------------ö
	;|             .STORE_LASTDIR                  |
	;ö---------------------------------------------ü

.store_lastdir:
	;--- in RCX pHu
	;--- in RDX pIo referenced
	push rsi
	push r12

	mov r12,rcx
	mov rsi,rdx

	mov rcx,[.hu.hCbx]
	call cbex.get_cursel
	mov rdx,rax
	inc rax
	cmovz rdx,rax

	mov rcx,[.hu.hCbx]
	call cbex.get_param
	inc rax
	cmovz rdx,rax
	mov [.io.ldir],rdx

	pop r12
	pop rsi
	ret 0

	;#---------------------------------------------ö
	;|             .SET_KDIRS                      |
	;ö---------------------------------------------ü
.set_kdirs:
	;--- in RCX pHu
	;--- in RDX pIo

	push rsi
	push r12

	mov r12,rcx
	mov rsi,rdx

	;--- set imagelists on known directories
	mov r9,[hsmSysList]
	mov rcx,[.hu.hCbx]
	call cbex.set_iml

	;--- set known dirs
	xor edx,edx
	mov rcx,.fill_kdirs
	call wspace.list_dir

	;--- try set last dir
	mov r8,[.io.ldir]
	test r8,r8
	jz	.set_kdirsE

	mov rdx,r8
	mov rcx,[.hu.hCbx]
	call cbex.is_param
	mov r8,rax
	inc rax
	cmovz r8,rax

.set_kdirsE:
	;--- select default kdir
	mov rcx,[.hu.hCbx]
	call cbex.sel_item

	pop r12
	pop rsi
	ret 0

	;#---------------------------------------------ö
	;|             .FILL_KDIRS                     |
	;ö---------------------------------------------ü

.fill_kdirs:
	;--- in RCX dir
	;--- in R12 pHu

	;--- in RCX hCb
	;--- in RDX string
	;--- in R8 imgindex
	;--- in R9 param
	;--- in R10 indent r10b,index overlay rest R10)
	;--- in R11 selimage

	push rbx
	mov rbx,rcx
	lea rdx,[.dir.dir]
	mov r11d,[.dir.iIcon]
	xor r10,r10
	mov r9,rbx
	mov r8d,[.dir.iIcon]
	mov rcx,[.hu.hCbx]
	call cbex.ins_item
	mov ecx,eax
	xor eax,eax
	inc eax
	pop rbx
	ret 0


	;#---------------------------------------------ö
	;|             .SET_STRINGS                    |
	;ö---------------------------------------------ü

.set_strings:
	;--- in RCX stack of this reference
	;--- 
	; termin  0
	; button  IDOK
	; button  IDCANCEL
	; edit    IO_EDI
	; static  IO_STC3
	; button  IO_BTN
	; cbx     IO_CBX
	; static  IO_STC2
	; static  IO_STC1
	; caption IO_DLG

	push rbp
	push rbx
	push rdi
	push rsi
	mov rbp,rsp

	sub rsp,\
		FILE_BUFLEN

	mov rdi,rsp
	mov rsi,rcx
	mov rax,[pHu]
	lea rbx,[rax+HU.hDlg-8]

.set_stringsA:
	mov rcx,rax
	mov r8,rdi
	inc rax
	mov edx,U16
	jz .set_stringsB
	call [lang.get_uz]

	mov r9,rdi
	mov rcx,[rbx]
	call win.set_text

.set_stringsB:
	lodsq
	add rbx,8
	test rax,rax
	jnz .set_stringsA

.set_stringsE:
	mov rsp,rbp
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------ö
	;|             .GET_HWNDS                      |
	;ö---------------------------------------------ü

.get_hwnds:
	;--- in RCX hDlg
	push rdi
	push r12

	mov rax,rcx
	mov r12,[pHu]
	lea rdi,[.hu.hDlg]
	stosq

	push 0
	push IDOK
	push IDCANCEL
	push IO_EDI
	push IO_STC3
	push IO_BTN
	push IO_CBX
	push IO_STC2
	mov edx,IO_STC1

.get_hwndsA:	
	mov rcx,[.hu.hDlg]
	call apiw.get_dlgitem
	pop rdx
	stosq
	test edx,edx
	jnz .get_hwndsA

	pop r12
	pop rdi
	ret 0
