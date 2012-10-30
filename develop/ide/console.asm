  
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

console:
	virtual at rbx
		.cons CONS
	end virtual

.proc:
@wpro rbp,\
		rbx rsi rdi

	cmp edx,\
		WM_INITDIALOG
	jz	.wm_initdialog
	cmp edx,\
		WM_WINDOWPOSCHANGED
	jz	.wm_poschged
	jmp	.ret0

.wm_poschged:
	mov rbx,[pCons]
	sub rsp,sizeof.RECT*3
	lea rdi,[rsp+\
		sizeof.RECT*2]
	mov rdx,rdi
	mov rcx,[.hwnd]
	call apiw.get_clirect

	mov rdx,rsp
	mov rcx,[.cons.hCbx]
	call apiw.get_winrect

	mov rax,SWP_NOZORDER
	mov r11d,[rsp+RECT.bottom]
	sub r11d,[rsp+RECT.top]
	mov r10d,[rdi+RECT.right]
	sub r10d,[rdi+RECT.left]
	mov r9d,[rdi+RECT.top]
	mov r8d,[rdi+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.cons.hCbx]
	call apiw.set_wpos

	mov eax,SWP_NOZORDER or \
		SWP_NOSENDCHANGING or \
		SWP_NOCOPYBITS

	mov r11d,[rdi+RECT.bottom]
	sub r11d,[rdi+RECT.top]
	sub r11d,CY_GAP*2
	mov ecx,[rsp+RECT.bottom]
	sub ecx,[rsp+RECT.top]
	sub r11d,ecx

	mov r10d,[rdi+RECT.right]
	sub r10d,[rdi+RECT.left]

	mov r9d,[rdi+RECT.top]
	add r9d,[rsp+RECT.bottom]
	sub r9d,[rsp+RECT.top]
	add r9d,CY_GAP

	mov r8d,[rdi+RECT.left]
	mov rdx,HWND_TOP
	mov rcx,[.cons.hSci]
	call apiw.set_wpos
	jmp	.ret1


.wm_initdialog:
	mov rbx,r9
	mov [.cons.hwnd],rcx
	mov rdi,apiw.get_dlgitem
	mov r8,rbx
	call apiw.set_wldata
	mov [.cons.id],CONS_DLG

	mov rdx,CONS_CBX
	mov rcx,[.hwnd]
	call rdi
	mov [.cons.hCbx],rax

	mov rdx,CONS_SCI
	mov rcx,[.hwnd]
	call rdi
	mov [.cons.hSci],rax

;@break
	mov rcx,rax
	call sci.set_defprop

	mov rcx,[.cons.hSci]
	call sci.def_flags

.ret1:				;message processed
	xor rax,rax
	inc rax
	jmp	.exit

.ret0:
	xor rax,rax
	jmp	.exit

.exit:
	@wepi
