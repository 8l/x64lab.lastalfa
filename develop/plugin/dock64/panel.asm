  
  ;#-------------------------------------------------ß
  ;|          dock64  MPL 2.0 License                |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

panel:
	;*----------------------------------------------------------
	;|                  PANEL.
	;*----------------------------------------------------------
	virtual at rbx
		.pnl PNL
	end virtual

	virtual at rsi
		.mdl MDL
	end virtual
	
	;*----------------------------------------------------------
	;|                  PANEL.WPROC
	;*----------------------------------------------------------

.proc:
@wpro rbp,\
	rbx rdi rsi
	cmp edx,WM_PAINT
	jz	.wm_paint
;	cmp edx,WM_WINDOWPOSCHANGED
;	jz	.wm_wposchged
	cmp edx,WM_NCLBUTTONUP
	jz	.wm_nclbutup
	cmp edx,WM_NCLBUTTONDOWN
	jz	.wm_nclbutdw
	cmp edx,WM_MOUSEMOVE
	jz	.wm_mmove
	cmp edx,WM_LBUTTONUP
	jz	.wm_lbutup
	cmp edx,WM_LBUTTONDOWN
	jz	.wm_lbutdw
	cmp edx,WM_SYSCOMMAND
	jz	.wm_syscomm
;	cmp rdx,WM_MOUSEACTIVATE
;	jz	.wm_mactivate
	cmp edx,WM_CREATE
	jz	.wm_create
	cmp edx,WM_DESTROY
	jz	.wm_destroy
	jmp	.defwndproc

.get_struct:
	mov rcx,[.hwnd]
	call apiw.get_wldata
	test rax,rax
	jz	.err_gs
	mov rbx,rax
	mov rsi,[.pnl.mdl]
.err_gs:
	ret 0

.wm_syscomm:
	call .get_struct
	jz	.defwndproc
	mov eax,[.wparam]
	and eax,0FFF0h
	cmp eax,SC_CLOSE
	jnz	.defwndproc
	or [.pnl.type],IS_HID
	mov rdx,SW_HIDE
	mov rcx,[.pnl.hwnd]
	call apiw.show
	jmp	.defwndproc

.lbutdw_part:
;	push rax
;	mov r8,rbx
;	mov rdx,rax
;	call art.cout2XX
;	pop rax
	cmp eax,PART_CBUT
	jnz	.lbutdw_split
	jmp	.defwndproc

.lbutdw_split:
	mov [.mdl.sside],al
	test [.pnl.type],SHA_PA
	mov rcx,[.hwnd]
	jz	@f
;@break
;mov al,[.pnl.alignment]
;test al,ALIGN_V
	and al,[.pnl.alignment]
	jz	@f
;	movzx r8,[.pnl.alignment]
;	mov rdx,rax
;	call art.cout2XX
	

	mov rcx,rbx
	call dock64.get_sfisha
	mov rcx,[rax+PNL.hwnd]
@@:
	call apiw.set_capt

	mov [.mdl.flags],\
		F_SPLIT ;or F_SHADOW
	
	lea rdx,[.mdl.shadrc]
	mov rcx,[.hwnd]
	call apiw.get_winrect

	mov eax,SWP_NOZORDER\
		or SWP_SHOWWINDOW
	mov r11d,\
		[.mdl.shadrc.bottom]
	sub r11d,\
		[.mdl.shadrc.top]
	mov r10d,\
		[.mdl.shadrc.right]
	sub r10d,\
		[.mdl.shadrc.left]
	mov r9d,\
		[.mdl.shadrc.top]
	mov r8d,\
		[.mdl.shadrc.left]
	mov rdx,HWND_TOP
	mov rcx,\
		[.mdl.hShadow]
	call apiw.set_wpos
	jmp	.defwndproc


	;--- button down from a panel
.wm_lbutdw:
	call .get_struct
	jz	.defwndproc

	sub rsp,20h
	mov rcx,rsp
	call apiw.get_curspos

	mov rdx,[rsp]
	mov rcx,[.hwnd]
	call apiw.ddetect
	test rax,rax
	jz	.defwndproc;.ret0

	mov rdx,[rsp]
	mov rcx,rbx
	call dock64.is_pton
	test rax,rax
	jnz	.lbutdw_part

	mov rcx,rbx
	call dock64.lo_drop
	or [.pnl.type],IS_FLO

	mov rdx,rsi
	mov rcx,rbx
	call dock64.lo_set

	lea rdx,[.pnl.wrc]
	mov rcx,[.hwnd]
	call apiw.get_winrect


	;3) --- set style as FLOAT
	mov r8d,FLOAT_STYLE
	mov [.pnl.style],r8d
	mov rcx,[.pnl.hwnd]
	call apiw.set_wlstyle

	;4) --- re-parent to desktop
	mov rdx,0
	mov rcx,[.pnl.hwnd]
	call apiw.set_parent

	;5) --- update layout
	mov rdx,WM_WINDOWPOSCHANGED
	mov rcx,rsi
	call dock64.layout

	mov eax,\
		SWP_FRAMECHANGED

	mov edx,[.pnl.wrc.bottom]
	sub edx,[.pnl.wrc.top]
	mov r11d,[.pnl.frc.bottom]
	sub r11d,[.pnl.frc.top]
	cmovle r11,rdx
	
	mov edx,[.pnl.wrc.right]
	sub edx,[.pnl.wrc.left]
	mov r10d,[.pnl.frc.right]
	sub r10d,[.pnl.frc.left]
	cmovle r10,rdx
	
	mov edx,r10d
	shr edx,2
	mov r8d,[rsp]
	sub r8,rdx

	movzx edx,[cy_caption]
	mov r9d,[rsp+4]
	sub r9,rdx

	mov rdx,HWND_TOP
	mov rcx,[.pnl.hwnd]
	call apiw.set_wpos

	lea rdx,[.pnl.wrc]
	mov rcx,[.pnl.hwnd]
	call apiw.get_winrect

	mov rax,[rsp]
	mov [.mdl.phit],rax

	;	mov r8,[rsp+8]
	;	mov rdx,qword[rsp]
	;	call art.cout2XX

	mov eax,[.pnl.wrc.left]
	sub [.mdl.phit.x],eax
	mov eax,[.pnl.wrc.top]
	sub [.mdl.phit.y],eax
	jmp	.wm_nclbutdwA

.wm_nclbutdw:
	mov eax,[.wparam]
	cmp eax,HTCAPTION
	jnz	.defwndproc

	call .get_struct
	jz	.defwndproc;.ret0

	sub rsp,20h
	lea rcx,[.mdl.phit]
	call apiw.get_curspos

	lea rdx,[.pnl.frc]
	mov rcx,[.hwnd]
	call apiw.get_winrect

	mov eax,[.pnl.frc.left]
	sub [.mdl.phit.x],eax
	mov eax,[.pnl.frc.top]
	sub [.mdl.phit.y],eax
	
.wm_nclbutdwA:
	mov rcx,[.hwnd]
	call apiw.set_capt
	mov [.mdl.flags],\
		F_MOVE

	jmp	.defwndproc;.ret0

.wm_nclbutup:
;	push rax
;	mov r8,rax
;	mov rdx,[.hwnd]
;	call art.cout2XX
;	pop rax

;	mov eax,[.wparam]
;	cmp eax,HTCLOSE
;	jnz	.wm_lbutup
;	;---
;	@break
;	jmp	.defwndproc

.wm_lbutup:
	;--- 1) get structure
	call .get_struct
	jz	.defwndproc;.ret0
	call apiw.rel_capt

	test [.mdl.flags],\
		F_SPLIT
	jnz	.lbutup_split

	mov rdx,[.mdl.target]
	test rdx,rdx
	jz	.lbutup_hide

	mov rcx,rbx
	call dock64.lo_drop

	mov rdx,[.mdl.target]
	mov rcx,rbx
	call dock64.lo_repo

	mov rdx,[.mdl.hwnd]
	mov rcx,[.hwnd]
	call apiw.set_parent

	mov r8,CHILD_STYLE
	mov [.pnl.style],r8d
	mov rcx,[.pnl.hwnd]
	call apiw.set_wlstyle

;lea rdx,[.pnl.frc]
;mov rcx,[.hwnd]
;call apiw.get_winrect


.lbutupA:
	lea rdx,[.mdl.shadrc]
	mov rcx,[.mdl.hShadow]
	call apiw.get_winrect

	;	mov r8,[.mdl.shadrc+8]
	;	mov rdx,[.mdl.shadrc]
	;	call art.cout2XX

	mov eax,SWP_NOZORDER;\
		;or SWP_NOSENDCHANGING

	mov r11d,\
		[.mdl.shadrc.bottom]
	sub r11d,\
		[.mdl.shadrc.top]
	mov r10d,\
		[.mdl.shadrc.right]
	sub r10d,\
		[.mdl.shadrc.left]
	mov r9d,\
		[.mdl.shadrc.top]
	mov r8d,\
		[.mdl.shadrc.left]
	mov rdx,HWND_TOP
	mov rcx,\
		[.pnl.hwnd]
	call apiw.set_wpos

	mov rdx,WM_WINDOWPOSCHANGED
	mov rcx,rsi
	call dock64.layout

.lbutup_hide:
	mov rdx,SW_HIDE
	mov rcx,[.mdl.hShadow]
	call apiw.show

.lbutup_ok:
	mov [.mdl.flags],0
	mov [.mdl.cside],0
	jmp	.defwndproc;.ret0

.lbutup_split:
	test [.pnl.type],\
		SHA_PA
	jz .lbutupA

;	movzx r8,[.pnl.ratio]
;	mov rdx,-1
;	call art.cout2XX

	mov rcx,rbx
	call dock64.get_sfisha
	mov rdi,r8
	sub rsp,16

	lea rdx,[rsp]
	mov rcx,[rdi+PNL.hwnd]
	call apiw.get_winrect

	mov ecx,[rsp+RECT.bottom]
	sub ecx,[rsp+RECT.top]

	movzx r8,[.pnl.ratio]
	movzx r9,[rdi+PNL.ratio]

	mov eax,r9d
	mov edx,[.mdl.shadrc.top]
	sub edx,[rsp+RECT.top]
	mul edx
	xor edx,edx
	test ecx,ecx
	jz .lbutup_hide
	div ecx
	mov [rdi+PNL.ratio],al
	add r9l,r8l
	sub r9l,al
	mov [.pnl.ratio],r9l
	
;	mov r8,rax
;	movzx rdx,[rdi+PNL.ratio]
;	call art.cout2XX

	add rsp,16
	jmp	.lbutupA


.wm_mmove:
	call .get_struct
	jz	.defwndproc;.ret0
	sub rsp,\
		sizeof.POINT+\	;--- x,y adjustemnt	
		sizeof.POINT+\	;--- x,y mouse movement
		sizeof.RECT			;--- shadow on side rect
	mov rcx,rsp
	call apiw.get_curspos

	xor eax,eax
	xor edi,edi
	mov rdi,rsi		;--- set RDI default target
	
	test [.mdl.flags],\
		F_MOVE
	jnz	.mmove_move
	test [.mdl.flags],\
		F_SPLIT
	jnz	.mmove_split

.mmove_check:
	test [.pnl.type],\
		IS_FLO
	jnz	.defwndproc
	mov r8,[rsp]
	mov [rsp+8],r8

	mov rdx,[rsp]
	mov rcx,rbx
	call dock64.is_pton

;	push rax
;	push rcx
;	push rdx
;	mov rdx,rax
;	mov r8,[rsp]
;	call art.cout2XX
;	pop rdx
;	pop rcx
;	pop rax


.mmove_checkE:
	cmp rcx,rdx
	jz	.defwndproc
	mov rcx,rdx
	call apiw.set_curs
	jmp	.defwndproc

.mmove_split:
	movzx rax,[.mdl.sside]
	and al,[.pnl.alignment]
	jnz	.mmove_splitA

	;--- apply shared panel policy
;	movzx r8,[.mdl.sside]
;	mov rdx,rbx
;	call art.cout2XX

	mov rcx,[rsp]
	call shadow.split_sharc
	test rax,rax
	jz	.defwndproc
	jmp	.mmove_splitB

.mmove_splitA:
;	movzx r8,[.mdl.sside]
;	mov rdx,rbx
;	call art.cout2XX

	mov rcx,[rsp]
	call shadow.split_rc
	test rax,rax
	jz	.defwndproc

.mmove_splitB:
	@reg2rect .mdl.shadrc,rax
	

	mov eax,SWP_NOZORDER;\
		;or SWP_NOSENDCHANGING
	mov r11d,\
		[.mdl.shadrc.bottom]
	sub r11d,\
		[.mdl.shadrc.top]
	mov r10d,\
		[.mdl.shadrc.right]
	sub r10d,\
		[.mdl.shadrc.left]
	mov r9d,\
		[.mdl.shadrc.top]
	mov r8d,\
		[.mdl.shadrc.left]
	mov rdx,HWND_TOP
	mov rcx,\
		[.mdl.hShadow]
	call apiw.set_wpos	

	jmp	.defwndproc

.mmove_move:
	mov r8,[rsp]
	mov [rsp+8],r8
	mov [rsp+16],r8

;mov r8,[rsp]
;mov rdx,[.mdl.phit]
;call art.cout2XX

	mov r8d,[rsp]
	mov r9d,[rsp+4]
	sub r8d,[.mdl.phit.x]
	sub r9d,[.mdl.phit.y]

	mov eax, SWP_NOZORDER\		;---0 
		or SWP_NOSENDCHANGING\
		or SWP_NOSIZE

	mov rdx,HWND_TOP
	mov rcx,[.hwnd]
	call apiw.set_wpos

	mov r9,1
	mov r8,rsp
	mov rdx,[.mdl.hwnd]
	mov rcx,0
	call apiw.map_wpt

	mov r8,\
		CWP_SKIPTRANSPARENT\
		or CWP_SKIPINVISIBLE
	mov rdx,[rsp]
	mov rcx,[.mdl.hwnd]
	call apiw.chwinfptx

	;push rax
	;	mov r8,[rsp+8]
	;	mov rdx,rax
	;	call art.cout2XX
	;pop rax

	test rax,rax
	jz	.mmove_moveH
	
	cmp rax,[.mdl.hwnd]
	jnz	.mmove_chi

	mov rax,[.mdl.src]
	mov [.mdl.shadrc],rax
	mov rax,[.mdl.src+8]
	mov [.mdl.shadrc+8],rax

	mov r9,2
	lea r8,[.mdl.shadrc]
	mov rdx,0
	mov rcx,[.mdl.hwnd]
	call apiw.map_wpt

;	mov r8,[.mdl.shadrc+8]
;	mov rdx,[.mdl.shadrc]
;	call art.cout2XX
	jmp	.mmove_chiA

.mmove_chi:
	mov rcx,rax
	call apiw.get_wldata
	test rax,rax
	jz	.mmove_moveH

	mov rdi,rax
	lea rdx,[rdi+PNL.wrc]
	mov rcx,[rdi+PNL.hwnd]
	call apiw.get_winrect

	mov rax,[rdi+PNL.wrc]
	mov [.mdl.shadrc],rax
	mov rax,[rdi+PNL.wrc+8]
	mov [.mdl.shadrc+8],rax

.mmove_chiA:
	mov edx,[rsp+8+POINT.y]
	mov ecx,[rsp+8+POINT.x]
	call dock64.get_side

	test eax,eax
	jz	.mmove_moveH
	cmp al,[.mdl.exclude]
	jz	.mmove_moveH
	test al,[.mdl.exclude]
	jnz	.mmove_moveH
	
	cmp al,[.pnl.exclude]
	jz	.mmove_moveH
	test al,[.pnl.exclude]
	jnz	.mmove_moveH
	;---
	jmp	.mmove_moveS

.mmove_moveH:
	xor edx,edx
	mov [.mdl.cside],dl
	mov [.mdl.target],rdx
	test [.mdl.flags],\
		F_SHADOW
	jz	.defwndproc;.ret0
	and [.mdl.flags],\
		not F_SHADOW

	mov eax,\
		SWP_NOZORDER or \
		SWP_HIDEWINDOW or \
		SWP_NOSIZE or\
		SWP_NOMOVE
	jmp	.mmove_moveP1

.mmove_moveS:
	xor edx,edx
	test [.mdl.flags],\
		F_SHADOW
	jz	.mmove_moveS2
	cmp rdi,[.mdl.target]
	jnz	.mmove_moveS2

.mmove_moveS3:
	cmp al,[.mdl.cside]
	jnz	.mmove_moveS2
	jmp	.defwndproc;.ret0

.mmove_moveS2:
	mov [.mdl.cside],al
	or [.mdl.flags],\
		F_SHADOW
	mov [.mdl.target],rdi

.mmove_moveP:
	movzx r8,[.mdl.cside]
	mov rdx,[.mdl.target]
	call art.cout2XX

	call shadow.size_rc

;	mov r8,[.mdl.shadrc+8]
;	mov rdx,[.mdl.shadrc]
;	call art.cout2XX

	mov eax,SWP_NOZORDER \
		or SWP_SHOWWINDOW

.mmove_moveP1:
	mov r11d,\
		[.mdl.shadrc.bottom]
	sub r11d,\
		[.mdl.shadrc.top]
	mov r10d,\
		[.mdl.shadrc.right]
	sub r10d,\
		[.mdl.shadrc.left]
	mov r9d,\
		[.mdl.shadrc.top]
	mov r8d,\
		[.mdl.shadrc.left]
	mov rdx,HWND_TOP
	mov rcx,\
		[.mdl.hShadow]
	call apiw.set_wpos

	jmp	.defwndproc;.ret0

.wm_wposchged:
	call .get_struct
	jz	.ret0
;	mov r8,[.lparam]
;	mov rdx,[.hwnd]
;	call art.cout2XX

;	mov rcx,[.pnl.hControl]
;	sub rsp,20h
;	call [LockWindowUpdate]
;	add rsp,20h


;	mov rcx,[.hwnd]
;	call apiw.get_dc
;	mov rdi,rax

;	mov r10d,[.pnl.ctrc.bottom]
;	mov r9d,[.pnl.ctrc.right]
;	mov r8d,[.pnl.ctrc.top]
;	mov edx,[.pnl.ctrc.left]
;	mov rcx,rdi
;	call apiw.excl_cliprect	

;	mov r8,TRUE
;	xor rdx,rdx
;	mov rcx,[.hwnd]
;	call apiw.invrect

;	mov rcx,0
;	sub rsp,20h
;	call [LockWindowUpdate]
;	add rsp,20h

;	mov r8,rax
;	mov rdx,rbx
;	call art.cout2XX


;	mov r8,[hBrPanel]
;	lea rdx,[.pnl.crc]
;	mov rcx,rdi
;	call apiw.fillrect


;	mov rdx,rdi
;	mov rcx,[.hwnd]
;	call apiw.rel_dc

;	mov eax,SWP_NOZORDER \
;		or SWP_NOSENDCHANGING\
;		or 0;SWP_NOREDRAW
;	mov r11d,[.pnl.ctrc.bottom]
;	mov r10d,[.pnl.ctrc.right]
;	mov r9d,[.pnl.ctrc.top]
;	mov r8d,[.pnl.ctrc.left]
;	mov rdx,HWND_TOP
;	mov rcx,[.pnl.hControl]
;	call apiw.set_wpos



;	mov r8,FALSE
;	xor rdx,rdx
;	mov rcx,[.hwnd]
;	call apiw.invrect
;	mov rax,[.lparam]
;	mov r8d,[rax+WINDOWPOS.flags]
;	test r8d,SWP_NOSIZE
;	jnz	.defwndproc;.ret0
	;jmp	.defwndproc;.ret0

	jmp	.ret0

	;*----------------------------------------------------------
	;|                  WM_DESTROY (PANEL)
	;*----------------------------------------------------------
.wm_destroy:
	call .get_struct
	jz	.ret0
	mov rcx,[.pnl.hControl]
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
	mov r8,rbx
	mov rdi,[.pnl.tmp]
	mov rsi,[.pnl.mdl]
	mov [.pnl.hwnd],rcx
	call apiw.set_wldata

;	mov [cside],0
;	xor edx,edx
	mov rdx,rdi
	mov rcx,rbx
	call dock64.lo_set

	;--------------- debugging 
	;sub rsp,110h
	;mov r9,rsp
	;mov r8,100h
	;mov rdx,WM_GETTEXT
	;mov rcx,[.hwnd]
	;call apiw.sms
	;mov r8,rsp
	;mov rdx,rbx
	;call art.cout2XU
	;add rsp,110h
	;------------------------

	;mov rax,[.pnl.hControl]
	;test rax,rax
	;jz	.ret0

	;mov rdx,[.pnl.hwnd]
	;mov rcx,rax
	;call apiw.set_parent
	inc [.mdl.nslots]
	mov eax,[.mdl.seed]
	call art.pmc_fuerst
	mov [.pnl.id],eax
	mov [.mdl.seed],eax

.ret0:
	xor rax,rax
	jmp	.exit

.ret1:
	xor rax,rax	
	inc eax
	jmp	.exit


	;*----------------------------------------------------------
	;|                  WM_PAINT (PANEL)
	;*----------------------------------------------------------
.wm_paint:
	call .get_struct
	jz	.ret0
	test [.pnl.type],\
		IS_HID
	jnz	.ret0

	sub rsp,\
		sizea16.PAINTSTRUCT+\
		FILE_BUFLEN
	mov rax,rsp
	push r12
	push r13

	mov r12,rax

	lea r9,[rax+\
		sizea16.PAINTSTRUCT]
	mov r8,100h
	mov rdx,WM_GETTEXT
	mov rcx,[.hwnd]
	call apiw.sms

	mov rdx,r12
	mov rcx,[.hwnd]
	call apiw.beg_paint
	mov rdi,rax

	lea rdx,[.pnl.crc]
	mov rcx,[.pnl.hwnd]
	call apiw.get_clirect

	mov rax,[.pnl.crc]
	mov [.pnl.ctrc],rax
	mov [.pnl.caprc],rax
	;mov [.pnl.cbutrc],rax
	mov rax,[.pnl.crc+8]
	mov [.pnl.ctrc+8],rax
	mov [.pnl.caprc+8],rax
	;mov [.pnl.cbutrc+8],rax

	movzx eax,[.pnl.alignment]
	movzx ecx,[cx_border]
	movzx edx,[cy_edge]
	movzx r8d,[cx_fxframe]
	movzx r9d,[cx_smbsize]
	;mov r9,8

	test [.pnl.type],IS_FLO
	jnz	.wm_paintB

	cmp al,ALIGN_LEFT
	jz	.wm_paintLX
	cmp al,ALIGN_TOP
	jz	.wm_paintUP
	cmp al,ALIGN_RIGHT
	jz	.wm_paintRX
	cmp al,ALIGN_BOTTOM
	jz	.wm_paintDW

.wm_paintCC:
	mov [.pnl.caprc.top],ecx
	mov [.pnl.caprc.bottom],r8d
	add [.pnl.caprc.bottom],r9d
	mov [.pnl.caprc.left],ecx
	sub [.pnl.caprc.right],ecx
	sub [.pnl.caprc.right],r8d
	sub [.pnl.caprc.right],r9d

	mov [.pnl.ctrc.left],ecx
	mov eax,[.pnl.caprc.right]
	add eax,r9d
	mov [.pnl.ctrc.right],eax
	mov eax,[.pnl.caprc.bottom]
	add eax,edx
	mov [.pnl.ctrc.top],eax

	;mov r8,[.pnl.ctrc+8]
	;mov rdx,[.pnl.ctrc]
	;call art.cout2XX
	jmp	.wm_paintA

.wm_paintRX:
	mov [.pnl.caprc.top],r8d
	mov [.pnl.caprc.bottom],r8d
	add [.pnl.caprc.bottom],r9d

	mov [.pnl.caprc.left],ecx
	add [.pnl.caprc.left],r8d

	sub [.pnl.caprc.right],ecx
	sub [.pnl.caprc.right],r8d
	sub [.pnl.caprc.right],r9d

	mov [.pnl.ctrc.left],ecx
	add [.pnl.ctrc.left],r8d
	mov eax,[.pnl.caprc.right]
	add eax,r9d
	mov [.pnl.ctrc.right],eax
	mov eax,[.pnl.caprc.bottom]
	add eax,edx
	mov [.pnl.ctrc.top],eax
	jmp	.wm_paintA

.wm_paintDW:
	mov [.pnl.caprc.top],r8d
	add [.pnl.caprc.top],ecx
	add [.pnl.caprc.top],edx

	mov [.pnl.caprc.bottom],r8d
	add [.pnl.caprc.bottom],r9d
	add [.pnl.caprc.bottom],ecx
	add [.pnl.caprc.bottom],edx

	mov [.pnl.caprc.left],ecx
	sub [.pnl.caprc.right],ecx
	sub [.pnl.caprc.right],r8d
	sub [.pnl.caprc.right],r9d

	mov [.pnl.ctrc.left],ecx
	mov eax,[.pnl.caprc.right]
	add eax,r9d
	mov [.pnl.ctrc.right],eax
	mov eax,[.pnl.caprc.bottom]
	add eax,edx
	mov [.pnl.ctrc.top],eax
	jmp	.wm_paintA

.wm_paintUP:
	mov [.pnl.caprc.top],r8d
	mov [.pnl.caprc.bottom],r8d
	add [.pnl.caprc.bottom],r9d
	mov [.pnl.caprc.left],ecx
	sub [.pnl.caprc.right],ecx
	sub [.pnl.caprc.right],r8d
	sub [.pnl.caprc.right],r9d

	mov [.pnl.ctrc.left],ecx
	mov eax,[.pnl.caprc.right]
	add eax,r9d
	mov [.pnl.ctrc.right],eax
	mov eax,[.pnl.caprc.bottom]
	add eax,edx
	mov [.pnl.ctrc.top],eax
	sub [.pnl.ctrc.bottom],ecx
	sub [.pnl.ctrc.bottom],edx
	jmp	.wm_paintA

.wm_paintLX:
	mov [.pnl.caprc.top],r8d
	mov [.pnl.caprc.bottom],r8d
	add [.pnl.caprc.bottom],r9d
	mov [.pnl.caprc.left],ecx

	sub [.pnl.caprc.right],ecx
	sub [.pnl.caprc.right],edx
	sub [.pnl.caprc.right],r8d
	sub [.pnl.caprc.right],r9d
		
	mov [.pnl.ctrc.left],ecx
	mov eax,[.pnl.caprc.right]
	add eax,r9d
	mov [.pnl.ctrc.right],eax
	mov eax,[.pnl.caprc.bottom]
	add eax,edx
	mov [.pnl.ctrc.top],eax
	;	mov r8,[.pnl.ctrc+8]
	;	mov rdx,[.pnl.ctrc]
	;	call art.cout2XX

.wm_paintA:
	mov r10d,[.pnl.ctrc.bottom]
	mov r9d,[.pnl.ctrc.right]
	mov r8d,[.pnl.ctrc.top]
	mov edx,[.pnl.ctrc.left]
	mov rcx,rdi
	call apiw.excl_cliprect	

	mov r8,[hBrPanel]
	lea rdx,[.pnl.crc]
	mov rcx,rdi
	call apiw.fillrect

	mov r8,[hBrActCapt]
	lea rdx,[.pnl.caprc]
	mov rcx,rdi
	call apiw.fillrect

	mov rdx,TRANSPARENT
	mov rcx,rdi
	call apiw.set_bkmode

	mov r10,DT_LEFT or \
		DT_VCENTER or \
		DT_NOCLIP or \
		DT_SINGLELINE	or \
		DT_END_ELLIPSIS
	lea r9,[.pnl.caprc]
	or r8,-1
	lea rdx,[r12+\
		sizea16.PAINTSTRUCT]
	mov rcx,rdi
	call apiw.drawtext

	mov eax,[.pnl.caprc.right]
	mov ecx,[.pnl.caprc.left]
	inc eax
	mov [.pnl.caprc.left],eax
	mov [.pnl.caprc.right],eax
	add [.pnl.caprc.right],17
	
	xor r11,r11
	lea r10,[.pnl.caprc]
	mov r9,CBS_NORMAL
	mov r8,WP_SMALLCLOSEBUTTON
	mov rdx,rdi
	mov rcx,[hThmWin]
	call apiw.th_drawbkg

.wm_paintB:
	mov eax,SWP_NOZORDER \
		or SWP_NOSENDCHANGING\
		or 0;SWP_NOREDRAW
	mov r11d,[.pnl.ctrc.bottom]
	sub r11d,[.pnl.ctrc.top]
	mov r10d,[.pnl.ctrc.right]
	sub r10d,[.pnl.ctrc.left]
	mov r9d,[.pnl.ctrc.top]
	mov r8d,[.pnl.ctrc.left]
	mov rdx,HWND_TOP
	mov rcx,[.pnl.hControl]
	call apiw.set_wpos

.wm_paintE:
	mov rdx,r12
	mov rcx,[.hwnd]
	call apiw.end_paint
	pop r13
	pop r12
	jmp	.defwndproc


.defwndproc:
	mov r9,[.lparam]
	mov r8,[.wparam]
	mov rdx,[.msg]
	mov rcx,[.hwnd]
	sub rsp,20h
	call [DefWindowProcW]

.exit:
@wepi


;	;*----------------------------------------------------------
;	;|                  PANEL.WM_LBUTTONDOWN
;	;*----------------------------------------------------------

;.wm_lbutdw:
;	call .get_structs
;	jz	.ret0
;	mov rcx,[.lparam]
;	call dock64.get_cursor
;	mov rsi,rax
;	call apiw.set_curs
;	test rsi,rsi
;	jz	.wm_lbutdw_panel

;.wm_lbutdw_split:
;	;--- 1) --- save hit point -----------
;	lea rcx,[.pt]
;	call apiw.get_curspos

;	mov rdx,qword[.pt]
;	mov rcx,[.hwnd]
;	call apiw.ddetect
;	test rax,rax
;	jz	.ret0

;	mov [fSplitting],TRUE
;	mov [fMoving],FALSE


;	mov rdx,rc_shadow
;	mov rcx,[.hwnd]
;	call apiw.get_winrect

;	mov rcx,[.hwnd]
;	call apiw.set_capt


;	lea rcx,[.rc]
;	call dock64.get_splitrect


;	mov r11,TRUE
;	mov r10d,[.rc+RECT.bottom]
;	mov r9d,[.rc+RECT.right]
;	mov r8d,[.rc+RECT.top]
;	mov edx,[.rc+RECT.left]
;	mov rcx,[hShadow]
;	call apiw.movewin


;;	call shadow.animate_show
;	call shadow.show
;	jmp	.ret0

;.wm_lbutdw_panel:
;	mov eax,[.lparam]
;	shr eax,16
;	cmp ax,[cy_caption]
;	ja	.ret0

;	lea rcx,[.pt]
;	call apiw.get_curspos

;	mov rdx,qword[.pt]
;	mov rcx,[.hwnd]
;	call apiw.ddetect
;	test rax,rax
;	jz	.ret0

;	lea rcx,[pt_start]
;	call apiw.get_curspos

;	mov rax,[.pt]
;	cmp rax,[pt_start]
;	jz	.ret0

;	;1) --- save dimensions ------
;	lea rdx,[.rc]
;	mov rcx,[.hwnd]
;	call apiw.get_winrect

;	mov eax,[.rc+RECT.right]
;	sub eax,[.rc+RECT.left]
;	mov edx,[.rc+RECT.bottom]
;	sub edx,[.rc+RECT.top]

;	test [.pnl.type],FLOAT_PANEL
;	jz	.wm_lbutdw_panelA
;	mov [.pnl.float_cx],eax
;	mov [.pnl.float_cy],edx

;.wm_lbutdw_panelA:
;	;2) --- save hit point -----------
;	mov eax,[.lparam]
;	and eax,07FFFh
;	mov edx,[.lparam]
;	shr edx,16
;	and edx,07FFFh

;	mov [pt_start.x],eax
;	mov [pt_start.y],edx

;	add ax,[cx_sframe]
;	add dx,[cy_sframe]
;	mov [pt_delta.x],eax
;	mov [pt_delta.y],edx
;	
;	mov rcx,[.hwnd]
;	call apiw.set_capt

;.wm_lbutdw_panelB:
;	mov [pTarget],0
;	mov [cside],0
;	
;	mov al,[.pnl.type]
;	mov [.pnl.ttype],al

;	test [.pnl.type],FLOAT_PANEL
;	jnz	.wm_lbutdw_panelC
;	or [.pnl.type],FLOAT_PANEL
;	and [.pnl.type],FLOAT_PANEL or HAS_CONTROL

;	;--- avoid blinking by undocking
;	mov r11,TRUE
;	xor r10,r10
;	xor r9,r9
;	xor r8,r8
;	xor edx,edx
;	mov rcx,[.hwnd]
;	call apiw.movewin

;	;3) --- set style as FLOAT
;	mov r8d,FLOAT_STYLE
;	mov [.pnl.style],r8d
;	mov rcx,[.hwnd]
;	call apiw.set_wlstyle

;	;4) --- re-parent to desktop
;	mov rdx,0
;	mov rcx,[.hwnd]
;	call apiw.set_parent

;.wm_lbutdw_panelC:
;	mov [fMoving],TRUE
;	mov [fShadowing],FALSE

;	test [.pnl.ttype],FLOAT_PANEL
;	jnz	.ret0

;	mov eax,SWP_NOMOVE or \
;		SWP_NOSIZE or \
;		SWP_NOZORDER or \
;		SWP_FRAMECHANGED 
;	xor r11,r11
;	xor r10,r10
;	xor r9,r9
;	xor r8,r8
;	mov rdx,HWND_TOP
;	mov rcx,[.pnl.hwnd]
;	call apiw.set_wpos


;.wm_lbutdw_panelD:
;;@break
;	call dock64.lo_drop

;	mov rdx,orc
;	mov rcx,[hMain]
;	call apiw.get_clirect

;;	mov rdx,orc
;	mov rcx,orc;maindock
;	call dock64.resize
;	jmp	.ret0

;-----------------------------------------------------------------
;.wm_mactivate:
;	call .get_structs
;	jz	.ret0

;	mov rax,[pLastPanel]
;	test rax,rax
;	jz	.wm_mactivateA
;	cmp rax,rbx
;	jz	.ret0

;	mov rcx,[rax+PNL.hwnd]
;	mov [rax+PNL.active],FALSE

;	xor r8,r8
;	xor rdx,rdx
;	call apiw.invrect
;	
;.wm_mactivateA:
;	mov [.pnl.active],TRUE
;	mov r8,FALSE;TRUE;FALSE
;	xor rdx,rdx
;	mov rcx,[.pnl.hwnd]
;	call apiw.invrect

;.wm_mactivateB:	
;	mov [pLastPanel],rbx
;	mov rax,MA_ACTIVATE
;	jmp	.exit

;	lea rsi,[.ps]
;	mov rdx,rsi
;	mov rcx,[.hwnd]
;	call apiw.beg_paint
;	mov rdi,rax
;	mov [.hDC],rax

;	lea rdx,[.pnl.crc]
;	mov rcx,[.pnl.hwnd]
;	call apiw.get_clirect

;	mov rax,[.pnl.crc]
;	mov [.rc],rax
;	mov rax,[.pnl.crc+8]
;	mov [.rc+8],rax

;	call .setup_hdc

;	mov r8,[hBrPanel]
;	lea rdx,[.rc]
;	mov rcx,[.hCompDC]
;	call apiw.fillrect

;	call .redraw_caption

;	movzx rax,[cy_caption]
;	mov ecx,[.pnl.crc.right]
;	mov edx,[.pnl.crc.bottom]

;;.is_splitter:
;	xor r8,r8
;	test [.pnl.type],FLOAT_PANEL
;	jnz	.no_grip
;	cmp [.pnl.alignment],ALIGN_CLIENT
;	jz	.no_grip

;	mov r8,RP_GRIPPERVERT
;	test [.pnl.alignment],ALIGN_LEFT
;	jnz	.grip_RX
;	test [.pnl.alignment],ALIGN_RIGHT
;	jnz	.grip_LX

;	mov r8,RP_GRIPPER
;	test [.pnl.alignment],ALIGN_BOTTOM
;	jnz	.grip_UP
;	test [.pnl.alignment],ALIGN_TOP
;	jnz	.grip_DW
;	jmp	.no_grip

;.grip_LX:
;	mov [.rc_grip+RECT.left],0
;	mov [.rc_grip+RECT.top],eax
;	add [.rc_grip+RECT.top],2
;	mov [.rc_grip+RECT.right],CX_SPLITTER
;	mov [.rc_grip+RECT.bottom],edx
;	sub [.rc_grip+RECT.bottom],2
;	add [.rc+RECT.left],CX_SPLITTER
;	mov [.rc+RECT.top],eax
;	jmp	.redraw_grip
;	
;.grip_RX:
;	mov [.rc_grip+RECT.top],eax
;	mov [.rc_grip+RECT.bottom],edx
;	mov [.rc_grip+RECT.left],ecx
;	sub [.rc_grip+RECT.left],CX_SPLITTER
;	mov [.rc_grip+RECT.right],ecx
;	sub [.rc+RECT.right],CX_SPLITTER
;	mov [.rc+RECT.top],eax
;	jmp	.redraw_grip

;.grip_UP:
;	mov [.rc_grip+RECT.left],1
;	mov [.rc_grip+RECT.top],eax
;	mov [.rc_grip+RECT.right],ecx
;	sub [.rc_grip+RECT.right],1
;	mov [.rc_grip+RECT.bottom],eax
;	add [.rc_grip+RECT.bottom],CY_SPLITTER
;	add [.rc_grip+RECT.bottom],1

;inc eax
;inc eax
;	mov [.rc+RECT.top],eax
;	add [.rc+RECT.top],CY_SPLITTER

;	jmp	.redraw_grip

;.grip_DW:
;	mov [.rc_grip+RECT.left],1
;	mov [.rc_grip+RECT.right],ecx
;	sub [.rc_grip+RECT.right],1
;	mov [.rc_grip+RECT.top],edx
;	sub [.rc_grip+RECT.top],CY_SPLITTER
;	mov [.rc_grip+RECT.bottom],edx
;	sub [.rc_grip+RECT.bottom],1

;	mov [.rc+RECT.top],eax
;	sub [.rc+RECT.bottom],CY_SPLITTER
;	jmp	.redraw_grip

;.no_grip:
;	mov [.rc+RECT.top],eax
;	mov [.pnl.crc.top],eax
;	jmp	.is_control

;.redraw_grip:

;;	xor r11,r11
;;	lea r10,[.rc_grip]
;;	xor r9,r9
;;	mov rdx,[.hCompDC]
;;	mov rcx,[hThRebar]
;;	call apiw.th_drawbkg

;.is_control:
;	test [.pnl.type],HAS_CONTROL
;	jz	.no_control

;;	lea rdx,[.rc]
;;	mov rcx,[.pnl.hControl]
;;	call apiw.get_winrect

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
;;add edx,4
;	mov r8d,[.rc+RECT.top]
;;add r8d,4
;	mov r9d,[.rc+RECT.right]
;	sub r9d,edx
;;sub r9d,4
;	mov eax,[.rc+RECT.bottom]
;	sub eax,r8d
;;sub eax,4

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

;.endpaintA:
;	mov rdx,rsi
;	mov rcx,[.hwnd]
;	call apiw.end_paint
;	jmp	.ret1



;	;--- using .hDC on R15 ------------
;	;--- .pnl.crc.right/bottom

;.setup_hdc:
;	;--- use R15 for locals
;	mov rcx,[.hDC]
;	call apiw.create_compdc
;	mov [.hCompDC],rax
;	mov r8d,[.pnl.crc.bottom]
;	mov edx,[.pnl.crc.right]
;	mov rcx,[.hDC]
;	call apiw.create_compbmp
;	mov [.hCompBmp],rax
;	mov rdx,[.hCompBmp]
;	mov rcx,[.hCompDC]
;	call apiw.selobj
;	mov [.hOldBmp],rax
;	ret 0

;.unset_hdc:
;	;--- use R15 for locals
;	mov rdx,[.hOldBmp]
;	mov rcx,[.hCompDC]
;	call apiw.selobj
;	mov rcx,[.hCompBmp]
;	call apiw.delobj
;	mov rcx,[.hCompDC]
;	call apiw.delobj
;	ret 0


;;----------------------------------
;.redraw_caption:
;	sub rsp,110h
;	mov r9,rsp
;	mov r8,100h
;	mov rdx,WM_GETTEXT
;	mov rcx,[.pnl.hwnd]
;	call apiw.sms

;	xor eax,eax
;	mov [.rc_capt+RECT.top],eax
;	mov [.rc_capt+RECT.left],eax
;	
;	mov eax,[.pnl.crc.right]
;	mov [.rc_capt+RECT.right],eax

;	movzx eax,[cy_caption]
;	mov [.rc_capt+RECT.bottom],eax

;	mov r8,[hBrInactCapt]
;	cmp [.pnl.active],FALSE
;	jz	@f
;	mov r8,[hBrActCapt]
;@@:
;	lea rdx,[.rc_capt]
;	mov rcx,[.hCompDC]
;	call apiw.fillrect

;	mov rax,[.rc_capt]
;	mov [.rc_text],rax
;	mov rax,[.rc_capt+8]
;	mov [.rc_text+8],rax

;	mov [.rc_text+RECT.top],1
;	sub [.rc_text+RECT.bottom],1
;	movzx eax,[cx_smicon]
;	inc eax
;	add [.rc_text+RECT.left],eax

;	movzx rax,[cx_smsize]
;	add eax,eax
;	inc eax
;	inc eax
;	inc eax
;	inc eax
;	sub [.rc_text+RECT.right],eax
;	
;	mov rdx,TRANSPARENT
;	mov rcx,[.hCompDC]
;	call apiw.set_bkmode

;	mov rdx,[hColInactText]
;	cmp [.pnl.active],FALSE
;	jz	@f
;	mov rdx,[hColActText]
;@@:
;	mov rcx,[.hCompDC]
;	call apiw.set_txtcol
;;@break
;	mov rdx,rsp;[.pnl.uzCapt]
;;	test rdx,rdx
;;	jz	@f
;;	mov cl,[.pnl.cptsCapt]
;;	test cl,cl
;;	jz	@f

;	mov r10,DT_LEFT or \
;		DT_VCENTER or \
;		DT_NOCLIP or \
;		DT_SINGLELINE	or \
;		DT_END_ELLIPSIS
;	lea r9,[.rc_text]
;	or r8,-1
;	mov rcx,[.hCompDC]
;	call apiw.drawtext
;@@:

;	mov eax,[.rc_capt+RECT.right]
;	dec eax
;	mov [.rc_capt+RECT.right],eax
;	sub ax,[cx_smsize]
;	mov [.rc_capt+RECT.left],eax
;	mov [.rc_capt+RECT.top],1
;	sub [.rc_capt+RECT.bottom],1

;	xor r11,r11
;	lea r10,[.rc_capt]
;	mov r9,CBS_NORMAL
;	mov r8,WP_CLOSEBUTTON
;	mov rdx,[.hCompDC]
;	mov rcx,[hThmWin]
;	call apiw.th_drawbkg

;	mov eax,[.rc_capt+RECT.left]
;	dec eax
;	mov [.rc_capt+RECT.right],eax
;	sub ax,[cx_smsize]
;	mov [.rc_capt+RECT.left],eax

;	xor r11,r11
;	lea r10,[.rc_capt]
;	mov r9,HBS_NORMAL
;	mov r8,WP_HELPBUTTON
;	mov rdx,[.hCompDC]
;	mov rcx,[hThmWin]
;	call apiw.th_drawbkg
;	add rsp,110h
;	ret 0


;	;*----------------------------------------------------------
;	;|                  PANEL.WM_LBUTTONUP
;	;*----------------------------------------------------------
;.wm_lbutup_split:
;	cmp [fSplitting],FALSE
;	jz	.ret0
;	
;	mov r9,2
;	lea r8,[rc_shadow]
;	mov rdx,[hMain]
;	mov rcx,0
;	call apiw.map_wpt

;;	mov rax,[rc_shadow]
;;	mov [.pnl.wrc],rax
;;	mov rax,[rc_shadow+8]
;;	mov [.pnl.wrc+8],rax

;;	lea rdx,[rc_shadow]
;;	mov rcx,[hMain]
;;	call apiw.scr2cli


;	call shadow.hide
;	call apiw.rel_capt

;	mov r8,[rc_shadow+8]
;	mov rdx,[rc_shadow]
;	call art.cout2XX

;	mov r11,TRUE
;	mov r10d,[rc_shadow.bottom]
;	sub r10d,[rc_shadow.top]
;	mov r9d,[rc_shadow.right]
;	sub r9d,[rc_shadow.left]
;	mov r8d,[rc_shadow.top]
;	mov edx,[rc_shadow.left]
;	mov rcx,[.hwnd]
;	call apiw.movewin


;;	mov eax,SWP_NOZORDER or \
;;		SWP_NOSENDCHANGING
;;	mov r11d,[rc_shadow.bottom]
;;	sub r11d,[rc_shadow.top]
;;	mov r10d,[rc_shadow.right]
;;	sub r10d,[rc_shadow.left]
;;	mov r9d,[rc_shadow.top]
;;	mov r8d,[rc_shadow.left]
;;	mov rdx,HWND_TOP
;;	mov rcx,[.hwnd];[.pnl.hwnd]
;;	call apiw.set_wpos

;;	mov rax,[rc_shadow]
;;	mov [.pnl.wrc],rax
;;	mov rax,[rc_shadow+8]
;;	mov [.pnl.wrc+8],rax
;;	mov rdx,orc
;;	mov rcx,[hMain]
;;	call apiw.get_clirect

;	mov rdx,orc
;	mov rcx,[hMain]
;	call apiw.get_clirect
;	
;	mov rcx,orc
;	call dock64.resize


;;	call shadow.hide
;;	call apiw.rel_capt

;	mov [fSplitting],FALSE
;	mov [fMoving],FALSE
;	jmp	.ret0

;.wm_lbutup:
;	call .get_structs
;	jz	.ret0

;	cmp [fMoving],FALSE
;	jz	.wm_lbutup_split

;	call apiw.rel_capt
;	mov [fMoving],FALSE

;	cmp [fShadowing],FALSE
;	jz	.wm_lbutup_release_float
;	mov [fShadowing],FALSE

;	mov al,[cside]
;	mov [.pnl.alignment],al
;	mov rcx,[pTarget]
;	test rcx,rcx
;	jz	.wm_lbutup_hide_shadow

;	call dock64.lo_set

;	mov r8d,CHILD_STYLE
;	mov [.pnl.style],r8d
;	mov rcx,[.hwnd]
;	call apiw.set_wlstyle

;	or [.pnl.type],FLOAT_PANEL
;	xor [.pnl.type],FLOAT_PANEL
;	or [.pnl.type],CHILD_PANEL
;	mov [.pnl.ttype],0	

;	mov rdx,[hMain]
;	mov rcx,[.hwnd]
;	call apiw.set_parent

;	lea rdx,[rc_shadow]
;	mov rcx,[hMain]
;	call apiw.scr2cli

;	mov r11,TRUE
;	mov r10d,[rc_shadow.bottom]
;	mov r9d,[rc_shadow.right]
;	mov r8d,[rc_shadow.top]
;	mov edx,[rc_shadow.left]
;	mov rcx,[.hwnd]
;	call apiw.movewin

;	mov rdx,orc
;	mov rcx,[hMain]
;	call apiw.get_clirect

;	mov rdx,orc
;	mov rcx,orc;maindock
;	call dock64.resize

;.wm_lbutup_hide_shadow:
;	call shadow.hide
;	jmp	.ret0

;.wm_lbutup_release_float:
;;	or [.pnl.type],FLOAT_PANEL
;	mov [.pnl.ttype],0
;	mov eax,[.pnl.crc.right]
;	mov [.pnl.float_cx],eax
;	mov eax,[.pnl.crc.bottom]
;	mov [.pnl.float_cy],eax
;	jmp	.ret0


;	;*----------------------------------------------------------
;	;|                 WM_MOUSEMOVE (PANEL)
;	;*----------------------------------------------------------

;.wm_mmove_split:
;	cmp [fSplitting],TRUE
;	jz	.wm_mmove_splitA

;	mov rcx,[.lparam]
;	call dock64.get_cursor
;	call apiw.set_curs

;;	mov rcx,[.pnl.hwnd]
;;	call apiw.set_focus

;	jmp	.ret0

;.wm_mmove_splitA:
;	mov r9d,[.pt+POINT.y]
;	mov r8d,[.pt+POINT.x]
;	mov rdx,rc_shadow
;	mov rcx,[hShadow]
;	call apiw.get_winrect
;	
;	;--- case align left
;	lea rdx,[.pt]
;	lea rcx,[.rc]
;	call dock64.size_splitrect

;	mov r11,TRUE
;	mov r10d,[.rc+RECT.bottom]
;	mov r9d,[.rc+RECT.right]
;	mov r8d,[.rc+RECT.top]
;	mov edx,[.rc+RECT.left]
;	mov rcx,[hShadow]
;	call apiw.movewin
;	jmp	.ret0


;.wm_mmove:
;	lea rcx,[.pt]
;	call apiw.get_curspos

;	call .get_structs
;	jz	.ret0

;	mov rax,qword[.pt]
;	mov qword[.ptwin],rax

;	cmp [fMoving],FALSE
;	jz	.wm_mmove_split

;	;mov [fMoving],TRUE

;	mov r9,1
;	lea r8,[.ptwin]
;	mov rdx,[hMain]
;	mov rcx,0
;	call apiw.map_wpt

;	sub rsp,20h
;	mov r8,CWP_SKIPTRANSPARENT
;	mov rdx,qword[.ptwin]
;	mov rcx,[hMain]
;	call [ChildWindowFromPointEx]
;	add rsp,20h

;	test rax,rax
;	jz	.wm_mmove_no_target
;	cmp rax,[hMain]
;	jnz	.wm_mmove_child

;	mov rax,[src+8]
;	mov [rc_shadow+8],rax
;	mov rax,[src]
;	mov [rc_shadow],rax
;	sub [rc_shadow+8],rax
;	mov rdi,maindock
;	jmp	.wm_mmove_client

;.wm_mmove_child:
;	mov rcx,rax
;	call apiw.get_wldata

;test rax,rax
;jz .wm_mmove_no_target

;	mov rdi,rax
;	lea rcx,[rax+PNL.wrc]
;	mov rax,[rcx]
;	mov [rc_shadow],rax
;	mov rax,[rcx+8]
;	mov [rc_shadow+8],rax

;.wm_mmove_client:
;	mov r9,1
;	lea r8,[rc_shadow]
;	mov rdx,0
;	mov rcx,[hMain]
;	call apiw.map_wpt

;;	push rax
;	mov r9d,[.pt+POINT.y]
;	mov r8d,[.pt+POINT.x]
;	call dock64.get_side

;;	mov dl,al
;;	mov cl,[fExclude]

;;	push rax
;;	movzx r8,[fExclude]
;;	movzx rdx,al
;;	call art.cout2XX
;;	pop rax

;	test rax,rax
;	jz	.wm_mmove_no_target
;	cmp al,[fExclude]
;	jz .wm_mmove_no_target
;	test al,[fExclude]
;	jnz .wm_mmove_no_target

;	mov rsi,rax
;	call shadow.set_side

;	;--- flag is shadowing
;	cmp [fShadowing],TRUE
;	jz	.wm_mmove_target
;	jmp	.wm_mmove_shadow

;.wm_mmove_target:
;	cmp rdi,[pTarget]
;	jnz	.wm_mmove_shadow
;	cmp [cside],sil
;	jz	.wm_mmove_panel

;.wm_mmove_shadow:
;	mov [fShadowing],TRUE
;	mov [pTarget],rdi
;	mov [cside],sil

;	mov r11,TRUE
;	mov r10d,[rc_shadow.bottom]
;	mov r9d,[rc_shadow.right]
;	mov r8d,[rc_shadow.top]
;	mov edx,[rc_shadow.left]
;	mov rcx,[hShadow]
;	call apiw.movewin
;	
;	;call shadow.animate_show
;	call shadow.show
;	jmp	.wm_mmove_panel

;.wm_mmove_no_target:
;	mov [cside],FALSE
;	mov [fShadowing],FALSE
;	call shadow.hide
;	mov [pTarget],FALSE

;.wm_mmove_panel:
;	mov eax,[pt_delta.x]
;	sub [.pt+POINT.x],eax
;	mov eax,[pt_delta.y]
;	sub [.pt+POINT.y],eax

;	mov rcx,SWP_NOSIZE
;	xor rdx,rdx
;	xor rax,rax

;	test [.pnl.ttype],FLOAT_PANEL
;	jnz	.wm_mmove_panelA

;	lea rcx,[.ptwin]
;	call apiw.get_curspos

;	mov eax,[.pnl.float_cx]
;	mov ecx,eax
;	shr ecx,1
;	sub [.ptwin+POINT.x],ecx
;	movzx ecx,[cy_caption]
;	shr ecx,1
;	sub [.ptwin+POINT.y],ecx
;;	movzx rdx,[.pnl.cy]

;	mov rax,[.ptwin]
;	mov [.pt],rax
;	xor rcx,rcx
;	mov edx,[.pnl.float_cy]
;	mov eax,[.pnl.float_cx]

;.wm_mmove_panelA:
;	mov r10,rax
;	mov r11,rdx
;	mov eax,ecx
;	mov r9d,[.pt+POINT.y]
;	mov r8d,[.pt+POINT.x]
;	mov rdx,HWND_TOP
;	mov rcx,[.pnl.hwnd]
;	call apiw.set_wpos
;	jmp	.ret0

