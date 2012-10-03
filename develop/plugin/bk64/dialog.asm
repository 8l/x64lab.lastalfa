  
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


dlg:

.open:
	;--- in RCX title
	;--- in RDX filespec
	;--- in R8 flags
	;--- in R9 startdir

	;--- on SINGLE SELECT
	;--- ret RAX path+filename

	;--- on FOS_ALLOWMULTISELECT
	;------------------------------------------------
	;--- ret RAX membuf of textptrs: free art.a16free
	;--- DQ num items
	;--- DQ PATH,
	;--- DQ text pointers: free using CoTaskMemFree

	push rbp
	push rbx
	push rdi
	push rsi
	push r12

	mov rbp,rsp
	xor eax,eax
	and rsp,-16
	mov r12,r8
	sub rsp,60h
	mov rsi,rsp
	mov rbx,r9

	@comptr \
		.pFod,rsi,iFileOpenDialog,\
		.pShia,rsi+8,iShellItemArray,\
		.pShi,rsi+16,iShellItem,\
		.nItems,rsi+24,dq ?,\
		.options,rsi+32,dq ?,\
		.pPath,rsi+40,dq ?,\
		.pStartShi,rsi+48,iShellItem,\
		.pRet,rsi+56,dq ?,\
		.title,rsi+64,dq ?,\
		.fspec,rsi+72,dq ?,\
		.tmpShi,rsi+80,iShellItem,\
		.pFile,rsi+88,dq ?

	mov [.title],rcx
	mov [.fspec],rdx

	mov rdi,rsp
	mov ecx,8
	rep stosq
	xor edi,edi		;--- ret value
		
	call apiw.co_init

	test rbx,rbx
	jz	.openF

	mov rcx,rbx
	sub rsp,20h
	lea r9,[.pStartShi]
	lea r8,[iid_Shi]
	xor edx,edx
	call [SHCreateItemFromParsingName]
	add rsp,20h
	test eax,eax
	jnl	.openF

	xor eax,eax
	mov [.pStartShi],rax

.openF:
	lea r10,[.pFod]
	mov r9,iid_FileOD
	mov r8,1
	xor edx,edx
	mov rcx,clsid_FileOD
	call apiw.co_createi
	test eax,eax
	jnz	.openE

	xor eax,eax
	xchg rdx,[.title]
	test rdx,rdx
	mov [.title],rax
	jz .openD

	@comcall .pFod->SetTitle
	test eax,eax
	jl .openE

.openD:
	xor eax,eax
	xchg rcx,[.fspec]
	test rcx,rcx
	mov [.fspec],rax
	jz .openD1

	mov rdx,[rcx]
	lea r8,[rcx+8]
	and edx,0FFh		
	@comcall .pFod->SetFileTypes
	test eax,eax
	jl .openE
	
.openD1:
	mov rdx,r12
	@comcall .pFod->SetOptions
	test eax,eax
	jl .openE

	mov rdx,[.pStartShi]
	test rdx,rdx
	jz	.openD2
	@comcall .pFod->SetFolder

.openD2:
	xor edx,edx
	@comcall .pFod->Show
	test eax,eax
	jl .openE

	test r12,\
		FOS_ALLOWMULTISELECT
	jnz .openMS

.openSS:
	;--- single selection -------
	xor rbx,rbx
	lea rdx,[.pShi]
	@comcall .pFod->GetResult
	test eax,eax
	jl .openB

	lea r8,[.pPath]
	mov rdx,SIGDN_FILESYSPATH
	@comcall .pShi->GetDisplayName

	;--- check FOLDERS root is X:\0 unicode
	;--- remove backslash ----------------
	xor ecx,ecx
	mov rax,[.pPath]
	test rax,rax
	jz .openSSA
	cmp cx,[rax+6]
	jnz	.openSSA
	mov [rax+4],cx
	
.openSSA:
	mov rdi,[.pPath]
	@comcall .pShi->\
		iUnknown.Release
	jmp .openB

.openMS:
	lea rdx,[.pShia]
	@comcall .pFod->GetResults
	test eax,eax
	jl .openB

	lea rdx,[.nItems]
	@comcall .pShia->GetCount
	mov rbx,[.nItems]
	test eax,eax
	jl .openC
	test ebx,ebx
	jz .openC

	lea r8,[.tmpShi]
	xor edx,edx
	@comcall .pShia->GetItemAt
	test eax,eax
	jl .openC

.openD6:
	lea rdx,[.pShi]
	@comcall .tmpShi->GetParent
	test eax,eax
	jl .openC

	lea r8,[.pPath]
	mov rdx,SIGDN_FILESYSPATH
	@comcall .pShi->GetDisplayName

	;--- case path is root is X:\0 unicode
	;--- remove backslash ----------------
	xor ecx,ecx
	mov rax,[.pPath]
	cmp cx,[rax+6]
	jnz	.openD3
	mov [rax+4],cx

.openD3:
	@comcall .pShi->\
		iUnknown.Release

.openD4:
	@comcall .tmpShi->\
		iUnknown.Release
	
	mov rcx,rbx
	add ecx,4			;--- 1 ppath + 1 nitems 2zero
	shl ecx,3
	call art.a16malloc
	test rax,rax
	jz .openC

	mov rdi,rax
	mov [rdi],rbx
	add rdi,8
	neg rbx
	
	dec rbx
	mov [.pRet],rax	
	jmp .openA2

.openA:
	lea r8,[.pShi]
	xor eax,eax
	mov rdx,rbx
	mov [r8],rax
	mov [rdi],rax
	mov [.pPath],rax
	add rdx,[.nItems]
	@comcall .pShia->\
		GetItemAt
	test eax,eax
	jl .openC

	lea r8,[.pPath]
	mov rdx,SIGDN_NORMALDISPLAY
	@comcall .pShi->\
		GetDisplayName
	test eax,eax
	jl .openC

	@comcall .pShi->\
		iUnknown.Release

.openA2:
	mov rax,[.pPath]
	mov [rdi],rax
	add rdi,8
	inc rbx
	jnz	.openA
	mov rdi,[.pRet]

.openC:
	@comcall .pShia->\
		iUnknown.Release

.openB:
	@comcall .pFod->\
		iUnknown.Release

.openE:
	mov rax,[.pStartShi]
	test rax,rax
	jz .openE1
	
	@comcall .pStartShi->\
		iUnknown.Release

.openE1:
	call apiw.co_uninit
	mov rax,rdi
	mov rdx,rbx
	mov rsp,rbp
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0
