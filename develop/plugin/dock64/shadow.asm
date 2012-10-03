  
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

shadow:

	;*----------------------------------------------------------
	;|                  SHADOW.
	;*----------------------------------------------------------
	virtual at rbx
		.pnl PNL
	end virtual

	virtual at rsi
		.mdl MDL
	end virtual

	;*----------------------------------------------------------
	;|                  SHADOW.WPROC
	;*----------------------------------------------------------

.proc:
	push rbp
	mov rbp,rsp
	and rsp,-16

	cmp rdx,WM_CREATE
	jz	.wm_create
	cmp rdx,WM_DESTROY
	jz	.wm_destroy
	jmp	.defwndproc

.wm_destroy:
	jmp	.ret0

.wm_create:
	jmp	.ret0

.ret0:
	xor rax,rax
	jmp	.exit

.ret1:
	xor rax,rax	
	inc eax
	jmp	.exit

.defwndproc:
	sub rsp,20h
;	mov r9,[.lparam]
;	mov r8,[.wparam]
;	mov rdx,[.msg]
;	mov rcx,[.hwnd]
	call [DefWindowProcW]
;	add rsp,20h
.exit:
	mov rsp,rbp
	pop rbp
	ret 0


.show:
	mov rdx,SW_SHOW
	jmp	.showshow

.hide:
	mov rdx,SW_HIDE
	jmp	.showshow

.showshow:
	;--- in RBX HINTSTRUCT
	;--- in RDX flag
	mov rcx,[.mdl.hShadow]
	jmp	apiw.show

.animate_show:
	mov r8,AW_BLEND
	mov rdx,80
	mov rcx,[.mdl.hShadow]
	jmp apiw.animate


	;/----------------------------------------------------------
	;|                  by F_SPLIT on shared panel
	;\----------------------------------------------------------
.split_sharc:
	;--- in RCX pt
	;--- (in RBX PNL)
	;--- (in RSI MDL)
	;--- RET RAX 0,packed rect
	push rdi
	push r12
	push r13
	push r14
	push r15

	xor eax,eax
	sub rsp,\
		sizeof.RECT*2
	mov r12,rcx

	mov r10d,\
		[.mdl.shadrc.right]
	sub r10d,\
		[.mdl.shadrc.left]
	jle	.split_sharcE
	mov r11d,\
		[.mdl.shadrc.bottom]
	sub r11d,\
		[.mdl.shadrc.top]
	jle	.split_rcE

	mov rax,[.mdl.shadrc]
	mov [rsp],rax
	mov rax,[.mdl.shadrc+8]
	mov [rsp+8],rax
	
	mov rcx,rbx
	call dock64.get_sfisha
	mov r13,r8
;	movzx edi,[r8+PNL.ratio]
;	movzx edi,[rax+PNL.ratio]
;	mov r13,rax
;	mov r15,r8

	lea rdx,[rsp+16]
	mov rcx,[r13+PNL.hwnd]
	call apiw.get_winrect
	
;	movzx r14,[cy_wmin]
;	add r14d,[rsp+16+RECT.top]

;	cmp r13,r15
;	jz	.split_sharcA
;	mov r15,[r13+PNL.share]
;	xor edi,edi

;.split_sharcA1:
;	test r15,r15
;	jz	.split_sharcA
;;movzx eax,[r15+PNL.ratio]
;;mov edi,eax
;	lea rdx,[rsp+16]
;	mov rcx,[r15+PNL.hwnd]
;	call apiw.get_winrect

;	mov eax,[rsp+16+RECT.bottom]
;	sub eax,[rsp+16+RECT.top]
;	add r14,rax

;;movzx r14,[cy_wmin]
;;add r14d,[rsp+16+RECT.top]
;;movzx edi,[r15+PNL.ratio]


;	mov r15,[r15+PNL.share]
;	jmp	.split_sharcA1
	
	
;	movzx r8,[cx_wmin]	
;	movzx r9,[cy_wmin]

.split_sharcA:
	mov al,\
		[.pnl.alignment]
	cmp al,ALIGN_LEFT
	jz	.split_sharcLX
;	cmp al,ALIGN_RIGHT
;	jz	.split_sharcLX

	jmp	.split_sharcE

.split_sharcLX:
	movzx rax,[cy_wmin]
	add eax,[rsp+16+RECT.top]
	shr r12,32
	cmp r12d,eax
	jb	.split_sharcE
	movzx r9,[cy_wmin]
	mov eax,[rsp+RECT.bottom]
	sub rax,r9
	cmp r12d,eax
	jae	.split_sharcE
	mov [rsp+RECT.top],r12d

;	mov ecx,[rsp+16+RECT.bottom]
;	sub ecx,[rsp+16+RECT.top]

;	movzx r8,[r13+PNL.ratio]
;	movzx r9,[.pnl.ratio]
;		
;	mov rax,r8	;--- old ratio
;	mov edx,[rsp+16+RECT.top]
;	add edx,ecx
;	sub edx,r12d
;	mul edx
;	xor edx,edx
;	div ecx
;	mov [r13+PNL.ratio],al

;	add r9l,r8l
;	sub r9l,al
;	mov [.pnl.ratio],r9l

;	movzx r8,[.pnl.ratio]
;	movzx rdx,[r13+PNL.ratio]
;	call art.cout2XX

;	movzx r9,[.pnl.ratio]
;	mov r8,rax


;	add r8,r9
;	mul edx
;	xor edx,edx
;	div ecx
;	sub r8l,al
;	mov [.pnl.ratio],r8l
	
;	
;	mov eax,[rsp+RECT.bottom]
;	sub eax,r12d
;	shl eax,8
;	mov ecx,[r13+PNL.tot_ssize]
;	xor edx,edx
;	div ecx
;	mov cl,[.pnl.ratio]
;	mov [.pnl.ratio],al
;	sub cl,al
;	mov [r13+PNL.ratio],cl


.split_sharcE:
	@rect2reg rax,rsp
	add rsp,\
		sizeof.RECT*2
	pop r15
	pop r14
	pop r13
	pop r12
	pop rdi
	ret 0

	;/----------------------------------------------------------
	;|                  split_rc by F_SPLIT
	;\----------------------------------------------------------

.split_rc:
	;--- in RCX pt
	;--- (in RBX PNL)
	;--- (in RSI MDL)
	;--- RET RAX 0,packed rect
	
	xor eax,eax

	sub rsp,\
		sizeof.RECT*2
	mov [rsp],rax
	mov [rsp+8],rax

	mov r10d,[.mdl.shadrc.right]
	sub r10d,[.mdl.shadrc.left]
	jle	.split_rcE

	mov r11d,[.mdl.shadrc.bottom]
	sub r11d,[.mdl.shadrc.top]
	jle	.split_rcE

	movzx r8,[cx_wmin]	
	movzx r9,[cy_wmin]

	mov rax,[.mdl.shadrc]
	mov [rsp],rax
	mov rax,[.mdl.shadrc+8]
	mov [rsp+8],rax
	
	mov al,[.pnl.alignment]
	
	cmp al,ALIGN_LEFT
	jz	.split_rcLX
	cmp al,ALIGN_RIGHT
	jz	.split_rcRX

	shr rcx,32
	cmp al,ALIGN_TOP
	jz	.split_rcUP
	cmp al,ALIGN_BOTTOM
	jz	.split_rcDW
	jmp	.split_rcE

	;---	slipt ALIGN_BOTTOM ----------
.split_rcDW:
	mov eax,[.mdl.shadrc.bottom]
	sub eax,r9d
	sub eax,r9d
	jle	.split_rcE

	cmp ecx,eax
	jae	.split_rcE

	mov eax,[.mdl.src.top]
	test eax,eax
	jnz	.split_rcDW1
	mov eax,[.mdl.crc.top]
	
.split_rcDW1:
	add eax,r9d
	add eax,r9d
	cmp ecx,eax
	jbe .split_rcE
	mov [rsp+RECT.top],ecx
	jmp .split_rcD

	;---	slipt ALIGN_TOP -------------
.split_rcUP:
	mov eax,[.mdl.shadrc.top]
	add eax,r9d
	add eax,r9d
	cmp ecx,eax
	jbe	.split_rcE

	mov eax,[.mdl.src.bottom]
	sub eax,r9d
	sub eax,r9d
	jg .split_rcUP1	

	mov eax,[.mdl.crc.bottom]
	sub eax,r9d
	sub eax,r9d
	jle .split_rcE

.split_rcUP1:
	cmp ecx,eax
	jae	.split_rcE
	mov [rsp+RECT.bottom],ecx
	jmp .split_rcD

	;---	slipt ALIGN_RIGHT -------------
.split_rcRX:
	mov eax,[.mdl.shadrc.right]
	sub eax,r8d
	jle	.split_rcE

	cmp ecx,eax
	jae	.split_rcE

	mov rax,[.mdl.src]
	test rax,rax
	jnz	.split_rcRX1
	mov rax,[.mdl.crc]
	
.split_rcRX1:
	add eax,r8d
	cmp ecx,eax
	jbe .split_rcE
	mov [rsp+RECT.left],ecx
	jmp .split_rcD


	;---	slipt ALIGN_LEFT -------------
.split_rcLX:
	mov eax,r8d
	add eax,[rsp+RECT.left]
	cmp ecx,eax
	jbe	.split_rcE

	mov rax,[.mdl.src+8]
	sub eax,r8d
	;sub eax,r8d
	jg .split_rcLX1	

	mov rax,[.mdl.crc+8]
	sub eax,r8d
	;sub eax,r8d
	jle .split_rcE

.split_rcLX1:
	cmp ecx,eax
	jae	.split_rcE
	mov [rsp+RECT.right],ecx

.split_rcD:
	mov al,[.pnl.alignment]
	mov ah,[.pnl.type]
	cmp al,ALIGN_CLIENT
	jz .split_rcE

	and ah,\
		SHA_FI or\
		SHA_PA

	test ah,ah
	jz .split_rcE

	mov rcx,rbx
	call dock64.get_sfisha
	mov r8d,\
		[rax+PNL.tot_ssize]

	lea rdx,[rsp+16]
	mov rcx,[rax+PNL.hwnd]
	push r8
	call apiw.get_winrect
	pop rdx
	mov cl,\
		[.pnl.alignment]
	lea r9,\
		[rsp+RECT.bottom]
	and cl,ALIGN_V
	test cl,cl
	jnz	.split_rcD1
	lea r9,\
		[rsp+RECT.right]

.split_rcD1:	
	mov [r9],edx

	mov eax,[rsp+16+RECT.top]
	add [r9],eax
	mov [rsp+RECT.top],eax

.split_rcE:
	@rect2reg rax,rsp
	add rsp,\
		sizeof.RECT*2
	ret 0

;	;/----------------------------------------------------------
;	;|                  split_rc by F_SPLIT
;	;\----------------------------------------------------------

;.split_rc:
;	;--- in RCX pt
;	;--- (in RBX PNL)
;	;--- (in RSI MDL)
;	;--- RET RAX 0,packed rect
;	xor eax,eax
;	sub rsp,\
;		sizeof.RECT*2
;	mov [rsp],rax
;	mov [rsp+8],rax

;	mov r10d,\
;		[.mdl.shadrc.right]
;	sub r10d,\
;		[.mdl.shadrc.left]
;	jle	.split_rcE
;	mov r11d,\
;		[.mdl.shadrc.bottom]
;	sub r11d,\
;		[.mdl.shadrc.top]
;	jle	.split_rcE

;	movzx r8,[cx_wmin]	
;	movzx r9,[cy_wmin]

;	mov rax,[.mdl.shadrc]
;	mov [rsp],rax
;	mov rax,[.mdl.shadrc+8]
;	mov [rsp+8],rax
;	
;	mov al,\
;		[.pnl.alignment]
;	
;	cmp al,ALIGN_LEFT
;	jz	.split_rcLX
;	cmp al,ALIGN_RIGHT
;	jz	.split_rcRX

;	shr rcx,32
;	cmp al,ALIGN_TOP
;	jz	.split_rcUP
;	cmp al,ALIGN_BOTTOM
;	jz	.split_rcDW
;	jmp	.split_rcE

;	;---	slipt ALIGN_BOTTOM ----------
;.split_rcDW:
;	mov eax,[.mdl.shadrc.bottom]
;	sub eax,r9d
;	sub eax,r9d
;	jle	.split_rcE

;	cmp ecx,eax
;	jae	.split_rcE

;	mov eax,[.mdl.src.top]
;	test eax,eax
;	jnz	.split_rcDW1
;	mov eax,[.mdl.crc.top]
;	
;.split_rcDW1:
;	add eax,r9d
;	add eax,r9d
;	cmp ecx,eax
;	jbe .split_rcE
;	mov [rsp+RECT.top],ecx
;	jmp .split_rcD

;	;---	slipt ALIGN_TOP -------------
;.split_rcUP:
;	mov eax,[.mdl.shadrc.top]
;	add eax,r9d
;	add eax,r9d
;	cmp ecx,eax
;	jbe	.split_rcE

;	mov eax,[.mdl.src.bottom]
;	sub eax,r9d
;	sub eax,r9d
;	jg .split_rcUP1	

;	mov eax,[.mdl.crc.bottom]
;	sub eax,r9d
;	sub eax,r9d
;	jle .split_rcE

;.split_rcUP1:
;	cmp ecx,eax
;	jae	.split_rcE
;	mov [rsp+RECT.bottom],ecx
;	jmp .split_rcD

;	;---	slipt ALIGN_RIGHT -------------
;.split_rcRX:
;	mov eax,[.mdl.shadrc.right]
;	sub eax,r8d
;	jle	.split_rcE

;	cmp ecx,eax
;	jae	.split_rcE

;	mov rax,[.mdl.src]
;	test rax,rax
;	jnz	.split_rcRX1
;	mov rax,[.mdl.crc]
;	
;.split_rcRX1:
;	add eax,r8d
;	cmp ecx,eax
;	jbe .split_rcE
;	mov [rsp+RECT.left],ecx
;	jmp .split_rcD


;	;---	slipt ALIGN_LEFT -------------
;.split_rcLX:
;	mov eax,r8d
;	add eax,[rsp+RECT.left]
;	cmp ecx,eax
;	jbe	.split_rcE

;	mov rax,[.mdl.src+8]
;	sub eax,r8d
;	;sub eax,r8d
;	jg .split_rcLX1	

;	mov rax,[.mdl.crc+8]
;	sub eax,r8d
;	;sub eax,r8d
;	jle .split_rcE

;.split_rcLX1:
;	cmp ecx,eax
;	jae	.split_rcE
;	mov [rsp+RECT.right],ecx

;.split_rcD:
;	mov al,[.pnl.alignment]
;	mov ah,[.pnl.type]
;	cmp al,ALIGN_CLIENT
;	jz .split_rcE

;	and ah,\
;		SHA_FI or\
;		SHA_PA

;	test ah,ah
;	jz .split_rcE

;	mov rcx,rbx
;	call dock64.get_sfisha
;	mov r8d,\
;		[rax+PNL.tot_ssize]

;	lea rdx,[rsp+16]
;	mov rcx,[rax+PNL.hwnd]
;	push r8
;	call apiw.get_winrect
;	pop rdx
;	mov cl,\
;		[.pnl.alignment]
;	lea r9,\
;		[rsp+RECT.bottom]
;	and cl,ALIGN_V
;	test cl,cl
;	jnz	.split_rcD1
;	lea r9,\
;		[rsp+RECT.right]

;.split_rcD1:	
;	mov [r9],edx

;	mov eax,[rsp+16+RECT.top]
;	add [r9],eax
;	mov [rsp+RECT.top],eax

;.split_rcE:
;	@rect2reg rax,rsp
;	add rsp,\
;		sizeof.RECT*2
;	ret 0

	;/----------------------------------------------------------
	;|                  size_rc by F_SHADOW-ing
	;\----------------------------------------------------------
.size_rc:
	;--- modifies MDL.shadrc according to policy
	;--- IN MDL.cside required alignment
	;--- (in RBX our float)
	;--- (in RSI MDL)
	sub rsp,\
		sizeof.RECT*2

	lea rdx,[rsp+16]
	mov rcx,[.pnl.hwnd]
	call apiw.get_winrect
	lea r11,[rsp+16]

.size_rcA:
	movzx eax,[.mdl.cside]

	;--- in RCX available cx,cy
	mov rcx,[.mdl.shadrc]
	mov [rsp],rcx

	mov rcx,[.mdl.shadrc+8]
	mov [rsp+8],rcx
	sub rcx,[rsp]

	mov r9,rcx
	shr ecx,1				;--- default half the dest cx/cy
	movzx edx,[cx_wmin]

	mov r8d,[.mdl.shadrc.right]
	sub r8d,[.mdl.shadrc.left]

	mov r10d,[r11+RECT.right]
	sub r10d,[r11+RECT.left]

	shr r8,1
	cmp r8,rdx		 ;--- cmp 1/2 AVAIL,MIN
	cmovbe r8,rdx	 ;--- set AVAIL = MIN if 1/2 AVAIL <= MIN
	cmp r10,r8		 ;--- cmp OUR,AVAIL
	cmovae r10,r8	 ;--- set OUR = AVAIL if OUR >= AVAIL

;	cmp r10,rdx		 ;--- cmp OUR,MIN
;	cmovb r10,rdx	 ;--- set OUR to MIN if OUR < MIN
;	cmp r8,rdx		 ;--- cmp AVAIL,MIN
;	cmovb r8,rdx	 ;--- set AVAIL to MIN if AVAIL < MIN
;	cmp r10,r8		 ;--- cmp OUR,AVAIL
;	cmovbe rcx,r10 ;--- set DEF (=1/2 AVAIL) for OUR

	cmp al,ALIGN_LEFT
	jz .size_rcLX
	cmp al,ALIGN_RIGHT
	jz	.size_rcRX

	mov rcx,r9
	shr rcx,33
	movzx edx,[cy_wmin]	;--- constrints to 2 * cy_wmin
	add edx,edx

	mov r8d,[.mdl.shadrc.bottom]
	sub r8d,[.mdl.shadrc.top]
	mov r10d,[r11+RECT.bottom]
	sub r10d,[r11+RECT.top]

	shr r8,1
	cmp r8,rdx		 ;--- cmp 1/2 AVAIL,MIN
	cmovbe r8,rdx	 ;--- set AVAIL = MIN if 1/2 AVAIL <= MIN
	cmp r10,r8		 ;--- cmp OUR,AVAIL
	cmovae r10,r8	 ;--- set OUR = AVAIL if OUR >= AVAIL

	cmp al,ALIGN_TOP
	jz	.size_rcUP
	cmp al,ALIGN_BOTTOM
	jz	.size_rcDW
	jmp .size_rcE

.size_rcLX:
	mov eax,[rsp+RECT.left]
	add eax,ecx
	mov [rsp+RECT.right],eax
	jmp	.size_rcE

.size_rcRX:
	mov eax,\
		[rsp+RECT.right]
	sub eax,ecx
	mov [rsp+RECT.left],eax
	jmp	.size_rcE

.size_rcUP:
	mov eax,\
		[rsp+RECT.top]
	add eax,ecx
	mov [rsp+RECT.bottom],eax
	jmp	.size_rcE

.size_rcDW:
	mov eax,\
		[rsp+RECT.bottom]
	sub eax,ecx
	mov [rsp+RECT.top],eax

.size_rcE:
;	mov r8,[rsp+8]
;	mov rdx,[rsp]
;	call art.cout2XX

	mov rax,[rsp]
	mov [.mdl.shadrc],rax
	mov rax,[rsp+8]
	mov [.mdl.shadrc+8],rax
	add rsp,sizeof.RECT*2
	ret 0

