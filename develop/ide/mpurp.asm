  
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

mpurp:
	virtual at rbx
		.mp MPURP
	end virtual

	virtual at rbx
		.conf CONFIG
	end virtual

.proc:
@wpro rbp,\
		rbx rsi rdi

	cmp edx,\
		WM_INITDIALOG
	jz	.wm_initd
	cmp edx,\
		WM_WINDOWPOSCHANGED
	jz	.wm_poschged
	cmp edx,WM_COMMAND
	jz	.wm_command
	cmp edx,WM_NOTIFY
	jz	.wm_notify
	jmp	.ret0


.wm_notify:
	mov rbx,[pMp]
	mov rdx,[r9+\
		NMHDR.hwndFrom]
	cmp rdx,[.mp.hLview]
	jz	.lview_notify
	cmp rdx,[.mp.hCbxFilt]
	jz	.filt_notify
	jmp	.ret0


.filt_notify:
	mov edx,[r9+NMHDR.code]
	cmp edx,CBEN_ENDEDITW
	jz	.filt_endedit
	jmp	.ret0

.filt_endedit:
	mov eax,[r9+\
		NMCBEENDEDITW.fChanged]
	test eax,eax
	jz	.ret0
	mov eax,[r9+\
		NMCBEENDEDITW.iWhy]
	cmp eax,CBENF_RETURN
	jnz	.ret0

	lea rcx,[r9+\
		NMCBEENDEDITW.szText]
	movzx eax,[.mp.idCat]
	cmp eax,MP_DEVT
	jnz	.ret0

	call devtool.addgroup
	jmp	.ret0

.lview_notify:
	mov edx,[r9+\
		NMHDR.code]
	cmp edx,NM_DBLCLK
	jz	.lview_dblclk
	cmp edx,\
		LVN_ITEMCHANGED
	jz	.lview_ichged
	jmp .ret0

.lview_ichged:
	mov rcx,\
		[r9+\
		NM_LISTVIEW.lParam]
	test rcx,rcx
	jz	.ret0

	test [r9+\
		NM_LISTVIEW.uNewState],\
		LVIS_FOCUSED \
		or LVIS_SELECTED
	jz	.ret0

	movzx eax,[.mp.idCat]
	cmp eax,MP_DEVT
	jnz	.ret0

	mov rbx,[pTopDevT]
	mov rdi,rcx		;--- save topitem
	test ebx,ebx
	jz	.ret0

	mov rax,[rcx+\
		TITEM.param]
	test rax,rax
	jnz .lview_ichgedA

	sub rsp,\
		FILE_BUFLEN

	mov r8d,[rcx+\
		TITEM.attrib]
	test r8,r8
	jz	.ret0
	add r8,rbx

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

	test eax,eax	;--- err get_fname
	jz	.ret0
	cmp eax,ecx
	jz	.ret0		;--- nopath

	xor eax,eax
	xchg rcx,rdx
	mov word[rcx-2],ax
	xor edx,edx
	mov rcx,r8
	call wspace.set_dir
	test rax,rax
	jz .ret0

	mov [rdi+\
		TITEM.param],rax

.lview_ichgedA:
	mov rcx,rax
	call mnu.set_dir
	jmp	.ret0


.lview_dblclk:
	mov edx,[r9+\
		NMITEMACTIVATE.iItem]
	inc edx
	jz	.ret0

	dec edx
	xor eax,eax

	sub rsp,\
		sizea16.LVITEMW

	mov r9,rsp
	mov [r9+\
		LVITEMW.iItem],edx
	mov [r9+\
		LVITEMW.iSubItem],eax
	mov rcx,[.mp.hLview]
	call lvw.get_param

	mov rcx,[rsp+\
		LVITEMW.lParam]
	test ecx,ecx
	jz	.ret0

	movzx edx,[.mp.idCat]
	cmp edx,MP_DEVT
	jnz	@f
	call .lvw_dblclk_devt
@@:
	jmp	.ret0

.wm_command:
	mov rbx,[pMp]
	cmp r9,[.mp.hCbxCat]
	jz	.cat_command
	cmp r9,[.mp.hCbxFilt]
	jz	.filt_command
	jmp	.ret0

	;#------------------------------------ö
	;|      .filt_command                 |
	;ö------------------------------------ü

.filt_command:
	shr r8,16
	cmp r8w,\
		CBN_SELCHANGE
	jnz	.ret0

	xor eax,eax
	mov [.mp.iFilt],ax

	mov rcx,r9
	call cbex.get_cursel
	inc eax
	jz	.ret0
	dec eax
	dec eax
	jc	.ret0
	inc eax

	sub rsp,\
		FILE_BUFLEN
	mov r8,rsp
	mov edx,eax
	mov rcx,[.mp.hCbxFilt]
	call cbex.get_item

	;--- RET RAX index,-1
	;--- RET RCX pText
	;--- RET RDX LPARAM
	;--- RET R9 index image

	inc eax
	jz	.ret0
	dec eax
	test edx,edx
	jz	.ret0

	mov [.mp.iFilt],ax
	cmp [.mp.idCat],\
		MP_DEVT
	jnz	@f
	call .filt_devt_group
@@:
	jmp	.ret0


	;#------------------------------------ö
	;|      .cat_command                  |
	;ö------------------------------------ü

.cat_command:
	shr r8,16
	cmp r8w,\
		CBN_SELCHANGE
	jnz	.ret0

	xor eax,eax
	mov [.mp.idCat],ax

	mov rcx,r9
	call cbex.get_cursel
	inc eax
	jz	.ret0
	dec eax
	dec eax
	jns	.cat_commandA

	mov [.mp.idCat],ax
	mov [.mp.iFilt],ax

	mov rcx,[.mp.hCbxFilt]
	call cbex.reset

	mov rcx,[.mp.hLview]
	call lvw.del_all
	jmp	.ret1


.cat_commandA:
	inc eax
	sub rsp,\
		FILE_BUFLEN
	mov r8,rsp
	mov edx,eax
	mov rcx,[.mp.hCbxCat]
	call cbex.get_item

	;--- RET RAX index,-1
	;--- RET RCX pText
	;--- RET RDX LPARAM
	;--- RET R9 index image

	inc eax
	jz	.ret0
	dec eax
	test edx,edx
	jz	.ret0

	cmp edx,MP_DEVT
	jnz	@f
	call .cat_sel_devt
	jmp	.ret0
@@:
	jmp	.ret0

.wm_poschged:
;@break
	mov rbx,[pMp]
	sub rsp,sizeof.RECT*2
	lea rdx,[rsp]
	mov rcx,[.hwnd]
	call apiw.get_clirect

	lea rdx,[rsp+16]
	mov rcx,[.mp.hCbxCat]
	call apiw.get_winrect
	;----------------------------------
	mov eax,SWP_NOZORDER
	mov r11d,[rsp+16+RECT.bottom]
	sub r11d,[rsp+16+RECT.top]
	mov rdi,r11

	mov r10d,[rsp+RECT.right]
	mov rsi,r10

	mov r9,CY_GAP
	mov r8d,0;CX_GAP
	mov rdx,HWND_TOP
	mov rcx,[.mp.hCbxCat]
	call apiw.set_wpos

	;----------------------------------
	mov eax,\
		SWP_NOZORDER
	mov r11,rdi
	
	mov r10,rsi
	mov r9,rdi
	add r9,CY_GAP*2

	mov r8d,0;CX_GAP
	mov rdx,HWND_TOP
	mov rcx,[.mp.hCbxFilt]
	call apiw.set_wpos

	;----------------------------------
	mov eax,\
		SWP_NOZORDER
	mov r11,rdi
	shr r11,1
	mov r10,rsi
	mov r9,rdi
	add r9,rdi
	add r9,CY_GAP*3
	mov r8d,0;CX_GAP
	mov rdx,HWND_TOP
	mov rcx,[.mp.hPrg]
	call apiw.set_wpos

	;--------------------------------------------
	mov eax,SWP_NOZORDER
	mov r10,rsi
	mov r9,rdi
	shr r9,1
	add r9,rdi
	add r9,rdi
	add r9,CY_GAP*4
	mov r11d,[rsp+\
		RECT.bottom]
	sub r11,r9
	sub r11,CY_GAP
	mov r8d,0;CX_GAP
	mov rdx,HWND_TOP
	mov rcx,[.mp.hLview]
	call apiw.set_wpos
	jmp	.ret0

	;#---------------------------------------------------ö
	;|      .WM_INITDialog                               |
	;ö---------------------------------------------------ü

.wm_initd:
	mov rbx,[pMp]
	mov [.mp.hDlg],rcx

	mov rdx,MPURP_CBX_CAT
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	mov [.mp.hCbxCat],rax
	mov rsi,rax

	mov r9,[hBmpIml]
	mov r8,LVSIL_SMALL
	mov rcx,rax
	call cbex.set_iml

	sub rsp,\
		FILE_BUFLEN
	mov rdi,rsp

	push 0
	; push BB_SYS
	; push BB_RET
	; push BB_REG
	; push BB_PROCESS
	; push BB_PROC
	; push BB_MACRO
	; push BB_LABEL
	; push BB_IMPORT
	; push BB_IMM
	; push BB_FLOW
	; push BB_EXPORT
	; push BB_DATA
	; push BB_COMMENT
	; push BB_CALL
	; push BB_CODE
	; push BB_AKEY
	; push BB_FOLDER
	; push BB_WSP
	
	;push 0
	;push MP_SCI_CLS

	push 11
	push MP_DEVT

	push -1
	mov ecx,BB_NULL

.wm_initdA:
	push rcx
	mov r8,rdi
	mov edx,U16
	call [lang.get_uz]
	
	;--- in RCX hCb
	;--- in RDX string
	;--- in R8 imgindex
	;--- in R9 param
	;--- in R10 indent r10b,index overlay rest R10)
	;--- in R11 selimage

	xor r10,r10
	pop r9
	pop r11
	mov rdx,rdi
	mov rcx,rsi
	mov r8,r11
	call cbex.ins_item

	pop rcx
	test rcx,rcx
	jnz .wm_initdA	

	xor r8,r8
	mov rcx,[.mp.hCbxCat]
	call cbex.sel_item

	mov rdx,MPURP_CBX_FILT
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	mov [.mp.hCbxFilt],rax

	mov rdx,MPURP_PRG
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	mov [.mp.hPrg],rax

	mov rdx,MPURP_LVIEW
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	mov [.mp.hLview],rax

	mov rsi,rax
	mov rbx,[pConf]

	mov r9d,\
		[.conf.mpurp.bkcol]
	mov rcx,rsi
	call lvw.set_bkcol

	mov r9d,\
		[.conf.mpurp.bkcol]
	mov rcx,rsi
	call lvw.set_txtbkcol

.ret1:
	xor rax,rax
	inc rax
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.exit:
	@wepi

	;#---------------------------------------------------ö
	;|      LVW_DBLCLK_DEVT                              |
	;ö---------------------------------------------------ü

.lvw_dblclk_devt:
	;--- in RCX param = topitem
	;--- (in RBX pCp)
	;--- in RDX iCat = param = MP_DEVT

	mov rax,[pTopDevT]

	mov rdi,[rcx+\
		TITEM.param]	;--- dir slot

	mov r8d,[rcx+\
		TITEM.attrib]
	add r8,rax
	cmp r8,rax
	jnz .lddA
	xor eax,eax
	ret 0
	
.lddA:
;@break
	sub rsp,\
		FILE_BUFLEN*2

	mov rdx,rsp
	lea rcx,[r8+\
		TITEM.value]
	call utf8.to16

	mov r8,\
		MAX_UTF16_FILE_CPTS
	lea rdx,[rsp+\
		FILE_BUFLEN]
	mov rcx,rsp
	call apiw.exp_env

	test eax,eax
	jz	.lddE
	cmp eax,\
		MAX_UTF16_FILE_CPTS
	jae .lddE

	lea rcx,[rsp+\
		FILE_BUFLEN]
	call art.is_file
	jz .lddE

	;@break
	;	xor edx,edx
	;	lea rcx,[rsp+\
	;		FILE_BUFLEN]
	;	call wspace.spawn
	;jmp	.lddE

	mov rax,rdi
	mov r8,[appDir]
	test rdi,rdi
	cmovz rax,r8
	mov rdx,[rax+\
		DIR.rdir]
	test [rax+\
		DIR.type],DIR_HASREF
	cmovnz rax,rdx
	
	;call mnu.get_dir
	;test edx,edx
	;cmovnz rax,rdx

	mov r11,\
		SW_SHOWDEFAULT
	lea r10,[rax+\
		DIR.dir]
	xor r9,r9
	lea r8,[rsp+\
		FILE_BUFLEN]
	xor edx,edx
	mov rcx,[hMain]
	call apiw.shexec

;@break
;---	lea r8,[rax+\
;---		DIR.dir]
;---	xor ecx,ecx
;---	lea rdx,[rsp+\
;---		FILE_BUFLEN]
;---	call wspace.spawn

.lddE:
	add rsp,\
		FILE_BUFLEN*2
	ret 0

	;#---------------------------------------------------ö
	;|      CAT_SEL_DEVT                                 |
	;ö---------------------------------------------------ü

.cat_sel_devt:
	;--- in RCX text buf 512
	;--- (in RBX pMp)
	;--- in RDX idCat = param = MP_DEVT
	
	push rdi
	push rsi
	push r12
	mov rdi,rcx

	xor eax,eax
	mov [.mp.idCat],dx
	mov [.mp.iFilt],ax

	mov rcx,[.mp.hCbxFilt]
	call cbex.reset
	
	mov rcx,[.mp.hLview]
	call lvw.del_all

	mov r8,rdi
	mov edx,U16
	mov ecx,UZ_TOOLBYG 
	call [lang.get_uz]
	xor r9,r9

	xor r11,r11
	xor r10,r10
	xor r9,r9
	xor r8,r8
	mov rdx,rdi
	mov rcx,[.mp.hCbxFilt]
	call cbex.ins_item

	mov r12,[pTopDevT]
	mov rsi,r12
	xor eax,eax
	test r12,r12
	jz	.csdE

.csdN:
	test [rsi+\
		TITEM.type],TOBJECT
	jnz	.csdG

.csdN1:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,r12
	cmp rsi,r12
	jnz	.csdN

	xor r8,r8
	mov rcx,[.mp.hCbxFilt]
	call cbex.sel_item
	jmp	.csdE

.csdG:
	mov r8d,[rsi+\
		TITEM.attrib]
	add r8,r12
	cmp r8,r12
	jz .csdN1

	lea rcx,[r8+\
		TITEM.value]
	mov rdx,rdi
	call utf8.to16

	;--- in RCX hCb
	;--- in RDX string
	;--- in R8 imgindex
	;--- in R9 param
	;--- in R10 indent r10b,index overlay rest R10)
	;--- in R11 selimage

	xor r11,r11
	xor r10,r10
	mov r9,rsi
	xor r8,r8
	mov rdx,rdi
	mov rcx,[.mp.hCbxFilt]
	call cbex.ins_item
	jmp	.csdN1

.csdE:
	pop r12
	pop rsi
	pop rdi
	ret 0

	;#---------------------------------------------------ö
	;|      FILT_SCI_CLS                                 |
	;ö---------------------------------------------------ü
.filt_sci_cls:
	ret 0


	;#---------------------------------------------------ö
	;|      FILT_DEVT_GROUP                              |
	;ö---------------------------------------------------ü

.filt_devt_group:
	;--- in RCX text buf 512
	;--- (in RBX pCp)
	;--- in RDX iFilt = param = pointer to top Group

	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14

	sub rsp,\
		FILE_BUFLEN
	mov r13,rsp

	xor eax,eax
	mov rdi,rcx

	test edx,edx
	jz	.fdgE

;@break

	mov r12,[pTopDevT]
	mov rsi,rdx
	test r12,r12
	jz	.fdgE

	mov rcx,[.mp.hLview]
	call lvw.del_all

	mov r9,[hlaSysList]
	mov r8,LVSIL_NORMAL
	mov rcx,[.mp.hLview]
	call lvw.set_iml

	mov r8,LV_VIEW_ICON
	mov rcx,[.mp.hLview]
	call lvw.set_view
	
	mov esi,[rsi+\
		TITEM.child]
	add rsi,r12
	cmp rsi,r12
	jz	.fdgE

.fdgN:
	cmp [rsi+\
		TITEM.type],TLABEL
	jz	.fdgG

.fdgN1:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,r12
	cmp rsi,r12
	jnz	.fdgN

	jmp	.fdgE

.fdgG:
	mov r8d,[rsi+\
		TITEM.attrib]
	add r8,r12
	cmp r8,r12
	jz .csdN1

	lea rcx,[r8+\
		TITEM.value]
	mov rdx,r13
	call utf8.to16

	mov r8,\
		MAX_UTF16_FILE_CPTS
	mov rdx,rdi
	mov rcx,r13
	call apiw.exp_env

	test eax,eax
	jz	.fdgE
	cmp eax,\
		MAX_UTF16_FILE_CPTS
	jae .fdgE

	mov rcx,rdi
	call art.is_file
	jz .fdgN1

	sub rsp,\
		sizeof.SHFILEINFOW

	mov r10,\
		SHGFI_SYSICONINDEX or \
		SHGFI_USEFILEATTRIBUTES

	mov r9,\
		sizeof.SHFILEINFOW

	mov r8,rsp
	xor edx,edx
	mov rcx,rdi
	call apiw.sfinfo

	mov r14d,[rsp+\
		SHFILEINFOW.iIcon]

	add rsp,\
		sizeof.SHFILEINFOW

	mov rcx,rdi
	call art.get_fname

	;--- RET EAX 0,numchars
	;--- RET ECX total len
	;--- RET EDX pname "file.asm"
	;--- RET R8 string

	test eax,eax	;--- err get_fname
	jz	.fdgN1

	cmp eax,ecx
	jz	.fdgN1		;--- nopath

	mov rcx,r14
	call .ins_item_view
	jmp	.fdgN1

.fdgE:
	add rsp,\
		FILE_BUFLEN
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|                   PROP.INS_ITEM                   |
	;ö---------------------------------------------------ü

.ins_item_view:
	;--- insert an item in the lvw hDocs
	;--- in RCX iIcon
	;--- in RDX text
	;--- (in RDI text buf 512)
	;--- (in RSI pointer top item)
	;--- (in RBX pCp)

	sub rsp,\
		sizeof.LVITEMW

	xor eax,eax
	mov [rsp+\
		LVITEMW.iSubItem],eax

	mov [rsp+\
		LVITEMW.lParam],rsi

	mov [rsp+\
		LVITEMW.iImage],ecx

	mov [rsp+\
		LVITEMW.pszText],rdx

	mov rcx,[.mp.hLview]
	call lvw.get_count

	mov [rsp+\
		LVITEMW.iItem],eax

	mov [rsp+\
		LVITEMW.mask],\
		LVIF_TEXT	or \
		LVIF_IMAGE or \
		LVIF_PARAM

	mov r9,rsp
	mov rcx,[.mp.hLview]
	call lvw.ins_item

	add rsp,\
		sizeof.LVITEMW
	ret 0


.sel_ifilt:
	;--- in RCX iindex
	mov eax,MPURP.hCbxFilt
	jmp	.sel_cbxitem

.sel_icat:
	;--- in RCX iindex
	mov eax,MPURP.hCbxCat
	jmp	.sel_cbxitem

.sel_cbxitem:
	mov r8,rcx
	mov rdx,[pMp]
	mov rcx,[rax+rdx]
	push [rdx+MPURP.hDlg]
	push rcx
	call cbex.sel_item
	pop r9
	mov r8,CBN_SELCHANGE
	shl r8,16
	mov edx,WM_COMMAND
	pop rcx
	call apiw.sms
	ret 0
