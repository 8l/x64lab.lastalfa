  
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

	;#---------------------------------------------------ö
	;|                   MPURP  custom create            |
	;ö---------------------------------------------------ü

.custom:
	;--- in RCX per
	;--- RET RAX per
	push rbp
	push rbx
	push rdi
	push rsi
	mov rbp,rsp

	mov rbx,rcx
	mov rdi,\
		[.mp.hDlg]
	
	;--- build the struc for peralfa
	mov [.mp.f_resize],\
		.repos
	mov [.mp.f_message],\
		.message

	mov edx,\
		PER_MPURP_CBX
	mov rcx,rdi
	call apiw.get_dlgitem
	mov [.mp.hCbx],rax

	sub rsp,\
		sizeof.RECT
	mov rdx,rsp
	mov rcx,rax
	call apiw.get_winrect

	mov eax,[rsp+RECT.bottom]
	sub eax,[rsp+RECT.top]
	mov [.mp.cyper],al

	add rsp,\
		sizeof.RECT

	mov edx,\
		PER_MPURP_PRG
	mov rcx,rdi
	call apiw.get_dlgitem
	mov [.mp.hPrg],rax

	;--- setup MPURP gui ----------
	mov r9,[hBmpIml]
	mov r8,LVSIL_SMALL
	mov rcx,[.mp.hCbx]
	call cbex.set_iml

	sub rsp,\
		FILE_BUFLEN
	mov rdi,rsp
	mov rsi,[.mp.hCbx]
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

	push 0
	push UZ_TEMPLATE
	push 11
	mov ecx,MP_DEVT

.customA:
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
	mov r8,r11
	mov rcx,rsi
	call cbex.ins_item

	pop rcx
	test rcx,rcx
	jnz .customA

	xor r8,r8
	mov rcx,rsi
	call cbex.sel_item

	;--- attach Devtool plugin -------
	xor esi,esi
	mov rcx,rbx
	call plug.get_slot
	test eax,eax
	jz .customE

	mov rsi,rax
	mov r10,[pDevT]
	mov [rsi],r10
	mov r9,devtool.proc
	mov r8,[.mp.hDlg]
	mov rdx,DEVT_DLG
	mov rcx,[hInst]
	call apiw.cdlgp

	mov rdx,SW_SHOW
	mov rcx,rax
	call apiw.show

	xor esi,esi
	mov rcx,rbx
	call plug.get_slot
	test eax,eax
	jz .customE

	;--- attach Template -------
	mov rsi,rax
	mov r10,[pTmpl]
	mov [rsi],r10
	mov r9,tmpl.proc
	mov r8,[.mp.hDlg]
	mov rdx,TMPL_DLG
	mov rcx,[hInst]
	call apiw.cdlgp

.customE:
	mov rsp,rbp
	mov rax,rbx
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0	

	;#---------------------------------------------------ö
	;|                   MPURP message                   |
	;ö---------------------------------------------------ü
.message:
	;--- in RCX = RBX per/mp
	;--- in RDX msg
	;--- in R8 wparam
	;--- in R9 lparam
	;--- in RAX per.id
	;--- allowed use RBX,RDI,RSI
	push rbp
	mov rbp,rsp

	cmp edx,\
		WM_COMMAND
	jz	.wm_command
	jmp	.ret0

.wm_command:
	cmp r9,[.mp.hCbx]
	jz	.cat_command
	jmp	.ret0

	;#------------------------------------ö
	;|      .cat_command                  |
	;ö------------------------------------ü
.cat_command:
	shr r8,16
	cmp r8w,\
		CBN_SELCHANGE
	jnz	.ret0

	mov rcx,r9
	call cbex.get_cursel
	inc eax
	jz	.ret0
	dec eax
	and eax,MAX_PLUG-1
	cmp al,[.mp.selped]
	jz	.ret0

;@break
	push rax
	push rax

	mov rdx,SW_HIDE
	mov al,[.mp.selped]
	mov r9,[rax*8+.mp.peds]
	mov rcx,[r9+PLUGGED.hwnd]
	call apiw.show

	pop rax
	mov [.mp.selped],al
	xor r9,r9
	xor r8,r8
	mov edx,WM_SIZE
	mov rcx,[.mp.hDlg]
	call apiw.sms

	pop rax
	mov rdx,SW_SHOWDEFAULT
	mov r9,[rax*8+.mp.peds]
	mov rcx,[r9+PLUGGED.hwnd]
	call apiw.show
	jmp	.ret1

;---	dec eax
;---	dec eax
;---	jns	.cat_commandA

;---	mov [.mp.idCat],ax
;---	mov [.mp.iFilt],ax

;---	mov rcx,[.mp.hCbxFilt]
;---	call cbex.reset

;---	mov rcx,[.mp.hLview]
;---	call lvw.del_all
;---	jmp	.ret1

.ret1:				;message processed
	xor rax,rax
	inc rax
	jmp	.retE

.ret0:
	xor rax,rax

.retE:
	mov rsp,rbp
	pop rbp
	ret 0



	;#---------------------------------------------------ö
	;|                   MPURP repos                     |
	;ö---------------------------------------------------ü

.repos:
	;--- in RCX per
	;--- in RDX rect
	;--- get selped
	push rbx
	push rdi
	push rsi
	push r12

	mov rbx,rcx
	mov rdi,rdx

	;--- plugger MPURP has a Progressbar and CBX
	;--- Cbx is 1/3 ,prg is 2/3
	movzx r12d,\
		[.mp.cyper]

	mov rax,\
		SWP_NOZORDER
	mov r11,r12
	shr r11,1
	push r11

	mov r10d,[rdi+RECT.right]
	sub r10d,[rdi+RECT.left]
	sub r10d,CX_GAP*2
	mov r9d,[rdi+RECT.top]
	add r9d,CY_GAP
	mov r8d,[rdi+RECT.left]
	add r8d,CX_GAP
	mov rdx,HWND_TOP
	mov rcx,[.mp.hPrg]
	call apiw.set_wpos	

	pop r9
	add r9,CY_GAP*2

	;--- set position CBX --------
	mov rax,\
		SWP_NOZORDER
	mov r11,r12
	push r9
	mov r10d,[rdi+RECT.right]
	sub r10d,[rdi+RECT.left]
	sub r10d,CX_GAP*2
	mov r8d,[rdi+RECT.left]
	add r8d,CX_GAP

	mov rdx,HWND_TOP
	mov rcx,[.mp.hCbx]
	call apiw.set_wpos

	;--------------------------

	movzx eax,[.mp.selped]
	and eax,(MAX_PLUG-1)
	mov rsi,\
		[rax*8+.mp.peds]

	mov rax,SWP_NOZORDER
	pop r9
	add r9,CY_GAP*2
	add r9,r12

	mov r11d,[rdi+RECT.bottom]
	sub r11d,[rdi+RECT.top]
	sub r11,r9
	mov r10d,[rdi+RECT.right]
	sub r10d,[rdi+RECT.left]
	sub r10d,CX_GAP*2
	mov r8d,[rdi+RECT.left]
	add r8d,CX_GAP

	mov rdx,HWND_TOP
	mov rcx,[rsi+\
		PLUGGED.hwnd]
	call apiw.set_wpos

	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0

