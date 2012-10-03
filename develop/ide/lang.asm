  
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

lang:
	virtual at rbx
		.mii MENUITEMINFOW
	end virtual


.reload:
	;--- in RCX lcid
	;--- RET IDYES IDNO
	push rbp
	push rbx
	push rsi
	mov rbp,rsp

	sub rsp,\
		FILE_BUFLEN

	mov rbx,rcx		;--- lcid
	mov rsi,rsp

	xor r9,r9
	mov r8,\
		LOCALE_NAME_MAX_LENGTH
	mov rdx,rsi
	mov rcx,rbx
	call apiw.lcid2name

	mov ecx,eax
	test ecx,ecx
	mov eax,IDNO
	jz	.reloadE

	mov rbx,[pConf]
	mov [rbx+\
		CONFIG.lcid],ax

	mov rcx,rsi
	lea rdx,[rbx+\
		CONFIG.lang16]
	call utf16.copyz

	mov rcx,rsi
	lea rdx,[rbx+\
			CONFIG.lang8]
	call utf16.to8

	mov r8,rsi
	mov edx,U16
	mov ecx,UZ_RESTART
	call [lang.get_uz]

	mov rdx,rsi
	mov r8,uzTitle
	mov rcx,[hMain]
	call apiw.msg_yn

.reloadE:
	mov rsp,rbp
	pop rsi
	pop rbx
	pop rbp
	ret 0


.enum:
	push rbp
	push rdi
	mov rbp,rsp

	mov rcx,[tMP_LANG]
	call mnu.reset

	sub rsp,\
	 FILE_BUFLEN+20h
	
	xor edx,edx
	mov rdi,rsp

	mov al,"*"
	stosw
	mov rax,qword[uzDll]
	stosq
	xor eax,eax
	stosw
	stosd

	stosq
	stosq

	;--- check for [lang\???] files
	push rdx
	push uzLangName
	push rdi
	push rdx
	call art.catstrw

	;---	in RCX upath		;--- example "E:" or "E:\mydir"
	;---	in RDX uattr		;--- FILE_ATTRIBUTE_HIDDEN
	;---	in R8  ulevel		;--- nesting level to stop search 0=all
	;---	in R9  ufilter	;--- "*.asm"
	;---	in R10 ucback   ;--- address of a calback
	;---	in R11 uparam   ;--- user param
	;---------------------------------------------------
	lea r11,[rsp+10h]
	mov r10,.cb_lang
	xor r8,r8
	inc r8
	mov r9,rsp
	mov edx,FILE_ATTRIBUTE_DIRECTORY
	mov rcx,rdi
	call [bk64.listfiles]

	mov rsp,rbp
	pop rdi
	pop rbp
	ret 0


.cb_lang:
	;---  the calback receives those args
	;--- in RCX path
	;--- in RDX w32fnd 
	;--- in R8h lenpath
	;--- in R9 uparam
	;--- ret RAX = 1 continue, 0 stop search

	test rdx,rdx
	jz	.cb_langA

	mov eax,[rdx+\
		WIN32_FIND_DATA.dwFileAttributes]
	test eax,\
		FILE_ATTRIBUTE_DIRECTORY
	jz  .cb_langA

	mov r10,[r9]
	lea rax,[rdx+\
		WIN32_FIND_DATA.cFileName]
	inc dword[r9]
	mov rdx,r10
	mov rcx,rax
	call .set_item

 .cb_langA:
	xor eax,eax
	inc eax
	ret 0


.set_item:
	;--- in RCX subpath [en]
	;--- in RDX ord id
	push rbp
	push rbx
	push rsi
	push rdi
	push r12
	push r13

	mov rbp,rsp
	sub rsp,\
		sizeof.MENUITEMINFOW+\
		FILE_BUFLEN

	mov rbx,rsp
	mov rsi,rcx
	lea rdi,[rsp+\
		sizeof.MENUITEMINFOW]
	mov r12,rdx
	
	;--- check against bad locales
	;--- min VISTA
	mov rcx,rsi
	call apiw.is_locname
	test eax,eax
	jz	.set_itemE

	;--- check [lang\xxxx\lang.dll]
	xor edx,edx

	push rdx
	push uzDll
	push uzLangName
	push uzSlash
	push rsi
	push uzSlash
	push uzLangName
	push rdi
	push rdx
	call art.catstrw

	mov rcx,rdi
	call art.is_file
	jz	.set_itemE

	mov r9,4
	mov r8,rdi
	mov edx,\
		LOCALE_ILANGUAGE or \
		LOCALE_RETURN_NUMBER
	mov rcx,rsi
	call apiw.get_locinfox
	mov eax,[rdi]
	mov r13,rax

	mov eax,"["
	stosw
	mov rcx,rsi
	mov rdx,rdi
	call utf16.copyz
	add rdi,rax
	mov eax,"]"
	stosw
	mov al,09h
	stosw

	mov r9,\
		LOCALE_NAME_MAX_LENGTH
	mov r8,rdi
	mov edx,\
		LOCALE_SNATIVELANGUAGENAME
	mov rcx,rsi
	call apiw.get_locinfox
	add rdi,rax
	add rdi,rax
	sub rdi,2
;---	mov eax,')'
;---	stosw
	xor eax,eax
	stosd
	
	mov [.mii.fMask],\
		MIIM_STRING or \
		MIIM_FTYPE or \
		MIIM_DATA or \
		MIIM_ID or \
		MIIM_CHECKMARKS or \
		MIIM_STATE

	mov [.mii.hbmpChecked],rax
	mov [.mii.hbmpUnchecked],rax

	mov rdx,[pConf]
	mov [.mii.fState],eax
	mov ecx,MFS_CHECKED
	cmp r13w,[rdx+\
		CONFIG.lcid]
	cmovz eax,ecx
	mov [.mii.fState],eax
	
	mov [.mii.fType],\
		MFT_STRING

	mov rax,r12
	add eax,MI_LANG
	mov [.mii.wID],eax

	mov [.mii.dwItemData],r13

	lea rax,[rsp+\
		sizeof.MENUITEMINFOW]
	mov [.mii.dwTypeData],rax
	
	mov r9,rbx
	mov rdx,r12
	mov rcx,[tMP_LANG]
	call apiw.mni_ins_bypos

	lea r8,[rsp+\
		sizeof.MENUITEMINFOW]
	mov rdx,r13
	call art.cout2XU

.set_itemE:
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0
