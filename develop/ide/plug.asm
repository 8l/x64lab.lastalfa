  
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

plug:
	virtual at rbx
		.per PLUGGER
	end virtual

.get_slot:
	;--- in RCX per struct
	;--- ret RAX 0,slot
	mov r9,rbx
	mov r8,rdi
	mov rbx,rcx
	xor eax,eax
	lea rdi,[.per.peds]
	mov ecx,MAX_PLUG
	repne scasq
	jnz	.get_slotE
	lea rax,[rdi-8]
	
.get_slotE:	
	xchg r9,rbx
	xchg r8,rdi
	ret 0

.proc:
@wpro rbp,\
		rbx rsi rdi

	cmp edx,\
		WM_INITDIALOG
	jz	.wm_initdialog
	cmp edx,WM_SIZE;\
		;WM_WINDOWPOSCHANGED
	jz	.wm_poschged
	cmp edx,WM_NOTIFY
	jz	.wm_message
	cmp edx,WM_COMMAND
	jz	.wm_message
	cmp edx,WM_DESTROY
	jz	.wm_message
	jmp	.ret0

.get_data:
	;--- RET RAX = RBX 0,data
	call apiw.get_wldata
	mov rbx,rax
	test rax,rax
	ret 0

.wm_message:
	call .get_data
	jz	.ret0
	mov eax,[.per.id]
	cmp eax,PER_MPURP
	jnz	.ret0

	mov r9,[.lparam]
	mov r8,[.wparam]
	mov rdx,[.msg]
	mov rcx,rbx
	call [.per.f_message]
	jmp	.exit


.wm_poschged:
	;--- first get per -----
	call .get_data
	test eax,eax
	jz	.ret0

	sub rsp,\
		sizeof.RECT
	mov rdx,rsp
	mov rcx,[.hwnd]
	call apiw.get_clirect
	
	mov rdx,rsp
	mov rcx,rbx
	call [.per.f_resize]
	jmp	.ret1


.wm_initdialog:
;@break
	mov rbx,r9
	mov rsi,rcx
	mov [.per.hDlg],rcx
	mov rdi,\
		apiw.get_dlgitem

	mov r8,rbx
	mov rcx,rsi
	call apiw.set_wldata

	mov eax,[.per.id]
	cmp eax,PER_MPURP
	jnz	.ret1

	mov rcx,rbx			
	call mpurp.custom

.ret1:				;message processed
	xor rax,rax
	inc rax
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.exit:
	@wepi
