  
  ;#-------------------------------------------------ß
  ;|          lang MPL 2.0 License                   |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä


lang:
	virtual at rbx
		.res_r RESDEF
	end virtual

.attach:
	ret 0

.detach:
	ret 0

.info_uz:
	;--- ret RAX ave ulen/ids
	;--- ret ECX ids
	;--- ret RDX lang
	;--- ret R8 header
	;--- ret R9 ulen
	;--- ret R10 lcid
	mov r8,res_h
	movzx ecx,[r8+\
		RESTABLE.ids]
	movzx eax,[r8+\
		RESTABLE.ulen]
	xor edx,edx
	test ecx,ecx
	mov r9,rax
	movzx r10,[r8+\
		RESTABLE.lcid]
	jz	.info_uzE
	div ecx

.info_uzE:
	mov rdx,qword[r8+\
		RESTABLE.lang]
	ret 0



.get_uz:
	;--- in RCX id
	;--- in DL type DH set
	;--- in R8 room for copied string
	;---
	;--- to get original string ------
	;--- in RCX id
	;--- RDX=0
	;--- RET RAX len
	;--- RET RCX dest string
	mov eax,ecx
	ror dx,8
	and eax,0FFh
	mov r10,res_r

	movzx eax,\
		word[res_i+rax*2]
	jmp	.get_uzN

.get_uzN1:
	movzx eax,\
		[r11+RESDEF.next]

.get_uzN:
	inc ax
	jz	.get_uzE
	dec ax
	lea r11,[rax+r10]
	cmp cx,[r11+\
		RESDEF.id]
	jnz	.get_uzN1

	test edx,edx
	jnz	.get_uzS
	lea rax,[r11+\
		sizeof.RESDEF]
	movzx ecx,[r11+\
		RESDEF.len]
	ret 0

.get_uzS:
	;--- check set
	cmp dl,\
		[r11+RESDEF.set]
	jnz	.get_uzN1
	push r8

	mov al,[r11+\
		RESDEF.type]
	shr edx,8
	and al,U8 or U16
	and dl,U8 or U16
	and dl,al
	jnz	.get_uzC

	lea rcx,[r11+\
		sizeof.RESDEF]
	mov rdx,r8
	mov r9,utf8.to16
	cmp al,U8
	jz	.get_uzC1
	mov r9,utf16.to8
	jmp .get_uzC1

.get_uzC:
	;--- copy it
	lea rcx,[r11+\
		sizeof.RESDEF]
	mov rdx,r8
	mov r9,utf8.copyz
	cmp al,U8
	jz	.get_uzC1
	mov r9,utf16.copyz

.get_uzC1:
	call r9
	pop rcx

.get_uzE:
	ret 0

;.utf16:
;	ret 0