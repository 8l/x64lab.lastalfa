  
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


	;#---------------------------------------------------ö
	;|               UTF16 routines                      |
	;ö---------------------------------------------------ü

utf16:
@using .cpts
.cpts:
	;--- in RCX uzstr
	;--- RET RCX uzstr
	;--- RET RAX (0,cpts)
	mov rdx,rcx
	xor eax,eax
	sub rcx,2
.cptsA:
	add rcx,2
	cmp ax,[rcx]
	jnz .cptsA
	sub rax,rdx
	add rax,rcx
	shr eax,1
	xchg rcx,rdx
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               UTF16                               |
	;ö---------------------------------------------------ü

@using .zsdbm
	;--- UTF16
	;--- in RCX uzstring
	;--- RET RDX len
	;--- RET RAX hash 
.zsdbm:
	push rcx
	mov r9,6121
.zsdbmA:
	movzx eax,word[rcx]
	test eax,eax
	jnz .zsdbmB
	pop rdx
	xchg r9,rax
	xchg rcx,rdx
	sub rdx,rcx
	ret 0
.zsdbmB:
	mov r8,r9
	xor al,ah
	mov rdx,r9
	shl r8,17
	xor ah,ah
	shl r9,6
	add rcx,2
	add r9,rax
	add r9,r8
	sub r9,rdx
	jmp	.zsdbmA
@endusing


;@using .xsdbm
;	;--- in RSI string
;	;--- in RCX len
;	;--- RET RAX hash 
;.xsdbm:
;	push rbx
;	push rcx
;	push rsi
;	xor rax,rax
;	mov r8,rcx
;	;xor rbx,rbx
;	mov rbx,6121
;.xsdbmA:
;	mov al,[rsi]
;	mov rcx,rbx
;	xor al,[rsi+1]
;	mov rdx,rbx
;	shl rcx,17
;	shl rbx,6
;	add rsi,2
;	add rbx,rax
;	add rbx,rcx
;	sub rbx,rdx
;	dec r8
;	jnz	.xsdbmA
;	xchg rbx,rax
;	pop rsi
;	pop rcx
;	pop rbx
;	ret 0
;@endusing

	;#---------------------------------------------------ö
	;|               UTF16                               |
	;ö---------------------------------------------------ü

@using .copyz
	;--- in RCX src
	;--- in RDX dest
	;--- RET rax len (no zero)
	;--- but copy zero too
.copyz:
	xor eax,eax
	test rcx,rcx
	jnz	.copyzB
	ret 0

.copyzB:
	test rdx,rdx
	jnz	.copyzC
	ret 0

.copyzC:
	mov rax,rdx
	xchg rcx,rsi
	shl rax,16
	xchg rdx,rdi

.copyzA:
	lodsw
	stosw
	test ax,ax
	jnz	.copyzA
	shr rax,16
	sub rax,rdi
	neg rax
	dec eax
	dec eax
	xchg rcx,rsi
	xchg rdx,rdi
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               UTF16                               |
	;ö---------------------------------------------------ü

@using .to8
.to8:
	;--- in RCX utf16 zero-string
	;--- in RDX dest buffer
	;--- ret CF error
	;--- ret RCX num cpts
	;--- ret RAX dest len
	push rdi
	push rsi
	push rbx

	mov rdi,rdx
	mov r10,rdx
	mov rsi,rcx

	xor rdx,rdx
	xor r9,r9

.to8A:
	;--- TODO: Check endianess and FFFD
	add rdi,rdx
	xor rax,rax
	xor rcx,rcx
	lodsw
	test eax,eax
	jnz	.to8B
	mov rcx,rdi
	stosw
	sub rcx,r10
	mov rax,rcx
	clc
	jmp	.exit_to8A

.to8B:
	movzx r8,ax
	cmp eax,HI_SUR_MIN
	sbb ecx,ecx
	cmp eax,HI_SUR_MAX+1
	adc ecx,0
	jz .no_sur

	lodsw
	test eax,eax
	jz	.err_sur
	cmp eax,LO_SUR_MIN
	sbb ecx,ecx
	cmp eax,LO_SUR_MAX+1
	adc ecx,0
	jz .err_sur

	sub eax,LO_SUR_MIN
	add eax,SUR_BASE
	xchg rax,r8
	sub eax,HI_SUR_MIN
	shl eax,10
	add rax,r8

.no_sur:
	mov ecx,3
	cmp eax,110000h	;4
	sbb edx,edx
	adc ecx,0
	xor r8,r8
	cmp eax,10000h	;3
	dec r8w
	sbb ecx,0
	cmp eax,800h		;2
	dec r8w
	sbb ecx,0		
	cmp eax,80h			;1
	sbb ecx,0
	test edx,edx
	cmovz rax,r8		;---	REPLACE_CPT,ecx=3

	add r9,rcx
	mov rdx,rcx
	xor r8,r8
	mov rbx,rax
	dec cl
	jz .onebyteA
	mov r8l,87h
	ror r8l,cl
	and r8l,0F0h
	
	or al,80h
	and al,0BFh
	mov [rdi+rcx],al
	shr ebx,6
	mov al,bl
	dec cl
	jz .onebyte

	or al,80h
	and al,0BFh
	mov [rdi+rcx],al
	shr ebx,6
	mov al,bl
	dec cl
	jz .onebyte

	or al,80h
	and al,0BFh
	mov [rdi+rcx],al
	shr ebx,6
	mov al,bl
	dec cl
	jz .onebyte
	
.onebyte:
	or al,r8l

.onebyteA:
	mov [rdi+rcx],al
	jmp	.to8A
	
.err_sur:
	xor rax,rax
	stc

.exit_to8:
	stosw
.exit_to8A:
	mov rcx,r9
	pop rbx
	pop rsi
	pop rdi
	ret 0
@endusing
;display_decimal $-.to_utf8

	;#---------------------------------------------------ö
	;|               UTF8  routines                      |
	;ö---------------------------------------------------ü
utf8:
@using .copyz
	;--- in RCX src
	;--- in RDX dest
	;--- RET rax len (no zero)
	;--- but copy zero too
.copyz:
	xor eax,eax
	test rcx,rcx
	jnz	.copyzB
	ret 0

.copyzB:
	test rdx,rdx
	jnz	.copyzC
	ret 0

.copyzC:
	mov rax,rdx
	xchg rcx,rsi
	shl rax,8
	xchg rdx,rdi

.copyzA:
	lodsb
	stosb
	test al,al
	jnz	.copyzA
	shr rax,8
	sub rax,rdi
	neg rax
	dec eax
	xchg rcx,rsi
	xchg rdx,rdi
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               UTF8                                |
	;ö---------------------------------------------------ü

@using .zsdbm
	;--- UTF8
	;--- in RCX uzstring
	;--- RET RDX len
	;--- RET RAX hash 
.zsdbm:
	push rcx
	mov r9,6121
.zsdbmA:
	movzx eax,byte[rcx]
	test al,al
	jnz .zsdbmB
	pop rdx
	xchg r9,rax
	xchg rcx,rdx
	sub rdx,rcx
	ret 0
.zsdbmB:
	mov r8,r9
	mov rdx,r9
	shl r8,17
	shl r9,6
	inc rcx
	add r9,rax
	add r9,r8
	sub r9,rdx
	jmp	.zsdbmA
@endusing

	;#---------------------------------------------------ö
	;|               UTF8                                |
	;ö---------------------------------------------------ü

@using .cpts
.cpts:
	;--- in RCX zeroterm utf8 string
	;--- ret RAX cpts
	;--- ret RCX actual utf8 stream len
	push rbx
	mov r8,rsi
	xor r9,r9
	mov rsi,rcx
	xor ebx,ebx
	xor rcx,rcx

.cptsA:
	call art.get_codepoint
	jz	.exit_cpts
	jl	.err_cpts
	add rsi,rcx
	add r9,rcx
	inc rbx
	jmp	.cptsA

.err_cpts:
	xor ebx,ebx

.exit_cpts:
	xchg rax,rbx
	xchg r8,rsi
	xchg rcx,r9
	pop rbx
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               UTF8                                |
	;ö---------------------------------------------------ü

@using .to16
align 4
.to16:
	;--- in RCX source
	;--- in RDX dest
	;--- RET CF error
	;--- RET RAX len dest
	;--- RET RDX len source
	push rdi
	push rsi
	push rbx
	xor r8,r8
	mov rsi,rcx
	mov rdi,rdx
	mov r9,rsi
	jmp	.to_utf16B

	;--- TODO: flag if store BOM here ----
.to_utf16A:
	inc r8
	inc r8
	stosw

.to_utf16B:
	;--- check for FFFD ?
	call art.get_codepoint
	jle	.exit_to_utf16
	add rsi,rcx
	xor rdx,rdx
	dec cl
	jz .to_utf16A
	dec cl
	jnz .try_3units

	;---2 units utf8 -> utf16
	xchg ah,al
	mov dh,ah
	and dh,1Fh
	and al,3Fh
	cbw
	shr edx,2
	or eax,edx
	jmp	.to_utf16A

.try_3units:
	bswap eax
	xchg rdx,rax
	dec cl
	jnz .try_4units
	shr edx,8
	;--- zzzzyyyy yyxxxxxx   1110zzzz 10yyyyyy 10xxxxxx
	;--- 3 utf8 cpt -> utf16
	and edx,000F'3F3Fh
	shrd eax,edx,6
	or al,dh
	ror eax,6
	shr edx,8
	or al,dh
	rol eax,12
	jmp	.to_utf16A

.try_4units:
	;--- convert to scalar ---
	and edx,0073F'3F3Fh
	shrd eax,edx,6
	or al,dh
	ror eax,6
	shr edx,16
	or al,dl
	ror eax,6
	shr edx,8
	or al,dh
	rol eax,18

	;--- create surrogate ----
	mov edx,eax
	shr eax,10
	and edx,3FFh
	add eax,0D7C0h
	or edx,0DC00h
	stosw
	inc r8
	inc r8
	xchg eax,edx
	jmp	.to_utf16A
	
;.err_.to_utf16:
;	xor rax,rax
;	stc
	
.exit_to_utf16:
	stosw
	mov rax,r8
	jc	@f
	mov rdx,rsi
	sub rdx,r9
	
@@:
	pop rbx
	pop rsi
	pop rdi
	ret 0
@endusing
