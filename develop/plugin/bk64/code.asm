  
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


bk64:

.attach:
	mov rsi,rsp
	and rsp,-16

	xor rcx,rcx
	sub rsp,20h
	call [CoInitialize]
	add rsp,20h

	mov rdi,apiw.loadcurs
	mov rbx,rcx
	mov [g.hInst],rcx

	mov rdx,IDC_SIZENS
	xor ecx,ecx
	call rdi
	mov [g.hNSCurs],rax

	mov rdx,IDC_SIZEWE
	xor ecx,ecx
	call rdi
	mov [g.hWECurs],rax

	mov rdx,IDC_ARROW
	xor ecx,ecx
	call rdi
	mov [g.hDefCurs],rax

	mov rdi,apiw.get_sysmet
	mov ecx,SM_CXSIZEFRAME
	call rdi
	mov [g.cx_sframe],ax

	mov ecx,\
		SM_CYSIZEFRAME
	call rdi
	mov [g.cy_sframe],ax

	mov ecx,\
		SM_CYSMCAPTION	
	call rdi
	mov [g.cy_caption],ax

	mov ecx,\
		SM_CYBORDER	
	call rdi
	mov [g.cy_border],ax

	mov ecx,\
		SM_CXSMICON
	call rdi
	mov [g.cx_smicon],ax

	mov ecx,\
		SM_CYSMICON
	call rdi
	mov [g.cy_smicon],ax

	mov ecx,\
		SM_CXSMSIZE
	call rdi
	mov [g.cx_smsize],ax

	mov ecx,\
		SM_CXSMSIZE
	call rdi
	mov [g.cy_smsize],ax

	mov ecx,00B6C0CCh;;00D9E1B9h;;53EC1Eh;
	call apiw.create_sbrush
	mov [g.hBrush],rax

	mov r10,patt_bmp
	mov r9,1
	mov r8,1
	mov rdx,8
	mov rcx,8
	call apiw.create_bmp
	mov rdi,rax

	mov rcx,rax
	call apiw.create_pbrush
	mov [g.hPattern],rax

.attachA:
	mov rcx,rdi
	call apiw.delobj

.ok_attach:	
	xor eax,eax
	inc eax

.err_attach:
	mov rsp,rsi
	ret 0

.detach:
	mov rsi,rsp
	and rsp,-16
	xor ecx,ecx
	sub rsp,20h
	call [CoUninitialize]
	mov rcx,[g.hBrush]
	call apiw.delobj
	mov rdi,[g.hPattern]
	jmp	.attachA



	;#---------------------------------------------ö
	;|            bk64.listfiles                   |
	;ö---------------------------------------------ü

.listfiles:
	;---	in RCX upath		;--- example "E:" or "E:\mydir"
	;---	in RDX uattr		;--- FILE_ATTRIBUTE_HIDDEN
	;---	in R8  ulevel		;--- nesting level to stop search 0=all
	;---	in R9  ufilter	;--- "*.asm"
	;---	in R10 ucback   ;--- address of a calback
	;---	in R11 uparam   ;--- user param
	;---------------------------------------------------
	;---  the calback receives those args
	;--- 
	;--- in RCX path
	;--- in RDX w32fnd 
	;--- in R8h lenpath
	;--- in R9 uparam
	;--- ret RAX = 1 continue search, 0 stop search

	xor eax,eax
	test r10,r10
	jnz	@f
	ret 0

	align 2
	.uzDot			du ".",0
	.uzAsterisk	du "*",0

@@:
	test ecx,ecx
	jnz	@f
	mov rcx,.uzDot
@@:
	test r9,r9
	jnz	@f
	mov r9,.uzAsterisk	
@@:
	push rbx
	push r12
	push r13
	push r14
	push r15

	dec edx
	mov ebx,edx
	inc edx
	or ebx,edx

	and ebx,\
		FILE_ATTRIBUTE_READONLY\
		or FILE_ATTRIBUTE_HIDDEN\
		or FILE_ATTRIBUTE_SYSTEM\
		or FILE_ATTRIBUTE_DIRECTORY\
		or FILE_ATTRIBUTE_ARCHIVE\
		or FILE_ATTRIBUTE_NORMAL\
		or FILE_ATTRIBUTE_TEMPORARY\
		or FILE_ATTRIBUTE_COMPRESSED

	mov r12,r8
	mov r13,r9
	mov r14,r10
	mov r15,r11

	call .listit
	
.listfilesE:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret 0

.listit:
	;--- in RCX upath
	;--- (in RBX uattr)
	;--- (in R12 ulevel)
	;--- (in R13 ufilter)
	;--- (in R14 ucback)
	;--- (in R15 uparam)

	push rbp
	mov rbp,rsp
	and rsp,-16

	xor eax,eax
	sub rsp,\
		210h+\ ;--- FILE_BUFLEN
		250h+\ ;--- WIN32_FIND_DATAW
		8+\    ;--- RDI home
		8+\		 ;--- RSI home
		8+\		 ;---
    4+\		 ;---
		4+\	   ;--- .flags for matching all/filter
		8+\		 ;--- .hFFile
		4+\		 ;--- .lenpath
		4		   ;--- .nitems

	label .path\
		qword at rbp-\
		(210h+250h+30h)
	label .w32fd\
		qword at rbp-\
		(250h+30h)
	label .rdi\
		qword at rbp-30h
	label .rsi\
		qword at rbp-28h
	label .flags\
		dword at rbp-14h
	label .hFFile\
		qword at rbp-10h
	label .lenpath\
		dword at rbp-8
	label .nitems\
		dword at rbp-4

	mov [.rdi],rdi
	mov [.rsi],rsi

	mov [.nitems],eax
	mov [.lenpath],eax
	mov [.flags],eax
	mov [.hFFile],rax
	dec r12

	lea rdi,[.path]
	mov rsi,rcx
	mov r8,rdi

@@:
	lodsw
	stosw
	test eax,eax
	jnz	@b
	sub rdi,2
	mov rdx,rdi
	sub rdx,r8
	mov [.lenpath],edx
	mov rsi,r13
	mov ax,"\"
	stosw

@@:
	lodsw
	stosw
	test eax,eax
	jnz	@b

	lea rsi,[.w32fd]
	mov rdx,rsi
	mov rcx,r8
	call apiw.ff_file
	mov [.flags],eax
	test eax,eax
	jg .listitA

.listitA2:
	mov ecx,[.lenpath]
	xor eax,eax
	lea rdi,[.path]
	add rdi,rcx

	mov ax,"\"
	stosw
	mov ax,"*"
	stosw
	xor eax,eax
	stosw
	mov [.flags],eax

	mov rdx,rsi
	lea rcx,[.path]
	call apiw.ff_file
	test eax,eax
	jg .listitA
	xor eax,eax

.listitA1:
	inc eax
	jmp	.listitE

.listitA:
	mov [.hFFile],rax
	
.listitN:
	lea rdx,[rsi+\
		WIN32_FIND_DATA.cFileName]

	mov r8d,[rsi+\
		WIN32_FIND_DATA.dwFileAttributes]

	mov eax,[rdx]
	cmp ax,002Eh
	jz	.listitB
	cmp eax,002E002Eh
	jz	.listitB

	;---  match attribs ----------
	mov rcx,rbx
	and rcx,r8
	jz	.listitC

	;--- directory override to report 
	;--- PATH and matched files

	test ecx,\
		FILE_ATTRIBUTE_DIRECTORY
	jnz	.listitM

	;--- feed RCX path
	;--- feed RDX w32fnd 
	;--- feed R8 lenpath
	;--- feed R9 param

	mov eax,[.flags]
	test eax,eax
	jz	.listitC

.listitM:
	mov r8d,[.lenpath]
	xor eax,eax
	lea rdi,[.path]
	mov rcx,rdi
	add rdi,r8
	stosw
	mov r9,r15
	mov rdx,rsi
	call r14
	mov word[rdi-2],"\"
	test eax,eax
	jz	.listitF

.listitC:
	mov eax,[rsi+\
		WIN32_FIND_DATA.dwFileAttributes]
	test al,\
		FILE_ATTRIBUTE_DIRECTORY
	jz	.listitB

	;--------- match level -------
	test r12,r12
	jz	.listitB

	lea rdi,[.path]
	mov ecx,[.lenpath]

	lea rdx,[rsi+\
		WIN32_FIND_DATA.cFileName]
	add rdi,rcx

	push rdi
	push rsi
	mov al,"\"
	mov rsi,rdx
	stosw
@@:
	lodsw
	stosw
	test ax,ax
	jnz	@b

	lea rcx,[.path]
	call .listit
	xor edx,edx
	pop rsi
	pop rdi
	mov [.flags],edx	;--- no reloop after dirs
	test eax,eax
	mov word[edi],dx
	jz	.listitF

.listitB:
	mov rdx,rsi
	mov rcx,[.hFFile]
	call apiw.fn_file
	test eax,eax
	jnz	.listitN
	inc eax

.listitF:
	push rax
	mov rcx,[.hFFile]
	call apiw.f_close
	mov edx,[.flags]
	pop rax

	test edx,edx
	jnz	.listitA2

.listitE:
	mov rdi,[.rdi]
	mov rsi,[.rsi]
	mov ecx,[.nitems]
	mov rsp,rbp
	inc r12
	pop rbp
	ret 0

