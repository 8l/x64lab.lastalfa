  
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


mnu:
	virtual at rbx
		.mii MENUITEMINFOW
	end virtual

	;#---------------------------------------------------ö
	;|                   SETUP                           |
	;ö---------------------------------------------------ü
	
.setup:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13

	mov rbp,rsp
	and rsp,-16

;---	mov rcx,[hMnuMain]
;---	test rcx,rcx
;---	jz	@f
;---	call apiw.mnu_destroy
	
;---@@:
	;--- create main menu
	call apiw.mnu_create
	mov [hMnuMain],rax

	xor r9,r9
	mov r8,[pOmni]
	mov rdx,tMP_WSPACE
	mov rcx,rax
	call .mp_add

	mov r9,1
	mov r8,rax
	mov rdx,tMP_FILE
	mov rcx,[hMnuMain]
	call .mp_add

	mov r9,2
	mov r8,rax
	mov rdx,tMP_EDIT
	mov rcx,[hMnuMain]
	call .mp_add

		mov r9,6
		mov r8,rax
		mov rdx,tMP_SCI
		mov rcx,[tMP_EDIT]
		call .mp_add

	mov r9,3
	mov r8,rax
	mov rdx,tMP_CONF
	mov rcx,[hMnuMain]
	call .mp_add

	mov r9,1
	mov r8,rax
	mov rdx,tMP_LANG
	mov rcx,[tMP_CONF]
	call .mp_add

		mov r9,3
		mov r8,rax
		mov rdx,tMP_DEVT
		mov rcx,[tMP_CONF]
		call .mp_add

	mov r9,4
	mov r8,rax
	mov rdx,tMP_PATH
	mov rcx,[hMnuMain]
	call .mp_add

	mov rcx,[hMain]
	call apiw.mnu_draw

.setupE:
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0


.mp_add:
	;--- in RCX hParent
	;--- in RDX sequence
	;--- in R8 ptr to OMNI
	;--- in R9 position
	;--- ret RAX ptr to OMNI

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

	sub rsp,\
		sizea16.MENUITEMINFOW
		
	mov r15,r9	;--- pos
	mov rsi,rdx
	mov r12,rcx
	mov rbx,rsp
	mov rdi,r8
	mov r14,rdx

	call apiw.mnp_create
	mov r13,rax
	mov [.mii.hSubMenu],rax

.mp_addN:
	xor eax,eax
	mov [.mii.dwItemData],rdi
	lodsw
	test eax,eax
	jnz	.mp_addB
	mov rax,rdi
	jmp	.mp_addE

.mp_addB:
	inc ax
	jnz	.mp_addB1
	;--- separator
	mov [.mii.wID],eax
	mov [.mii.fType],\
		MFT_SEPARATOR
	mov eax,MIIM_ID
	xor edx,edx
	jmp	.mp_addD

.mp_addB1:
	dec eax
	stosw
	mov ecx,eax
	mov [.mii.wID],eax

	lodsw	
	stosw	;--- store icon

	add rdi,4
	mov [.mii.dwTypeData],rdi

	mov r8,rdi
	mov edx,U16
	call [lang.get_uz]

	mov word[rdi-2],ax	;--- len
	add rdi,rax
	xor eax,eax
	stosw

	lodsw
	mov ecx,eax
	and eax,MFT_STRING\
		or MFT_BITMAP\
		or MFT_MENUBARBREAK\
		or MFT_MENUBREAK\
		or MFT_OWNERDRAW\   
		or MFT_RADIOCHECK\   
		or MFT_SEPARATOR\  
		or MFT_RIGHTORDER\   
		or MFT_RIGHTJUSTIFY
	mov [.mii.fType],eax

	and ecx,MFS_DISABLED\
		or MFS_GRAYED\
		or MFS_CHECKED\  
		or MFS_HILITE\ 
		or MFS_DEFAULT  
	mov [.mii.fState],ecx

	lodsw
	and eax,MIIM_ID \
		or MIIM_SUBMENU\
		or MIIM_STRING\
		or MIIM_FTYPE\
		or MIIM_STATE\
		or MIIM_CHECKMARKS\
		or MIIM_TYPE\
		or MIIM_DATA\
		or MIIM_BITMAP

.mp_addD:

	mov [.mii.fMask],eax
	mov r9,rbx
	mov rdx,r15
	mov rcx,r12
	call apiw.mni_ins_bypos
	inc r15

	test [.mii.fMask],\
		MIIM_SUBMENU
	jz	.mp_addN
	xor r15,r15
	mov r12,r13
	mov [r14],r13		;--- store tMP
	jmp	.mp_addN
	
.mp_addE:
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

	;#---------------------------------------------------ö
	;|                GET_DIR                            |
	;ö---------------------------------------------------ü

;.get_dir:
;	;--- RET RAX DIR,appdir
;	;--- ret RDX 0,rdir
;	sub rsp,\
;		sizeof.MENUITEMINFOW
;	xor eax,eax
;	mov [rsp+\
;		MENUITEMINFOW.fMask],\
;		MIIM_DATA
;	mov [rsp+\
;		MENUITEMINFOW.dwItemData],\
;		rax
;	mov r9,rsp
;	mov edx,MP_PATH
;	mov rcx,[hMnuMain]
;	call apiw.mni_get_byid
;
;	mov r8,[appDir]
;	mov rax,[rsp+\
;		MENUITEMINFOW.dwItemData]
;	mov rdx,[r8+\
;		DIR.rdir]
;	test eax,eax
;	cmovz rax,r8
;
;	add rsp,\
;		sizeof.MENUITEMINFOW
;	cmp rax,r8
;	cmovnz rdx,[rax+\
;		DIR.rdir]
;	ret 0

	;#---------------------------------------------------ö
	;|                RESET                              |
	;ö---------------------------------------------------ü

.reset:
	;--- in RCX hMenuPopup
	push rbx
	push rdi

	mov rbx,rcx
	call apiw.get_mnuicount
	test eax,eax
	jz	.resetE
	mov rdi,rax
	jmp	.resetB

.resetA:	
	mov r8,MF_BYPOSITION	
	mov rdx,rdi
	mov rcx,rbx
	call apiw.mnu_del

.resetB:
	dec rdi
	jns .resetA
	
.resetE:	
	pop rdi
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|                SET_DIR                            |
	;ö---------------------------------------------------ü

.set_dir:
	;--- in RCX DIRslot
;@break
	push rbp
	push rbx

	mov rbp,rsp
	and rsp,-16
	mov rbx,rcx

	sub rsp,\
		sizeof.MENUITEMINFOW+\
		FILE_BUFLEN
	mov rbx,rsp
	lea rax,[rsp+\
		sizeof.MENUITEMINFOW]

	mov [.mii.fMask],\
		MIIM_STRING or \
		MIIM_FTYPE or \
		MIIM_DATA

	mov [.mii.fType],\
		MFT_STRING or\
		MFT_RIGHTJUSTIFY

	mov [.mii.dwItemData],rcx
	lea rcx,[rcx+DIR.dir]
	push rax

	push 0
	push uzBlackLxPTri
	push uzSpace
	push uzCPar
	push rcx
	push uzOPar
	push rax
	push 0
	call art.catstrw

	pop [.mii.dwTypeData]
	
	mov r9,rbx
	mov edx,MP_PATH
	mov rcx,[hMnuMain]
	call apiw.mni_set_byid

	mov rcx,[hMain]
	call apiw.mnu_draw

	mov rsp,rbp
	pop rbx
	pop rbp
	ret 0


