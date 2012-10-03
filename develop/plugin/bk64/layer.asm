  
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


lay64:
	virtual at rbx
		.laym LAYS
	end virtual

	virtual at rbx
		.layc LAYS
	end virtual


	;/----------------------------------------------------------
	;|                  DOCKMAN.RESIZE
	;\----------------------------------------------------------
.resize:
	;--- in RCX hLayer
	;--- in RDX msg
	xor eax,eax
	cmp rdx,WM_WINDOWPOSCHANGED
	jz	.r_posched
	cmp rdx,WM_WINDOWPOSCHANGING
	jz	.r_posched
	cmp rdx,WM_SIZE
	jz	.r_posched
	ret 0

.r_posched:
	push rbp
	push rbx
	push rdi
	push rsi

	mov rbx,rcx
	lea rdx,[.laym.crc]
	mov rcx,[.laym.hMain]
	call apiw.get_clirect
	mov rbp,rbx			;--- in RBP main layer

	mov rax,[.laym.crc]
	mov [.laym.drc],rax
	mov rax,[.laym.crc+8]
	mov [.laym.drc+8],rax

	movzx rax,[.laym.ord]
	mov rbx,[.laym.pChild]
	test rax,rax
	jz	.resizeH
	test rbx,rbx
	jz	.resizeH

	mov ecx,eax
	call apiw.beg_defwpos
	mov rdi,rax			;--- in RDI pos structure

;@break
	call .resizeD

	mov rcx,rdi
	call apiw.end_defwpos

;@break
	mov rcx,[rbp+LAYS.paramA]
	test rcx,rcx
	jz 	.resizeH

	lea rdi,[rbp+LAYS.drc]
	mov eax,SWP_NOZORDER ;or\
		;SWP_NOSENDCHANGING
	mov r11d,[rdi+RECT.bottom]
	sub r11d,[rdi+RECT.top]
	mov r10d,[rdi+RECT.right]
	sub r10d,[rdi+RECT.left]
	mov r9d,[rdi+RECT.top]
	mov r8d,[rdi+RECT.left]
	mov rdx,HWND_TOP
	call apiw.set_wpos

.resizeH:
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0


.resizeD:
	;--- in RBX panel
	test [.layc.flags],\
		FLAYC_SPLIT
	jnz	.resizeD4

	lea rdx,[.layc.wrc]
	mov rcx,[.layc.hwnd]
	call apiw.get_winrect

	lea rdx,[.layc.crc]
	mov rcx,[.layc.hwnd]
	call apiw.get_clirect

	mov r9,2
	lea r8,[.layc.wrc]
	mov rdx,[.layc.hwnd]
	xor ecx,ecx
	call apiw.map_wpt
	
.resizeD4:
	mov rax,[.layc.crc]
	mov [.layc.grc],rax
	mov rax,[.layc.crc+8]
	mov [.layc.grc+8],rax

	mov al,[.layc.align]
	cmp al,ALIGN_LEFT
	jz	.resizeAL
	cmp al,ALIGN_TOP
	jz	.resizeAT
	cmp al,ALIGN_RIGHT
	jz	.resizeAR
	cmp al,ALIGN_BOTTOM
	jz	.resizeAB
	cmp al,ALIGN_CLIENT
	jnz	.resizeD1

.resizeAC:
	mov ecx,[rbp+LAYS.drc.left]
	mov edx,[rbp+LAYS.drc.top]
	mov r8d,[rbp+LAYS.drc.right]
	sub r8d,ecx
	mov r9d,[rbp+LAYS.drc.bottom]
	sub r9d,edx
	test r9,r9
	jbe	.resizeD1
	test r8,r8
	jbe	.resizeD1

;	xor rax,rax
;	mov [rbp+LAYS.drc],rax
;	mov [rbp+LAYS.drc+8],rax

	;--- calc control rect
	xor eax,eax
	mov [.layc.hrc.left],eax
	mov [.layc.hrc.top],eax
	mov [.layc.hrc.right],r8d
	mov [.layc.hrc.bottom],r9d

	;--- set grip rect
	mov [.layc.grc],rax
	mov [.layc.grc+8],rax
	jmp	.resizeD2

.resizeAL:
;@break
	mov ecx,[rbp+LAYS.drc.left]
	mov edx,[rbp+LAYS.drc.top]
	mov r9d,[rbp+LAYS.drc.bottom]
	sub r9d,edx
	mov r8d,[.layc.wrc.right]
	sub r8d,[.layc.wrc.left]
	test r8,r8
	jz	.resizeD1
	add [rbp+LAYS.drc.left],r8d

;	push rcx
;	push rdx
;	push r8
;	push r9

;	mov r8d,[rbp+LAYS.drc.right]
;	mov edx,[rbp+LAYS.drc.left]
;	call art.cout2XX
;	
;	pop r9
;	pop r8
;	pop rdx
;	pop rcx


	;--- set control rect ---------
	xor eax,eax
	mov [.layc.hrc.left],eax
	mov [.layc.hrc.top],eax
	mov [.layc.hrc.right],r8d
	mov [.layc.hrc.bottom],r9d
	sub [.layc.hrc.right],CX_GRIP

	;--- set grip rect
	mov eax,[.layc.grc.right]
	sub eax,CX_GRIP
	mov [.layc.grc.left],eax
	jmp	.resizeD2

.resizeAT:
	mov ecx,[rbp+LAYS.drc.left]
	mov edx,[rbp+LAYS.drc.top]
	mov r8d,[rbp+LAYS.drc.right]
	sub r8d,ecx
	mov r9d,[.layc.wrc.bottom]
	sub r9d,[.layc.wrc.top]
	test r9,r9
	jz	.resizeD1
	add [rbp+LAYS.drc.top],r9d

	;--- set control rect ---------
	xor eax,eax
	mov [.layc.hrc.left],eax
	mov [.layc.hrc.top],eax
	mov [.layc.hrc.right],r8d
	mov [.layc.hrc.bottom],r9d
	sub [.layc.hrc.bottom],CY_GRIP

	;--- set grip rect
	mov eax,[.layc.grc.bottom]
	sub eax,CY_GRIP
	mov [.layc.grc.top],eax
	jmp	.resizeD2

.resizeAR:
	mov edx,[rbp+LAYS.drc.top]
	mov r9d,[rbp+LAYS.drc.bottom]
	sub r9d,edx
	mov r8d,[.layc.wrc.right]
	sub r8d,[.layc.wrc.left]
	mov ecx,[rbp+LAYS.drc.right]
	sub ecx,r8d
	test r9,r9
	jz	.resizeD1
	mov [rbp+LAYS.drc.right],ecx

	;--- set control rect ---------
	xor eax,eax
	mov [.layc.hrc.left],CX_GRIP
	mov [.layc.hrc.top],eax
	mov [.layc.hrc.right],r8d
	mov [.layc.hrc.bottom],r9d
	sub [.layc.hrc.right],CX_GRIP

	;--- set grip rect
	xor eax,eax
	mov [.layc.grc.left],eax
	mov [.layc.grc.top],eax
	mov [.layc.grc.right],CX_GRIP
	mov [.layc.grc.bottom],r9d
	jmp	.resizeD2

.resizeAB:
	mov ecx,[rbp+LAYS.drc.left]
	mov r8d,[rbp+LAYS.drc.right]
	sub r8d,ecx
	mov r9d,[.layc.wrc.bottom]
	sub r9d,[.layc.wrc.top]
	mov edx,[rbp+LAYS.drc.bottom]
	sub edx,r9d
	test r8,r8
	jz	.resizeD1
	mov [rbp+LAYS.drc.bottom],edx

	;--- set control rect ---------
	xor eax,eax
	mov [.layc.hrc.left],eax
	mov [.layc.hrc.top],CX_GRIP
	mov [.layc.hrc.right],r8d
	mov [.layc.hrc.bottom],r9d
	sub [.layc.hrc.bottom],CX_GRIP

	;--- set grip rect
	xor eax,eax
	mov [.layc.grc.left],eax
	mov [.layc.grc.top],eax
	mov [.layc.grc.right],r8d
	mov [.layc.grc.bottom],CX_GRIP
	jmp	.resizeD2


.resizeD2:
	mov [.layc.drc.left],ecx
	mov [.layc.drc.top],edx
	mov [.layc.drc.right],r8d
	mov [.layc.drc.bottom],r9d

	push rbp
	mov rbp,rsp
	and rsp,-16
	sub rsp,40h
	
	mov rax,SWP_NOACTIVATE \
		or SWP_NOZORDER
	mov [rsp+38h],rax
	mov [rsp+30h],r9
	mov [rsp+28h],r8
	mov [rsp+20h],rdx

	mov r9,rcx
	mov r8,HWND_BOTTOM
	mov rdx,[.layc.hwnd]
	mov rcx,rdi
	call [DeferWindowPos]

	mov rsp,rbp
	pop rbp


;	test [.layc.type],HAS_CONTROL
;	jz .resizeD1

;.resizeD3:
;	mov r11,TRUE
;	mov r10d,[.layc.hrc.bottom]
;	mov r9d,[.layc.hrc.right]
;	mov r8d,[.layc.hrc.top]
;	mov edx,[.layc.hrc.left]
;	mov rcx,[.layc.hControl]
;	call apiw.movewin

.resizeD1:
	mov rbx,[.layc.pNext]
	test rbx,rbx
	jnz	.resizeD
	ret 0


	;/---------------------------------------------------------
	;|                  PROC
	;\---------------------------------------------------------

.proc:
	push rbp
	push rbx
	push rdi
	push rsi
	mov rbp,rsp
	sub rsp,20h

	.hwnd 	equ rbp-8
	.msg		equ rbp-16
	.wparam equ rbp-24
	.lparam equ rbp-32

	mov [.hwnd],rcx
	mov [.msg],rdx
	mov [.wparam],r8
	mov [.lparam],r9
	and rsp,-16

	cmp rdx,WM_WINDOWPOSCHANGED
	jz	.wm_winposched
	cmp rdx,WM_MOUSEMOVE
	jz	.wm_mmove
;	cmp rdx,WM_WINDOWPOSCHANGING
;	jz	.wm_winposched
;	cmp rdx,WM_PAINT
;	jz	.wm_paint
;	cmp rdx,WM_MOUSEACTIVATE
;	jz	.wm_mouseact
	cmp rdx,WM_LBUTTONUP
	jz	.wm_lbup
	cmp rdx,WM_LBUTTONDOWN
	jz	.wm_lbdw
	cmp rdx,WM_CREATE
	jz	.wm_create
	cmp rdx,WM_DESTROY
	jz	.wm_destroy
	jmp	.defwndproc

.get_structs:
	mov rcx,[.hwnd]
	xor ebx,ebx
	call apiw.get_wldata
	test rax,rax
	jz	.err_gs
	mov rbx,rax
.err_gs:
	ret 0

.set_mcurs:
	;--- ret RCX hCursor
	lea rdx,[g.hDefCurs]
	cmp [.layc.align],\
		ALIGN_CLIENT
	jz	.set_mcursA
	add rdx,8
	test [.layc.align],HGRIP
	jnz	.set_mcursA
	add rdx,8
	
.set_mcursA:
	mov rcx,[rdx]
	call apiw.set_curs
	ret 0

	;*----------------------------------------
	;|                  WM_LBUTTONUP
	;*----------------------------------------
.wm_lbup:
	call .get_structs
	jz	.ret0
	call apiw.rel_capt
	test [.layc.flags],\
		FLAYC_SPLIT
	jz	.ret0


	and [.layc.flags],\
		not FLAYC_SPLIT
	jmp	.ret0

	;*----------------------------------------
	;|                  WM_LBUTTONDOWN
	;*----------------------------------------
.wm_lbdw:
	call .get_structs
	jz	.ret0
	push 0
	mov rcx,rsp
	call apiw.get_curspos
	pop rdx
	mov rcx,[.hwnd]
	call apiw.ddetect
	test rax,rax
	jz	.ret0
	xor [.layc.flags],\
		FLAYC_SPLIT
	mov rcx,[.hwnd]
	call apiw.set_capt
	jmp	.ret0
	;*----------------------------------------
	;|                  WM_MOUSEMOVE
	;*----------------------------------------
.wm_mmove:
	call .get_structs
	jz	.ret0
	call .set_mcurs

;	push 0
;	mov rcx,rsp
;	call apiw.get_curspos
;	pop rdx
;	mov r8,rdx
;	and edx,0FFFFh
;	shr r8,32
;	call art.cout2XX

	test [.layc.flags],\
		FLAYC_SPLIT
	jz	.wm_mmoveA

;	push r12




;	push 0
;	mov rcx,rsp
;	call apiw.get_curspos

;	mov r9,1
;	mov r8,rsp
;	mov rdx,[.layc.hwnd]
;	xor ecx,ecx
;	call apiw.map_wpt
	
;	mov rdx,rsp
;	mov rcx,[.layc.hwnd]
;	call apiw.scr2cli

;	pop rcx
;	mov r8,rcx
;	mov rdx,rcx
;	and edx,0FFFFh
;	shr r8,32
;	call art.cout2XX

	mov rcx,[.lparam]
;	and ecx,ecx
;	js .ret0
;	test cx,cx
;	js .ret0

;	push rcx
;	mov r8d,[.layc.wrc.left]
;	mov edx,ecx
;	and edx,0FFFFh
;	call art.cout2XX
;	pop rcx
	
;	mov rcx,[.lparam];r12
;	and ecx,07FFF7FFFh
	call .calc_wrect
;	push r13
;	push r14
;	push r15


;	pop r15
;	pop r14
;	pop r13
;	pop r12
	jmp	.ret0

.wm_mmoveA:
	jmp	.ret0


.calc_wrect:
	;--- in RCX wpoint
	;--- in RBX layc

	push rbp
	cmp [.layc.align],\
		ALIGN_CLIENT
	jz	.calc_wrectE

	mov edx,ecx	;--- ECX wx
	xor eax,eax
	and ecx,0FFFFh
	shr edx,16	;--- EDX wy
	mov rbp,[.layc.pLaym]

	test [.layc.align],\
		VGRIP
	jnz	.calc_wrectV

.calc_wrectH:
	cmp [.layc.align],\
		ALIGN_TOP
	jz	.calc_wrectAT

.calc_wrectAB:
	test dx,dx
	jns	@f
	and edx,0FFFFh
	mov eax,edx
	mov esi,edx
	shl rax,32
	or rax,rcx
	not si

	push rax
	mov rcx,rsp
	call apiw.get_curspos

	mov rax,[rbp+LAYS.drc]
	ror rax,32
	add rax,CY_MIN
	rol rax,32
	push rax
	mov r9,1
	mov r8,rsp
	mov rdx,0
	mov rcx,[rbp+LAYS.hMain]
	call apiw.map_wpt	

	pop rdx
	pop r8
	shr rdx,32
	and edx,0FFFFh
	shr r8,32
	and r8d,0FFFFh
	cmp edx,r8d
	jae .calc_wrectE
	add [.layc.wrc.bottom],esi
	jmp	.calc_wrectR

@@:
	mov r9d,[.layc.wrc.bottom]
	sub r9d,CY_MIN
	cmp edx,r9d
	jae .calc_wrectE
	sub [.layc.wrc.bottom],edx
	jmp	.calc_wrectR

.calc_wrectAT:
	mov r9d,[rbp+LAYS.drc.bottom]
	sub r9d,CY_MIN
	cmp edx,CY_MIN
	jle .calc_wrectE
	cmp edx,r9d
	jae .calc_wrectE
	mov [.layc.wrc.bottom],edx
	mov [.layc.crc.bottom],edx
	jmp	.calc_wrectR

.calc_wrectV:
	cmp [.layc.align],\
		ALIGN_LEFT
	jz	.calc_wrectAL

.calc_wrectAR:
	test cx,cx
	jns	@f
	and ecx,0FFFFh
	mov eax,edx
	mov esi,ecx
	shl rax,32
	or rax,rcx
	not si

	push rax
	mov rcx,rsp
	call apiw.get_curspos

	mov rax,[rbp+LAYS.drc]
	add rax,CX_MIN
	push rax
	mov r9,1
	mov r8,rsp
	mov rdx,0
	mov rcx,[rbp+LAYS.hMain]
	call apiw.map_wpt	

	pop rcx
	pop r8
	and ecx,0FFFFh
	and r8d,0FFFFh
	cmp ecx,r8d
	jae .calc_wrectE
	add [.layc.wrc.right],esi
	jmp	.calc_wrectR
@@:
	mov r9d,[.layc.wrc.right]
	sub r9,CX_MIN
	cmp rcx,r9
	jae .calc_wrectE
	sub [.layc.wrc.right],ecx
	jmp	.calc_wrectR

.calc_wrectAL:
;	push rcx
;	push rdx
;	push r8
;	push r9

;	mov r8d,[.layc.drc.left]
;	mov edx,ecx
;	call art.cout2XX
;	
;	pop r9
;	pop r8
;	pop rdx
;	pop rcx

	mov r9d,[rbp+LAYS.drc.right]
	sub r9d,[.layc.drc.left]
	sub r9d,CX_MIN
	cmp ecx,CX_MIN
	jle .calc_wrectE
	cmp ecx,r9d
	jae .calc_wrectE
	mov [.layc.wrc.right],ecx
	mov [.layc.crc.right],ecx
	jmp	.calc_wrectR

;	mov r9d,[rbp+LAYS.drc.right]
;	sub r9d,CX_MIN
;	cmp ecx,CX_MIN
;	jle .calc_wrectE
;	cmp ecx,r9d
;	jae .calc_wrectE
;	mov [.layc.wrc.right],ecx
;	mov [.layc.crc.right],ecx
;	jmp	.calc_wrectR

.calc_wrectR:
	mov rcx,rbp
	call .r_posched

.calc_wrectE:
	pop rbp
	ret 0

	

.wm_mouseact:
.wm_winposched:
	call .get_structs
	jz	.ret0

;	mov rax,[.lparam]
;	mov r8d,[rax+WINDOWPOS.flags]
;	mov rdx,[.msg]
;	call art.cout2XX
;	mov rax,[.lparam]
;	mov r8d,[rax+WINDOWPOS.flags]
;	test r8d,SWP_NOSIZE
;	jnz	.ret0
	mov r8,FALSE;TRUE
	lea rdx,[.layc.grc]
	mov rcx,[.layc.hwnd]
	call apiw.invrect
	
	mov eax,SWP_NOZORDER ;or	SWP_NOSENDCHANGING or SWP_NOCOPYBITS
	mov r11d,[.layc.hrc.bottom]
	mov r10d,[.layc.hrc.right]
	mov r9d,[.layc.hrc.top]
	mov r8d,[.layc.hrc.left]
	mov rdx,HWND_TOP
	mov rcx,[.layc.hControl]
	call apiw.set_wpos
	jmp	.ret0


	;*----------------------------------------------------------
	;|                  WM_DESTROY (PANEL)
	;*----------------------------------------------------------

.wm_destroy:
	call .get_structs
	jz	.ret0
	mov rcx,[.layc.hControl]
	test rcx,rcx
	jz	.wm_destroyA
	call apiw.destroy

.wm_destroyA:
	mov rcx,rbx
	call art.a16free
	jmp	.ret0

	;*----------------------------------------------------------
	;|                  WM_CREATE (PANEL)
	;*----------------------------------------------------------
.wm_create:
	mov rbx,[r9]
	mov r8,[r9]
	call apiw.set_wldata

	xor eax,eax
	mov rcx,[.layc.paramB] ;--- sharing
	mov rsi,[.layc.pLaym] ;--- main layer
	mov rdi,.lo_share
	mov rdx,rsi

	mov [.layc.paramB],rax
;	mov [.layc.paramA],rax

	test [.layc.type],\
		SHARE_PANEL or \
		SHARE_FIRST
	jnz	.wm_createA
	mov rdi,.lo_set

.wm_createA:
	call rdi

	movzx eax,[rsi+LAYS.id]
	mov [.layc.id],al
	inc [rsi+LAYS.id]

	mov rdx,[.hwnd]
	mov [.layc.hwnd],rdx

	mov rcx,[.layc.hControl]
	test rcx,rcx
	jz	.ret0
	call apiw.set_parent
	jmp	.ret0

.ret0:
	xor rax,rax
	jmp	.exit

.ret1:
	xor rax,rax	
	inc eax
	jmp	.exit

.defwndproc:
	mov r9,[.lparam]
	mov r8,[.wparam]
	mov rdx,[.msg]
	mov rcx,[.hwnd]
	sub rsp,20h
	call [DefWindowProcW]

.exit:
	mov rsp,rbp	
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0


	;/----------------------------------------------------------
	;|                  INIT
	;\----------------------------------------------------------

.init:
	push rbx
	push rdi
	push rsi
	;--- in RCX hwnd
	;--- in RDX hInstance
	;--- in R8 FLAGS 
	push r8
	mov rdi,rcx
	xor ebx,ebx
	mov rsi,rdx
	mov ecx,sizeof.LAYS
	call art.a16malloc
	pop r8
	test rax,rax
	jz	.exit_init

	mov rbx,rax
	;and r8,FLAYM_MDI
	mov [.laym.hInst],rsi
	mov [.laym.hMain],rdi
	mov [.laym.paramA],r8 ;--- eventual MDICLIENT

	sub rsp,\
		sizeof.WNDCLASSEXW
	mov rdi,rsp
	
	virtual at rdi
		.wcx WNDCLASSEXW
	end virtual

	xor eax,eax
	mov rdx,rdi
	mov ecx,sizeof.WNDCLASSEXW /8	;80
	rep stosq
	mov rdi,rdx

;	mov [.wcx.cbWndExtra],8
	mov [.wcx.cbSize],\
		sizeof.WNDCLASSEXW
	mov [.wcx.hInstance],rsi
	mov [.wcx.lpfnWndProc],\
		.proc
	mov [.wcx.lpszClassName],\
		uzPanelClass

;	mov rax,[g.hBrush]
;	mov [.wcx.hbrBackground],rax
	mov [.wcx.hbrBackground],\
		COLOR_BTNFACE+1

	mov rcx,rdi
	call apiw.regcls

	add rsp,\
		sizeof.WNDCLASSEXW

	test rax,rax
	jnz .exit_init

.err_initA:
	mov rcx,rbx
	call art.a16free
	xor ebx,ebx

.exit_init:
	xchg rax,rbx
	pop rsi
	pop rdi
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|                      RELEASE                      |
	;ö---------------------------------------------------ü
.release:
	;--- in RCX hLayer
	jmp	art.a16free

	;/----------------------------------------------------------
	;|                  PANEL
	;\----------------------------------------------------------

.panel:
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15

	;--- in RCX hLayer
	;--- in RDX flags DH/DL
	;--- in R8 sharing
	;--- in R9 rect
	;--- in R10 eventual control

	mov rbp,rcx ;--- hLayer
	xor ebx,ebx
	mov r12,rdx	;--- flags DH,DL
	mov r13,r8	;--- pSharing
	mov r14,r9	;--- rect
	mov r15,r10	;--- hControl
	
	;--- RET RAX LAYS
	;--- RET RDX hwnd
	xor eax,eax
	mov rcx,\
		sizeof.LAYS
	call art.a16malloc
	test rax,rax
	jz	.err_panelA
	mov rbx,rax

	mov [.layc.paramB],r13
	mov [.layc.pLaym],rbp

	test r15,r15
	jz	.panelB

	mov rcx,r15
	call apiw.is_win
	test rax,rax
	jz	.panelB

	mov [.layc.hControl],r15
	or [.layc.type],HAS_CONTROL

.panelB:
	mov rax,r12
	and al,\
		ALIGN_CLIENT or \
		ALIGN_LEFT or \
		ALIGN_TOP or \
		ALIGN_BOTTOM or \
		ALIGN_RIGHT

	and ah,\
		SHARE_PANEL or \
		SHARE_FIRST
	or [.layc.type],ah

	test al,al
	jnz	.panelD
	mov al,ALIGN_LEFT

.panelD:
	mov [.layc.align],al
	mov rdx,r14

	push rbx
	push [rbp+LAYS.hInst]
	push 0
	push [rbp+LAYS.hMain]

	mov r8,100
	mov r9,100
	test rdx,rdx
	jz	.panelE

	mov r8,rdx
	xor r9,r9
	xor edx,edx
	test al,VGRIP
	jnz	.panelE
	xchg r8,r9

.panelE:
	push r9
	push r8
	push rdx
	push rdx

	push CHILD_STYLE
	push rdx
	push uzPanelClass
	push rdx
	call apiw.cwinex
	mov rdx,rax
	test rax,rax
	jnz	.exit_panel
	
.err_panelB:
	;--- cannot create panel
	mov rcx,rbx
	call art.a16free
	xor edx,edx
	xor rbx,rbx

.err_panelA:
	;--- no memory

.exit_panel:
	xchg rax,rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret 0


;	call .get_structs
;	jz	.ret0
;	mov rcx,[.layc.hwnd]
;	call apiw.get_dc
;	mov rdi,rax

;	mov r8,[g.hBrush]
;	lea rdx,[.layc.grc]
;	mov rcx,rdi
;	call apiw.fillrect	

;	mov rdx,rdi
;	mov rcx,[.layc.hwnd]
;	call apiw.rel_dc
;	jmp	.ret1

	;*----------------------------------------------------------
	;|                  WM_PAINT (PANEL)
	;*----------------------------------------------------------
;.wm_paint:
;	call .get_structs
;	jz	.ret0

;	sub rsp,sizeof.PAINTSTRUCT
;	mov rsi,rsp

;	push r12				;--- in R12 hdc
;	push r13
;	push r14
;	push r15

;	mov rdx,rsi
;	mov rcx,[.hwnd]
;	call apiw.beg_paint
;	mov r12,rax

;	mov rcx,rax
;	call apiw.create_compdc
;	mov r13,rax;[.hCompDC],rax

;	mov r8d,[.layc.crc.bottom]
;	mov edx,[.layc.crc.right]
;	mov rcx,r12
;	call apiw.create_compbmp
;	mov r14,rax;[.hCompBmp],rax

;	mov rdx,rax;[.hCompBmp]
;	mov rcx,r13;[.hCompDC]
;	call apiw.selobj
;	mov r15,rax;[.hOldBmp],rax

;	mov r8,[g.hBrush]
;	lea rdx,[.layc.crc]
;	mov rcx,r13;[.hCompDC]
;	call apiw.fillrect

;	mov r10d,[.layc.hrc.bottom]
;	mov r9d,[.layc.hrc.right]
;	mov r8d,[.layc.hrc.top]
;	mov edx,[.layc.hrc.left]
;	mov rcx,r13
;	call apiw.excl_cliprect

;	call .calc_crect
;	test [.layc.align],ALIGN_CLIENT
;	jnz	@f
;	lea rdx,[.layc.crc]
;@@:

;	mov r8,[g.hBrush]
;	lea rdx,[.layc.grc]
;	mov rcx,r12
;	call apiw.fillrect


;	xor r9,r9
;	xor r8,r8
;	lea rdx,[.layc.grc]
;	mov rcx,r12
;	call apiw.drawstt
;@@:
;	mov r9,DFCS_BUTTONPUSH	
;	mov r8,DFC_BUTTON	
;	lea rdx,[.layc.grc]
;	mov rcx,r12
;	call apiw.draw_fctrl

;	mov r9,BF_RECT	
;	mov r8,EDGE_RAISED	
;	lea rdx,[.layc.grc]
;	mov rcx,r12
;	call apiw.draw_edge

;	xor rcx,rcx
;	mov eax,[.layc.crc.bottom]
;	push 0
;	push SRCCOPY
;	push rcx
;	push rcx
;	push r13;qword[.hCompDC]
;	push rax
;	sub rsp,20h
;	mov r9d,[.layc.crc.right]
;	mov r8d,0;[.pnl.crc.top]
;	mov edx,0;[.pnl.crc.left]
;	mov rcx,r12;[.hDC]
;	call [BitBlt]
;	add rsp,50h

;	mov rdx,r15;[.hOldBmp]
;	mov rcx,r13;[.hCompDC]
;	call apiw.selobj
;	mov rcx,r14;[.hCompBmp]
;	call apiw.delobj
;	mov rcx,r13;[.hCompDC]
;	call apiw.delobj


;	mov eax,SWP_NOZORDER or \
;		SWP_NOSENDCHANGING or \
;		SWP_NOCOPYBITS
;	mov r11d,[.layc.hrc.bottom]
;	mov r10d,[.layc.hrc.right]
;	mov r9d,[.layc.hrc.top]
;	mov r8d,[.layc.hrc.left]
;	mov rdx,HWND_TOP
;	mov rcx,[.layc.hControl]
;	call apiw.set_wpos


;.wm_paintH:
;	mov rdx,rsi
;	mov rcx,[.hwnd]
;	call apiw.end_paint

;	pop r15
;	pop r14
;	pop r13
;	pop r12
;	jmp	.ret0



;.is_control:
;	test [.pnl.type],HAS_CONTROL
;	jz	.no_control

;;	lea rdx,[.rc]
;;	mov rcx,[.pnl.hControl]
;;	call shared.get_winrect

;;	mov r9,2
;;	lea r8,[.rc]
;;	mov rdx,[.pnl.hwnd]
;;	xor rcx,rcx
;;	sub rsp,20h
;;	call [MapWindowPoints]
;;	add rsp,20h

;	mov r10d,[.rc+RECT.bottom]
;	mov r9d,[.rc+RECT.right]
;	mov r8d,[.rc+RECT.top]
;	mov edx,[.rc+RECT.left]
;	mov rcx,rdi
;	call apiw.excl_cliprect


;.no_control:
;	xor rcx,rcx
;	mov eax,[.pnl.crc.bottom]
;	push 0				;---pad 16
;	push SRCCOPY
;	push rcx
;	push rcx
;	push qword[.hCompDC]
;	push rax
;	sub rsp,20h
;	mov r9d,[.pnl.crc.right]
;	mov r8d,0;[.pnl.crc.top]
;	mov edx,0;[.pnl.crc.left]
;	mov rcx,[.hDC]
;	call [BitBlt]
;	add rsp,50h

;.endpaint:
;	call .unset_hdc

;	test [.pnl.type],HAS_CONTROL
;	jz	.endpaintA

;	mov edx,[.rc+RECT.left]
;	mov r8d,[.rc+RECT.top]

;	mov r9d,[.rc+RECT.right]
;	sub r9d,edx
;	mov eax,[.rc+RECT.bottom]
;	sub eax,r8d

;	mov r11,rax
;	mov r10,r9
;	mov eax,SWP_NOZORDER or \
;		SWP_NOSENDCHANGING or \
;		SWP_NOCOPYBITS
;	mov r9,r8
;	mov r8,rdx
;	mov rcx,[.pnl.hControl]
;	mov rdx,HWND_TOP
;	call apiw.set_wpos



;.calc_crect:
;	;--- in RBX panel
;	lea rdx,[.layc.crc]
;	mov rcx,[.layc.hwnd]
;	call apiw.get_clirect

;	mov rax,[.layc.crc]
;	mov [.layc.hrc],rax
;	mov [.layc.grc],rax

;	mov rax,[.layc.crc+8]
;	mov [.layc.hrc+8],rax
;	mov [.layc.grc+8],rax

;	mov al,[.layc.align]
;	mov ecx,[.layc.crc.right]
;	mov edx,[.layc.crc.bottom]
;	cmp al,ALIGN_CLIENT
;	jnz	.calc_rectA
;	ret 0

;.calc_rectA:
;	shr al,1
;	jc	.calc_rectAL
;	shr al,1
;	jc	.calc_rectAT
;	shr al,1
;	jc	.calc_rectAR

;.calc_rectAB:	
;.calc_rectAT:	

;.calc_rectAL:
;	mov [.layc.grc.right],ecx
;	sub ecx,CX_GRIP
;	mov [.layc.hrc.right],ecx
;	mov [.layc.grc.left],ecx
;	jmp	.calc_rectH

;.calc_rectAR:	

;.calc_rectH:
;	ret 0
	
	;/----------------------------------------------------------
	;|                  LO_SET
	;\----------------------------------------------------------

.lo_set:
	;--- IN RDX main lays
	;--- IN RBX our layc
	xor eax,eax
	test rdx,rdx
	jnz	.lo_setA
	ret 0

.lo_setA:
	mov rcx,rdx
	cmp rax,[rdx+LAYS.pLast]
	jz	.lo_setB
	mov rcx,[rdx+LAYS.pLast]

.lo_setB:
	mov [.layc.pNext],rax
	mov [rcx+LAYS.pChild],rbx
	mov [rdx+LAYS.pLast],rbx
	mov rax,rbx
	ret 0


	;/----------------------------------------------------------
	;|                  LO_SHARE
	;\----------------------------------------------------------

.lo_share:
	;--- in RDX main lays
	;--- in RBX our first shared layc 
	;--- in RCX our next shared layc
	xor eax,eax
	test rcx,rcx
	jnz	.lo_shareA
	ret 0

.lo_shareA:
	call .is_panel
	test rax,rax
	jz	.lo_shareA1
	test r10,r10
	jz	.lo_shareB

	mov rax,[r10+LAYS.pShare]
	or [rcx+LAYS.type],\
		SHARE_PANEL
	mov [r10+LAYS.pShare],rcx
	mov [rcx+LAYS.pShare],rax
	jmp .lo_shareC

.lo_shareA1:
	call .lo_set
	test rax,rax
	jnz	.lo_shareB
	ret 0

.lo_shareB:
	or [.layc.type],\
		SHARE_FIRST or \
		SHARE_PANEL
	or [rcx+LAYS.type],\
		SHARE_PANEL
	mov [.layc.pShare],rcx

.lo_shareC:
	mov rax,rcx
	ret 0

	;/----------------------------------------------------------
	;|                  IS_PANEL
	;\----------------------------------------------------------

.is_panel:
	;--- in RDX main lays
	;--- in RBX panel to search for

	;--- RET RAX found panel 
	;--- RET R10 first share
	mov r11,rdx

.is_panelF:
	xor eax,eax
	xor r10,r10
	cmp rax,rdx
	jnz	.is_panelB
	ret 0

.is_panelD:
	mov rdx,r9

.is_panelB:
	mov r9,[rdx+LAYS.pChild]
	mov r8,[rdx+LAYS.pShare]

.is_panelA:
	cmp rbx,r9
	jnz	.is_panelE

.is_panelC:
	mov rax,rbx
	mov rdx,r11
	ret 0

.is_panelE:
	test r8,r8
	jz	.is_panelD
	test [r8+LAYS.type],\
		SHARE_FIRST
	cmovnz r10,r8
	cmp rbx,r8
	jz	.is_panelC
	mov r8,[r8+LAYS.pShare]
	jmp	.is_panelE


	;/----------------------------------------------------------
	;|                  .shareds
	;\----------------------------------------------------------
;.shareds:
;	;--- in RBX SHARE_FIRST panel
;	;--- RET RCX num panels
;	xor rcx,rcx
;	mov r8,[.pnl.pShare]

;.count_sharedB:
;	inc rcx
;	test r8,r8
;	jz	.count_sharedA
;	mov r8,[r8+PANELSTRUCT.pShare]
;	jmp	.count_sharedB

;.count_sharedA:
;	ret 0






