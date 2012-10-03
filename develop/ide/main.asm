  
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


	display "- infos: ",13,10
	define status 0
	match =TRUE,DEBUG	{
		display "--- Compile DEBUG ",13,10
		define status 1
	}
	match =0,status {
		display "--- Compile RELEASE "
		match v,VERSION \{
				display "[",\`v,"]",13,10 \}
		define DEBUG FALSE
		define status 1
	}

	match =TRUE,DEBUG	{
		format PE64 CONSOLE 5.0
	}
	match =FALSE,DEBUG	{
		format PE64 GUI 5.0
	}
	STACK_SIZE equ 1000'0000h
	STACK_LIMIT equ 11000h
	heap	1000000h
	stack	STACK_SIZE
	entry start

	;#----------------------------------------ö
	;--- [Dienstag] - 19.Juni.2012 - 10:47:15
	;ä----------------------------------------ü

	include "macro\mrk_macrow.inc"
	include "macro\com_macro.inc"
	include "plugin\dock64\equates.inc"
	include "plugin\top64\equates.inc"
	include "plugin\bk64\equates.inc"

	include "x64lab.equ"
	include "structs.inc"
	include "shared\art.equ"
	include "lang\lang.inc"
	include "shared\shobjidl.inc"

	;-----------------------------------
	include "data.inc"
	include "shared\art.inc"
	include "bridge.inc"
	include "shared\unicode.inc"
	include "shared\scintilla.inc"
	
section '.code' code readable executable
	include "shared\api.asm"
	include "shared\art.asm"
	include "shared\bridge.asm"
	include "shared\unicode.asm"

	include "config.asm"
	include "window.asm"
	include "edit.asm"
	include "menu.asm"
	include "tree.asm"
	include "accel.asm"
	include "console.asm"
	include "mpurp.asm"
	include "sciwrap.asm"
	include "wspace.asm"
	include "iodlg.asm"
	include "devtool.asm"
	include "ext.asm"
	include "lang.asm"

start:
	;	call get_version
	;	call win.ask_tar
	;	call win.err_notar
	push rbp
	push rbx
	push rdi
	push rsi
	push r15
	mov rbp,rsp

	call config.setup_libs
	test rax,rax
	jz	.err_start

	mov eax,\
		sizeof.DIR+\
		400h*8+\	;--- dirHash
		80h*8+\		;--- envHash
		100h*8+\	;--- extHash
		((MI_OTHER-MNU_X64LAB) * sizeof.KEYA)+\
		sizeof.SYSTIME+\
		sizeof.HU+\
		sizeof.CONFIG+\
		sizeof.CONS+\
		sizeof.KEYDLG+\
		sizeof.MPURP+\
		(sizeof.IODLG*5)+\
		sizeof.EDIT

	@frame rax
	mov rdx,rax
	call art.zeromem

	mov rdx,curDir
	mov rax,rsp
	mov r8,NUM_ITEMS
@@:
	mov rcx,[rdx]
	mov [rdx],rax
	add rdx,8
	add rax,rcx
	dec r8
	jnz @b

	virtual at rbx
		.dir DIR
	end virtual

	xor rcx,rcx
	mov rbx,[curDir]
	lea rdx,[.dir.dir]
	call art.get_appdir
	mov [.dir.cpts],ax

	mov rcx,rbx
	call config.setup_dirs

	xor rcx,rcx
	call apiw.get_modh
	mov	[hInst],rax
	
	;	call art.cmdline
	;	mov [pCmdline],rax
	;	call ext.setup

	call config.open
	test eax,eax
	jz	.err_start

	call config.setup_gui
	call ext.setup

.winmain:
	mov ecx,\
		sizea16.WNDCLASSEXW\
		+10h 				;--- later use with CreateWindow and MSG
	sub rsp,rcx
	mov rbx,rsp

	virtual at rbx
		.wcx WNDCLASSEXW
	end virtual

	shr ecx,3
	mov rdi,rsp
	xor eax,eax
	rep stosq

	mov rax,[hInst]
	mov [.wcx.hInstance],rax
	mov [.wcx.cbSize],\
		sizeof.WNDCLASSEXW

	xor edx,edx
	mov rcx,\
		ICC_BAR_CLASSES or \
		ICC_PROGRESS_CLASS or \
		ICC_TREEVIEW_CLASSES or \
		ICC_TAB_CLASSES or \
		ICC_USEREX_CLASSES or \
		ICC_LISTVIEW_CLASSES
	call apiw.icex

	mov rdx,ICO_X64LAB
	mov rcx,[hInst]
	call apiw.loadicon

	mov	[.wcx.hIcon],rax
	mov	[.wcx.hIconSm],rax

	call mnu.setup

	mov edx,IDC_ARROW
	xor ecx,ecx
	call apiw.loadcurs

	mov	[.wcx.hCursor],rax
	mov [.wcx.lpfnWndProc],\
		winproc
	mov [.wcx.lpszClassName],\
		uzClass
	mov [.wcx.hbrBackground],\
		COLOR_BTNFACE+1

	mov rcx,rbx
	call apiw.regcls
	test rax,rax
	jz .err_startC

	xor ecx,ecx

	virtual at rsi
		.conf CONFIG
	end virtual

	mov rsi,[pConf]

	mov [rbx+58h],rcx
	mov rax,[hInst]
	mov [rbx+50h],rax

	mov rax,[hMnuMain]
	mov [rbx+48h],rax
	mov [rbx+40h],rcx

	sub rsp,16
	mov rax,[.conf.pos]
	@reg2rect rsp,rax

	mov eax,[rsp+RECT.bottom]
	mov [rbx+38h],rax
	mov eax,[rsp+RECT.right]
	mov [rbx+30h],rax
	mov eax,[rsp+RECT.top]
	mov [rbx+28h],rax
	mov eax,[rsp+RECT.left]
	mov [rbx+20h],rax
	add rsp,16

	mov r9,\
		WS_OVERLAPPEDWINDOW \
		or WS_CLIPCHILDREN ;or WS_CLIPSIBLINGS
	mov r8,uzTitle
	mov rdx,uzClass
	mov rcx,WS_EX_WINDOWEDGE 
	call [CreateWindowExW]
	test rax,rax
	jz .err_startD
	mov rdi,rax

	movzx rdx,\
		[.conf.fshow]
	mov rcx,rdi
	call apiw.show

	mov rcx,rdi
	call apiw.update

	call accel.setup
	mov [hAccel],rax

	mov rsi,rsp
	lea rdi,[rbx+20h]

.begin_msg_loop:
	xor r9,r9
	xor r8,r8
	xor edx,edx
	mov rsp,rbx
	mov rcx,rdi
	call [GetMessageW]
	test eax,eax
	jz	.end_msg_loop

	mov rdx,[hAccel]
	test rdx,rdx
	jz	.no_accel

	mov r8,rdi
	mov rcx,[hMain]
	call [TranslateAcceleratorW]
	test eax,eax
	jnz	.begin_msg_loop

.no_accel:
	mov rcx,rdi
	call [TranslateMessage]

	mov rcx,rdi
	call [DispatchMessageW]
	jmp	.begin_msg_loop

	;.err_winmain:
	;	sub rsp,20h
	;	mov r9,MB_ICONERROR+MB_OK
	;	xor r8,r8
	;	mov rdx,0;_error
	;	xor rcx,rcx
	;	call [MessageBoxExW]

.end_msg_loop:
	mov rsp,rsi

.err_startD:
	mov rcx,[hAccel]
	test rcx,rcx
	jz	.err_startD1
	call apiw.destroy_acct

.err_startD1:
	;--- error windowing
	mov rcx,[hMnuMain]
	call apiw.mnu_destroy

	mov rcx,[hBmpIml]
	call iml.destroy

.err_startC:
	;--- error registering

.err_startB:
	;--- error loading sci

.err_start:
	call ext.discard
	call config.unset_lang
	call config.unset_libs

.err_startA:
	mov rsp,rbp
	pop r15
	pop rsi
	pop rdi
	pop rbx
	pop rbp

	xor ecx,ecx
	call apiw.exitp
	;--- ret 0

	;ü------------------------------------------ö
	;|     WINPROC                              |
	;#------------------------------------------ä
	
winproc:
	virtual at rbx
		.labf LABFILE
	end virtual

	virtual at rbx
		.dir DIR
	end virtual

	virtual at rbx
		.conf CONFIG
	end virtual

	virtual at rsi
		.io	IODLG
	end virtual

	@wpro rbp,\
		rbx rdi rsi
	cmp edx,\
		WM_WINDOWPOSCHANGED
	jz	.wm_poschged
	cmp edx,WM_DRAWITEM
	jz	.wm_drawitem
	cmp edx,WM_NOTIFY
	jz	.wm_notify
	cmp edx,WM_COMMAND
	jz	.wm_command
	cmp	edx,WM_DESTROY
	jz	.wm_destroy
	cmp edx,WM_CREATE
	jz	.wm_create
	cmp edx,WM_MEASUREITEM
	jz	.wm_measitem
	cmp edx,WM_SYSCOMMAND
	jz	.wm_syscomm
	cmp edx,WM_INITMENUPOPUP
	jz	.wm_init_mnp
	cmp edx,WM_CLOSE
	jz	.wm_close
	cmp edx,\
		WM_QUERYENDSESSION
	jz	.wm_close
	jmp	.defwndproc

.wm_init_mnp:
	cmp r8,[tMP_LANG]
	jnz	.ret0

	;ü------------------------------------------ö
	;|     MP_LANG                             |
	;#------------------------------------------ä

.mp_lang:
	call lang.enum
	jmp	.ret0

	;ü------------------------------------------ö
	;|     WM_CLOSE                             |
	;#------------------------------------------ä

.wm_close:
	mov rcx,ASK_SAVE
	call wspace.save_docs
	test rax,rax
	jle .ret0

	call wspace.check
	test eax,eax
	jle .ret0

	sub rsp,\
		FILE_BUFLEN

	xor edx,edx
	mov rax,rsp

	;--- write [config\docking.bin]
	push rdx
	push uzBinExt
	push uzDocking
	push uzSlash
	push uzConfName
	push rax
	push rdx
	call art.catstrw	

	mov rdx,rsp
	mov rcx,[hDocker]
	call [dock64.save]

	xor eax,eax
	inc eax
	jmp	.defwndproc

.wm_syscomm:
	;---  follow ------
.wm_poschged:
	mov r9,[.lparam]
	mov r8,[.wparam]
	mov rdx,[.msg]
	mov rcx,[hDocker]
	call [dock64.layout]
	jmp	.defwndproc

.wm_command:
	mov eax,r8d
	cmp ax,MI_FI_OPEN
	jz	.mi_fi_open
	cmp ax,MI_FI_SAVE
	jz	.mi_fi_save
	cmp ax,MI_FI_NEWF
	jz	.mi_fi_newf
	cmp ax,MI_FI_NEWB
	jz	.mi_fi_newb
	cmp ax,MI_FI_IMP
	jz	.mi_fi_imp
	cmp ax,MI_FI_CLOSE
	jz	.mi_fi_close
	cmp ax,MI_WS_SAVE
	jz	.mi_ws_save
	cmp ax,MI_WS_LOAD
	jz	.mi_ws_load
	cmp ax,MI_WS_NEW
	jz	.mi_ws_new
	cmp ax,MI_WS_EXIT
	jz	.mi_ws_exit
	cmp ax,MI_ED_LNK
	jz	.mi_ed_lnk
	cmp ax,MI_ED_REMITEM
	jz	.mi_ed_remitem
	cmp ax,MI_DEVT_ADD
	jz	.mi_devt_add
	cmp ax,MI_DEVT_REM
	jz	.mi_devt_rem
	cmp ax,MI_DEVT_MAN
	jz	.mi_devt_man
	cmp ax,MI_DEVT_REL
	jz	.mi_devt_rel
	cmp ax,MI_DEVT_REMG
	jz	.mi_devt_remg
	cmp ax,MI_DEVT_ADDG
	jz	.mi_devt_addg
	cmp ax,MI_PA_BROWSE
	jz	.mi_pa_browse
	cmp ax,MI_ED_RELSCICLS
	jz	.mi_ed_relscicls
	cmp ax,MI_CONF_KEY
	jz	.mi_conf_key
	cmp ax,MI_SCI_COMML
	jz	.mi_sci_comml
	cmp ax,MI_SCI_UNCOMML
	jz	.mi_sci_uncomml

	;--- language items
	cmp ax,MI_LANG
	jb	.defwndproc
	cmp ax,MI_LANG+255
	ja	.defwndproc

.mi_lang:
	sub rsp,\
		sizea16.MENUITEMINFOW

	mov r9,rsp
	mov [r9+\
		MENUITEMINFOW.fMask],\
		MIIM_DATA
	mov edx,eax
	mov rcx,[tMP_LANG]
	call apiw.mni_get_byid

	mov rcx,[rsp+\
		MENUITEMINFOW.dwItemData]
	test rcx,rcx
	jz	.ret0

	mov rdx,[pConf]
	cmp cx,[rdx+\
		CONFIG.lcid]
	jz	.ret0

	call lang.reload
	cmp eax,IDNO
	jnz	.mi_ws_exit
	jmp	.ret0


	;ü------------------------------------------ö
	;|     MI_SCI_UNCOMMLine                      |
	;#------------------------------------------ä
	;ü------------------------------------------ö
	;|     MI_SCI_COMMLine                      |
	;#------------------------------------------ä
.mi_sci_uncomml:
	mov rdi,\
		sci.uncommline
	jmp	.mi_sci_commlA

.mi_sci_comml:
	mov rdi,\
		sci.commline

.mi_sci_commlA:

	mov rsi,[pEdit]
	mov rbx,\
		[rsi+EDIT.curlabf]
	cmp rbx,\
		[rsi+EDIT.deflabf]
	jz	.ret0
	test [rbx+\
		LABFILE.type],LF_TXT
	jz	.ret0

	lea rcx,[rbx+\
		sizeof.LABFILE]

	;--- get "ext" hash from [myfile.ext]
	call ext.fe2hash
	test eax,eax
	jz	.ret0

	;--- check for EXT_SLOT of "ext" hash
	mov rcx,rax
	call ext.is_ext
	test eax,eax
	jz	.ret0

	;--- check for class hash id
	mov rcx,[rax+\
		EXT_SLOT.clsid]
	test rcx,rcx
	jz	.ret0
	call ext.is_class
	test rax,rax
	jz	.ret0

	mov rdx,rax
	mov r8,rdi
	mov rcx,[rbx+\
		LABFILE.hSci]
	call sci.comment
	jmp	.ret0

	;ü------------------------------------------ö
	;|     MI_CONF_KEY                          |
	;#------------------------------------------ä

.mi_conf_key:
	xor r10,r10
	mov r9,accel.proc
	mov r8,[hMain]
	mov rdx,KEY_DLG
	mov rcx,[hInst]
	call apiw.dlgbp
	jmp	.ret0

	;ü------------------------------------------ö
	;|     PA_BROWSE                            |
	;#------------------------------------------ä

.mi_pa_browse:
	sub rsp,\
		sizea16.MENUITEMINFOW

	mov r9,rsp
	mov [r9+\
		MENUITEMINFOW.fMask],\
		MIIM_DATA
	mov edx,MP_PATH
	mov rcx,[hMnuMain]
	call apiw.mni_get_byid
	mov rbx,[rsp+\
		MENUITEMINFOW.dwItemData]
	test rbx,rbx
	jz	.ret0

	mov rax,rbx
	test [.dir.type],\
		DIR_HASREF
	jz @f
	mov rax,[.dir.rdir]
@@:
	lea r8,[rax+DIR.dir]
	mov r11,SW_SHOWNORMAL	
	xor r10,r10
	xor r9,r9
	mov edx,uzExplore
	xor ecx,ecx
	call apiw.shexec
	jmp	.ret0

	;ü------------------------------------------ö
	;|     MI_ED_RELSCICLS                      |
	;#------------------------------------------ä
.mi_ed_relscicls:
	call ext.discard
	call ext.setup
	mov ecx,UZ_MSG_SCIREL
	jmp	.mi_devt_addgA

	;ü------------------------------------------ö
	;|     DEVT_ADDG                            |
	;#------------------------------------------ä
.mi_devt_addg:
	mov ecx,\
		UZ_MSG_TADDG

.mi_devt_addgA:
	sub rsp,\
		FILE_BUFLEN
	mov r8,rsp
	mov edx,U16
	call [lang.get_uz]

	mov r8,uzTitle
	mov rdx,rsp
	mov rcx,[hMain]
	call apiw.msg_ok
	jmp	.ret0

	;ü------------------------------------------ö
	;|     DEVT_REMG                            |
	;#------------------------------------------ä
.mi_devt_remg:
	call devtool.remgroup
	jmp	.ret0


	;ü------------------------------------------ö
	;|     DEVT_REL                             |
	;#------------------------------------------ä

.mi_devt_rel:
	call devtool.discard
	call devtool.load
	mov ecx,iCAT_CBX_DEVT
	call mpurp.sel_icat
	xor ecx,ecx
	call mpurp.sel_ifilt
	jmp	.ret0

	;ü------------------------------------------ö
	;|     DEVT_MAN                             |
	;#------------------------------------------ä
.mi_devt_man:
	sub rsp,\
		FILE_BUFLEN
	xor edx,edx
	mov rax,rsp

	push rdx
	push uzUtf8Ext
	push uzDevTName
	push rax
	push rdx
	call art.catstrw

	mov rax,[confDir]
	lea rcx,[rax+DIR.dir]

	mov r8,\
		LF_FILE or\
		LF_TXT
	mov rdx,rsp
	call wspace.new_labf
	test eax,eax
	jz .ret0

	mov rcx,rax
	call wspace.open_file
	test eax,eax
	jz .ret0

	mov rcx,rax
	call edit.view

	mov r8,rsp
	mov edx,U16
	mov ecx,UZ_INFO_TREL
	call [lang.get_uz]

	mov r8,uzTitle
	mov rdx,rsp
	mov rcx,[hMain]
	call apiw.msg_ok
	jmp	.ret0

	;ü------------------------------------------ö
	;|     DEVT_REM                             |
	;#------------------------------------------ä
.mi_devt_rem:
	call devtool.remtool
	jmp	.ret0

	;ü------------------------------------------ö
	;|     DEVT_ADD                             |
	;#------------------------------------------ä

.mi_devt_add:
	call devtool.addtool
	jmp .ret0

	;ü------------------------------------------ö
	;|     WS_EXIT                              |
	;#------------------------------------------ä

.mi_ws_exit:
	xor r9,r9
	xor r8,r8
	mov rdx,WM_CLOSE
	mov rcx,[hMain]
	call apiw.sms
	jmp	.exit

	;ü------------------------------------------ö
	;|     FI_IMP                               |
	;#------------------------------------------ä

.mi_fi_imp:
	mov rcx,[hTree]
	call tree.get_sel
	test eax,eax
	jnz .mi_fi_impA

.mi_fi_impB:
	;--- please,choose an item in treeview
	sub rsp,FILE_BUFLEN
	mov r8,rsp
	mov edx,U16
	mov ecx,UZ_INFO_SELITEM
	call [lang.get_uz]

	mov r8,uzTitle
	mov rdx,rsp
	mov rcx,[hMain]
	call apiw.msg_ok
	jmp	.ret0

.mi_fi_impA:
	sub rsp,\
		sizeof.TVITEMW
	mov r9,rsp
	mov edx,eax
	mov rcx,[hTree]
	call tree.get_param
	test eax,eax
	jz .ret0

	mov rcx,[rsp+\
		TVITEMW.lParam]
	test rcx,rcx
	jz .ret0
	mov rbx,rcx

	call tree.get_paraft
	test rax,rax
	jz	.ret0

	push r12
	push r13
	push r14
	push r15

	mov r12,.mi_fi_openI
	mov r13,rdx	;--- parent
	mov r14,r8	;--- insafter
	xor r15,r15

	mov rax,[.labf.dir]
	lea r9,[rax+DIR.dir]
	jmp	.mi_fi_openA

.mi_fi_openO:
	;--- by opening docs
	;--- in RAX labf
	mov rcx,rax
	call wspace.open_file
	ret 0

.mi_fi_openI:
	;--- by importing docs
	;--- in RAX labf
	mov r8,r14
	mov rdx,r13
	mov rcx,rax
	call tree.insert
	test rax,rax
	cmovnz r14,rax
	ret 0

	;ü------------------------------------------ö
	;|     FI.OPEN                              |
	;#------------------------------------------ä
	
.mi_fi_open:
	push r12
	push r13
	push r14
	push r15

	mov r12,.mi_fi_openO
	xor r13,r13
	xor r14,r14
	xor r9,r9
	xor r15,r15

.mi_fi_openA:
	mov r8,FOS_ALLOWMULTISELECT\
		or FOS_NODEREFERENCELINKS\
		or FOS_ALLNONSTORAGEITEMS\
		or FOS_PATHMUSTEXIST
	xor edx,edx
	xor ecx,ecx
	call [dlg.open]
	test rax,rax
	jz	.mi_fi_openE

	mov rbx,rax					;--- pnum items
	lea rsi,[rax+8]			;--- ppath
	lea rdi,[rax+16]		;--- files
	and qword[rax],0FFh	;--- max 255 files

.mi_fi_openN:
	mov r8,\
		LF_FILE or\
		LF_TXT
	mov rdx,[rdi]
	mov rcx,[rsi]
	call wspace.new_labf

	call r12
	test eax,eax
	cmovnz r15,rax		

	mov rcx,[rdi]
	call apiw.co_taskmf
	add rdi,8
	dec byte[rbx]
	jnz .mi_fi_openN
	
	mov rcx,[rsi]
	call apiw.co_taskmf
	mov rcx,rbx
	call art.a16free

	cmp r12,.mi_fi_openI
	jz .mi_fi_openM

	test r15,r15
	jz	.mi_fi_openE
	mov rcx,r15
	call edit.view
	jmp	.mi_fi_openE

.mi_fi_openM:
	mov rbx,[pLabfWsp]
	or [.labf.type],\
		LF_MODIF

.mi_fi_openE:
	pop r15
	pop r14
	pop r13
	pop r12
	jmp	.ret0

	;ü------------------------------------------ö
	;|     FI_CLOSE                             |
	;#------------------------------------------ä

.mi_fi_close:
	;--- RET EAX = -1 errror
	;--- RET EAX = 0 cannot close/abort operation
	;--- RET EAX = 1 no need to save/saved ok
	mov rsi,[pEdit]
	mov rbx,\
		[rsi+EDIT.curlabf]
	cmp rbx,\
		[rsi+EDIT.deflabf]
	jz	.ret1

.mi_fi_closeA:
	mov rdx,ASK_SAVE
	mov rcx,rbx
	call wspace.close_file
	jmp	.exit

	;ü------------------------------------------ö
	;|     FI_SAVE                              |
	;#------------------------------------------ä

.mi_fi_save:
	mov rsi,[pEdit]
	mov rbx,\
		[rsi+EDIT.curlabf]
	cmp rbx,\
		[rsi+EDIT.deflabf]
	jz	.ret1

	mov rdx,NOASK_SAVE
	mov rcx,rbx
	call wspace.save_file
	test eax,eax
	jle	.ret0
	mov rcx,rbx
	call edit.view
	jmp	.ret0

	;ü------------------------------------------ö
	;|     WS_LOAD                              |
	;#------------------------------------------ä

.mi_ws_load:
	xor r9,r9
	mov r8,FOS_NODEREFERENCELINKS\
		or FOS_ALLNONSTORAGEITEMS\
		or FOS_NOVALIDATE \
		or FOS_PATHMUSTEXIST
	xor edx,edx
	xor ecx,ecx
	call [dlg.open]
	test rax,rax
	jz	.ret0

	mov rbx,rax
	sub rsp,\
		FILE_BUFLEN
	mov rsi,rsp

	mov rdx,rsp
	mov rcx,rax
	call utf16.copyz

	mov rcx,rbx
	call apiw.co_taskmf
	jmp	.mi_ws_newA

	;ü------------------------------------------ö
	;|     MI_ED_REMITEM                        |
	;#------------------------------------------ä

.mi_ed_remitem:
	sub rsp,\
		FILE_BUFLEN

	mov rcx,[hTree]
	call tree.get_sel
	test eax,eax
	jz .ret0

	cmp rax,[hRootWsp]	;--- no action on wsp
	jz	.ret0
	mov rdi,rax

	mov r9,rsp
	mov rdx,rax
	mov rcx,[hTree]
	call tree.get_param

	mov rbx,[rsp+\
		TVITEMW.lParam]
	
	mov ecx,[rsp+\
		TVITEMW.cChildren]
	dec ecx
	jz	.mi_ed_remitemA

	test ebx,ebx
	jz	.ret0

	test [.labf.type],\
		LF_OPENED
	jz	.mi_ed_remitemB
	
	mov edx,NOASK_SAVE
	mov eax,ASK_SAVE
	test [.labf.type],\
		LF_MODIF
	cmovnz edx,eax

	mov rcx,rbx
	call wspace.close_file
	test eax,eax
	jle	.ret0

.mi_ed_remitemB:
	mov rcx,rbx
	call art.a16free

	mov r9,rdi
	mov rcx,[hTree]
	call tree.del_item
	jmp	.mi_ed_remitemE

.mi_ed_remitemA:
	;--- item has subitems
	mov r8,rsp
	mov edx,U16
	mov ecx,UZ_MSG_REMITEM
	call [lang.get_uz]

	mov r8,uzTitle
	mov rdx,rsp
	mov rcx,[hMain]
	call apiw.msg_yn
	cmp eax,IDNO
	jz	.ret0

	mov rdx,rdi
	mov rcx,\
		wspace.close_delitem
	call wspace.list
	test eax,eax
	jle .ret0

	mov rdx,rdi
	mov rcx,\
		wspace.discard_delitem
	call wspace.list

.mi_ed_remitemE:
	mov rbx,[pLabfWsp]
	or [.labf.type],\
		LF_MODIF
	jmp	.ret0

	;ü------------------------------------------ö
	;|     .MI_ED_LNK                           |
	;#------------------------------------------ä

.mi_ed_lnk:
	sub rsp,\
		sizeof.TVITEMW
	mov rdi,rsp
	xor rsi,rsi

	mov rcx,[hTree]
	call tree.get_sel
	test eax,eax
	jz .mi_fi_impB

	push r12
	push r13

	mov rsi,rax
	mov r12,[hRootWsp]
	mov r13,TVI_FIRST
	mov rbx,[pLabfWsp]
	cmp rax,r12
	jz	.mi_ed_lnkA

	;--- get param of selected item ---
	mov r9,rdi
	mov rdx,rsi
	mov rcx,[hTree]
	call tree.get_param
	test eax,eax
	jz .mi_ed_lnkE

	mov rbx,[rdi+\
		TVITEMW.lParam]
	xor eax,eax
	test rbx,rbx
	jz .mi_ed_lnkE

	mov r9,[.labf.hItem]
	mov rcx,[hTree]
	call tree.get_parent
	test rax,rax
	jz	.mi_ed_lnkE

	mov r12,rax
	mov r13,[.labf.hItem]
	
	mov r9,r12
	mov rcx,[hTree]
	call tree.get_child
	cmp rax,r13
	jnz .mi_ed_lnkA
	mov r13,TVI_FIRST
  jmp .mi_ed_lnkA

	test [.labf.type],\
		LF_FILE
	jnz	.mi_ed_lnkA

	mov r12,rax
	mov r13,[.labf.hItem]

.mi_ed_lnkA:
	mov rsi,[pIo]
	mov rcx,IO_NEWLNK
	add rsi,rcx
	mov rdx,rbx
	mov rax,[.labf.dir]

	mov [.io.ldir],rax
	call iodlg.start

	cmp eax,IDCANCEL
	jz .mi_ed_lnkE

	xor eax,eax
	lea rdi,[.io.buf]
	cmp ax,word[rdi]
	jnz	.mi_ed_lnkB
	
	mov rax,[.io.ldir]
	mov rcx,[rax+DIR.rdir]
	lea rdi,[rax+DIR.dir]

	test [rax+DIR.type],\
		DIR_HASREF
	jz .mi_ed_lnkC
	lea rdi,[rcx+DIR.dir]

.mi_ed_lnkC:
	mov rcx,rdi
	call art.get_fname
	mov rdi,rdx
	
.mi_ed_lnkB:
	mov r8,LF_LNK
	mov rax,[.io.ldir]
	mov rdx,rdi
	lea rcx,[rax+DIR.dir]
	call wspace.new_labf

	test eax,eax
	jz	.mi_ed_lnkE
	mov rbx,rax

	mov r8,r13
	mov rdx,r12
	mov rcx,rbx
	call tree.insert

	mov rdx,[pLabfWsp]
	or [rdx+LABFILE.type],\
		LF_MODIF
	test eax,eax
	jnz	.mi_ed_lnkE

	and [rdx+LABFILE.type],\
		not LF_MODIF

	mov rcx,rbx
	call art.a16free
	xor eax,eax

.mi_ed_lnkE:
	pop r13
	pop r12
	jmp	.ret0


	;ü------------------------------------------ö
	;|     WS_NEW                               |
	;#------------------------------------------ä

.mi_ws_new:
	;--- RET EAX = -1 errror
	;--- RET EAX = 0 cannot close/abort operation
	;--- RET EAX = 1 no need to save/saved ok
	xor esi,esi

.mi_ws_newA:
	mov rcx,ASK_SAVE
	call wspace.save_docs
	test rax,rax
	jle .exit

	call wspace.check
	test eax,eax
	jle .exit

	xor r9,r9
	mov rax,[pConf]
	test rsi,rsi
	mov qword[rax+\
		CONFIG.wsp],r9
	mov rcx,rsi
	jz	.wm_createA

	lea rdx,[rax+CONFIG.wsp]
	mov rsi,rdx
	call utf16.copyz

	mov rcx,rsi
	jmp	.wm_createA

	;ü------------------------------------------ö
	;|     WM_CREATE                            |
	;#------------------------------------------ä

.wm_create:
	mov [hMain],rcx
	mov rcx,[hMain]
	call win.controls

	call devtool.load

	mov rax,[pConf]

	sub rsp,\
		FILE_BUFLEN*2
	lea rcx,[rax+\
		CONFIG.wsp]
	mov rdx,rsp
	call apiw.exp_env
	mov rcx,rdx

;	xor rcx,rcx

.wm_createA:
	call wspace.load_wsp
	test rax,rax
	jz	.ret1

	mov r9,[hRootWsp]
	mov r8,TVE_EXPAND
	mov rcx,[hTree]
	call tree.exp_item

	mov rcx,[curDir]
	call mnu.set_dir
	jmp	.ret1

	;ü------------------------------------------ö
	;|     WS_SAVE                              |
	;#------------------------------------------ä

.mi_ws_save:
	mov rax,[pEdit]
	mov rbx,\
		[rax+EDIT.curlabf]
	
	mov rcx,NOASK_SAVE
	call wspace.save_docs
	test rax,rax
	jle .exit

	call wspace.save_wsp
	mov rsi,rax

	mov rdx,[pEdit]
	mov rcx,\
		[rdx+EDIT.curlabf]
	mov rax,rsi
	cmp rcx,rbx
	jz	.exit

	mov rcx,rbx
	call edit.view
	mov rax,rsi
	jmp .exit


	;ü------------------------------------------ö
	;|     FI_NEW                               |
	;#------------------------------------------ä

.mi_fi_newf:
	mov rcx,[hTree]
	call tree.get_sel
	test eax,eax
	jz .mi_fi_impB

	sub rsp,\
		sizeof.TVITEMW
	mov r9,rsp
	mov edx,eax
	mov rcx,[hTree]
	call tree.get_param
	test eax,eax
	jz .ret0

	mov rbx,[rsp+\
		TVITEMW.lParam]
	test rbx,rbx
	jz .ret0

	mov edx,\
		LF_FILE or \
		LF_TXT
	mov rcx,rbx
	call wspace.new_file
	test rax,rax
	jz	.exit

	mov rbx,[pLabfWsp]
	or [.labf.type],\
		LF_MODIF
	jmp	.exit

.mi_fi_newb:
	call wspace.new_bt
	jmp	.ret1

	;ü------------------------------------------ö
	;|     WM_NOTIFY                            |
	;#------------------------------------------ä

.wm_notify:
	mov rdx,[r9+NMHDR.hwndFrom]
	cmp rdx,[hTree]
	jz	wspace.tree_notify
	cmp rdx,[hDocs]
	jz	wspace.docs_notify

.wm_notifyE:
	jmp	.ret0

	;ü------------------------------------------ö
	;|     WM_DRAWITEM                          |
	;#------------------------------------------ä

.wm_drawitem:
	virtual at rbx
		.dis	DRAWITEMSTRUCT
	end virtual
	mov rbx,r9

	cmp [.dis.CtlType],\
		ODT_MENU
	jnz	.ret0

.wm_dis_mnu:
	mov eax,[.dis.itemID]
	test eax,eax
	jnz	.wm_dis_mnuA

	;--- draw space for separator 
	mov rcx,NULL_BRUSH
	call apiw.get_stockobj

	mov r8,COLOR_MENU+1
	lea rdx,[.dis.rcItem]
	mov rcx,[.dis.hDC]
	call apiw.fillrect
	jmp	.ret1

.wm_dis_mnuA:
	push r12
	push r13

.wm_dis_mnuD:
	mov r8,COLOR_MENU+1
	test [.dis.itemState],\
		ODS_GRAYED
	jnz	.wm_dis_mnuB

	mov r8,COLOR_MENU+1
	test [.dis.itemState],\
		ODS_SELECTED
	jz	.wm_dis_mnuB
	mov r8,\
		COLOR_INACTIVECAPTION+1
	
.wm_dis_mnuB:
	lea rdx,[.dis.rcItem]
	mov rcx,[.dis.hDC]
	call apiw.fillrect

	mov rdi,[.dis.itemData]
	test rdi,rdi
	jz .wm_dis_mnuB1	

	movzx eax,[rdi+OMNI.iIcon]
	mov r11,\
		ILD_TRANSPARENT
	mov r10d,\
		[.dis.rcItem.top]
	add r10d,4
	mov r9d,\
		[.dis.rcItem.left]
	add r9d,1
	mov r8,[.dis.hDC]
	mov rdx,rax
	mov rcx,[hBmpIml]
	call iml.draw

.wm_dis_mnuB1:	
;---	mov rdx,[hMnuFont]
;---	mov rcx,[.dis.hDC]
;---	call apiw.selobj
;---	mov r12,rax

	mov rdx,TRANSPARENT
	mov rcx,[.dis.hDC]
	call apiw.set_bkmode

	mov eax,[.dis.itemID]
	cmp eax,MI_OTHER
	jae	.wm_dis_mnuB2

;@break
	sub eax,MNU_X64LAB
	jl	.wm_dis_mnuB2
	shl eax,5		;--- x 32 size of KEYA
	add rax,[pKeya]
	lea rdx,[rax+KEYA.name]

	sub [.dis.rcItem.right],20
	mov r10,DT_NOCLIP\
		or DT_RIGHT	\
		or DT_VCENTER	\
		or DT_SINGLELINE	
	lea r9,[.dis.rcItem]
	mov r8,-1
	mov rcx,[.dis.hDC]
	call apiw.drawtext
	add [.dis.rcItem.right],20

.wm_dis_mnuB2:
	mov ecx,COLOR_GRAYTEXT
	test [.dis.itemState],\
		ODS_GRAYED
	jnz	.wm_dis_mnuC
	mov ecx,COLOR_MENUTEXT

.wm_dis_mnuC:
	call apiw.get_syscol
	mov rdx,rax
	mov rcx,[.dis.hDC]
	call apiw.set_txtcol

	test rdi,rdi
	jz	.wm_dis_mnuE
	add rdi,sizeof.OMNI

	mov r10,DT_NOCLIP\
		or DT_VCENTER	\
		or DT_SINGLELINE	

	lea r9,[.dis.rcItem]
	add [.dis.rcItem.left],16+8
	mov r8,-1
	mov rdx,rdi
	mov rcx,[.dis.hDC]
	call apiw.drawtext

;---	mov rdx,r12
;---	mov rcx,[.dis.hDC]
;---	call apiw.selobj

.wm_dis_mnuE:
	pop r13
	pop r12
	jmp	.ret1


.wm_measitem:
	mov r9,[.lparam]
	virtual at rbx
		.mis MEASUREITEMSTRUCT
	end virtual

	mov rbx,r9
	cmp [.mis.CtlType],\
		ODT_MENU
	jnz	.ret0

	mov rdi,[.mis.itemData]
	test rdi,rdi
	jz .ret1

	movzx eax,[rdi+OMNI.len]
	shr eax,1
	inc eax

	add eax,10	;--- eventual chars for accel
	mov ecx,[tmMnuSize.cx]
	mul ecx
	add eax,16	;--- size of an icon
	add eax,1+1	;--- lx,rx pixel icon
	add eax,4		;--- last pixel+4 pixel space
	mov [.mis.itemWidth],eax

	mov eax,[tmMnuSize.cy]
	add eax,2+2	;--- 2*2 pixel gap
	add eax,3+3	;--- 2*(border)
	mov [.mis.itemHeight],eax
	jmp	.ret1


	;ü------------------------------------------ö
	;|     WM_DESTROY                           |
	;#------------------------------------------ä

.wm_destroy:
	call config.write
	call devtool.discard

	xor rcx,rcx
	call [PostQuitMessage]

	mov rcx,[hDocker]
	call [dock64.discard]
	jmp	.ret0

.defwndproc:
	mov r9,[.lparam]
	mov r8,[.wparam]
	mov rdx,[.msg]
	mov rcx,[.hwnd]
	sub rsp,20h
	call [DefWindowProcW]
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.ret1:
	xor rax,rax
	inc rax

.exit:
	@wepi

	display "--- Size of code "
	display_decimal $-$$
	display 13,10

	include "%x64devdir%\shared\importw.inc"
	section '.rsrc' data readable resource from 'x64lab.res'

	display "--- Size of resources "
	display_decimal $-$$
	display 13,10
