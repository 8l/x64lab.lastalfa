  
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

float:
.create:
	;--- in RCX hParent
	push rbp
	mov rbp,rsp
	and rsp,-16
	sub rsp,\
		FILE_BUFLEN

	mov r8,[hInst]
	xor eax,eax
	mov rdx,rsp
	
	mov [rdx+58h],rax
	mov [rdx+50h],r8
	mov [rdx+48h],rax
	mov [rdx+40h],rcx

	mov qword[rdx+38h],96
	mov qword[rdx+30h],96
	mov [rdx+28h],rax
	mov [rdx+20h],rax
	mov r9,\
		WS_POPUPWINDOW;	WS_CHILD 
	xor r8,r8
	mov rdx,uzStcClass
	mov rcx,\
		WS_EX_LAYERED ;or WS_EX_TOPMOST
	call [CreateWindowExW]
	test rax,rax
	jz .createE
	push rax

	mov r9,LWA_ALPHA
	mov r8,128
	xor edx,edx
	mov rcx,rax
	call apiw.set_lwattr
	pop rax

.createE:
	mov rsp,rbp
	pop rbp
	ret 0

.draw:
	;--- in RCX hIcon
	;--- in RDX text
	push rbp
	push rbx
	push rdi
	push rsi
	push r12

	mov rbp,rsp
	and rsp,-16

	sub rsp,\
		sizeof.RECT
	mov r12,rsp

	mov rbx,rcx
	mov rdi,rdx

	mov rcx,[hFloat]
	call apiw.get_dc
	mov rsi,rax

	mov rdx,TRANSPARENT
	mov rcx,rax
	call apiw.set_bkmode

	push DI_NORMAL
	push 0
	push 0
	push 32
	push 32
	mov r9,rbx
	mov r8,16
	mov edx,32
	mov rcx,rsi
	sub rsp,20h
	call [DrawIconEx]
	
	mov [r12+RECT.left],4
	mov [r12+RECT.top],32+16+4
	mov [r12+RECT.right],96-4
	mov [r12+RECT.bottom],96-4

	mov r10,\
		DT_END_ELLIPSIS or \
		DT_NOCLIP
	mov r9,r12
	or r8,-1
	mov rdx,rdi
	mov rcx,rsi
	call apiw.drawtext

	mov rdx,rsi
	mov rcx,[hFloat]
	call apiw.rel_dc
	
	mov rsp,rbp
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0
