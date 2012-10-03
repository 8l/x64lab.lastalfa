  
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



bridge:
;	match m,MODULE {	display `m }
@using .attach
.attach:
	;--- in RCX modname bridge
	;--- in RDX path
	push rbx
	push rdi
	push rsi

	xor rax,rax
	sub rsp,FILE_BUFLEN
	xor r8,r8
	mov rbx,rcx
	mov r8w,[rcx+8]	;--- size of unicode string
	mov rdi,rsp
	add rcx,10
	mov rsi,rcx
	add rsi,r8				;--- ptable to fill
	
	push rax
	push uzDll
	push rcx
	test rdx,rdx
	jz	@f
	push uzSlash
	push rdx
@@:
	push rdi
	push 0
	call art.catstrw

	mov rdx,LOAD_WITH_ALTERED_SEARCH_PATH
	mov rcx,rdi
	call apiw.loadlib
	test eax,eax
	jz .err_attach

	mov [rbx],rax		
	mov rdi,rax
	mov edx,[rax+80h+18h+14h]	;--- DOS headsize + Filehead + Base of Code offset
	add rdi,rdx								;--- now in RDI base of code
	xor rax,rax
	mov r9,rdi

.try_func:
	lodsd
	test eax,eax
	jz	.exit_attach
	mov r8,rsi
	mov edx,eax
	mov rsi,rdi
	
.try_hash:
	lodsq
	test eax,eax
	jz	.err_hash
	cmp eax,edx
	jnz	.try_hash
	shr rax,32
	add rax,[rbx]
	mov [r8],rax

.err_hash:
	mov rdi,r9
	mov rsi,r8
	add rsi,8
	jmp	.try_func

.exit_attach:
	mov rax,[rbx]

.err_attach:
	add rsp,FILE_BUFLEN
	pop rsi
	pop rdi
	pop rbx
	ret 0
@endusing

@using .detach
.detach:
	;--- in RCX modname bridge
	push rsi
	xor rax,rax
	mov rsi,rcx
	lodsq
	test rax,rax
	jz	.err_detach
	xor rdx,rdx
	mov rcx,rax
	mov [rsi-8],rdx
	call apiw.freelib
	xor rax,rax
	lodsw
	xor rdx,rdx
	add rsi,rax

.next_detach:
	lodsd
	test eax,eax
	jz	.err_detach
	mov [rsi],rdx
	add rsi,8
	jmp	.next_detach

.err_detach:
	pop rsi
	ret 0
@endusing
