  
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

	virtual at rbx
		.devt	DEVT
	end virtual

	virtual at rsi
		.devtitem	DEVTITEM
	end virtual

.proc:
@wpro rbp,\
		rbx rsi rdi

	cmp edx,\
		WM_WINDOWPOSCHANGED
	jz	.wm_poschged
	cmp edx,WM_COMMAND
	jz	.wm_command
	cmp edx,WM_NOTIFY
	jz	.wm_notify
	cmp edx,\
		WM_INITDIALOG
	jz	.wm_initd
	cmp edx,\
		WM_DESTROY
	jz	.wm_destroy
	jmp	.ret0

.get_data:
	;--- RET RAX = RBX 0,data
	call apiw.get_wldata
	mov rbx,rax
	test rax,rax
	ret 0

.wm_notify:
	mov rbx,[pDevT]
	mov rdx,[r9+\
		NMHDR.hwndFrom]
	cmp rdx,[.devt.hLvw]
	jz	.lvw_notify
	cmp rdx,[.devt.hCbx]
	jz	.cbx_notify
	cmp rdx,[hTip]
	jz	.tip_notify
	cmp rdx,[.devt.hTlb]
	jz	.tlb_notify_real
	jmp	.ret0

.tlb_notify_real:
	mov edx,[r9+NMHDR.code]
	cmp edx,TBN_GETINFOTIPW
	jnz	.ret0
;@break
	xor r8,r8
	xor r9,r9
	mov rcx,[hTip]
	call tip.popup
	jmp	.ret0
	
.tip_notify:
	mov rax,[r9+\
		NMHDR.idFrom]
	cmp rax,[.devt.hTlb]
	jnz	.ret0

.tlb_notify:
	mov edx,[r9+NMHDR.code]
	cmp edx,TTN_GETDISPINFOW
	jz	.tip_getdispinfo
	jmp	.ret0

.tip_getdispinfo:
	mov rdi,r9
	mov rax,[r9+NMTTDISPINFO.lpszText]
	mov rax,uzDefault
	mov [r9+NMTTDISPINFO.lpszText],rax

	sub rsp,8+\
		sizeof.TBBUTTON
	call apiw.get_msgpos
	mov ecx,eax
	and eax,0FFFFh
	and ecx,0FFFF0000h
	shl rcx,16
	or rax,rcx
	mov [rsp],rax

	mov r9,1
	mov r8,rsp
	mov rdx,[.devt.hTlb]
	mov rcx,0
	call apiw.map_wpt

	mov r9,rsp
	xor r8,r8
	mov edx,TB_HITTEST
	mov rcx,[.devt.hTlb]
	call apiw.sms
	test eax,eax
	js	.ret0

	mov r9,rsp
	mov r8,rax
	mov rcx,[.devt.hTlb]
	call tlb.get_but
	test eax,eax
	jz	.ret0

	mov edx,[rsp+\
		TBBUTTON.idCommand]
	mov rcx,[tMP_DEVT]
	call mnu.get_data
	test eax,eax
	jz	.ret0

	lea rdx,[rax+\
		sizeof.OMNI]
	mov [rdi+\
		NMTTDISPINFO.lpszText],rdx
	jmp	.ret1

.cbx_notify:
	mov edx,[r9+NMHDR.code]
	cmp edx,CBEN_ENDEDITW
	jz	.cbx_endedit
	jmp	.ret0

.cbx_endedit:
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
	call .addgroup
	jmp	.ret0

.lvw_notify:
	mov edx,[r9+\
		NMHDR.code]
	cmp edx,NM_DBLCLK
	jz	.lvw_dblclk
	cmp edx,\
		LVN_ITEMCHANGED
	jz	.lvw_ichged
	jmp .ret0
	
.lvw_ichged:
	mov rax,[r9+\
		NM_LISTVIEW.lParam]
	test rax,rax
	jz	.ret0

	test [r9+\
		NM_LISTVIEW.uNewState],\
		LVIS_FOCUSED \
		or LVIS_SELECTED
	jz	.ret0

	mov rcx,[rax+\
		DEVTITEM.dir]
	call mnu.set_dir
	jmp	.ret0

.lvw_dblclk:
	mov edx,[r9+\
		NMITEMACTIVATE.iItem]
	inc edx
	jz	.ret0

	dec edx
	xor eax,eax

	sub rsp,\
		sizea16.LVITEMW+\
		FILE_BUFLEN

	mov r9,rsp
	mov [r9+\
		LVITEMW.iItem],edx
	mov [r9+\
		LVITEMW.iSubItem],eax
	mov rcx,[.devt.hLvw]
	call lvw.get_param

	mov rcx,[rsp+\
		LVITEMW.lParam]
	test ecx,ecx
	jz	.ret0

	mov rsi,rcx
	mov rdx,[.devtitem.dir]
	test edx,edx
	jz .ret0
	mov r8,[rdx+DIR.rdir]
	test [rdx+DIR.type],\
		DIR_HASREF
	cmovz r8,rdx

	mov rax,rsp
	lea rcx,[r8+DIR.dir]
	mov rdi,rcx

	lea rdx,[rsi+\
		sizeof.DEVTITEM]

	push 0
	push rdx
	push uzSlash
	push rcx
	;---	push uzStart
	push rax
	push 0
	call art.catstrw

	mov rcx,rsp
	;--- lea rcx,[rsp+16]
	call art.is_file
	jz .ret0

	;--- TODO: to be changed after having
  ;--- dialog of properties setting on item
	;--- ok using cmd /C pat+file and
	;--- SW_SHOWNORMAL by spawning consoles
	;--- while SW_HIDE for other file,etc
	
	;---	mov r8,rdi
	;---	mov rdx,rsp
	;---	xor ecx,ecx
	;---	call wspace.spawn

	mov r11,\
		SW_SHOWDEFAULT
	mov r10,rdi
	xor r9,r9
	mov r8,rsp
	xor edx,edx
	mov rcx,[hMain]
	call apiw.shexec
	jmp	.ret0

.wm_command:
	mov rbx,[pDevT]
	cmp r9,[.devt.hCbx]
	jz	.cbx_command
	cmp r9,[.devt.hTlb]
	jz	.tlb_command
	;@break
	jmp	.ret0

.tlb_command:
	xor r9,r9
	and r8,0FFFFh
	mov edx,WM_COMMAND
	mov rcx,[hMain]
	call apiw.sms
	jmp	.ret0

.cbx_command:
	shr r8,16
	cmp r8w,\
		CBN_SELCHANGE
	jnz	.ret0

	mov rcx,r9
	call cbex.get_cursel
	mov ecx,eax
	inc eax
	jz	.ret0
	call .viewgroup
	jmp	.ret0

.wm_destroy:
	call .get_data
	jz	.ret0

	;--- write
	call .write

	;--- destroy ----
	mov rcx,rbx
	call .discard
	jmp	.ret0


.wm_poschged:
	push r12
	push r13
	push r14
	push r15

	mov rbx,[pDevT]
	sub rsp,\
		sizeof.RECT

	mov rdx,rsp	
	mov rcx,[.devt.hTlb]
	call apiw.get_winrect
	mov r12d,[rsp+RECT.bottom]
	sub r12d,[rsp+RECT.top]	;--- toolbar cy
	
	mov rdx,rsp
	mov rcx,[.devt.hCbx]
	call apiw.get_winrect
	mov r13d,[rsp+RECT.bottom]
	sub r13d,[rsp+RECT.top]	;--- cbx cy

	mov rdx,rsp
	mov rcx,[.hwnd]
	call apiw.get_clirect

	mov r14d,[rsp+RECT.right]
	sub r14d,[rsp+RECT.left]

	mov rax,SWP_NOZORDER or\
		SWP_NOMOVE
	mov r9d,[rsp+RECT.top]
	mov r8d,[rsp+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.devt.hTlb]
	call apiw.set_wpos

	mov rax,SWP_NOZORDER
	mov r11,r13
	mov r10,r14
	mov r9,r12
	mov r8d,[rsp+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.devt.hCbx]
	call apiw.set_wpos

	mov eax,SWP_NOZORDER ;or \
;---		SWP_NOSENDCHANGING or \
;---		SWP_NOCOPYBITS

	mov r9,r12
	add r9,r13
	mov r11d,[rsp+RECT.bottom]
	sub r11,r9
	sub r11,CY_GAP*2
	mov r10,r14
	add r9,CY_GAP
	mov r8d,[rsp+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.devt.hLvw]
	call apiw.set_wpos	
	pop r15
	pop r14
	pop r13
	pop r12
	jmp	.ret0

.wm_initd:
	mov rbx,r9
	mov [.devt.hwnd],rcx
	mov r8,rbx
	call apiw.set_wldata
	mov [.devt.id],DEVT_DLG

	mov rdx,DEVT_CBX
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	mov [.devt.hCbx],rax

	mov rdx,DEVT_LVW
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	mov [.devt.hLvw],rax

	mov rsi,[pConf]
	mov r9d,\
		[rsi+CONFIG.devt.bkcol]
	mov rcx,[.devt.hLvw]
	call lvw.set_bkcol

	mov r9d,\
		[rsi+CONFIG.devt.bkcol]
	mov rcx,[.devt.hLvw]
	call lvw.set_txtbkcol

	;-------------------------
	mov r9,[hlaSysList]
	mov r8,LVSIL_NORMAL
	mov rcx,[.devt.hLvw]
	call lvw.set_iml

	mov r8,LV_VIEW_ICON
	mov rcx,[.devt.hLvw]
	call lvw.set_view

	;-------------------------
	mov rdx,DEVT_TLB
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	mov [.devt.hTlb],rax

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

	push 0
	push MI_DEVT_REMG
	push 0
	push MI_DEVT_ADDG
	push 12
	push MI_DEVT_REM
	push 10
	mov r8,MI_DEVT_ADD
	or edi,-1

.wm_initdT:
	inc edi
	pop rdx
	mov r9,TBSTATE_ENABLED	
	shl r9,8
	or r9l,TBSTYLE_BUTTON
	xor r10,r10
	xor r11,r11
	;mov r11,uzDefault
	mov eax,edi
	mov rcx,[.devt.hTlb]
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
	mov r8,[.devt.hTlb]
	mov rdx,[.hwnd]
	mov rcx,[hTip]
	call tip.add

	sub rsp,\
		FILE_BUFLEN

	mov r8,rsp
	mov edx,U16
	mov ecx,UZ_MSG_TADDG
	call [lang.get_uz]

	mov rcx,[.devt.hCbx]
	call cbex.get_edit

	mov r9,rsp
	mov r8,rax
	mov rdx,[.hwnd]
	mov rcx,[hTip]
	call tip.add

	mov rcx,rbx
	call .load
	test eax,eax
	jz	.ret1
	mov rsi,rax

.wm_initdA:
	push [rsi+\
		DEVTITEM.next]

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
	lea rdx,[rsi+\
		sizeof.DEVTITEM]
	mov rcx,[.devt.hCbx]
	call cbex.ins_item
	pop rsi
	test rsi,rsi
	jnz	.wm_initdA

	xor ecx,ecx
	call .viewgroup

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


	;ü------------------------------------------ö
	;|     .viewgroup                           |
	;#------------------------------------------ä
.viewgroup:
	;--- in RCX idx
	;--- ret RAX 0,item
	push rbx
	push rsi
	push r12

	mov r12,rcx
	mov rbx,[pDevT]
	mov rcx,[.devt.hLvw]
	call lvw.del_all

	mov rdx,r12
	mov rcx,[.devt.hCbx]
	call cbex.get_param
	test edx,edx
	jz	.viewgroupE

	mov rax,[rdx+\
		DEVTITEM.item]
	test eax,eax
	jz	.viewgroupF
	mov rsi,rax

.viewgroupA:
	push [.devtitem.next]
	or r8,-1
	mov rcx,[.devt.hLvw]
	mov rdx,rsi
	call .ins_item

	pop rsi
	test esi,esi
	jnz	.viewgroupA

.viewgroupF:
	mov r8,r12
	mov rcx,[.devt.hCbx]
	call cbex.sel_item

.viewgroupE:
	pop r12
	pop rsi
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|                   PROP.INS_ITEM                   |
	;ö---------------------------------------------------ü

.ins_item:
	;--- in RCX hLvw
	;--- in RDX DEVTITEM
	;--- in R8 after index,-1 at end
	push rbx
	push rsi
	push rdi
	push r12

	sub rsp,\
		sizeof.SHFILEINFOW+\
		FILE_BUFLEN+\
		sizeof.LVITEMW

	mov r12,r8
	mov rbx,rcx
	mov rdi,rsp
	mov rsi,rdx

	;--- compose path+filename
	mov rdx,[.devtitem.dir]
	test edx,edx
	jz .ins_itemE
	mov r8,[rdx+DIR.rdir]
	test [rdx+DIR.type],\
		DIR_HASREF
	cmovz r8,rdx

	lea rax,[r8+DIR.dir]
	lea rdx,[rsi+\
		sizeof.DEVTITEM]
	lea rcx,[rdi+\
		sizeof.SHFILEINFOW]

	push 0
	push rdx
	push uzSlash
	push rax
	push rcx
	push 0
	call art.catstrw

	;--- check existence -----
	lea rcx,[rdi+\
		sizeof.SHFILEINFOW]
	call art.is_file
	jz .ins_itemE

	;--- get large icon of it ----
	mov r10,\
		SHGFI_SYSICONINDEX or \
		SHGFI_USEFILEATTRIBUTES

	mov r9,\
		sizeof.SHFILEINFOW

	mov r8,rdi
	xor edx,edx
	lea rcx,[rdi+\
		sizeof.SHFILEINFOW]
	call apiw.sfinfo

	inc r12
	jnz	.ins_itemA
	;--- count items ------
	mov rcx,rbx
	call lvw.get_count
	mov r12,rax

.ins_itemA:
	lea r9,[rsp+\
		sizeof.SHFILEINFOW+\
		FILE_BUFLEN]

	mov [r9+\
		LVITEMW.iItem],r12d

	mov ecx,[rsp+\
		SHFILEINFOW.iIcon]

	mov [r9+\
		LVITEMW.iImage],ecx

	xor eax,eax
	mov [r9+\
		LVITEMW.iSubItem],eax

	mov [r9+\
		LVITEMW.lParam],rsi

	lea rdx,[rsi+\
		sizeof.DEVTITEM]

	mov [r9+\
		LVITEMW.pszText],rdx

	mov [r9+\
		LVITEMW.mask],\
		LVIF_TEXT	or \
		LVIF_IMAGE or \
		LVIF_PARAM

	mov rcx,rbx
	call lvw.ins_item

.ins_itemE:
	add rsp,\
		sizeof.SHFILEINFOW+\
		FILE_BUFLEN+\
		sizeof.LVITEMW
	pop r12
	pop rdi
	pop rsi
	pop rbx
	ret 0

	;ü------------------------------------------ö
	;|     .ADDGROUP                            |
	;#------------------------------------------ä

.addgroup:
	;--- in RCX 0,name
	push rbx
	push rdi
	push rsi
	push r12

	mov rdi,rcx
	mov rbx,[pDevT]
	sub rsp,\
		sizeof.COMBOBOXEXITEMW

	mov rcx,[.devt.hCbx]
	call cbex.get_cursel
	mov edx,eax
	mov r12,rax
	inc eax
	jz	.addgroupA

	mov rcx,[.devt.hCbx]
	call cbex.get_param
	xor eax,eax
	test edx,edx
	jz	.addgroupE

	mov rsi,rdx

.addgroupA:
	xor r8,r8
	xor edx,edx
	mov rcx,rdi
	call .new
	test eax,eax
	jz	.addgroupE

	lea rdi,\
		[rax+sizeof.DEVTITEM]

	mov r9,rsp
	xor r8,r8

	push rax
	inc r12
	jnz	.addgroupB
	mov [.devt.pGrp],rax
	jmp	.addgroupC

.addgroupB:
	mov rcx,[.devtitem.next]
	mov [rax+DEVTITEM.next],rcx
	mov [.devtitem.next],rax

.addgroupC:
	mov [r9+\
		COMBOBOXEXITEMW.mask],\
		CBEIF_TEXT or \
		CBEIF_LPARAM

	mov [r9+\
		COMBOBOXEXITEMW.pszText],rdi
	mov [r9+\
		COMBOBOXEXITEMW.lParam],rax
	mov [r9+\
		COMBOBOXEXITEMW.iItem],r12

	mov rdx,\
		CBEM_INSERTITEMW
	mov rcx,\
		[.devt.hCbx]
	call apiw.sms

	mov rcx,r12
	call .viewgroup
	pop rax

.addgroupE:
	add rsp,\
		sizeof.COMBOBOXEXITEMW
	pop r12
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
	mov rbp,rsp

	mov rbx,[pDevT]
	and rsp,-16

	sub rsp,\
		FILE_BUFLEN*2

	mov rcx,\
		[.devt.hCbx]
	call cbex.get_cursel
	mov r12,rax

	mov edx,eax
	mov rcx,[.devt.hCbx]
	call cbex.get_param

	xor eax,eax
	test edx,edx
	jz	.remgroupE
	mov rsi,rdx

	mov r8,rsp
	mov edx,U16
	mov ecx,UZ_MSG_U_TGREM
	call [lang.get_uz]

	mov rdi,rax
	add rdi,rsp
	@nearest 16,rdi

 	lea r8,[rsi+\
		sizeof.DEVTITEM]
	mov rdx,rsp
	mov rcx,rdi
	sub rsp,20h
	call [swprintf]
	add rsp,20h

	mov r8,uzTitle
	mov rdx,rdi
	mov rcx,[hMain]
	call apiw.msg_yn
	cmp eax,IDNO
	jz .remgroupE

;@break
	mov rdi,r12
	test r12,r12
	jz	.remgroupB

	xor eax,eax
	mov rcx,[.devt.pGrp]
	test ecx,ecx
	jz .remgroupE

.remgroupA1:
	mov rdx,[rcx+\
		DEVTITEM.next]
	cmp rdx,rsi
	jz	.remgroupA
	inc eax
	mov rcx,rdx
	jmp	.remgroupA1

.remgroupA:
	mov r8,[.devtitem.next]
	mov [rcx+DEVTITEM.next],r8
	mov rdi,rax
	test rdx,rdx
	jnz	.remgroupF
	dec rdi
	dec r12
	jmp	.remgroupF

.remgroupB:
	;--- our is the 1st
	mov rax,[.devtitem.next]
	mov [.devt.pGrp],rax
	test rax,rax
	jnz	.remgroupF
	dec rdi

.remgroupF:
	mov rcx,[.devtitem.item]

.remgroupF2:
	test rcx,rcx
	jz	.remgroupF1
	push [rcx+\
		DEVTITEM.next]
	call art.a16free
	pop rcx
	jmp	.remgroupF2

.remgroupF1:
	mov rcx,[.devt.hLvw]
	call lvw.del_all

	mov r8,r12
	mov rcx,[.devt.hCbx]
	call cbex.del_item	

	mov rcx,rsi
	call art.a16free

	test edi,edi
	js .remgroupE

	mov r8,rdi
	mov rcx,[.devt.hCbx]
	call cbex.sel_item

	mov r9,[.devt.hCbx]
	mov r8,CBN_SELCHANGE
	shl r8,16
	mov edx,WM_COMMAND
	mov rcx,[.devt.hwnd]
	call apiw.sms


.remgroupE:
	mov rsp,rbp
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;ü------------------------------------------ö
	;|     .DISCARD    DEVTOOL                  |
	;#------------------------------------------ä

.discard:
	;--- in RCX devt
	push rbx
	mov rbx,rcx

	xor eax,eax
	mov rcx,[.devt.pGrp]
	test rcx,rcx
	jnz .discardG
	pop rbx
	ret 0

.discardG:
	mov rdx,[rcx+\
		DEVTITEM.item]
	test rdx,rdx
	jz	.discardG1

	push rcx
	mov rcx,rdx

.discardI:
	push [rcx+\
		DEVTITEM.next]
	call art.a16free
	pop rcx
	test ecx,ecx
	jnz	.discardI
	pop rcx
	
.discardG1:
	push [rcx+\
		DEVTITEM.next]

.discardG2:
	call art.a16free
	pop rcx
	test ecx,ecx
	jnz	.discardG

	pop rbx
	ret 0

	;ü------------------------------------------ö
	;|     .LOAD   DEVTOOL                      |
	;#------------------------------------------ä

.load:
	;--- in RCX devt
	;--- ret RAX pGrp
	push rbp
	push rbx
	push rsi
	push r12

	mov rbp,rsp
	mov rbx,rcx
	sub rsp,\
		FILE_BUFLEN
	xor r12,r12

	mov rax,rsp
	xor edx,edx

	;--- check load for [config\devtool.utf8]
	push rdx
	push uzUtf8Ext
	push uzDevTName
	push uzSlash
	push uzConfName
	push rax
	push rdx
	call art.catstrw

.loadA:
	;--- check file exists
	mov rcx,rsp
	call art.is_file
	jz .loadD

	mov rcx,rsp
	call [top64.parse]
	test rax,rax
	jz	.loadD
	mov rsi,rax

	;--- RET RCX datasize
	;--- RET RDX numitems
	test edx,edx
	jz	.loadD1

	mov rcx,rax
	call .read
	test eax,eax
	jz	.loadD1
	mov r12,rax

.loadD1:
	mov rcx,rsi
	call [top64.free]
	test r12,r12
	jnz	.loadE

.loadD:
	xor r8,r8
	xor edx,edx
	xor ecx,ecx
	call .new
	test rax,rax
	jz	.loadE
	mov r12,rax

.loadE:
	mov [.devt.pGrp],r12
	mov rax,r12
	mov rsp,rbp
	pop r12
	pop rsi
	pop rbx
	pop rbp
	ret 0

	;ü------------------------------------------ö
	;|     .READ   DEVTOOL                      |
	;#------------------------------------------ä
.read:
	;--- in RCX top
	;--- ret RAX first group
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15
	mov rbp,rsp

	sub rsp,\
		FILE_BUFLEN*2+10h
	mov r15,rsp
	mov rbx,rcx
	mov rsi,rcx
	xor r12,r12
	xor r13,r13
	push 0

.readA:
	test [rsi+\
		TITEM.type],TOBJECT
	jz	.readN

	mov eax,[rsi+\
		TITEM.attrib]
	add rax,rbx
	cmp rax,rbx
	jz	.readN

	cmp [rax+\
		TITEM.type],\
		TQUOTED
	jnz	.readN

	lea rcx,[rax+\
		TITEM.value]

	movzx edx,[rax+\
		TITEM.len]
	xor eax,eax
	dec edx
	jl	.readN
	inc edx

	mov rdx,r15
	call utf8.to16

	xor r8,r8
	xor edx,edx
	mov rcx,r15
	call .new

	test eax,eax
	jz	.readF		;--- preserve what is done ok

	push rax
	xchg rax,r12
	test rax,rax
	jz .readA2
	mov [rax+\
		DEVTITEM.next],r12

.readA2:
	xor r13,r13	;--- prev item
	mov [r12+\
		DEVTITEM.next],r13
	mov [r12+\
		DEVTITEM.item],r13

.readI:
	;--- read items -----------
	mov r14d,[rsi+\
		TITEM.child]
	test r14,r14
	jz .readN
	add r14,rbx

.readI1:
	xor eax,eax
	mov [r15],rax
	mov [r15+8],rax

	test [r14+\
		TITEM.type],TLABEL
	jz	.readNI

	mov edi,[r14+\
		TITEM.attrib]
	test edi,edi
	jz .readNI
	add rdi,rbx

	xor eax,eax
	cmp [rdi+\
		TITEM.type],TQUOTED
	jnz	.readNI

	movzx ecx,[rdi+\
		TITEM.len]
	dec ecx
	jl	.readNI
	inc ecx

	;--- store cmd ---------
	lea rdx,[r15+16]
	lea rcx,[rdi+\
		TITEM.value]
	call utf8.to16
	
	;--- check cmd flags -------
	xor eax,eax
	mov edi,[rdi+\
		TITEM.attrib]
	test edi,edi
	jz .readI3
	add rdi,rbx

	cmp [rdi+\
		TITEM.type],TNUMBER
	jnz	.readI3

	mov ecx,[rdi+\
		TITEM.lo_dword]
	and [r15],rcx
	
	;--- check param -------
	mov edi,[rdi+\
		TITEM.attrib]
	xor eax,eax
	test edi,edi
	jz .readI3
	add rdi,rbx

	cmp [rdi+\
		TITEM.type],TQUOTED
	jnz	.readI3
	
	movzx ecx,[rdi+\
		TITEM.len]
	dec ecx
	jl	.readI3
	inc ecx
	
	;--- store param ---------
	lea rdx,[r15+\
		16+FILE_BUFLEN]
	lea rcx,[rdi+\
		TITEM.value]
	push rdx
	call utf8.to16
	pop qword[r15+8]

.readI3:
	mov r9,SW_SHOWDEFAULT
	mov r8,[r15]
	test r8,r8
	cmovz r8,r9

	mov rdx,[r15+8]
	lea rcx,[r15+16]
	call .new
	test rax,rax
	jz .readNI	;<--- continue to next valid item

	mov [rax+\
		DEVTITEM.group],r12
	
	test r13,r13
	jnz	@f
	mov [r12+\
		DEVTITEM.item],rax
	mov r13,rax
	jmp	.readNI
@@:
	mov [r13+\
		DEVTITEM.next],rax
	mov r13,rax

.readNI:
	mov r14d,[r14+\
		TITEM.next]
	add r14,rbx
	cmp r14,rbx
	jnz	.readI1

.readN:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,rbx
	cmp rsi,rbx
	jnz	.readA

.readF:	
	mov rax,[rsp]
	test rax,rax
	lea rdx,[rsp+8]
	cmovnz r12,rax
	mov rsp,rdx
	jnz	.readF
	mov rax,r12

.readE:
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

	;ü------------------------------------------ö
	;|     .NEW    DEVTOOL                      |
	;#------------------------------------------ä
.new:
	;--- in RCX cmd
	;--- in RDX para
	;--- in R8 flags
	;--- RET RAX DEVTITEM
	push rbp
	push rbx
	push rdi
	push rsi

	mov rbp,rsp
	mov rbx,r8
	mov rsi,rcx
	mov rdi,rdx
	
	mov eax,\
		sizeof.DEVTITEM+\
		FILE_BUFLEN*3
	sub rsp,rax

	mov rdx,rsp
	mov rcx,rax
	call art.zeromem

	test ebx,ebx
	jz	.newD

.newI:
	;--- work on a cmd ----
	mov [rsp+\
		DEVTITEM.flags],ebx

	mov r8,\
		MAX_UTF16_FILE_CPTS
	lea rdx,[rsp+\
		sizeof.DEVTITEM+\
		FILE_BUFLEN*2]
	mov rcx,rsi
	xor ebx,ebx
	call apiw.exp_env
	test eax,eax
	jz	.newE

	cmp eax,\
		MAX_UTF16_FILE_CPTS
	jae .newE

	lea rcx,[rsp+\
		sizeof.DEVTITEM+\
		FILE_BUFLEN*2]
	call art.is_file
	jz	.newE

	mov rcx,rsi
	call art.get_fname

	;--- RET EAX 0,numchars
	;--- RET ECX total len
	;--- RET EDX pname "file.asm"
	;--- RET R8 string

	xor r8,r8
	test eax,eax 	;--- err get_fname
	jz .newE
	
	cmp eax,ecx
	jz	.newE		;--- nopath
	
	push rdx
	push qword[rdx-8]
	mov rcx,rsi
	mov [rdx-2],r8w

	xor r8,r8
	xor edx,edx
	call wspace.set_dir
	pop r8
	test eax,eax
	pop rcx
	mov [rcx-8],r8
	jz .newE
	
	mov [rsp+\
		DEVTITEM.dir],rax

	lea rdx,[rsp+\
		sizeof.DEVTITEM]
	call utf16.copyz
	add eax,4
	mov [rsp+\
		DEVTITEM.oparam],eax

	inc eax
	@nearest 8,eax

	add eax,\
		sizeof.DEVTITEM
	mov ecx,eax
	mov ebx,eax

	test edi,edi
	jz	.newA

	mov eax,[rsp+\
		DEVTITEM.oparam]
	mov rcx,rdi
	lea rdx,[rax+rsp+\
		sizeof.DEVTITEM]
	call utf16.copyz	
	add ebx,eax
	add ebx,4
	mov ecx,ebx
	jmp	.newA

.newD:
	test rsi,rsi
	jnz	.newG

	;--- default group
	lea r8,[rsp+\
		sizeof.DEVTITEM]
	mov edx,U16
	mov ecx,UZ_TOOLGEN
	call [lang.get_uz]
	add eax,4
	mov [rsp+\
		DEVTITEM.oparam],eax
	add eax,\
		sizeof.DEVTITEM+4
	inc eax
	@nearest 8,eax
	mov ecx,eax
	mov ebx,eax
	jmp	.newA
	
.newG:
	lea rdx,[rsp+\
		sizeof.DEVTITEM]
	mov rcx,rsi
	call utf16.copyz
	add eax,4
	mov [rsp+\
		DEVTITEM.oparam],eax
	add eax,\
		sizeof.DEVTITEM
	inc eax
	@nearest 8,eax
	mov ecx,eax
	mov ebx,eax

.newA:
	call art.a16malloc
	xchg rax,rbx
	test ebx,ebx
	jz	.newE

	mov rdx,rbx
	mov rsi,rsp
	mov rdi,rbx
	mov ecx,eax
	shr ecx,3
	rep movsq
	mov rbx,rdx

.newE:
	mov rax,rbx
	mov rsp,rbp
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0


	;ü------------------------------------------ö
	;|     .ADDTOOL                             |
	;#------------------------------------------ä

.addtool:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15

	sub rsp,\
		sizeof.LVITEMW+\
		FILE_BUFLEN

	;--- check against no groups
	xor r14,r14	;--- selected DEVTITEM
	xor r15,r15	;--- selected GROUP
	xor ebp,ebp	;--- group index

	mov rbx,[pDevT]
	mov rax,[.devt.pGrp]
	test eax,eax
	jz .addtoolE

	;--- force update when just added group
	mov rcx,[.devt.hCbx]
	call apiw.set_focus

	mov rcx,[.devt.hCbx]
	call cbex.get_cursel
	inc eax
	jz .addtoolE
	dec eax
	mov rbp,rax

	mov rdx,rax
	mov rcx,[.devt.hCbx]
	call cbex.get_param
	test edx,edx
	jz .addtoolE
	mov r15,rdx

	;--- check if toolitem selected
	mov r9,\
		LVNI_SELECTED
	or r8,-1
	mov rcx,[.devt.hLvw]
	call lvw.get_next
	mov r12,rax

	mov rdx,[toolDir]
	lea r13,[rdx+DIR.dir]
	inc rax
	jnz	.addtoolA

	;--- get dir from current menu
	call mnu.get_dir
	mov r13,rax
	jmp	.addtoolA1

.addtoolA:
	xor r10,r10
	mov r8,r12
	mov r9,rsp
	mov [r9+\
		LVITEMW.iItem],r12d
	mov [r9+\
		LVITEMW.iSubItem],r10d
	mov rcx,[.devt.hLvw]
	call lvw.get_param

	mov rax,[rsp+\
		LVITEMW.lParam]
	test rax,rax
	jz	.addtoolE
	mov r14,rax

	mov r13,\
		[rax+DEVTITEM.dir]
	
.addtoolA1:
	;--- get expanded dir -----
	mov rax,r13
	mov rdx,[r13+DIR.rdir]
	test [rax+DIR.type],\
		DIR_HASREF
	cmovnz r13,rdx

	lea r8,[rsp+\
		sizeof.LVITEMW]
	mov edx,U16
	mov ecx,UZ_TOOLPICK
	call [lang.get_uz]
	
	;--- in RCX title
	;--- in RDX filespec
	;--- in R8 flags
	;--- in R9 startdir

	lea r9,[r13+DIR.dir]
	mov r8,0\
		or FOS_NODEREFERENCELINKS\
		or FOS_ALLNONSTORAGEITEMS\
		or FOS_PATHMUSTEXIST
	xor edx,edx
	lea rcx,[rsp+\
		sizeof.LVITEMW]
	call [dlg.open]

	test eax,eax
	jz	.addtoolE
	mov rdi,rax

	;--- in RCX cmd
	;--- in RDX para
	;--- in R8 flags
	mov r8,\
		SW_SHOWNORMAL
	xor edx,edx
	mov rcx,rdi
	call .new
	test eax,eax
	jz .addtoolF
	mov rsi,rax

	mov r8,r12
	mov rdx,rax
	mov rcx,[.devt.hLvw]
	call .ins_item

	mov [.devtitem.group],r15

	mov rcx,[r15+\
		DEVTITEM.item]
	test rcx,rcx
	jnz .addtoolG2
	mov [r15+\
		DEVTITEM.item],rsi
	jmp	.addtoolF

.addtoolG2:
	inc r12
	jz	.addtoolG
	mov rax,[r14+\
		DEVTITEM.next]
	mov [.devtitem.next],rax
	mov [r14+\
		DEVTITEM.next],rsi
	jmp	.addtoolF


.addtoolG:
	test rcx,rcx
	jnz	.addtoolG1
	mov [rdx+\
		DEVTITEM.next],rsi
	jmp	.addtoolF

.addtoolG1:
	mov rdx,rcx
	mov rcx,[rcx+\
		DEVTITEM.next]
	jmp	.addtoolG

.addtoolF:
	mov rcx,rdi
	call apiw.co_taskmf

	mov rcx,rbp
	call .viewgroup


.addtoolE:
	add rsp,\
		sizeof.LVITEMW+\
		FILE_BUFLEN
	pop r15
	pop r14
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
	;--- check if toolitem selected
	push rbx
	push rsi
	push r12

	mov rbx,[pDevT]
	sub rsp,\
		sizeof.LVITEMW

	mov r9,\
		LVNI_SELECTED
	or r8,-1
	mov rcx,[.devt.hLvw]
	call lvw.get_next
	inc rax
	jz	.remtoolE
	dec rax
	mov r12,rax

	xor r10,r10
	mov r8,rax
	mov r9,rsp
	mov [r9+\
		LVITEMW.iItem],eax
	mov [r9+\
		LVITEMW.iSubItem],r10d
	mov rcx,[.devt.hLvw]
	call lvw.get_param

	mov rax,[rsp+\
		LVITEMW.lParam]
	test rax,rax
	jz	.remtoolE
	mov rsi,rax

	;--- get previous item listing from first
	mov rdx,[.devtitem.group]
	test edx,edx
	jz	.remtoolE 

	mov rcx,[rdx+\
		DEVTITEM.item]
	cmp rcx,rsi
	jnz	.remtoolA

	;--- our is first
	mov rax,[rcx+\
		DEVTITEM.next]
	mov [rdx+\
		DEVTITEM.item],rax
	jmp	.remtoolF

.remtoolA:
	mov rdx,[rcx+\
		DEVTITEM.next]
	cmp rsi,rdx
	jz	.remtoolA1
	test edx,edx
	jz	.remtoolE	;--- err pointers
	mov rcx,rdx
	jmp	.remtoolA

.remtoolA1:
	mov rax,\
		[.devtitem.next]
	mov [rcx+\
		DEVTITEM.next],rax
	
.remtoolF:
	mov r8,r12
	mov rcx,[.devt.hLvw]
	call lvw.del_item

	mov rcx,rsi
	call art.a16free

.remtoolE:
	add rsp,\
		sizeof.LVITEMW
	pop r12
	pop rsi
	pop rbx
	ret 0


;---.io_btn:
;---	mov rsi,[pIo]
;---	add rsi,IO_DEVTOOL
;---	mov rbx,[pHu]
;---	lea rdi,[.io.buf]

;---	mov r9,rdi
;---	mov r8,0\
;---		or FOS_NODEREFERENCELINKS\
;---		or FOS_ALLNONSTORAGEITEMS\
;---		or FOS_PATHMUSTEXIST
;---	mov rcx,rbx
;---	call iodlg.set_browsedir

;---	mov eax,[rdi]
;---	test eax,eax
;---	jz	.ret0

;---	mov rcx,rdi
;---	call art.is_file
;---	jz	.ret0

;---	mov rcx,rdi
;---	call art.get_fname

;---	;--- RET EAX 0,numchars
;---	;--- RET ECX total len
;---	;--- RET EDX pname "file.asm"
;---	;--- RET R8 string

;---	test eax,eax	;--- err get_fname
;---	jz	.ret0

;---	cmp eax,ecx
;---	jz	.ret0		;--- nopath

;---	mov r9,rdx
;---	mov rcx,[rbx+HU.hEdi]
;---	call win.set_text

;---	jmp	.ret0

;---.id_ok:
;---.id_cancel:	
;---	mov rcx,[.hwnd]
;---	call iodlg.store_pos

;---	mov rdx,[pIo]
;---	add rdx,IO_DEVTOOL
;---	mov rcx,[pHu]
;---	call iodlg.store_lastdir

;---	mov rdx,[.wparam]
;---	mov rcx,[.hwnd]
;---	call apiw.enddlg
;---	jmp	.ret1

;---.discard:
;---	xor ecx,ecx
;---	xor eax,eax
;---	xchg rcx,[pTopDevT]
;---	mov [pTopDevT.dsize],eax
;---	mov [pTopDevT.items],eax
;---	test ecx,ecx
;---	jnz	.discardA
;---	ret 0

	;ü------------------------------------------ö
	;|     .DISCARD    DEVTOOL                  |
	;#------------------------------------------ä

.items:
	;--- in RCX devt
	;--- ret RAX size
	;--- ret RCX numitems
	push rbx
	push r12
	push r13
	mov rbx,rcx

	xor r12,r12
	xor r13,r13
	xor eax,eax
	mov rcx,[.devt.pGrp]
	push 0

.itemsA:
	test rcx,rcx
	jz .itemsB
	push rcx
	inc r13
	mov eax,[rcx+\
		DEVTITEM.oparam]
	shl eax,1
	add eax,16
	@nearest 16,eax
	add r12,rax
	mov rcx,[rcx+\
		DEVTITEM.next]
	jmp .itemsA

.itemsB:
	pop rcx
	test rcx,rcx
	jz	.itemsE
	mov rdx,[rcx+\
		DEVTITEM.item]

.itemsB1:
	test rdx,rdx
	jz	.itemsB
	inc r13
	mov eax,[rdx+\
		DEVTITEM.oparam]
	shl eax,1
	mov r8,[rdx+\
		DEVTITEM.dir]
	movzx ecx,[r8+\
		DIR.cpts]
	@nearest 8,ecx
	add eax,ecx
	shl eax,1
	add eax,16
	@nearest 16,eax
	add r12,rax
	mov rdx,[rdx+\
		DEVTITEM.next]
	jmp .itemsB1
	
.itemsE:
	mov rcx,r13
	mov rax,r12
	pop r13
	pop r12
	pop rbx
	ret 0


	;ü------------------------------------------ö
	;|     .WRITE      DEVTOOL                  |
	;#------------------------------------------ä

.write:
	push rbp
	push rbx
	push rsi
	push rdi
	push r12
	push r13
	mov rbp,rsp
	and rsp,-16

	mov rcx,[pDevT]
	mov rbx,rcx
	call .items
	mov r12,rcx		;--- save numitems

	add rax,1024	;--- common stub
	add rax,\
		FILE_BUFLEN	;--- space for formatting path+file etc
	shl rcx,5			;--- _"(.:0123456789ABCDEFh
	add rax,rcx
	@nearest 16,rax
	@frame rax

	lea rdi,[rax+\
		FILE_BUFLEN]

	mov rdx,rax
	call art.zeromem

	
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

	mov rdx,[.devt.pGrp]
	test r12,r12
	jnz	.writeA4
	
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
	jmp	.writeF

.writeA:
	mov r13,rdx
	mov r12,[r13+\
		DEVTITEM.item]
	mov eax,'	.:"'
	stosd

	lea rcx,\
		[r13+sizeof.DEVTITEM]
	mov rdx,rdi
	call utf16.to8
	add rdi,rax

	mov ax,'"('
	stosw
	@do_eol
	jmp	.writeA2

.writeA1:
;---@break
	;--- write item ------
	mov al,09h
	stosb
	mov eax,'	.:"'
	stosd

	mov r8,[r12+\
		DEVTITEM.dir]
	lea rcx,\
		[r8+DIR.dir]
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov al,"\"
	stosb
	lea rcx,\
		[r12+sizeof.DEVTITEM]
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov ax,'",'
	stosw
	mov al,'0'
	stosb

	;--- write flags -------
	mov rdx,rsp
	mov rsi,rsp
	mov ecx,[r12+\
		DEVTITEM.flags]
	call art.qword2a
	add rsi,rdx ;--- 000012345 delta to valid is 4
	mov ecx,eax
	rep movsb
	mov ax,"h,"
	stosw
	mov al,'"'
	stosb

	;--- write param -------
	mov ecx,[r12+DEVTITEM.oparam]
	add rcx,r12
	add rcx,\
		sizeof.DEVTITEM
	mov rdx,rdi
	call utf16.to8
	add rdi,rax
	mov al,'"'
	stosb
	@do_eol
	mov r12,[r12+\
		DEVTITEM.next]

.writeA2:
	test r12,r12
	jnz	.writeA1

.writeA3:
	mov al,09h
	stosb
	mov al,")"
	stosb
	@do_eol

	mov rdx,[r13+\
		DEVTITEM.next]

.writeA4:
	test edx,edx
	jnz	.writeA
	

.writeF:
	@do_eol
	mov rax,rsp
	xor edx,edx

	;--- compound [config\devtool.utf8]
	push rdx
	push uzUtf8Ext
	push uzDevTName
	push uzSlash
	push uzConfName
	push rax
	push rdx
	call art.catstrw

	mov rcx,rsp
	call art.fcreate_rw
	inc eax
	jz .writeE
	dec eax
	mov rbx,rax				;--- file handle

	mov r8,rdi
	lea rdx,[rsp+\
		FILE_BUFLEN]
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

