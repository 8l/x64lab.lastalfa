  
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

dock64:
	virtual at rbx
		.pnl PNL
	end virtual

	virtual at rcx	;--- our panel
		.our PNL
	end virtual

	virtual at rdx	;--- target panel
		.tgt PNL
	end virtual

	virtual at rcx
		.wcx WNDCLASSEXW
	end virtual

	virtual at rsi
		.mdl MDL
	end virtual

	;/----------------------------------------------------------
	;|                  DOCKMAN.ATTACH
	;\----------------------------------------------------------

.attach:
	;--- .hInstance RCX
	;--- .fdwReason RDX
	;--- .reserved R8
	mov [hInstance],rcx
	xor rdi,rdi
	mov rsi,apiw.loadcurs
	mov rbx,rcx
	
	mov edx,IDC_SIZENS
	xor ecx,ecx
	call rsi
	mov [hVCurs],rax

	mov edx,IDC_SIZEWE
	xor ecx,ecx
	call rsi
	mov [hHCurs],rax

	mov edx,IDC_ARROW
	xor ecx,ecx
	call rsi
	mov [hDCurs],rax
	mov rdi,rax

	mov rsi,\
		apiw.create_sbrush

	;2)---  register shadow class
	mov ecx,0CDCB0Bh
	call rsi
	xor edx,edx

	sub rsp,\
		sizea16.WNDCLASSEXW
	mov rcx,rsp
	mov [.wcx.hbrBackground],rax
	mov [.wcx.cbSize],\
		sizeof.WNDCLASSEXW
	mov [.wcx.lpszClassName],\
		uzShadowClass
	mov [.wcx.hIconSm],rdx
	mov [.wcx.lpszMenuName],rdx
	mov [.wcx.hCursor],rdi
	mov [.wcx.hIcon],rdx

	mov r8,[hInstance]
	mov [.wcx.hInstance],r8
;	mov [.wcx.hInstance],rdx

	mov [.wcx.cbWndExtra],edx
	mov [.wcx.cbClsExtra],edx
	mov [.wcx.lpfnWndProc],\
		shadow.proc
	mov [.wcx.style],\
		CS_BYTEALIGNCLIENT \
		or CS_BYTEALIGNWINDOW \
		or CS_GLOBALCLASS
	call apiw.regcls
	
	add rsp,\
		sizea16.WNDCLASSEXW
	test rax,rax
	jz	.err_attach
	mov [atom_shadow],ax

	;3)---  register panel class
	mov ecx,0E5E1E1h;0CCC5BAh
	call rsi
	mov [hBrPanel],rax

	xor edx,edx
	sub rsp,\
		sizea16.WNDCLASSEXW
	mov rcx,rsp
	mov [.wcx.hbrBackground],rdx
	mov [.wcx.cbSize],\
		sizeof.WNDCLASSEXW
	mov [.wcx.lpszClassName],\
		uzPanelClass
	mov [.wcx.hIconSm],rdx
	mov [.wcx.lpszMenuName],rdx
	mov [.wcx.hCursor],rdi
	mov [.wcx.hIcon],rdx
	mov [.wcx.hInstance],rdx
	mov [.wcx.cbWndExtra],8
	mov [.wcx.cbClsExtra],edx
	mov [.wcx.lpfnWndProc],\
		panel.proc
	mov [.wcx.style],\
		CS_BYTEALIGNCLIENT \
		or CS_BYTEALIGNWINDOW\
		or 0
	call apiw.regcls

	add rsp,\
		sizea16.WNDCLASSEXW
	test rax,rax
	jz	.err_attach
	
	mov [atom_panel],ax
	mov rsi,apiw.get_syscolbr

	mov ecx,\
		COLOR_ACTIVECAPTION	
	call rsi
	mov [hBrActCapt],rax

	mov ecx,\
		COLOR_INACTIVECAPTION	
	call rsi
	mov [hBrInactCapt],rax

	mov rsi,apiw.get_syscol

	mov ecx,\
		COLOR_CAPTIONTEXT	
	call rsi
	mov [hColActText],rax

	mov ecx,\
		COLOR_GRAYTEXT
	call rsi
	mov [hColInactText],rax
	jmp	.detachA

.err_attach:
	call .detach
	or rax,-1
	jmp	.detachB
	
.detach:
	mov rdi,apiw.unregcls
	xor edx,edx
	movzx ecx,[atom_shadow]
	call rdi

	xor edx,edx
	movzx ecx,[atom_panel]
	call rdi

.detachA:	
	xor rax,rax

.detachB:
	inc rax
	ret 0

	;/----------------------------------------------------------
	;|                  DOCK64.PANEL
	;\----------------------------------------------------------
.panel:
	;--- in RCX hDocker/hShare
	;--- in RDX flags: type/exclude/alignment
	;--- in R8:
  ;---   SHA_PA ---> ratio (0 -> 256)
  ;---   SHA_FI ---> cx,cy (0 -> 7FFh)
	;---   CHILD  ---> cx,cy (0 -> 7FFh)
  ;---   FLOAT  ---> packed rect
	;--- in R9 caption
	;--- RET RAX PNL
	;--- RET EDX pmc_id
	push rbp
	push rbx
	push rsi
	push r12
	push r13
	mov rbp,rsp
	and rsp,-16

	xor eax,eax
	xor ebx,ebx
	sub rsp,60h

	and edx,\
		ALIGN_ALL or\
		EXCLUDE_ALL or\
		FLAGS_ALL

	push r9
	mov rsi,rcx
	mov r12,rdx
	mov r13,r8
	
	mov ecx,\
		sizeof.PNL
	call art.a16malloc
	pop rdx
	test eax,eax
	jz	.panelE
	mov rbx,rax

	;--- set caption ---
	mov r8,rdx
	mov rcx,\
		uzPanelClass
	test edx,edx
	cmovz r8,rcx
	mov [rsp],r8

	;--- set MDL ------
	mov [.pnl.mdl],rsi
	mov [.pnl.tmp],rsi
	test [.mdl.type],\
		DOCKER
	jnz	@f
	mov rax,[rsi+\
		PNL.mdl]
	mov [.pnl.mdl],rax

@@:
	;--- set exclude/alignment
	mov rax,r12
	mov [.pnl.alignment],al
	mov [.pnl.exclude],ah

	;--- set type/rect -------
	shr eax,16
	mov [.pnl.type],al
	mov r8,\
		7FF'07FF'03FF'03FFh
	mov rcx,\
		0100'0100'0010'0010h
	test al,IS_FLO
	jz	@f

	;--- set RECT for float
	;and r13,r8
	test r13,r13
	cmovz r13,rcx
	@reg2rect .pnl.wrc,r13
	jmp .panelD

@@:
	and r8,1FFh
	test al,SHA_PA
	jz	@f

	;--- set aligned size for SHA_PA
	and r8,07Fh
	and r13,r8
	test r13,r13
	cmovz r13,r8
	mov [.pnl.ratio],r13l
	jmp .panelD

@@:
	and r13,r8
	mov cl,ah
	and cl,ALIGN_V
	test cl,ALIGN_V
	jz	@f
	mov [.pnl.wrc.right],r13d
	jmp	.panelD

@@:
	mov cl,ah
	and cl,ALIGN_H
	test cl,ALIGN_H
	jz	@f
	mov [.pnl.wrc.bottom],r13d
	jmp	.panelD

@@:
	mov [.pnl.wrc.right],r13d
	mov [.pnl.wrc.bottom],r13d

.panelD:
	mov r8,[rsp]
	mov r9d,CHILD_STYLE
	test al,IS_FLO
	jz	.panelD1
	mov r9d,FLOAT_STYLE

.panelD1:
	mov rsi,[.pnl.mdl]
	xor r10,r10

	mov [rsp+58h],rbx
	mov rax,[.mdl.hInst]
	mov [rsp+50h],rax
	mov [rsp+48h],r10

	mov rax,[.mdl.hwnd]
	mov [rsp+40h],rax

	mov eax,[.pnl.wrc.bottom]
	mov [rsp+38h],eax
	mov eax,[.pnl.wrc.right]
	mov [rsp+30h],eax
	mov eax,[.pnl.wrc.top]
	mov [rsp+28h],eax
	mov eax,[.pnl.wrc.left]
	mov [rsp+20h],eax

	mov rdx,uzPanelClass
	mov ecx,WS_EX_TOOLWINDOW\
		or WS_EX_TOPMOST
	call [CreateWindowExW]
	xor edx,edx
	test rax,rax
	jz	.panelF
	mov edx,[.pnl.id]
	jmp	.panelE
	
.panelF:
	mov rcx,rbx
	call art.a16free
	xor ebx,ebx

.panelE:
	mov rsp,rbp
	mov rax,rbx
	pop r13
	pop r12
	pop rsi
	pop rbx
	pop rbp
	ret 0

.save:
	;/----------------------------------------------------------
	;|                  DOCK64.SAVE
	;\----------------------------------------------------------
	;--- save to binary path+filename
	;--- in RCX hDocker
	;--- in RDX path+filename
	;--- RET 
	push rbx
	push rdi
	push rsi

	mov rdi,rdx
	xor ebx,ebx
	xor esi,esi

	call .order
	test eax,eax
	jz	.saveE
	mov rsi,rax	;--- malloc16

	mov ebx,ecx	;--- panels
	add ebx,edx	;--- floats
	inc ebx			;--- MDL

	mov rcx,rdi
	call art.fcreate_rw
	mov r8,rbx
	shl r8,6		;--- 64 sizeof.DOCKITEM
	xor ebx,ebx
	inc eax
	jz .saveF
	dec eax
	mov rbx,rax				;--- file handle

	mov rdx,rsi
	mov rcx,rax
	call art.fwrite

	mov rcx,rbx
	call art.fclose
	mov rbx,rax

.saveF:
	mov rcx,rsi
	call art.a16free
	
.saveE:
	mov rax,rbx
	pop rsi
	pop rdi
	pop rbx
	ret 0

	;/----------------------------------------------------------
	;|                  DOCK64.ORDER
	;\----------------------------------------------------------
.order:
	;--- query and return info by pmc_id
	;--- in RCX hDocker
	;--- RET RCX 0,panels 
	;--- RET RDX 0,floats
	;--- RET RAX mallocED pointer to DOCKITEMs
	;--- start floats DOCKITEM
	;--- panels
	push rbp
	push rbx
	push rdi
	push rsi
	push r12  ;--- num panels
	push r13	;--- num floats

	mov rbp,rsp
	and rsp,-16

	mov rsi,rcx
	xor r12,r12
	xor r13,r13
	xor edi,edi
	test rsi,rsi
	jz	.orderE

	movzx ecx,[.mdl.nslots]
	inc ecx
	shl ecx,6		;--- 64 sizeof.DOCKITEM
	sub rsp,rcx
	xor eax,eax
	mov rdi,rsp
	shr ecx,3
	rep stosq
	mov rdi,rsp

	mov [rdi+\
		DOCKITEM.id],16807

	movzx eax,\
		[.mdl.exclude]
	and al,EXC_ALL
	shl eax,8
	mov [rdi+\
		DOCKITEM.flags],eax
	;--- calc info,popcount etc.
	add rdi,\
		sizeof.DOCKITEM

	mov rbx,\
		[.mdl.floats]

.orderF:
	test ebx,ebx
	jz 	@f

	inc r13
	call .info_size
	;--- RET ECX id
	;--- RET EDX flags: type/exclude/alignment
	;--- RET R8: size info	
	mov [rdi+\
		DOCKITEM.id],ecx
	mov [rdi+\
		DOCKITEM.flags],edx
	mov [rdi+\
		DOCKITEM.pack_rc],r8
	add rdi,\
		sizeof.DOCKITEM
	mov rbx,[.pnl.next]
	jmp	.orderF

@@:
	mov rbx,\
		[.mdl.panels]

.orderP:
	test ebx,ebx
	jnz .orderP1

.orderM:
	;--- 
	movzx ecx,\
		[.mdl.nslots]
	inc ecx
	shl ecx,6		;--- 64 sizeof.DOCKITEM
	mov ebx,ecx
	call art.a16malloc
	xor edx,edx
	xor ecx,ecx
	test rax,rax
	jz	.orderE1

	mov rdi,rax
	mov ecx,ebx
	mov rdx,rax
	shr ecx,3
	mov rsi,rsp
	rep movsq
	mov rdi,rdx
	jmp	.orderE

.orderP1:
	inc r12
	call .info_size
	;--- RET ECX id
	;--- RET EDX flags: type/exclude/alignment
	;--- RET R8: size info	
	mov [rdi+\
		DOCKITEM.id],ecx
	mov [rdi+\
		DOCKITEM.flags],edx
	mov [rdi+\
		DOCKITEM.pack_rc],r8
	add rdi,\
		sizeof.DOCKITEM
	test [.pnl.type],\
		SHA_FI or SHA_PA
	jz	.orderP2
	push rbx

.orderS1:
	mov rbx,\
		[.pnl.share]
	test rbx,rbx
	jz	.orderS

	inc r12
	call .info_size
	;--- RET ECX id
	;--- RET EDX flags: type/exclude/alignment
	;--- RET R8: size info	
	mov [rdi+\
		DOCKITEM.id],ecx
	mov [rdi+\
		DOCKITEM.flags],edx
	mov [rdi+\
		DOCKITEM.pack_rc],r8
	add rdi,\
		sizeof.DOCKITEM
	jmp	.orderS1

.orderS:
	pop rbx

.orderP2:
	mov rbx,\
		[.pnl.next]
	jmp	.orderP

.orderE:
	mov rcx,r12
	mov rdx,r13
	mov rax,rdi

.orderE1:
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	
	;/----------------------------------------------------------
	;|                  DOCK64.INFO
	;\----------------------------------------------------------
.info:
	;--- query and return info by pmc_id
	;--- in RCX hDocker
	;--- in RDX id
	;--- RET RAX 0,PNL
	;--- RET RCX id
	;--- RET RDX flags: type/exclude/alignment
	;--- RET R8: size info
  ;---   SHA_PA ---> ratio (0 -> 256)
  ;---   SHA_FI ---> cx,cy (0 -> 7FFh)
	;---   CHILD  ---> cx,cy (0 -> 7FFh)
  ;---   FLOAT  ---> packed rect
	xor eax,eax
	test ecx,ecx
	jnz .infoA
	ret 0

.infoA:
	push rbx
	push rsi

	xchg rcx,rdx
	xor ebx,ebx
	mov rsi,rdx
	call .is_id
	mov rbx,rax
	test eax,eax
	jz	@f
	call .info_size
@@:
	mov rax,rbx
	pop rsi
	pop rbx
	ret 0


.info_size:
	;--- uses (RBX PNL)
	;--- uses (RSI MDL)
	;--- RET RCX id
	;--- RET RDX flags: type/exclude/alignment
	;--- RET R8: size info	
	sub rsp,\
		sizeof.RECT
	mov ecx,\
		[.pnl.id]
	movzx edx,\
		[.pnl.type]
	mov eax,edx
	shl rdx,16
	mov dh,\
		[.pnl.exclude]
	mov dl,\
		[.pnl.alignment]
	movzx r8d,\
		[.pnl.cxy]
	test al,\
		IS_FLO
	jz	@f
	mov r8,rsp
	push rcx
	push rdx

	mov rdx,r8
	mov rcx,[.pnl.hwnd]
	call apiw.get_winrect

	pop rdx
	pop rcx

	mov eax,[rsp+\
		RECT.top]
	sub [rsp+\
		RECT.bottom],eax
	mov eax,[rsp+\
		RECT.left]
	sub [rsp+\
		RECT.right],eax

	@rect2reg r8,rsp
	jmp	.info_sizeE
@@:
	test al,\
		SHA_PA
	jz	@f
	movzx r8d,\
		[.pnl.ratio]
	jmp	.info_sizeE
@@:
	mov r8,rsp
	push rcx
	push rdx

	mov rdx,r8
	mov rcx,[.pnl.hwnd]
	call apiw.get_winrect

	pop rdx
	pop rcx

	mov r8,[rsp+8]
	sub r8,[rsp]

	test dl,ALIGN_V
	jnz @f
	shr r8,32
@@:
	and r8d,r8d

.info_sizeE:
	add rsp,\
		sizeof.RECT
	ret 0


	;/----------------------------------------------------------
	;|                  DOCK64.BIND
	;\----------------------------------------------------------
.bind:
	;--- bind control to window
	;--- in RCX hDocker 
	;--- in RDX id
	;--- in R8X hControl
	;--- RET RAX PNL
	xor eax,eax
	test ecx,ecx
	jnz .bindA
	ret 0

.bindA:
	xchg rcx,rdx
	push rbx
	push rsi
	push r8
	
	mov rsi,rdx
	call .is_id
	mov rbx,rax
	pop rcx
	test eax,eax
	jz	.bindE

	mov [.pnl.hControl],rcx
	mov rdx,[.pnl.hwnd]
	call apiw.set_parent
	or [.pnl.type],\
		HAS_CO
	mov rax,rbx

.bindE:
	pop rsi
	pop rbx
	ret 0

	;/----------------------------------------------------------
	;|                  DOCK64.id2panel
	;\----------------------------------------------------------

.id2panel:
	;--- in RCX MDL
	;--- in RDX id
	;--- get panel from id
	mov r9,rsi
	xchg rcx,rdx
	mov rsi,rdx
	call .is_id
	xchg rsi,r9
	ret 0
	

.is_id:
	;--- in ECX id
	;--- (uses RSI MDL) RAX,RDX,R8
	;--- RET RAX 0,PNL
	;--- RET RCX id
	mov rdx,\
		[.mdl.floats]
	xor eax,eax
	test rdx,rdx
	jz	.is_idP

.is_idF:
	cmp ecx,[rdx+\
		PNL.id]
	jnz	.is_idF1

.is_idE:
	mov rax,rdx
	ret 0

.is_idF1:
	cmp rax,[rdx+\
		PNL.next]
	jz .is_idP

	mov rdx,[rdx+\
		PNL.next]
	jmp	.is_idF

.is_idP:
	mov rdx,\
		[.mdl.panels]

.is_idP0:
	test edx,edx
	jz .is_idE

.is_idP1:
	cmp ecx,[rdx+\
		PNL.id]
	jz .is_idE

	test [rdx+\
		PNL.type],\
	SHA_FI or SHA_PA
	jz	.is_idP2

	mov r8,[rdx+\
		PNL.share]

.is_idP3:
	test r8,r8
	jz	.is_idP2

	cmp ecx,[r8+\
		PNL.id]
	jnz	.is_idP4
	mov rax,r8
	ret

.is_idP4:
	mov r8,[r8+\
		PNL.share]
	jnz .is_idP3

.is_idP2:
	mov rdx,[rdx+\
		PNL.next]
	jmp	.is_idP0

	;/----------------------------------------------------------
	;|                  DOCK64.DISCARD
	;\----------------------------------------------------------
.discard:
	;--- in RCX mdl
	jmp	art.a16free


	;/----------------------------------------------------------
	;|                  DOCK64.LOAD
	;\----------------------------------------------------------
.load:
	;--- load binary path+filename
	;--- in RCX hwnd
	;--- in RDX hInstance
	;--- in R8 filename
	;--- RET RAX 0,MDL
	push rcx
	push rdx

	mov rcx,r8
	call art.fload
	mov r8,rax
	mov r9,rcx
	pop rdx
	test rax,rax
	pop rcx
	jnz @f
	ret 0
@@:
	push r8
	shr r9,6		;--- 64 sizeof.DOCKITEM
	call .loadmem
	xchg rcx,[rsp]
	xor edx,edx
	mov [rsp],rax
	call art.vfree
	pop rax
	ret 0

	;/----------------------------------------------------------
	;|                  DOCK64.LOAD_MEM
	;\----------------------------------------------------------
	
.loadmem:
	;--- load layout from memory struct of DOCKITEM
	;--- in RCX hwnd
	;--- in RDX hInstance
	;--- in R8 mem
	;--- in R9 num DOCKITEMS
	;--- RET RAX 0,MDL
	push rbx
	push rsi
	push r12
	push r13	;--- share first handle of shared panels

	mov rbx,r8
	xor esi,esi
	xor r13,r13
	mov r12,r9

	;--- check binary safety
	mov r8d,[rbx+\
		DOCKITEM.flags]
	call .init

	test rax,rax
	jz	.loadmemE
	mov rsi,rax
	jmp	.loadmemN

.loadmemA:
	mov rcx,rsi
	mov edx,[rbx+\
		DOCKITEM.flags]

	and edx,\
		FLAGS_ALL or \
		EXCLUDE_ALL or \
		ALIGN_ALL

	mov r8,[rbx+\
		DOCKITEM.pack_rc]
	xor r9,r9

	test edx,\
		SHARE_PANEL
	jz	.loadmemB
	
	test r13,r13
	jnz	.loadmemA1
	
	and edx,not (\
		FLOAT_PANEL or \	
		SHARE_PANEL or \	
		SHARE_FIRST )

	mov [rbx+\
		DOCKITEM.flags],edx

	jmp	.loadmemB

.loadmemA1:
	mov rcx,r13

.loadmemB:
	call .panel
	;--- in RCX hDocker/hShare
	;--- in RDX flags: type/exclude/alignment
	;--- in R8:
  ;---   SHA_PA ---> ratio (0 -> 256)
  ;---   SHA_FI ---> cx,cy (0 -> 7FFh)
	;---   CHILD  ---> cx,cy (0 -> 7FFh)
  ;---   FLOAT  ---> packed rect
	;--- in R9 caption
	mov edx,[rbx+\
		DOCKITEM.flags]
	test rax,rax
	jnz	.loadmemB1

	;--- all may happen. but without dock system
	;--- app cannot work -----------------------

	;--- TODO: check for already created panels
	;--- and destroy them
	mov rcx,rsi
	call .discard
	xor esi,esi
	jmp	.loadmemE

.loadmemB1:
	test edx,\
		SHARE_FIRST
	cmovnz r13,rax
	mov edx,[rbx+\
		DOCKITEM.id]
	mov [rax+PNL.id],edx
	mov [rbx+\
		DOCKITEM.rt_hPanel],rax
	
.loadmemN:
	add rbx,\
		sizeof.DOCKITEM
	dec r12
	jnz	.loadmemA
	
.loadmemE:
	mov rax,rsi
	pop r13
	pop r12
	pop rsi
	pop rbx
	ret 0


	;/----------------------------------------------------------
	;|                  DOCK64.INIT
	;\----------------------------------------------------------
.init:
	push rbx
	push rdi
	push rsi
	;--- in RCX hwnd
	;--- in RDX hInstance
	;--- in R8H exclude flags as EXCLUDE_*
	;--- RET RAX MDL

	mov rsi,r8
	mov rbx,rcx
	mov rdi,rdx

	mov ecx,\
		sizeof.MDL
	call art.a16malloc
	test rax,rax
	jz	.err_initA
	xchg rax,rsi

	mov [.mdl.type],DOCKER
	mov [.mdl.hInst],rdi
	and ah,EXC_ALL
	mov rcx,rdi
	mov [.mdl.exclude],ah
	mov [.mdl.hwnd],rbx

	xor eax,eax
	mov rdi,rsp
	and rsp,-16

;@break
	;2)--- create shadow window ----------------
	push rax
	push rcx
	push rax
	push rax ;---0

	push rax
	push rax
	push rax
	push rax

	mov r9,\
		WS_POPUP or \
		WS_VISIBLE or \
		WS_BORDER or \
		0 ;or \
;		WS_CAPTION or \
;		WS_SYSMENU

	mov r8,0;uzShadowClass
	mov rdx,uzShadowClass

	mov rcx,\
		WS_EX_LAYERED \
		or WS_EX_TRANSPARENT \
		or WS_EX_TOOLWINDOW\
		or 0;WS_EX_TOPMOST
		;0;WS_EX_NOPARENTNOTIFY	

;@break
	sub rsp,20h
	call [CreateWindowExW]
	mov rsp,rdi
	test rax,rax
	jnz	.initA

	mov rcx,rsi
	call .discard
	xor eax,eax
	jmp	.err_initA

.initA:
	mov [.mdl.hShadow],rax

	mov r9,LWA_ALPHA
	mov r8,128;64
	xor edx,edx
	mov rcx,rax
	call apiw.set_lwattr

	mov [.mdl.seed],16807

	call .get_setting
	mov rax,rsi

.err_initA:
	;--- err not enough mem -----------
	pop rsi
	pop rdi
	pop rbx
	ret 0

	;*----------------------------------------------------------
	;|       DOCK.GET_SETTING
	;*----------------------------------------------------------

.get_setting:
	;--- (in RSI MDL)
	push rdi
	mov rdi,apiw.get_sysmet

	mov ecx,SM_CXMIN
	call rdi
	mov [cx_wmin],al

	mov ecx,SM_CYMIN
	call rdi
	mov [cy_wmin],al

	mov ecx,\
		SM_CXFIXEDFRAME
	call rdi
	mov [cx_fxframe],al

	mov ecx,\
		SM_CYFIXEDFRAME
	call rdi
	mov [cy_fxframe],al

	mov ecx,\
		SM_CYCAPTION	
	call rdi
	mov [cy_caption],al

	mov ecx,\
		SM_CYBORDER	
	call rdi
	mov [cy_border],al

	mov ecx,\
		SM_CXBORDER	
	call rdi
	mov [cx_border],al

	mov ecx,\
		SM_CXSMICON
	call rdi
	mov [cx_smicon],al

	mov ecx,\
		SM_CYSMICON
	call rdi
	mov [cy_smicon],al

	mov ecx,\
		SM_CXSMSIZE
	call rdi
	mov [cx_smbsize],al

	mov ecx,\
		SM_CXEDGE
	call rdi
	mov [cx_edge],al

	mov ecx,\
		SM_CYEDGE
	call rdi
	mov [cy_edge],al

	mov rdi,apiw.th_open
	mov rdx,uzThmWinClass
	mov rcx,[.mdl.hwnd]
	call rdi
	mov [hThmWin],rax

	movzx eax,[cx_border]
	add al,[cx_edge]
	add al,[cx_fxframe]
	mov [.mdl.cx_grip],al
	mov [.mdl.cy_grip],al

	;	mov rdx,uzThRebarClass
	;	mov rcx,[hMain]
	;	call rdi
	;	mov [hThRebar],rax
	pop rdi
	ret 0

	;*----------------------------------------------------------
	;|       DOCK64.LO_DROP  (exclusion from the list)
	;*----------------------------------------------------------
.lo_drop:
	;--- IN RCX our PNL
	;--- (IN RSI MDL)
	xor eax,eax
	lea rdx,[.mdl.panels]
	mov r8,[.our.prev]
	mov r9,[.our.next]

	test [.our.type],IS_FLO
	jz	.lo_dropC
	lea rdx,[.mdl.floats]

.lo_dropF:
	cmp rcx,[rdx]
	jnz	@f
	mov [rdx],r9
	jmp	.lo_dropF1
@@:
	cmp rax,[rdx]
	jnz	.lo_dropF1
	mov [rdx],r9

.lo_dropF1:
	test r8,r8
	jz	.lo_dropF2
	mov [r8+PNL.next],r9

.lo_dropF2:
	test r9,r9
	jz	.lo_dropF3
	mov [r9+PNL.prev],r8

.lo_dropF3:
	and [.our.type],\
		not (SHA_PA or SHA_FI or IS_FLO )

	mov [.our.prev],rax
	mov [.our.next],rax
	ret 0

.lo_dropC:
	test [.our.type],SHA_PA
	jnz	.lo_drop_sha

	test [.our.type],SHA_FI
	jz	.lo_dropF

.lo_drop_sfi:
	and [.our.type],not SHA_FI

	cmp rax,[.our.share]
	jz .lo_dropF

	mov r10,[.our.share]
	and [r10+PNL.type],\
		not SHA_PA

	cmp rax,[r10+PNL.share]
	jz	.lo_drop_sfi1

	or [r10+PNL.type],\
		SHA_FI

.lo_drop_sfi1:
	mov [r10+PNL.prev],r8
	mov [r10+PNL.next],r9
	mov [.our.share],rax

	cmp rcx,[rdx]
	jnz	.lo_drop_sfi3
	mov [rdx],r10

.lo_drop_sfi3:
	test r8,r8
	jz	.lo_drop_sfi4
	mov [r8+PNL.next],r10

.lo_drop_sfi4:
	test r9,r9
	jz	.lo_dropF3
	mov [r9+PNL.prev],r10
	jmp	.lo_dropF3

.lo_drop_sha:
;@break
	mov r9,[.our.share]
	call .get_sfisha
	test rax,rax
	jz	.lo_dropF3 ;--- this error

	xor r10,r10
	mov [r8+PNL.share],r9
	mov [.our.share],r10

	cmp rax,r8
	jnz	.lo_dropF3

	and [rax+PNL.type],\
		not SHA_FI
	test r9,r9
	jz	.lo_dropF3

	or [rax+PNL.type],\
		SHA_FI
	jmp	.lo_dropF3

	;*----------------------------------------------------------
	;|       DOCK64.get_sfisha
	;*----------------------------------------------------------
.get_sfisha:
	;--- in RCX our panel
	;--- RET RAX 0,main SHA_FI
	;--- RET RDX = RAX ,main SHA_FI
	;--- RET R8 eventual preceeding SHA_PA 
	xor rax,rax
	mov rdx,[.mdl.panels]
	jmp	.get_sfishaB

.get_sfishaC:
	test [rdx+PNL.type],\
		SHA_FI
	jz	.get_sfishaA

	mov r8,rdx
	cmp rcx,rdx
	jz	.get_sfishaE
	
.get_sfishaF:
	cmp rax,[r8+PNL.share]
	jnz	.get_sfishaD
	xor r8,r8

.get_sfishaA:
	mov rdx,[rdx+PNL.next]

.get_sfishaB:
	cmp rax,rdx
	jnz	.get_sfishaC

.get_sfishaE:
	mov rax,rdx
	ret 0

.get_sfishaD:
	cmp rcx,[r8+PNL.share]
	jz	.get_sfishaE
	cmp rax,[r8+PNL.share]
	jz	.get_sfishaA
	mov r8,[r8+PNL.share]
	jmp	.get_sfishaF
	
	;/----------------------------------------------------------
	;|                  DOCK64.LO_SET initial settings
	;\----------------------------------------------------------
.lo_set:
	;--- IN RCX our PNL
	;--- IN RDX pnl AFTER (docker or SHARE_FIRST)
	;--- IN RSI MDL
	xor rax,rax
	test rcx,rcx
	jnz	.lo_setA
	ret 0

.lo_setA:
	test rdx,rdx
	jnz	.lo_setB
	ret 0

.lo_setB:
	cmp rdx,rsi
	jz	.lo_setD

.lo_setS:
	cmp rax,[rdx+PNL.share]
	jz	.lo_setS1
	mov rdx,[rdx+PNL.share]
	jmp	.lo_setS
	
.lo_setS1:
	mov [rdx+PNL.share],rcx
	mov [rcx+PNL.next],rax
	mov rax,rcx
	ret 0

.lo_setD:
	lea r8,[.mdl.panels]
	test [rcx+PNL.type],\
		IS_FLO
	jz .lo_setC
	lea r8,[.mdl.floats]

.lo_setC:
	mov rdx,[r8]
	cmp rax,rdx
	jnz	.lo_setCN
	mov [r8],rcx

	mov [rcx+PNL.next],rax
	mov [rcx+PNL.prev],rax
	mov rax,rcx
	ret 0

.lo_setCN:
	cmp rax,[rdx+PNL.next]
	jz	.lo_setCN1
	mov rdx,[rdx+PNL.next]
	jmp	.lo_setCN

.lo_setCN1:
	mov [rdx+PNL.next],rcx

.lo_setCN2:
	mov [rcx+PNL.next],rax
	mov [rcx+PNL.prev],rdx
	mov rax,rcx
	ret 0

	;/----------------------------------------------------------
	;|                  DOCK64.repo
	;\----------------------------------------------------------

.lo_repo:
	;--- IN RCX our pnl
	;--- IN RDX target
	;--- (IN RSI MDL)
	;--- in (MDL.cside valid side)
	movzx eax,[.mdl.cside]
	cmp rdx,rsi
	jz	.lo_repo_oncc

	mov ah,[.tgt.type]
	mov r8,[.tgt.prev]
	mov r9,[.tgt.next]

	test ah,SHA_PA
	jnz	.lo_repo_onsha
	test ah,SHA_FI
	jnz	.lo_repo_onsfi

	;------------- ON PAN ------------------
	;--- reposition on pure panel
.lo_onpan:
	mov ah,[.tgt.alignment]
	cmp ah,ALIGN_LEFT
	jz	.lo_onpan_lx
	cmp ah,ALIGN_TOP
	jz	.lo_onpan_up
	cmp ah,ALIGN_RIGHT
	jz	.lo_onpan_rx
	cmp ah,ALIGN_BOTTOM
	jz	.lo_onpan_dw

	;------------- ON PAN CC ---------------
	;--- reposition on client panel ----
.lo_onpan_cc:
	cmp al,ALIGN_LEFT
	jz	.lo_onpan_lx
	cmp al,ALIGN_TOP
	jz	.lo_onpan_up
	cmp al,ALIGN_RIGHT
	jz	.lo_onpan_rx
	cmp al,ALIGN_BOTTOM
	jz	.lo_onpan_dw
	;--- swap with client panel ----
	ret 0

	;------------------------------------
.lo_onpan_rx:
	mov [.our.alignment],\
		ALIGN_RIGHT
	cmp al,ALIGN_LEFT
	jz	.lo_onpan_rx_lx
	cmp al,ALIGN_RIGHT
	jz	.lo_onpan_rx_rx
	cmp al,ALIGN_TOP
	jz	.lo_onpan_rx_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onpan_rx_dw

.lo_onpan_rx_up:
	;--- on RX ask UP ----
	;--- RCX before RDX as shared first
	xchg rdx,rcx
	jmp	.lo_onpan_lx_up
	ret 0

.lo_onpan_rx_dw:
	jmp	.lo_onpan_lx_dw
	ret 0

	;------------------------------------
.lo_onpan_up:
	mov [.our.alignment],\
		ALIGN_TOP
	cmp al,ALIGN_TOP
	jz	.lo_onpan_up_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onpan_up_dw
	cmp al,ALIGN_LEFT
	jz	.lo_onpan_lx_up
	cmp al,ALIGN_RIGHT
	jz	.lo_onpan_lx_dw
	ret 0

	;------------------------------------
.lo_onpan_dw:
	mov [.our.alignment],\
		ALIGN_BOTTOM
	cmp al,ALIGN_TOP
	jz	.lo_onpan_dw_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onpan_dw_dw
	cmp al,ALIGN_LEFT
	jz	.lo_onpan_lx_up
	cmp al,ALIGN_RIGHT
	jz	.lo_onpan_lx_dw
	ret 0

;------------------------------------
.lo_onpan_lx:
	mov [.our.alignment],\
		ALIGN_LEFT
	cmp al,ALIGN_LEFT
	jz	.lo_onpan_lx_lx
	cmp al,ALIGN_RIGHT
	jz	.lo_onpan_lx_rx
	cmp al,ALIGN_TOP
	jz	.lo_onpan_lx_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onpan_lx_dw
	
	;--- swap panels
.lo_onpan_lx_cc:
.lo_onpan_dw_cc:
.lo_onpan_up_cc:
.lo_onpan_rx_cc:
	ret 0

.lo_onpan_lx_dw:
	xor eax,eax
	or [.tgt.type],\
		SHA_PA or SHA_FI
	xor [.tgt.type],SHA_PA

	or [.our.type],\
		SHA_FI or SHA_PA
	xor [.our.type],SHA_FI

	mov [.tgt.ratio],30
	mov [.our.ratio],30
	mov [.tgt.share],rcx
	mov [.our.share],rax
	ret 0

.lo_onpan_lx_up:
	xor eax,eax
	or [.our.type],\
		SHA_FI or SHA_PA
	xor [.our.type],SHA_PA

	or [.tgt.type],\
		SHA_PA or SHA_FI
	xor [.tgt.type],SHA_FI

	mov [.our.ratio],30
	mov [.our.share],rdx
	mov [.tgt.ratio],30
	mov [.tgt.share],rax

	cmp rdx,[.mdl.panels]
	jnz	@f
	mov [.mdl.panels],rcx
	mov [.our.prev],rax
@@:
	cmp rax,[.mdl.panels]
	jnz	@f
	mov [.mdl.panels],rcx
@@:
	test r8,r8
	jz	@f
	mov [r8+PNL.next],rcx
	mov [.our.prev],r8
@@:	
	mov [.our.next],rax
	mov [.tgt.prev],rax
	test r9,r9
	jz	@f
	mov [.our.next],r9
	mov [r9+PNL.prev],rcx
@@:
	ret 0

.lo_onpan_rx_rx:
	;--- RCX our panel ask RX
	;--- RDX is RX
.lo_onpan_dw_dw:
	;--- RCX our panel ask DW
	;--- RDX is DW
.lo_onpan_up_up:
	;--- RCX our panel ask UP
	;--- RDX is UP
.lo_onpan_lx_lx:
	;--- RCX our panel ask LX
	;--- RDX is LX
	xor eax,eax
	cmp rdx,[.mdl.panels]
	jnz	@f
	mov [.mdl.panels],rcx
	mov [.our.prev],rax
@@:
	cmp rax,[.mdl.panels]
	jnz	@f
	mov [.mdl.panels],rcx
@@:
	test r8,r8
	jz	@f
	mov [r8+PNL.next],rcx
	mov [.our.prev],r8
@@:	
	mov [.our.next],rdx
	mov [.tgt.prev],rcx
	ret 0

.lo_onpan_dw_up:
	;--- RCX our panel ask UP
	;--- RDX is DW
.lo_onpan_up_dw:
	;--- RCX our panel ask DW
	;--- RDX is UP
.lo_onpan_rx_lx:
	;--- RCX our panel ask LX
	;--- RDX is RX
.lo_onpan_lx_rx:
	;--- RCX our panel ask RX
	;--- RDX is LX
	test r9,r9
	jz	@f
	mov [r9+PNL.prev],rcx
@@:
	mov [.tgt.next],rcx
	mov [.our.prev],rdx
	mov [.our.next],r9
	ret 0

	;------------------- ON SHA ---------------
.lo_repo_onsha:
	mov ah,[.tgt.alignment]
	cmp ah,ALIGN_LEFT
	jz	.lo_onsha_lx
	cmp ah,ALIGN_RIGHT
	jz	.lo_onsha_rx
	cmp ah,ALIGN_TOP
	jz	.lo_onsha_up
	cmp ah,ALIGN_BOTTOM
	jz	.lo_onsha_dw
	ret 0

	;------------------- ON SHA DW ------------
.lo_onsha_dw:
	mov [.our.alignment],\
		ALIGN_BOTTOM
	cmp al,ALIGN_TOP
	jz	.lo_onsha_lx_rx
	cmp al,ALIGN_BOTTOM
	jz	.lo_onsha_lx_lx
	cmp al,ALIGN_LEFT
	jz	.lo_onsha_lx_up
	cmp al,ALIGN_RIGHT
	jz	.lo_onsha_lx_dw
	ret 0

	;------------------- ON SHA UP ------------
.lo_onsha_up:
	mov [.our.alignment],\
		ALIGN_TOP
	cmp al,ALIGN_TOP
	jz	.lo_onsha_lx_lx
	cmp al,ALIGN_BOTTOM
	jz	.lo_onsha_lx_rx
	cmp al,ALIGN_LEFT
	jz	.lo_onsha_lx_up
	cmp al,ALIGN_RIGHT
	jz	.lo_onsha_lx_dw
	ret 0

;.lo_onsha_up_rx:
;;@break
;	xor eax,eax
;	or [.our.type],\
;		SHA_FI or SHA_PA
;	xor [.our.type],SHA_FI
;	mov [.tgt.ratio],30
;	mov r9,[.tgt.share]
;	mov [.tgt.share],rcx
;	mov [.our.share],r9
;	ret 0

	;------------------- ON SHA RX -------------
.lo_onsha_rx:
	mov [.our.alignment],\
		ALIGN_RIGHT
	cmp al,ALIGN_LEFT
	jz	.lo_onsha_lx_rx
	cmp al,ALIGN_RIGHT
	jz	.lo_onsha_lx_lx
	cmp al,ALIGN_TOP
	jz	.lo_onsha_lx_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onsha_lx_dw
	ret 0

	;------------------- ON SHA LX -------------
.lo_onsha_lx:
	mov [.our.alignment],\
		ALIGN_LEFT
	cmp al,ALIGN_LEFT
	jz	.lo_onsha_lx_lx
	cmp al,ALIGN_RIGHT
	jz	.lo_onsha_lx_rx
	cmp al,ALIGN_TOP
	jz	.lo_onsha_lx_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onsha_lx_dw
	ret 0

.lo_onsha_lx_lx:
	mov r9,rcx	
	mov rcx,rdx
	call .get_sfisha
	
	mov rcx,r9
	mov rdx,rax
	mov r8,[.tgt.prev]
	mov r9,[.tgt.next]
	jmp	.lo_onpan_lx_lx

.lo_onsha_lx_rx:
	mov r9,rcx	
	mov rcx,rdx
	call .get_sfisha
	mov rcx,r9
	mov rdx,rax
	mov r9,[.tgt.next]
	jmp	.lo_onpan_lx_rx

.lo_onsha_lx_up:
;@break
	or [.our.type],\
		SHA_FI or SHA_PA
	xor [.our.type],SHA_FI
	mov [.our.ratio],30

	mov r10,rdx
	mov r9,rcx
	mov rcx,rdx
	call .get_sfisha

	mov rcx,r9
	xor eax,eax
	mov r9,[.tgt.share]
	mov [r8+PNL.share],rcx
	mov [.our.share],r10
	ret 0
	
.lo_onsha_lx_dw:
;@break
	xor eax,eax
	or [.our.type],\
		SHA_FI or SHA_PA
	xor [.our.type],SHA_FI
	mov [.tgt.ratio],30
	mov r9,[.tgt.share]
	mov [.our.share],r9
	mov [.tgt.share],rcx
	ret 0
	
	;------------------- ON SFI ---------------
.lo_repo_onsfi:
;@break
	mov ah,[.tgt.alignment]
	cmp ah,ALIGN_LEFT
	jz	.lo_onsfi_lx
	cmp ah,ALIGN_RIGHT
	jz	.lo_onsfi_rx
	cmp ah,ALIGN_TOP
	jz	.lo_onsfi_up
	cmp ah,ALIGN_BOTTOM
	jz	.lo_onsfi_dw
	ret 0

	;------------------- ON SFI DW ---------------
.lo_onsfi_dw:
	mov [.our.alignment],\
		ALIGN_BOTTOM
	cmp al,ALIGN_LEFT
	jz	.lo_onsfi_lx_up
	cmp al,ALIGN_RIGHT
	jz	.lo_onsfi_lx_dw
	cmp al,ALIGN_TOP
	jz	.lo_onpan_up_dw
	cmp al,ALIGN_BOTTOM
	jz	.lo_onpan_up_up
	ret 0

	;------------------- ON SFI UP ---------------
.lo_onsfi_up:
	mov [.our.alignment],\
		ALIGN_TOP
	cmp al,ALIGN_TOP
	jz	.lo_onpan_up_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onpan_up_dw
	cmp al,ALIGN_LEFT
	jz	.lo_onsfi_lx_up
	cmp al,ALIGN_RIGHT
	jz	.lo_onsfi_lx_dw
	ret 0

	;------------------- ON SFI RX ---------------
.lo_onsfi_rx:
	mov [.our.alignment],\
		ALIGN_RIGHT
	cmp al,ALIGN_LEFT
	jz	.lo_onpan_rx_lx
	cmp al,ALIGN_RIGHT
	jz	.lo_onpan_rx_rx
	cmp al,ALIGN_TOP
	jz	.lo_onsfi_lx_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onsfi_lx_dw
	ret 0
	
	;------------------- ON SFI LX ---------------
.lo_onsfi_lx:
	mov [.our.alignment],\
		ALIGN_LEFT
	cmp al,ALIGN_LEFT
	jz	.lo_onpan_lx_lx
	cmp al,ALIGN_RIGHT
	jz	.lo_onpan_lx_rx
	cmp al,ALIGN_TOP
	jz	.lo_onsfi_lx_up
	cmp al,ALIGN_BOTTOM
	jz	.lo_onsfi_lx_dw
	ret 0

.lo_onsfi_lx_dw:
	xor eax,eax
	or [.tgt.type],\
		SHA_PA or SHA_FI
	xor [.tgt.type],SHA_PA

	or [.our.type],\
		SHA_FI or SHA_PA
	xor [.our.type],SHA_FI

	mov [.our.ratio],30
	mov r10,[.tgt.share]
	mov [.our.share],r10
	mov [.tgt.share],rcx
	ret 0
	
.lo_onsfi_lx_up:
	xor eax,eax
	or [.our.type],\
		SHA_FI or SHA_PA
	xor [.our.type],SHA_PA

	or [.tgt.type],\
		SHA_PA or SHA_FI
	xor [.tgt.type],SHA_FI

	mov [.our.ratio],30
	mov [.our.share],rdx
	mov [.tgt.ratio],30

	cmp rdx,[.mdl.panels]
	jnz	@f
	mov [.mdl.panels],rcx
	mov [.our.prev],rax
@@:
	cmp rax,[.mdl.panels]
	jnz	@f
	mov [.mdl.panels],rcx
@@:
	test r8,r8
	jz	@f
	mov [r8+PNL.next],rcx
	mov [.our.prev],r8
@@:	
	mov [.our.next],rax
	mov [.tgt.prev],rax
	test r9,r9
	jz	@f
	mov [.our.next],r9
	mov [r9+PNL.prev],rcx
@@:
	ret 0

.lo_repo_oncc:
	mov [.our.alignment],al
	jmp .lo_set

.lo_repoE:
	ret 0


;.lo_repo_chi_cli:
;	cmp rcx,rdx
;	jz	.lo_repo_chif_cli
;	push rbx
;	push rcx
;	mov rbx,rcx
;	call .get_prevchild
;	pop rcx
;	pop rbx
;	mov rdx,[rax+PNL.pChild]
;	mov [rax+PNL.pChild],rbx
;	mov rdx,[rcx+PNL.pChild]
;	mov [.pnl.pChild],rdx
;	call .swap_panels
;	ret 0
	

;	;/----------------------------------------------------------
;	;|                  reposition on SHARE_PANEL
;	;\----------------------------------------------------------
;.lo_repo_onshap:
;	;--- our RCX is a SHARE_PANEL
;;@break
;	push rcx
;	push rbx
;	mov rbx,rcx
;	call .get_prevchild
;	pop rbx
;	pop rcx
;	test r8,r8
;	jz	.err_lo_repo
;	mov r9,rax

;	mov al,[.pnl.alignment]	;--- the target side we need
;	cmp al,ALIGN_CLIENT
;	jz	.lo_repo_shap_cli
;	mov ah,[rcx+PNL.alignment]
;	cmp ah,al
;	jz	.lo_repo_shap_pc
;	or ah,al
;	cmp ah,ALIGN_V
;	jz	.lo_repo_shap_fc
;	cmp ah,ALIGN_H
;	jz	.lo_repo_shap_fc
;	cmp ah,PSIDE
;	jz	.lo_repo_shap_ps
;	cmp ah,FSIDE
;	jz	.lo_repo_shaf_fs
;	cmp al,ALIGN_LEFT
;	jz	.lo_repo_shap_ps
;	cmp al,ALIGN_TOP
;	jz	.lo_repo_shap_ps
;	cmp al,ALIGN_RIGHT
;	jz	.lo_repo_shaf_fs
;	cmp al,ALIGN_BOTTOM
;	jz	.lo_repo_shaf_fs
;	ret 0

;.lo_repo_shap_cli:
;	mov rax,r9
;	mov rdx,[rax+PNL.pShare]
;	mov [rax+PNL.pShare],rbx
;	mov rdx,[rcx+PNL.pShare]
;	mov [.pnl.pShare],rdx
;	call .swap_panels
;	ret 0

;.lo_repo_shap_ps:
;	xor al,ah
;	mov [.pnl.alignment],al
;	or [.pnl.type],SHA_PA
;	mov rax,[r9+PNL.pShare]
;	mov [.pnl.pShare],rax
;	mov [r9+PNL.pShare],rbx
;	ret 0

;.lo_repo_shap_fc:
;	mov rcx,r8
;	jmp	.lo_repo_shaf_fc

;.lo_repo_shap_pc:
;	mov rcx,r8
;	jmp	.lo_repo_shaf_pc


	;/----------------------------------------------------------
	;|                  DOCK64.LAYOUT
	;\----------------------------------------------------------
.layout:
	;--- RCX hDocker
	;--- RDX msg
	;--- R8 wparam
	;--- R9 lparam
;	cmp edx,\
;		WM_WINDOWPOSCHANGING
;	jz	.layout_float
	test ecx,ecx
	jnz	@f
	ret 0
@@:
	cmp edx,\
		WM_SYSCOMMAND
	jz	.layout_float
	cmp edx,\
		WM_WINDOWPOSCHANGED
	jz	.layoutA
	cmp edx,\
		WM_SIZE;WINDOWPOSCHANGED
	jz	.layoutA
	ret 0

.layout_float:
	mov rdx,\
		[rcx+MDL.floats]
	test rdx,rdx
	jnz	@f
	ret 0
@@:
	push rbx
	push rsi

	mov rax,r8
	mov rbx,rdx
	and eax,0FFF0h

;	push rax
;	mov r8,rax
;	mov rdx,[.pnl.hwnd]
;	call art.cout2XX
;	pop rax

	mov esi,SW_HIDE	
	cmp ax,SC_MINIMIZE
	jz .layout_floatA

	cmp ax,SC_RESTORE
	jnz	.layout_floatE
	mov esi,SW_RESTORE

.layout_floatA:
	test [.pnl.type],\
		IS_FLO
	jz	.layout_floatB
	test [.pnl.type],\
		IS_HID
	jnz	.layout_floatB
	
	mov edx,esi
	mov rcx,[.pnl.hwnd]
	call apiw.show

.layout_floatB:
	mov rbx,[.pnl.next]
	test rbx,rbx
	jnz .layout_floatA

.layout_floatE:
	pop rsi
	pop rbx
	ret 0


.layoutA:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15

	mov rbp,rsp
	and rsp,-16
	mov rsi,rcx

	sub rsp,\
		sizeof.RECT
	mov r12,rsp

.layout_chi:
;@break

	mov rdx,r12
	mov rcx,[.mdl.hwnd]
	call apiw.get_clirect

	mov rax,[r12]
	mov [.mdl.src],rax
	mov [.mdl.crc],rax
	mov rax,[r12+8]
	mov [.mdl.crc+8],rax
	mov [.mdl.src+8],rax
	mov [.mdl.tmp_ssize],eax
	mov rbx,[.mdl.panels]

;	cmp [r12+RECT.right],40
;	jle .layoutE
;	cmp [r12+RECT.bottom],40
;	jle .layoutE


	movzx ecx,[.mdl.nslots]
	call apiw.beg_defwpos
	mov rdi,rax
	jmp	.layout_chiB

.layout_chiA:
	mov rbx,[.pnl.next]

.layout_chiB:
	test rbx,rbx
	jz	.layout_chiE

	lea rdx,[.pnl.wrc]
	mov rcx,[.pnl.hwnd]
	call apiw.get_winrect

;	mov r9,2
;	lea r8,[.pnl.wrc]
;	mov rdx,[.pnl.hwnd]
;	mov rcx,0
;	call apiw.map_wpt

	test [.pnl.type],\
		IS_HID
	jnz	.layout_chiA
	
	test [.pnl.type],\
		SHA_FI
	jnz	.layout_sha

.layout_chiB1:
	movzx rax,[.pnl.alignment]
	xor rcx,rcx

.layout_chiC_LX:
	;--- child LEFT
	cmp al,ALIGN_LEFT
	jnz	.layout_chiC_UP
	mov ecx,[.mdl.src.left]
	mov edx,[.mdl.src.top]
	mov r8d,[.pnl.wrc.right]
	sub r8d,[.pnl.wrc.left]
	mov r9d,[.mdl.src.bottom]
	sub r9d,edx
	;mov [.pnl.tot_ssize],r9d
	test r8,r8
	jnz	.layout_chiC_LX1
	movzx r8,[.pnl.cxy]

.layout_chiC_LX1:
	add [.mdl.src.left],r8d
	jmp	.layout_chiR


.layout_chiC_UP:
	;--- child TOP
	cmp al,ALIGN_TOP
	jnz	.layout_chiC_RX
	mov ecx,[.mdl.src.left]
	mov edx,[.mdl.src.top]
	mov r8d,[.mdl.src.right]
	sub r8d,ecx
	;mov [.pnl.tot_ssize],r8d
	mov r9d,[.pnl.wrc.bottom]
	sub r9d,[.pnl.wrc.top]
	test r9,r9
	jnz	.layout_chiC_UP1
	movzx r9,[.pnl.cxy]

.layout_chiC_UP1:
	add [.mdl.src.top],r9d
	jmp	.layout_chiR


.layout_chiC_RX:
	;--- child RIGHT
	cmp al,ALIGN_RIGHT
	jnz	.layout_chiC_DW
	mov edx,[.mdl.src.top]
	mov r9d,[.mdl.src.bottom]
	sub r9d,edx
	;mov [.pnl.tot_ssize],r9d
	mov r8d,[.pnl.wrc.right]
	sub r8d,[.pnl.wrc.left]
	mov ecx,[.mdl.src.right]
	sub ecx,r8d
	test r9,r9
	jnz	.layout_chiC_RX1
	movzx ecx,[.pnl.cxy] 

.layout_chiC_RX1:
	mov [.mdl.src.right],ecx
	jmp	.layout_chiR
@@:

.layout_chiC_DW:
	;--- child BOTTOM
	cmp al,ALIGN_BOTTOM
	jnz	.layout_chiC_CC
	mov ecx,[.mdl.src.left]
	mov r8d,[.mdl.src.right]
	sub r8d,ecx
	;mov [.pnl.tot_ssize],r8d
	mov r9d,[.pnl.wrc.bottom]
	sub r9d,[.pnl.wrc.top]
	mov edx,[.mdl.src.bottom]
	sub edx,r9d
	test r8,r8
	jnz	.layout_chiC_DW1
	movzx edx,[.pnl.cxy] 

.layout_chiC_DW1:
	mov [.mdl.src.bottom],edx
	jmp	.layout_chiR

.layout_chiC_CC:
	;--- child CLIENT
	lea rax,[.mdl.src]
	mov ecx,[rax+RECT.left]
	mov edx,[rax+RECT.top]
	mov r8d,[rax+RECT.right]
	sub r8d,ecx
	mov r9d,[rax+RECT.bottom]
	sub r9d,edx

	test r9,r9
	jbe	.layout_chiA
	test r8,r8
	jbe	.layout_chiA

	mov rax,[.mdl.src]
	mov [.mdl.crc],rax
	mov rax,[.mdl.src+8]
	mov [.mdl.crc+8],rax
	
	xor eax,eax
	mov [.mdl.src],rax
	mov [.mdl.src+8],rax
	jmp	.layout_chiR

;------------------------- LX ---------------------------
.layout_chiR:
	mov [.pnl.wrc.left],ecx
	mov [.pnl.wrc.top],edx
	mov [.pnl.wrc.right],r8d
	mov [.pnl.wrc.bottom],r9d

	push SWP_NOZORDER \
		or SWP_NOACTIVATE\
		or SWP_NOCOPYBITS\
		or 0;SWP_FRAMECHANGED;0;SWP_NOREDRAW
	push r9
	push r8
	push rdx
	mov r9,rcx
	mov r8,HWND_TOP
	mov rdx,[.pnl.hwnd]
	mov rcx,rdi
	sub rsp,20h
	call [DeferWindowPos]
	mov rdi,rax
	add rsp,40h
	jmp	.layout_chiA

	;--- SHA ----------------------------------
.layout_sha:
	mov r9d,[.mdl.src.bottom]
	sub r9d,[.mdl.src.top]
	mov al,[.pnl.alignment]
	and al,ALIGN_V
	test al,al
	jnz	@f
	mov r9d,[.mdl.src.right]
	sub r9d,[.mdl.src.left]
@@:
	mov [.pnl.tot_ssize],r9d
	mov [.mdl.tmp_ssize],r9d

	xor eax,eax
	xor r8,r8
	cmp rax,[.pnl.share]
	jz	.layout_chiB1

	;--- count shared on the stack
	;--- RET in R8 numshared (included FIRST)
	;--- RET RCX total ratio
	push rbx		;--- our FIRST shared
	mov r14,rsp
	mov rdx,rbx
	movzx ecx,[.pnl.ratio]

.layout_shaA:
	movzx eax,[rdx+PNL.ratio]
	sub rsp,8
	add ecx,eax
	mov rdx,[rdx+PNL.share]
	inc r8
	mov [rsp],rdx
	test rdx,rdx
	jnz	.layout_shaA

.layout_shaB:
;@break
	mov al,-1
	cmp ecx,eax	;--- max ratio
	jbe	.layout_shaC
	;--- adjust ratio

.layout_shaC:
	;--- adjust FIRST
	sub al,cl
	cmp [.pnl.ratio],ah
	jnz	.layout_shaD
	mov [.pnl.ratio],al

.layout_shaD:
	mov al,[.pnl.alignment]
	cmp al,ALIGN_LEFT
	jz	.layout_shaLX
	cmp al,ALIGN_RIGHT
	jz	.layout_shaRX
	cmp al,ALIGN_TOP
	jz	.layout_shaUP
	cmp al,ALIGN_BOTTOM
	jz	.layout_shaDW
.layout_shaE:
	mov rsp,r14
	pop rbx
	jmp	.layout_chiA

	;--- SHA ---------------------------- DW ---
	;-------------------------------------------
.layout_shaDW:
;	mov ecx,[src.left]
;	mov r8d,[src.right]
;	sub r8d,ecx
;	mov r9d,[.pnl.wrc.bottom]
;	sub r9d,[.pnl.wrc.top]
;	mov edx,[src.bottom]
;	sub edx,r9d

;	test r8,r8
;	jz	.resizeE
;	mov [src.bottom],edx
	mov [.mdl.tmpLeft],0
	mov r15d,[.pnl.wrc.bottom]
	sub r15d,[.pnl.wrc.top]
;	test r15,r15
;	jnz	@f
;	movzx r15,[.pnl.cxy]
;@@:
	mov r12,r14

.layout_shaDWA:
	mov rbx,[r12]
	test rbx,rbx
	jz	.layout_shaDWE

	sub r12,8
	movzx eax,[.pnl.ratio]
	mul [.mdl.tmp_ssize]
	shr eax,8
	mov r11,rax
	mov ecx,[.mdl.src.left]
	xor edx,edx
	add ecx,[.mdl.tmpLeft]
	add [.mdl.tmpLeft],r11d

	cmp edx,[r12]
	jnz	.layout_shaDWB

	mov edx,[.mdl.tmp_ssize]
	sub edx,[.mdl.tmpLeft]
	add r11d,edx

.layout_shaDWB:
	mov r13,rsp
	and rsp,-16

	push SWP_NOZORDER \
		or SWP_NOACTIVATE\
		or SWP_NOCOPYBITS

	;--- bleah!! improve !!
	mov r10d,[.mdl.src.bottom]
	sub r10d,r15d

	push r15
	push r11
	push r10

	mov r9d,ecx
	mov r8,HWND_TOP
	mov rdx,[.pnl.hwnd]
	mov rcx,rdi
	sub rsp,20h
	call [DeferWindowPos]
	mov rdi,rax
	mov rsp,r13
	jmp .layout_shaDWA

.layout_shaDWE:
;	mov r9d,[.pnl.wrc.bottom]
;	sub r9d,[.pnl.wrc.top]
;	mov edx,[src.bottom]
;	sub edx,r9d

;	test r8,r8
;	jz	.resizeE
;	mov [src.bottom],edx

	mov rsp,r14
	pop rbx
	mov r8d,[.pnl.wrc.bottom]
	sub r8d,[.pnl.wrc.top]
	mov edx,[.mdl.src.bottom]
	test r8,r8
	ja @f
	movzx r8,[.pnl.cxy]
@@:
	sub edx,r8d
	mov [.mdl.src.bottom],edx
	jmp	.layout_chiA



	;--- SHA ---------------------------- UP ---
	;-------------------------------------------
.layout_shaUP:
	mov [.mdl.tmpLeft],0
	mov r15d,[.pnl.wrc.bottom]
	sub r15d,[.pnl.wrc.top]
	test r15,r15
	jnz	@f
	movzx r15,[.pnl.cxy]
@@:
	mov r12,r14

.layout_shaUPA:
	mov rbx,[r12]
	test rbx,rbx
	jz	.layout_shaUPE

	sub r12,8
	movzx eax,[.pnl.ratio]
	mul [.mdl.tmp_ssize]
	shr eax,8
	mov r11,rax
	mov ecx,[.mdl.src.left]
	xor edx,edx
	add ecx,[.mdl.tmpLeft]
	add [.mdl.tmpLeft],r11d

	cmp edx,[r12]
	jnz	.layout_shaUPB

	mov edx,[.mdl.tmp_ssize]
	sub edx,[.mdl.tmpLeft]
	add r11d,edx

.layout_shaUPB:
	mov r13,rsp
	and rsp,-16

	push SWP_NOZORDER \
		or SWP_NOACTIVATE\
		or SWP_NOCOPYBITS

	;--- bleah!! improve !!
	mov r10d,[.mdl.src.top]

	push r15
	push r11
	push r10

	mov r9d,ecx
	mov r8,HWND_TOP
	mov rdx,[.pnl.hwnd]
	mov rcx,rdi
	sub rsp,20h
	call [DeferWindowPos]
	mov rdi,rax
	mov rsp,r13
	jmp .layout_shaUPA

.layout_shaUPE:
	mov rsp,r14
	pop rbx
	mov r8d,[.pnl.wrc.bottom]
	sub r8d,[.pnl.wrc.top]
	test r8,r8
	ja @f
	movzx r8,[.pnl.cxy]
@@:
	add [.mdl.src.top],r8d
	jmp	.layout_chiA



	;--- SHA ---------------------------- RX ---
	;-------------------------------------------
.layout_shaRX:
	mov [.mdl.tmpTop],0
	mov r15d,[.pnl.wrc.right]
	sub r15d,[.pnl.wrc.left]
	test r15,r15
	jnz	@f
	movzx r15,[.pnl.cxy]
@@:
	mov r12,r14

	mov ecx,[.mdl.src.right]
	sub ecx,r15d
	mov [.mdl.src.right],ecx

.layout_shaRXA:
	mov rbx,[r12]
	test rbx,rbx
	jz	.layout_shaRXE

	sub r12,8
	movzx eax,[.pnl.ratio]
	mul [.mdl.tmp_ssize]
	shr eax,8
	mov r11,rax
	mov ecx,[.mdl.src.top]
	xor edx,edx
	add ecx,[.mdl.tmpTop]
	add [.mdl.tmpTop],r11d

	cmp edx,[r12]
	jnz	.layout_shaRXB

	mov edx,[.mdl.tmp_ssize]
	sub edx,[.mdl.tmpTop]
	add r11d,edx

.layout_shaRXB:
	mov r13,rsp
	and rsp,-16
	push SWP_NOZORDER \
		or SWP_NOACTIVATE\
		or SWP_NOCOPYBITS

	push r11
	push r15
	push rcx

	mov r9d,[.mdl.src.right]
	;sub r9d,r15d

	mov r8,HWND_TOP
	mov rdx,[.pnl.hwnd]
	mov rcx,rdi
	sub rsp,20h
	call [DeferWindowPos]

	mov rdi,rax
	mov rsp,r13
	jmp .layout_shaRXA

.layout_shaRXE:
	mov rsp,r14
	pop rbx
;	mov r8d,[.pnl.wrc.right]
;	sub r8d,[.pnl.wrc.left]
;	test r8,r8
;	ja @f
;	movzx r8,[.pnl.cxy]
;@@:
	;mov [.mdl.src.right],r8d
	jmp	.layout_chiA

	;--- SHA ---------------------------- LX ---
	;-------------------------------------------
.layout_shaLX:
	mov [.mdl.tmpTop],0
	mov r15d,[.pnl.wrc.right]
	sub r15d,[.pnl.wrc.left]
	test r15,r15
	jnz	@f
	movzx r15,[.pnl.cxy]
@@:
	mov r12,r14

.layout_shaLXA:
	mov rbx,[r12]
	test rbx,rbx
	jz	.layout_shaLXE

	sub r12,8
	movzx eax,[.pnl.ratio]
	mul [.mdl.tmp_ssize]
	shr eax,8
	mov r11,rax
	mov ecx,[.mdl.src.top]
	xor edx,edx
	add ecx,[.mdl.tmpTop]
	add [.mdl.tmpTop],r11d

	cmp edx,[r12]
	jnz	.layout_shaLXB

	mov edx,[.mdl.tmp_ssize]
	sub edx,[.mdl.tmpTop]
	add r11d,edx

.layout_shaLXB:
	mov r13,rsp
	and rsp,-16
	push SWP_NOZORDER \
		or SWP_NOACTIVATE\
		or SWP_NOCOPYBITS

	push r11
	push r15
	push rcx

	mov r9d,[.mdl.src.left]
	mov r8,HWND_TOP
	mov rdx,[.pnl.hwnd]
	mov rcx,rdi
	sub rsp,20h
	call [DeferWindowPos]
	mov rdi,rax
	mov rsp,r13
	jmp .layout_shaLXA

.layout_shaLXE:
	mov rsp,r14
	pop rbx
	mov r8d,[.pnl.wrc.right]
	sub r8d,[.pnl.wrc.left]
	test r8,r8
	ja @f
	movzx r8,[.pnl.cxy]
@@:
	add [.mdl.src.left],r8d
	jmp	.layout_chiA

.layout_chiE:
	mov rcx,rdi
	call apiw.end_defwpos

.layoutE:
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


	;*----------------------------------------------------------
	;|                  DOCK64.IS_PTON
	;*----------------------------------------------------------
.is_pton:
	;--- in RCX pnl
	;--- in RDX pt
	;--- ret RAX 0 or part
	;--- ret RCX previous cursor
	;--- ret RDX hCursor

	push rdi
	push r12
	push r13

	sub rsp,\
		sizeof.RECT
	mov rdi,rdx
	mov r13,rdx

	call apiw.get_curs
	mov r12,rax

;	mov rax,[.pnl.wrc]
;	mov [rsp],rax
;	mov rax,[.pnl.wrc+8]
;	mov [rsp+8],rax

	mov rdx,rsp
	mov rcx,[.pnl.hwnd]
	call apiw.get_winrect
	
	movzx eax,[.mdl.cx_grip]

	mov r8d,[rsp+RECT.left]
	add r8,rax
	mov r9d,[rsp+RECT.top]
	add r9,rax
	mov r10d,[rsp+RECT.right]
	sub r10,rax
	mov r11d,[rsp+RECT.bottom]
	sub r11,rax

	mov eax,PART_GRIP
	movzx ecx,[.pnl.alignment]

	mov rdx,[hHCurs]
	cmp cl,ALIGN_LEFT
	jz	.is_pton_lx
	cmp cl,ALIGN_RIGHT
	jz	.is_pton_rx

	mov rdx,[hVCurs]
	shr rdi,32

	cmp cl,ALIGN_TOP
	jz	.is_pton_up
	cmp cl,ALIGN_BOTTOM
	jz	.is_pton_dw
	jmp	.is_ptonD

.is_pton_lx:
	mov al,ALIGN_LEFT
	cmp edi,r10d
	jae	.is_ptonE
;	jmp .is_ptonD

.is_pton_lxA:
	cmp [.pnl.type],\
		SHA_PA
	jnz .is_ptonD
	mov rdx,[hVCurs]
	mov al,ALIGN_TOP
	shr rdi,32
	mov r9d,[rsp+RECT.top]
	add r9,3
	cmp edi,r9d
	jbe	.is_ptonE
	jmp .is_ptonD

.is_pton_rx:
	mov al,ALIGN_RIGHT
	cmp edi,r8d
	jbe	.is_ptonE
	jmp .is_ptonD

.is_pton_up:
	mov al,ALIGN_TOP
	cmp edi,r11d
	jae	.is_ptonE
	jmp .is_ptonD

.is_pton_dw:
	mov al,ALIGN_BOTTOM
	cmp edi,r9d
	jbe	.is_ptonE
	jmp .is_ptonD

.is_ptonD:
	xor eax,eax
	mov rdx,[hDCurs]

.is_ptonE:
	mov rcx,r12
	add rsp,\
		sizeof.RECT
	pop r13
	pop r12
	pop rdi
	ret 0

	;*----------------------------------------------------------
	;|                  DOCK.GET_SIDE
	;*----------------------------------------------------------
.get_side:
	;--- in RDI target PNL
	;--- in ECX POINT.x
	;--- in EDX POINT.y

	xor rax,rax
	;--- IN R8 LX+Kx
	mov r8d,\
		[rdi+PNL.wrc.left]
	add r8d,CX_SPOT

	;--- IN R9 DW-Ky
	mov r9d,\
		[rdi+PNL.wrc.bottom]
	sub r9d,CY_SPOT

	cmp ecx,r8d
	jb	.gs_tryD

	;--- IN R10 RX-Kx
	mov r10d,\
		[rdi+PNL.wrc.right]
	sub r10d,CX_SPOT

	;--- IN R11 UP+Ky
	mov r11d,\
		[rdi+PNL.wrc.top]
	add r11d,CX_SPOT

	cmp ecx,r10d
	jae .gs_tryB

	cmp edx,r11d
	ja	.gs_tryC
	mov al,ALIGN_TOP
	ret 0

.gs_tryC:
	cmp edx,r9d
	jb	.gs_tryCC
	mov al,ALIGN_BOTTOM
	ret 0

.gs_tryB:
	cmp edx,r11d
	jb	.gs_tryCC
	mov al,ALIGN_RIGHT
	ret 0

.gs_tryD:
	cmp edx,r9d
	ja	.gs_tryCC
	mov al,ALIGN_LEFT
	ret 0

.gs_tryCC:
	mov al,\
		[rdi+PNL.alignment]
	and al,ALIGN_H

	;--- in R8 x unit
	mov r8d,\
		[rdi+PNL.wrc.right]
	sub r8d,\
		[rdi+PNL.wrc.left]
	shr r8,3
	mov r10,r8

	;--- in R9 y unit
	mov r9d,\
		[rdi+PNL.wrc.bottom]
	sub r9d,\
		[rdi+PNL.wrc.top]
	shr r9,3
	mov r11,r9

	test al,ALIGN_H
	jnz	.gs_tryCCH

.gs_tryCCV:
	;--- P point 3X,2Y
	;--- Q point 5X,6Y
	add r8,r8
	add r8,r10
	add r10,r10
	add r10,r8

	add r9,r9
	add r11,r9
	add r11,r11
	jmp	.gs_tryCC1

.gs_tryCCH:
	;--- P point 2X,3Y
	;--- Q point 6X,4Y
	add r8,r8
	add r10,r8
	add r10,r10

	add r9,r9
	add r9,r11
	add r11,r11
	add r11,r9

.gs_tryCC1:
	add r8d,\
		[rdi+PNL.wrc.left]
	add r10d,\
		[rdi+PNL.wrc.left]
	add r9d,\
		[rdi+PNL.wrc.top]
	add r11d,\
		[rdi+PNL.wrc.top]

	mov al,ALIGN_CLIENT
	cmp ecx,r8d
	jb	.gs_noside
	cmp edx,r9d
	jb	.gs_noside
	cmp ecx,r10d
	ja	.gs_noside
	cmp edx,r11d
	ja 	.gs_noside
	ret 0
	
.gs_noside:
	xor eax,eax
	ret 0

;	;/----------------------------------------------------------
;	;|                  DOCKMAN.SWAP_PANELS
;	;\----------------------------------------------------------

;.swap_panels:
;	;--- in RCX dest panel
;	;--- in RBX source panel
;	push rbp
;	push rbx
;	push rcx
;	push rdi
;	push rsi
;	mov rbp,rsp
;	and rsp,-16

;	mov rsi,rbx
;	mov rdi,rcx
;	
;;	or [rcx+PANELSTRUCT.type],FLOAT_PANEL
;;@break
;	mov al,[rdi+PNL.type]
;	mov dl,[rsi+PNL.type]

;	or al,dl

;	and al,SHARE_PANEL or \
;		SHARE_FIRST or \
;		HAS_CONTROL

;	mov [rsi+PNL.type],al

;	or dl,FLOAT_PANEL
;	or dl,al

;	and dl,FLOAT_PANEL or \
;			HAS_CONTROL

;	mov [rdi+PNL.type],dl

;	mov al,[rdi+PNL.alignment]
;	mov [.pnl.alignment],al

;	mov [rdi+PNL.alignment],0

;	
;	lea rdx,[rdi+PNL.wrc]
;	mov rcx,[.pnl.hwnd]
;	call apiw.get_winrect

;	mov rbx,rdi
;	xor rcx,rcx
;	call .lo_set

;	mov r8d,FLOAT_STYLE
;	mov [.pnl.style],r8d
;	mov rcx,[.pnl.hwnd]
;	call apiw.set_wlstyle

;	mov rdx,0
;	mov rcx,[.pnl.hwnd]
;	call apiw.set_parent

;	mov eax,SWP_NOZORDER or \
;			SWP_FRAMECHANGED
;	mov r11d,[rsi+PNL.float_cy]
;	mov r10d,[rsi+PNL.float_cx]
;	mov r9d,[.pnl.wrc.top]
;	mov r8d,[.pnl.wrc.left]
;	mov rdx,HWND_TOP
;	mov rcx,[.pnl.hwnd]
;	call apiw.set_wpos


;;	sub rsp,20h
;;	mov r8,TRUE
;;	xor rdx,rdx
;;	mov rcx,[rdi+PANELSTRUCT.hwnd]
;;	call [InvalidateRect]
;;	add rsp,20h

;	mov rsp,rbp
;	pop rsi
;	pop rdi
;	pop rcx
;	pop rbx
;	pop rbp
;	ret 0

