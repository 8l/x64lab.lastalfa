tmpl:
  
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

	virtual at rbx
		.tmpl	TMPL
	end virtual

.proc:
@wpro rbp,\
		rbx rsi rdi
	cmp edx,WM_MOUSEMOVE
	jz	.wm_mmove
	cmp edx,WM_LBUTTONUP
	jz	.wm_lbup
	cmp edx,\
		WM_NOTIFY
	jz	.wm_notify
	cmp edx,\
		WM_WINDOWPOSCHANGED
	jz	.wm_poschged
	cmp edx,\
		WM_COMMAND
	jz	.wm_command
	cmp edx,\
		WM_INITDIALOG
	jz	.wm_initd
	jmp	.ret0

.wm_lbup:
	mov rbx,[pTmpl]
	call apiw.rel_capt
	xor eax,eax
	cmp [.tmpl.fDrag],al
	jz	.ret0

	push r12
	push r13

	mov rdx,SW_HIDE
	mov rcx,[hFloat]
	call apiw.show

	mov rdi,[.tmpl.hDrop]
	test edi,edi
	jz	.wm_lbupE

	;--- check drop target
	mov edx,\
		CFG_EDIT_DOCK_ID
	mov rcx,[hDocker]
	call [dock64.id2panel]
	test eax,eax
	jz	.wm_lbupA
	cmp rdi,[rax+PNL.hwnd]
	jz	.wm_lbupM

.wm_lbupA:	
	mov edx,\
		CFG_DOCS_DOCK_ID
	mov rcx,[hDocker]
	call [dock64.id2panel]
	test eax,eax
	jz	.wm_lbupE
	cmp rdi,[rax+PNL.hwnd]
	jnz	.wm_lbupE
	
.wm_lbupB:
	;--- open as blank and template it
	call wspace.new_bt
	mov rdi,rax

	sub rsp,\
		FILE_BUFLEN
	mov rsi,rsp
	mov rax,[.tmpl.param]
	lea rcx,\
		[rax+DIR.dir]
	lea rdx,[.tmpl.text]

	push 0
	push rdx
	push uzSlash
	push rcx
	push rsi
	push 0
	call art.catstrw
	
	mov rcx,rsi
	call art.fload
	;--- RET RAX pmem,0,-err
	;--- RET RCX original file size
	;--- RET RDX pextension / flag error
	add rsp,\
		FILE_BUFLEN

	mov r13,rcx
	mov r12,rax
	test rax,rax
	jnz	.wm_lbupC

	xor r12,r12
	xor r13,r13
	cmp edx,-3	;--- zero size
	jnz .wm_lbupE

.wm_lbupC:	
	lea rcx,[.tmpl.text]
	call ext.load
	test eax,eax
	jz	.wm_lbupD
	
	mov rdx,rdi
	mov rcx,rax
	call ext.apply

.wm_lbupD:
	test r12,r12
	jz .wm_lbupE

	test r13,r13
	jz	.wm_lbupF

	mov r9,r12
	mov r8,r13
	mov rcx,[rdi+\
		LABFILE.hSci]
	call sci.add_txt

.wm_lbupF:
	mov rcx,r12
	call art.vfree
	jmp	.wm_lbupE
	

.wm_lbupM:
	;--- open to modify template ---
	mov r8,\
		LF_FILE or\
		LF_TXT
	mov rax,[.tmpl.param]
	lea rdx,[.tmpl.text]
	lea rcx,[rax+DIR.dir]
	call wspace.new_labf
	test eax,eax
	jz .wm_lbupE

	mov rcx,rax
	call wspace.open_file
	test eax,eax
	jz .wm_lbupE

	mov rcx,rax
	call edit.view
	
.wm_lbupE:
	xor ecx,ecx
	mov [.tmpl.fDrag],cl

	xchg rcx,[.tmpl.hIcon]
	call apiw.destr_icon
	xor eax,eax
	mov [.tmpl.hDrop],rax
	mov [.tmpl.hIcon],rax
	mov [.tmpl.param],rax
	mov qword[.tmpl.text],rax

	pop r13
	pop r12
	jmp	.ret0

.wm_mmove:
	xor ecx,ecx
	mov rbx,[pTmpl]
	cmp [.tmpl.fDrag],cl
	jz	.ret0

	sub rsp,\
		FILE_BUFLEN
	mov rcx,rsp
	call apiw.get_curspos

	mov rax,[.lparam]
	mov rcx,rax
	and eax,0FFFFh
	mov [rsp+8+POINT.x],eax
	shr ecx,16
	mov [rsp+8+POINT.y],ecx

	mov r9,1
	lea r8,[rsp+8]
	mov rdx,[hMain]
	mov rcx,[.hwnd]
	call apiw.map_wpt

	;--- TODO: dosent take floating panel ----
	mov rdx,[rsp+8]
	mov rcx,[hMain]
	call apiw.chwinfpt
	mov [.tmpl.hDrop],rax

;---	mov qword[rsp+16],0
;---	lea r9,[rsp+16]
;---	mov rcx,rax
;---	call win.get_text

;---	lea r8,[rsp+16]
;---	mov rdx,[rsp+8]
;---	call art.cout2XU

	lea rdx,[.tmpl.text]
	mov rcx,[.tmpl.hIcon]
	call float.draw

	mov r11,TRUE
	mov r10d,96
	mov r9d,96
	mov r8d,[rsp+POINT.y]
	mov edx,[rsp+POINT.x]
	mov rcx,[hFloat]
	call apiw.movewin
	jmp	.ret0


.wm_command:
	mov rbx,[pTmpl]
	cmp r9,[.tmpl.hTlb]
	jz	.tlb_command
	jmp	.ret0

.tlb_command:
	mov rax,r8
	rol eax,16
	cmp ax,BN_CLICKED
	jnz	.ret0
	;--- TODO: later use for now only
  ;--- UZ_TMPL_MOD in R8
	;---	xor r9,r9
	;---	and r8,0FFFFh
	;---	mov edx,WM_COMMAND
	;---	mov rcx,[hMain]
	;---	call apiw.sms
	jmp	.ret0


.wm_notify:
	mov rbx,[pTmpl]
	mov rdx,[r9+\
		NMHDR.hwndFrom]
	cmp rdx,[hTip]
	jz	.tip_notify
	cmp rdx,[.tmpl.hTlb]
	jz	.tlb_notify_real
	cmp rdx,[.tmpl.hLvwT]
	jz	.lvwT_notify
	cmp rdx,[.tmpl.hLvwC]
	jz	.lvwC_notify
	jmp	.ret0

.lvwC_notify:
	mov edx,[r9+\
		NMHDR.code]
	cmp edx,\
		LVN_BEGINDRAG
	jz	.lvwC_begdrag
	jmp .ret0
	
.lvwC_begdrag:
	;--- set the iItem being dragged
	mov eax,[r9+\
		NM_LISTVIEW.iItem]
	mov [.tmpl.iDrag],eax

	xor edx,edx
	mov [.tmpl.hDrop],rdx
	mov [.tmpl.hIcon],rdx
	mov [.tmpl.param],rax
	mov qword[.tmpl.text],rdx

	;--- get Text and Param
	sub rsp,\
		sizea16.LVITEMW+\
		sizea16.SHFILEINFOW
	mov r9,rsp

	mov [r9+\
		LVITEMW.iSubItem],edx
	lea r8,[.tmpl.text]
	mov [r9+\
		LVITEMW.pszText],r8
	mov [r9+\
		LVITEMW.cchTextMax],128-1
	mov [r9+\
		LVITEMW.iItem],eax
	mov [r9+LVITEMW.mask],\
		LVIF_PARAM or \
		LVIF_TEXT
	mov rcx,[.tmpl.hLvwC]
	call lvw.get_item
	test eax,eax
	jz	.ret0

	mov rax,[rsp+\
		LVITEMW.lParam]
	test eax,eax
	jz	.ret0
	mov [.tmpl.param],rax

	;--- get large hIcon of it
	mov r10,\
		SHGFI_ICON or \
		SHGFI_LARGEICON	 or \
		SHGFI_USEFILEATTRIBUTES
	mov r9,\
		sizeof.SHFILEINFOW
	mov r8,rsp
	xor edx,edx
	lea rcx,[.tmpl.text]
	call apiw.sfinfo

	mov rax,[rsp+\
		SHFILEINFOW.hIcon]
	mov [.tmpl.hIcon],rax
	
	
	;--- set position --------
	call apiw.get_msgpos
	movzx r8,ax
	shr eax,16
	mov r9,rax

	mov eax,\
		SWP_SHOWWINDOW \
		or SWP_NOSIZE
	mov rdx,HWND_TOP
	mov rcx,[hFloat]
	call apiw.set_wpos

;@break
	lea rdx,[.tmpl.text]
	mov rcx,[.tmpl.hIcon]
	call float.draw

	mov rcx,[.hwnd]
	call apiw.set_capt
	mov [.tmpl.fDrag],1
	jmp	.ret1


.lvwT_notify:
	mov edx,[r9+\
		NMHDR.code]
;---	cmp edx,NM_DBLCLK
;---	jz	.lvw_dblclk
	cmp edx,\
		LVN_ITEMCHANGED
	jz	.lvwT_ichged
	jmp .ret0
	
.lvwT_ichged:
	mov rax,[r9+\
		NM_LISTVIEW.lParam]
	test rax,rax
	jz	.ret0

	test [r9+\
		NM_LISTVIEW.uNewState],\
		LVIS_FOCUSED \
		or LVIS_SELECTED
	jz	.ret0
	mov [.tmpl.view],ax

	push rax
	mov rcx,rax
	call mnu.set_dir

	pop rcx
	call .list_items
	jmp	.ret0
	

.tlb_notify_real:
	mov edx,[r9+NMHDR.code]
	cmp edx,TBN_GETINFOTIPW
	jnz	.ret0
	xor r8,r8
	xor r9,r9
	mov rcx,[hTip]
	call tip.popup
	jmp	.ret0
	
.tip_notify:
	mov rax,[r9+\
		NMHDR.idFrom]
	cmp rax,[.tmpl.hTlb]
	jnz	.ret0

.tlb_notify:
	mov edx,[r9+NMHDR.code]
	cmp edx,TTN_GETDISPINFOW
	jz	.tip_getdispinfo
	jmp	.ret0

.tip_getdispinfo:
	mov rdi,r9

	mov rax,[r9+\
		NMTTDISPINFO.lpszText]

	mov rax,uzDefault
	mov [r9+\
		NMTTDISPINFO.lpszText],rax

	sub rsp,8+\
		sizeof.TBBUTTON+\
		FILE_BUFLEN
	call apiw.get_msgpos

	mov ecx,eax
	and eax,0FFFFh
	and ecx,0FFFF0000h
	shl rcx,16
	or rax,rcx
	mov [rsp],rax

	mov r9,1
	mov r8,rsp
	mov rdx,[.tmpl.hTlb]
	mov rcx,0
	call apiw.map_wpt

	mov r9,rsp
	xor r8,r8
	mov edx,TB_HITTEST
	mov rcx,[.tmpl.hTlb]
	call apiw.sms
	test eax,eax
	js	.ret0

	mov r9,rsp
	mov r8,rax
	mov rcx,[.tmpl.hTlb]
	call tlb.get_but
	test eax,eax
	jz	.ret0

	;--- TODO: check len
	mov ecx,[rsp+\
		TBBUTTON.idCommand]
	lea r8,[rdi+\
		NMTTDISPINFO.szText]	;--- max 80 cpts
	mov [rdi+\
		NMTTDISPINFO.lpszText],r8
	mov edx,U16
	call [lang.get_uz]
	jmp	.ret1


.wm_poschged:
	mov rbx,[pTmpl]
	sub rsp,\
		sizeof.RECT

	mov rdx,rsp	
	mov rcx,[.tmpl.hTlb]
	call apiw.get_winrect
	mov edi,[rsp+RECT.bottom]
	sub edi,[rsp+RECT.top]	;--- toolbar cy

	mov rdx,rsp
	mov rcx,[.hwnd]
	call apiw.get_clirect

	mov rax,SWP_NOZORDER or\
		SWP_NOMOVE
	mov r9d,[rsp+RECT.top]
	mov r8d,[rsp+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.tmpl.hTlb]
	call apiw.set_wpos

	mov rax,SWP_NOZORDER
	mov r11d,[rsp+RECT.bottom]
	shr r11,2
	mov r10d,[rsp+RECT.right]
	mov r9d,[rsp+RECT.top]
	add r9,rdi
	mov r8d,[rsp+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.tmpl.hLvwT]
	call apiw.set_wpos

	mov rax,SWP_NOZORDER
	mov r9d,[rsp+RECT.bottom]
	shr r9,2
	add r9,CY_GAP
	add r9,rdi
	
	mov r11d,[rsp+RECT.bottom]
	sub r11,r9
	mov r10d,[rsp+RECT.right]
	mov r8d,[rsp+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.tmpl.hLvwC]
	call apiw.set_wpos
	jmp	.ret0

.wm_initd:
	mov rbx,r9
	mov [.tmpl.hwnd],rcx
	mov rdi,rcx

	mov r8,rbx
	call apiw.set_wldata
	mov [.tmpl.id],TMPL_DLG

	mov edx,TMPL_LVWC
	mov rcx,rdi
	call apiw.get_dlgitem
	mov [.tmpl.hLvwC],rax

	mov edx,TMPL_LVWT
	mov rcx,rdi
	call apiw.get_dlgitem
	mov [.tmpl.hLvwT],rax

	mov r9d,00EBD6CBh
	mov rcx,[.tmpl.hLvwC]
	call lvw.set_bkcol

	mov r9d,00EBD6CBh
	mov rcx,[.tmpl.hLvwC]
	call lvw.set_txtbkcol

	mov r9d,00E4DDD2h
	mov rcx,[.tmpl.hLvwT]
	call lvw.set_bkcol

	mov r9d,00E4DDD2h
	mov rcx,[.tmpl.hLvwT]
	call lvw.set_txtbkcol

	mov edx,TMPL_TLB
	mov rcx,rdi
	call apiw.get_dlgitem
	mov [.tmpl.hTlb],rax

	mov r9,[hBmpIml]
	xor r8,r8
	mov rcx,rax
	call tlb.set_iml

	;--- in RAX iButton
  ;--- in RDX iBitmap
	;--- in R8 idCommand
	;--- in R9H	fsState
	;--- in R9L fsStyle
	;--- in R10 dwData
	;--- in R11 iString

	push 0	;--- terminate

	;---	push 17
	;---	push UZ_TMPL_PRJ
	push 16
	mov r8,UZ_TMPL_MOD
	or edi,-1

.wm_initdT:
	inc edi
	pop rdx
	mov r9,\
		TBSTATE_ENABLED or \
		TBSTATE_CHECKED
	shl r9,8
	or r9l,BTNS_CHECKGROUP
	xor r10,r10
	xor r11,r11
	;mov r11,uzDefault
	mov eax,edi
	mov rcx,[.tmpl.hTlb]
	call tlb.ins_but
	pop r8
	test r8,r8
	jnz	.wm_initdT

	;--- in RCX hTip
	;--- in RDX parent container of the tool
	;--- in R8 hTool
	;--- in R9 text
	mov r9,\
		LPSTR_TEXTCALLBACK
	mov r8,[.tmpl.hTlb]
	mov rdx,[.hwnd]
	mov rcx,[hTip]
	call tip.add

	mov r9,[hsmSysList]
	mov r8,LVSIL_SMALL
	mov rcx,[.tmpl.hLvwT]
	call lvw.set_iml

	mov r9,[hsmSysList]
	mov r8,LVSIL_SMALL
	mov rcx,[.tmpl.hLvwC]
	call lvw.set_iml

	;--- only this now
	mov ecx,UZ_TMPL_MOD
	call .view

.ret1:				;message processed
	xor rax,rax
	inc rax
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.exit:
	@wepi


.view:
	;--- in RCX id view (button)
	push rbp
	push rbx
	push r12
	mov rbp,rsp

	mov rbx,[pTmpl]
	mov r12,rcx
	sub rsp,\
	 FILE_BUFLEN

	mov rcx,[.tmpl.hLvwT]
	call lvw.del_all

	mov rcx,[.tmpl.hLvwC]
	call lvw.del_all

	;--- check for [template\?????\*] directories
	mov rdi,rsp
	mov rdx,[templDir]
	lea rax,[rdx+DIR.dir]

	push 0
	push uzModName
	push uzSlash
	push rax
	push rdi
	push 0
	call art.catstrw	
	
	mov [.tmpl.view],\
		r12w

	;---	in RCX upath		;--- example "E:" or "E:\mydir"
	;---	in RDX uattr		;--- FILE_ATTRIBUTE_HIDDEN
	;---	in R8  ulevel		;--- nesting level to stop search 0=all
	;---	in R9  ufilter	;--- "*.asm"
	;---	in R10 ucback   ;--- address of a calback
	;---	in R11 uparam   ;--- user param
	;---------------------------------------------------

	mov r11,uzModName
	mov r10,.cb_dirs
	xor r8,r8
	xor r9,r9
	mov rdx,\
		FILE_ATTRIBUTE_DIRECTORY
	mov rcx,rdi
	call [bk64.listfiles]

	mov rsp,rbp
	pop r12
	pop rbx
	pop rbp
	ret 0

.cb_dirs:
	;---  the calback receives those args
	;--- in RCX path
	;--- in RDX w32fnd 
	;--- in R8h lenpath
	;--- in R9 uparam
	;--- ret RAX = 1 continue search, 0 stop search
	mov r11,rdx
	test rdx,rdx
	jz	.cb_dirsA

	lea r8,[r11+\
		WIN32_FIND_DATA.cFileName]

	mov rcx,r9
	mov rdx,r8
	call .ins_dir

.cb_dirsA:
	xor eax,eax
	inc eax
	ret 0

	;#---------------------------------------------------ö
	;|                   TMPL.INS_DIR                    |
	;ö---------------------------------------------------ü

.ins_dir:
	;--- in RCX typestring "module"
	;--- in RDX subdir "asm"
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14

	sub rsp,\
		FILE_BUFLEN+\
		sizea16.LVITEMW

	mov r12,rcx
	mov r13,rdx
	mov rbx,[pTmpl]
	mov rdi,rsp

	mov rdx,[templDir]
	lea rax,[rdx+\
		DIR.dir]

	push 0
	push rax
	push rdi
	push 0
	call art.catstrw	

	push rax

	push 0
	push r13
	push uzSlash
	push r12
	push uzSlash
	push rdi
	call art.catstrw	

	xor r8,r8
	xor edx,edx
	mov rcx,rdi
	call wspace.set_dir
	pop rcx
	test rax,rax
	jz	.ins_dirE
	mov r14,rax

	add rdi,rcx
	add rdi,rcx

	;--- count items ------
	mov rcx,[.tmpl.hLvwT]
	call lvw.get_count
	
.ins_dirA:
	lea r9,[rsp+\
		FILE_BUFLEN]

	mov [r9+\
		LVITEMW.iItem],eax

	mov ecx,[r14+\
		DIR.iIcon]

	mov [r9+\
		LVITEMW.iImage],ecx

	xor eax,eax
	mov [r9+\
		LVITEMW.iSubItem],eax

	mov [r9+\
		LVITEMW.lParam],r14

	mov [r9+\
		LVITEMW.pszText],rdi

	mov [r9+\
		LVITEMW.mask],\
		LVIF_PARAM or \
		LVIF_TEXT	or \
		LVIF_IMAGE

	mov rcx,[.tmpl.hLvwT]
	call lvw.ins_item

.ins_dirE:
	add rsp,\
		FILE_BUFLEN+\
		sizea16.LVITEMW
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0


;---	;ü------------------------------------------ö
;---	;|     .insert                              |
;---	;#------------------------------------------ä

.list_items:
	;--- in RCX dir
	
	;---	in RCX upath		;--- example "E:" or "E:\mydir"
	;---	in RDX uattr		;--- FILE_ATTRIBUTE_HIDDEN
	;---	in R8  ulevel		;--- nesting level to stop search 0=all
	;---	in R9  ufilter	;--- "*.asm"
	;---	in R10 ucback   ;--- address of a calback
	;---	in R11 uparam   ;--- user param
	;---------------------------------------------------
	push rcx

	mov rax,[pTmpl]
	mov rcx,[rax+TMPL.hLvwC]
	call lvw.del_all

	pop r11
	mov r10,.cb_items
	xor r8,r8
	xor r9,r9
	inc r8
	mov edx,\
		(not FILE_ATTRIBUTE_DIRECTORY)
	lea rcx,[r11+DIR.dir]
	call [bk64.listfiles]
	ret 0

.cb_items:
	;---  the calback receives those args
	;--- in RCX path
	;--- in RDX w32fnd 
	;--- in R8h lenpath
	;--- in R9 uparam
	;--- ret RAX = 1 continue search, 0 stop search

	mov r11,rdx
	test rdx,rdx
	jz	.cb_itemsA

	lea r8,[r11+\
		WIN32_FIND_DATA.cFileName]

	mov rcx,r9
	mov rdx,r8
	call .ins_item

.cb_itemsA:
	xor eax,eax
	inc eax
	ret 0


.ins_item:
	;--- in RCX dir
	;--- in RDX filename
;@break
	push rbx
	push r12
	push r13

	sub rsp,\
		sizeof.SHFILEINFOW+\
		sizeof.LVITEMW

	mov r12,rcx
	mov r13,rdx
	mov rbx,[pTmpl]

;@break
	;--- get small icon of it ----
	mov r10,\
		SHGFI_SYSICONINDEX or \
		SHGFI_USEFILEATTRIBUTES

	mov r9,\
		sizeof.SHFILEINFOW

	mov r8,rsp
	xor edx,edx
	mov rcx,r13
	call apiw.sfinfo

	;--- count items ------
	mov rcx,[.tmpl.hLvwC]
	call lvw.get_count
	
	lea r9,[rsp+\
		sizeof.SHFILEINFOW]

	mov [r9+\
		LVITEMW.iItem],eax

	mov ecx,[rsp+\
		SHFILEINFOW.iIcon]

	mov [r9+\
		LVITEMW.iImage],ecx

	xor eax,eax
	mov [r9+\
		LVITEMW.iSubItem],eax

	mov [r9+\
		LVITEMW.lParam],r12

	mov [r9+\
		LVITEMW.pszText],r13

	mov [r9+\
		LVITEMW.mask],\
		LVIF_PARAM or \
		LVIF_TEXT	or \
		LVIF_IMAGE

	mov rcx,[.tmpl.hLvwC]
	call lvw.ins_item

.ins_itemE:
	add rsp,\
		sizeof.SHFILEINFOW+\
		sizeof.LVITEMW
	pop r13
	pop r12
	pop rbx
	ret 0



