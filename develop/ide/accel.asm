  
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

accel:
	virtual at rsi
		.lvc LVCOLUMNW
	end virtual

	virtual at rsi
		.lvi LVITEMW
	end virtual

	virtual at rbx
		.kdlg KEYDLG
	end virtual

	;ü-----------------------------------------ö
	;|     .setup                              |
	;#-----------------------------------------ä

.setup:
	;--- ret RAX 0,hAccel
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14

	mov rbp,rsp
	and rsp,-16

	mov r13,[pKeya]
	mov rcx,\
		(MI_OTHER-MNU_X64LAB) *\
		sizeof.KEYA
	mov rdx,r13
	call art.zeromem

	xor edx,edx
	sub rsp,\
		FILE_BUFLEN

	xor r12,r12
	mov rax,rsp

	;--- check for config\accels.utf8
	push rdx
	push uzUtf8Ext
	push uzAccelName
	push uzSlash
	push uzConfName
	push rax
	push rdx
	call art.catstrw

	mov rcx,rsp
	call [top64.parse]

	test rax,rax
	jz	.setupE
	mov rbx,rax

	dec edx			;--- no/1 items
	jle	.setupF
	mov r12,rdx
	inc edx
	shl edx,3
	sub rsp,rdx
	mov rdi,rsp

	mov rsi,rax
	mov r14,rsp	;--- stack start of table

	cmp [rbx+\
		TITEM.type],TLABEL
	jnz	.setupF
	
.setupA:
	mov rdx,1FFF'00FF'001Fh
	;---    -ID-  KEY  FLAG

	mov esi,[rsi+\
		TITEM.attrib]
	add rsi,rbx
	cmp rbx,rsi
	jz	.setupG

	cmp [rsi+\
		TITEM.type],TNUMBER
	jnz	.setupA
	mov rax,qword[rsi+\
		TITEM.qword_val]

	;--- check if > MI_OTHER or MI_USER
	and rax,rdx
	mov r8,rax
	stosw
	shr rax,16
	movzx ecx,ax
	stosd

	shr rax,16
	cmp ax,MI_OTHER
	jae .setupA

	sub ax,MNU_X64LAB
	shl eax,5			;--- x 32 sizeof.KEYA
	add rax,r13

	mov [rax+\
		KEYA.fVirt],r8l
	mov [rax+\
		KEYA.key],cx
	call .frm_key2txt
	jmp	.setupA

.setupG:
	mov rdx,r12
	mov rcx,r14
	call apiw.create_acct
	mov r12,rax

.setupF:
	mov rcx,rbx
	call [top64.free]
	
.setupE:
	mov rax,r12
	mov rsp,rbp
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;ü-----------------------------------------ö
	;|     .WRITE                              |
	;#-----------------------------------------ä
.write:
	;--- write to [config\accels.utf8]
	;--- in RCX pointer to keya
	push rbp
	push rbx
	push rdi
	push rsi
	push r12

	mov rbp,rsp
	and rsp,-16
	mov rbx,rcx

	@frame FILE_BUFLEN+\
		(32*256)+\	;--- each line max 32 byte
		1024				;--- header etc

	lea rdi,[rax+\
		FILE_BUFLEN]
	
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


	mov al,09
	stosb
	mov eax,".:"
	stosw

	xor r12,r12
	mov rsi,rsp

.writeA1:
	mov edx,[rbx]
	test edx,edx
	jz	.writeA

	mov al,"\"
	stosb
	@do_eol
	mov ax,0909h
	stosw
	mov al,"0"
	stosb
	;--- 

	movzx ecx,r12l
	add ecx,MNU_X64LAB
	shl rcx,32
	or rcx,rdx
	mov rdx,rsi
	;--- IN RCX number
	;--- IN RDX outbuffer MIN 24 bytes
	call art.qword2a

	;--- RET RAX valid chars
	;--- RET RCX outbuffer
	;--- RET RDX delta to valid bytes 

	mov rcx,rax
	add rsi,rdx
	rep movsb
	mov rsi,rsp
	
	mov ax,"h,"
	stosw

.writeA:
	add rbx,\
		sizeof.KEYA
	inc r12l
	jnz	.writeA1

	mov rdx,rdi
	dec rdi
	cmp ah,","
	cmovnz rdi,rdx

	@do_eol
	@do_eol

	;--- format [config\accel.utf8]
	mov rax,rsp
	push 0
	push uzUtf8Ext
	push uzAccelName
	push uzSlash
	push uzConfName
	push rax
	push 0
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
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0



	;ü-----------------------------------------ö
	;|     .proc                               |
	;#-----------------------------------------ä

.proc:
@wpro rbp,\
		rbx rsi rdi

	cmp edx,WM_INITDIALOG
	jz	.wm_initd
	cmp edx,WM_COMMAND
	jz	.wm_command
	cmp edx,WM_NOTIFY
	jz	.wm_notify
	jmp	.ret0

.wm_notify:
	mov rbx,[pKdlg]
	mov rdx,[r9+\
		NMHDR.hwndFrom]
	cmp rdx,[.kdlg.hLvw]
	jz	.lvw_notify
	jmp	.ret0

.lvw_notify:
	mov edx,[r9+\
		NMHDR.code]
	cmp edx,\
		LVN_ITEMCHANGING
	jz	.lvw_schged
	jmp .ret0

.lvw_schged:
	mov rcx,[r9+\
		NM_LISTVIEW.lParam]
	test rcx,rcx
	jz	.ret0

	xor eax,eax
	mov [.kdlg.last],rax
	test [r9+\
		NM_LISTVIEW.uNewState],\
		LVIS_FOCUSED \
		or LVIS_SELECTED ;or LVIS_FOCUSED
	jz	.lvw_schgedE;.ret0

	;--- in RCX OMNI struct
	mov rsi,rcx
	movzx eax,[rcx+OMNI.id]
	mov rdi,[pKeya]
	sub ax,MNU_X64LAB
	jl	.ret0
	shl eax,5			;--- x 32 sizeof.KEYA
	xor r9,r9
	xor r8,r8
	add rdi,rax
	cmp r9d,[rdi]
	jz	.lvw_schgedA
	movzx r8,[rdi+KEYA.key]

.lvw_schgedA:
	mov edx,HKM_SETHOTKEY
	mov rcx,[.kdlg.hHot]
	call apiw.sms

	movzx ecx,[rdi+KEYA.fVirt]
	call .set_chks

	mov [.kdlg.last],rsi		;--- set OMNI
	movzx eax,[rsi+OMNI.id]

.lvw_schgedE:
	call art.w2u
	push 0
	push 0
	mov rcx,[.kdlg.hStaId]
	mov [rsp],rax
	mov r9,rsp
	call win.set_text
	jmp	.ret0

	;ü-----------------------------------------ö
	;|     .wm_command                         |
	;#-----------------------------------------ä

.wm_command:
	mov rbx,[pKdlg]
	mov rax,r8
	and eax,0FFFFh
	cmp ax,IDOK
	jz	.id_rebuild
	cmp ax,IDCANCEL
	jz	.id_cancel
	cmp ax,KEY_BTN_SET
	jz	.btn_set
	jmp	.ret0

.btn_set:
	;--- avoid no item selected
	sub rsp,\
		sizea16.LVITEMW+\
		FILE_BUFLEN
	mov rsi,[.kdlg.last]	;--- RSI Omni
	test rsi,rsi
	jz	.ret0

	;--- get vkey input; 0 is free slot
	mov edx,HKM_GETHOTKEY
	mov rcx,[.kdlg.hHot]
	call apiw.sms
	mov rdi,rax			;--- RDI vKey
	test eax,eax
	jz	.btn_setA

	call .get_chks
	;--- RET RAX fVirt
	shl edi,16
	or edi,eax
	jmp	.btn_setB

.btn_setA:
	;--- free slot on nokey
	mov ecx,eax
	call .set_chks

.btn_setB:
	movzx eax,[rsi+\
		OMNI.id]
	mov rcx,[pKeya]
	sub ax,MNU_X64LAB
	jl	.ret0
	shl eax,5			;--- x 32 sizeof.KEYA
	add rax,rcx
	mov [rax],edi
	;--- in RAX slot keya
	call .frm_key2txt
	
	mov rcx,rsi
	lea rdx,[rsp+\
		sizea16.LVITEMW]
	;--- in RCX pOmni
	;--- in RDX buffer
	call .frm_rectxt

	mov r9,\
		LVNI_SELECTED
	or r8,-1
	mov rcx,[.kdlg.hLvw]
	call lvw.get_next
	inc rax
	jz	.ret0

	dec rax
	mov r9,rsp
	xor r10,r10
	mov rdi,rax

	lea rdx,[rsp+\
		sizea16.LVITEMW]
	mov [r9+\
		LVITEMW.mask],\
		LVIF_TEXT
	mov [r9+\
		LVITEMW.iSubItem],r10d
	mov [r9+\
		LVITEMW.pszText],rdx
	mov r8,rax
	mov rcx,[.kdlg.hLvw]
	call lvw.set_itext

	mov rcx,[.kdlg.hLvw]
	call apiw.set_focus

	mov r8,rdi
	mov rcx,[.kdlg.hLvw]
	call lvw.edit_lab

	mov rax,rsp
	mov rcx,[.kdlg.hLvw]
	mov [rax+\
		NM_LISTVIEW.hdr.hwndFrom],rcx
	mov [rax+\
		NM_LISTVIEW.hdr.code],\
		LVN_ITEMCHANGING
	mov [rax+\
		NM_LISTVIEW.uNewState],\
		LVIS_FOCUSED \
		or LVIS_SELECTED
	mov [rax+\
		NM_LISTVIEW.lParam],rsi
	mov r9,rax
	mov edx,WM_NOTIFY
	mov rcx,[.kdlg.hDlg]
	call apiw.sms
	jmp	.ret0

.id_cancel:
	;--- restore old current table ---
	mov rcx,\
		[.kdlg.oldKeya]
	mov r8,\
		(MI_OTHER-MNU_X64LAB) \
		* sizeof.KEYA
	mov rdx,[pKeya]
	call art.xmmcopy
	jmp	.id_ok

.id_rebuild:
	mov rcx,[pKeya]
	call .write
	;--- on error rewrite old table
	;---test eax,eax

	mov rcx,[hAccel]
	test rcx,rcx
	jz	.id_rebuildA
	call apiw.destroy_acct
	xor eax,eax
	mov [hAccel],rax

.id_rebuildA:
	call .setup
	mov [hAccel],rax

.id_ok:
	call .store_pos

	mov r9,0
	mov r8,LVSIL_SMALL
	mov rcx,[.kdlg.hLvw]
	call lvw.set_iml

	mov rcx,\
		[.kdlg.oldKeya]
	call art.a16free

	mov rcx,[.kdlg.hDlg]
	call apiw.enddlg
	jmp	.ret1

.wm_initd:
	sub rsp,\
		sizea16.LVITEMW+\ ;--- 80 > 64 = sizea16.LVCOLUMNW
		FILE_BUFLEN
	mov rsi,rsp
	mov rbx,[pKdlg]
	xor eax,eax
	mov [.kdlg.hDlg],rcx
	mov [.kdlg.last],rax
	mov [.kdlg.oldKeya],rax

	;--- create backup keya table
	mov ecx,\
		(MI_OTHER-MNU_X64LAB) \
		* sizeof.KEYA
	mov edi,ecx
	call art.a16malloc
	mov [.kdlg.oldKeya],rax

	mov rcx,[pKeya]
	mov rdx,rax
	mov r8,rdi
	call art.xmmcopy

	push 0
	push KEYDLG.hHot
	push 0
	push KEY_HOT
	push KEYDLG.hLvw
	push 0
	push KEY_LVW
	push KEYDLG.hChkCtrl
	push UZ_CTRL
	push KEY_CHK_CTRL
	push KEYDLG.hChkAlt
	push UZ_ALT
	push KEY_CHK_ALT
	push KEYDLG.hChkShift
	push UZ_SHIFT
	push KEY_CHK_SHIFT
	push KEYDLG.hChkNoInv
	push UZ_NOINV
	push KEY_CHK_NOINV
	push KEYDLG.hBtnSet
	push UZ_SET
	push KEY_BTN_SET

	push KEYDLG.hOk
	push UZ_REBUILD
	push IDOK

	push KEYDLG.hCanc
	push UZ_CANCEL
	push IDCANCEL

	push KEYDLG.hStaId
	push UZ_WZERO
	push KEY_STA_ID

	mov rdi,[.hwnd]
	mov rcx,MI_CONF_KEY
	jmp	.wm_initdA1
 
.wm_initdA:
	mov rcx,[.hwnd]
	call apiw.get_dlgitem
	pop rcx
	pop r8

	mov rdi,rax
	mov [rbx+r8],rax

.wm_initdA1:
	mov r8,rsi
	mov edx,U16
	call [lang.get_uz]

	mov r9,rsi
	mov rcx,rdi
	call win.set_text

	pop rdx
	test edx,edx
	jnz	.wm_initdA

.wm_initH:
	;--- hotkey set rules
	mov r9,0
	mov r8, \
		HKCOMB_A or \
		HKCOMB_C or \
		HKCOMB_CA or \
		HKCOMB_S or \
		HKCOMB_SA or \
		HKCOMB_SC or \
		HKCOMB_SCA
	mov edx,HKM_SETRULES
	mov rcx,[.kdlg.hHot]
	call apiw.sms

	mov r9,\
		LVS_EX_FULLROWSELECT \
		or LVS_EX_GRIDLINES \
		or LVS_EX_FLATSB \
		or 0;LVS_EX_AUTOSIZECOLUMNS
	xor r8,r8
	mov rcx,[.kdlg.hLvw]
	call lvw.set_xstyle

	mov r9,[hBmpIml]
	mov r8,LVSIL_SMALL
	mov rcx,[.kdlg.hLvw]
	call lvw.set_iml

	mov rsi,rsp
	lea rdi,[rsp+\
		sizea16.LVITEMW]

	mov [.lvc.cx],512
	mov [.lvc.mask],\
		LVCF_WIDTH

	xor r8,r8
	mov r9,rsi
	mov rcx,[.kdlg.hLvw]
	call lvw.ins_col

	mov rax,[.kdlg.rc]
	test rax,rax
	jnz	.wm_initdB
	mov rax,[.kdlg.rc+8]
	test rax,rax
	jnz	.wm_initdB
	call .store_pos

.wm_initdB:
	mov eax,SWP_NOZORDER
	mov r11d,[.kdlg.rc.bottom]
	sub r11d,[.kdlg.rc.top]
	mov r10d,[.kdlg.rc.right]
	sub r10d,[.kdlg.rc.left]
	mov r9d,[.kdlg.rc.top]
	mov r8d,[.kdlg.rc.left]
	mov rdx,HWND_TOP
	mov rcx,[.kdlg.hDlg]
	call apiw.set_wpos

.wm_initdC:
	;--- set listview ---
	;--- in RSI lvitem
	;--- in RDI buf512
	push r12
	push r13

.wm_initdC1:
	push 0
	push 0
	push MI_CONF_KEY
	push [hMP_CONF]

	push 0
	;push MI_SCI_UNCOMMB
	;push MI_SCI_COMMB
	push MI_SCI_UNCOMML
	push MI_SCI_COMML
	push [hMP_SCI]

	push 0
	push MI_DEVT_ADD
	push MI_DEVT_REM
	push MI_DEVT_ADDG
	push MI_DEVT_REMG
	push MI_DEVT_MAN
	push MI_DEVT_REL
	push [hMP_DEVT]

	push 0
	push MI_PA_BROWSE
	push [hMP_PATH]

	push 0
	push MI_ED_LNK
	push MI_ED_REMITEM
	push MI_ED_RELSCICLS
	push [hMP_EDIT]

	push 0
	push MI_FI_OPEN
	push MI_FI_IMP
	push MI_FI_NEWB
	push MI_FI_NEWF
	push MI_FI_SAVE
	push MI_FI_CLOSE
	push [hMP_FILE]

	push 0
	push MI_WS_LOAD
	push MI_WS_NEW
	push MI_WS_SAVE
	push MI_WS_EXIT
	mov r12,[hMP_WSPACE]
	
.wm_initdC2:
	pop rdx
	test rdx,rdx
	jnz .wm_initdC4

.wm_initdC3:
	pop r12
	test r12,r12
	jz	.wm_initdF
	pop rdx

.wm_initdC4:
	mov rcx,r12
	call .get_info

	xor edx,edx
	mov [rsi+\
		LVITEMW.iItem],edx
	mov [rsi+\
		LVITEMW.iSubItem],edx
	movzx ecx,\
		[rax+OMNI.iIcon]		;--- icon id
	mov [rsi+\
		LVITEMW.iImage],ecx
	mov [rsi+\
		LVITEMW.pszText],rdi
	mov [rsi+\
		LVITEMW.lParam],rax

	mov rdx,rdi
	mov rcx,rax
	call .frm_rectxt

	mov [rsi+\
		LVITEMW.mask],\
		LVIF_IMAGE \
		or LVIF_PARAM \
		or LVIF_TEXT
	mov r9,rsi
	xor r8,r8
	mov rcx,[.kdlg.hLvw]
	call lvw.ins_item
	jmp	.wm_initdC2

.wm_initdF:
	pop r13
	pop r12

.ret1:				;message processed
	xor rax,rax
	inc rax
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.exit:
	@wepi

	;ü-----------------------------------------ö
	;|     .FRM_RECORD :[1024]:(....):"text"   |
	;#-----------------------------------------ä

.frm_rectxt:
	;--- in RCX pOmni
	;--- in RDX buffer
	push rbx
	push rdi

	mov rbx,rcx
	mov rdi,rdx
	
	;--- : [1024] ------
	mov eax," "
	stosw
	mov al,":"
	stosw
	mov al," "
	stosw
	mov al,"["
	stosw

	movzx eax,[rbx+\
		OMNI.id]
	call art.w2u
	stosq
	
	mov eax,"]"
	stosw
	mov al," "
	stosw
	mov al,":"
	stosw
	mov al," "
	stosw
	mov al,"("
	stosw

	mov al,"."
	stosw
	stosw
	stosw
	stosw

	;--- (....) : --------
	movzx eax,[rbx+\
		OMNI.id]
	mov rdx,[pKeya]
	xor ecx,ecx
	sub ax,MNU_X64LAB
	shl eax,5			;--- x 32 sizeof.KEYA
	add rax,rdx
	cmp ecx,[rax]
	jz	@f
	sub rdi,8
	lea rcx,[rax+\
		KEYA.name]		;--- menu text
	mov rdx,rdi
	call utf16.copyz
	add rdi,rax

@@:
	mov eax,")"
	stosw
	mov al," "
	stosw
	mov al,":"
	stosw
	mov al," "
	stosw
	mov al,'"'
	stosw
	
	lea rcx,[rbx+sizeof.OMNI];4] ;--- menu text
	mov rdx,rdi
	call utf16.copyz
	add rdi,rax

	mov eax,'"'
	stosw
	xor eax,eax
	stosd
	
	pop rdi
	pop rbx
	ret 0

	;ü-----------------------------------------ö
	;|     .FRM_KEY2TXT                        |
	;#-----------------------------------------ä

.frm_key2txt:
	;--- in RAX slot keya
	push rdi

	lea rdi,[rax+\
		KEYA.name]
	mov r9,rdi

	movzx ecx,[rax+\
		KEYA.key]

	movzx edx,[rax+\
		KEYA.fVirt]

	xor eax,eax
	stosq
	stosq
	stosq
	stosd

	mov rdi,r9
	test dl,FCONTROL
	mov eax,24D2h	; small enclosed c
	jz	@f
	stosw
@@:	
	test dl,FALT
	mov eax,24D0h	; small enclosed a
	jz	@f
	stosw
@@:	
	test dl,FSHIFT
	mov eax,24E2h	; small enclosed s
	jz	@f
	stosw
@@:
	test cl,cl
	jz	@f
	mov dl,\
		MAPVK_VK_TO_VSC
	call apiw.map_vk
	shl rax,16
	mov rdx,rdi
	mov r8,(28-6)/2
	mov rcx,rax
	call apiw.get_keynt
@@:
	pop rdi
	ret

	;ü-----------------------------------------ö
	;|     .GET_CHKS                           |
	;#-----------------------------------------ä

.get_chks:
	;--- (uses RBX kdlg)
	;--- RET RAX fVirt
	; FVIRTKEY  = 01h
	; FNOINVERT = 02h
	; FSHIFT    = 04h
	; FCONTROL  = 08h
	; FALT      = 10h
	push rdi
	push 0
	push [.kdlg.hChkNoInv]
	push [.kdlg.hChkShift]
	push [.kdlg.hChkCtrl]
	push [.kdlg.hChkAlt]
	xor rdi,rdi
	jmp	.get_chksB

.get_chksA:
	xor r9,r9
	xor r8,r8
	mov edx,BM_GETCHECK
	call apiw.sms
	or edi,eax
	shl edi,1

.get_chksB:
	pop rcx
	test rcx,rcx
	jnz .get_chksA
	mov eax,edi
	or eax,1
	pop rdi
	ret 0

	;ü-----------------------------------------ö
	;|     .SET_CHKS                           |
	;#-----------------------------------------ä

.set_chks:
	;--- (uses RBX kdlg)
	;--- in CL fVirt
	shr cl,1
	xor eax,eax
	push 0
	push 0
	push [.kdlg.hChkAlt]
	push 0
	push [.kdlg.hChkCtrl]
	push 0
	push [.kdlg.hChkShift]
	push 0
	push [.kdlg.hChkNoInv]
;@break
	shr cl,1
	adc dword[rsp+8],eax
	shr cl,1
	adc dword[rsp+24],eax
	shr cl,1
	adc dword[rsp+40],eax
	shr cl,1
	adc dword[rsp+56],eax
	jmp	.set_chksB

	; FVIRTKEY  = 01h
	; FNOINVERT = 02h
	; FSHIFT    = 04h
	; FCONTROL  = 08h
	; FALT      = 10h

.set_chksA:
	pop r8
	xor r9,r9
	mov edx,BM_SETCHECK
	call apiw.sms

.set_chksB:
	pop rcx
	test ecx,ecx
	jnz	.set_chksA
	ret 0

	;ü-----------------------------------------ö
	;|     .GET_INFO (from menuitem)           |
	;#-----------------------------------------ä

.get_info:
	;--- in RCX hMenu
	;--- in RDX id menuitem
	;--- (uses RBX pKdlg)
	sub rsp,\
		sizeof.MENUITEMINFOW
	mov r9,rsp
	xor eax,eax
	mov [r9+\
		MENUITEMINFOW.fMask],\
		MIIM_DATA
	mov [r9+\
		MENUITEMINFOW.dwItemData],rax

	call apiw.mni_get_byid
	mov rax,[rsp+\
		MENUITEMINFOW.dwItemData]
	add rsp,\
		sizeof.MENUITEMINFOW
	ret 0

.store_pos:
	;--- (uses RBX pKdlg)
	sub rsp,\
		sizeof.RECT
	mov rdx,rsp
	mov rcx,[.kdlg.hDlg]
	call apiw.get_winrect

	lea rdx,[.kdlg.rc]
	mov rax,[rsp]
	mov [rdx],rax
	mov rax,[rsp+8]
	mov [rdx+8],rax
	add rsp,\
		sizeof.RECT
	ret 0

