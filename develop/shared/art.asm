  
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
	;|     Assembly Run Time                             |
	;ö---------------------------------------------------ü

art:

@using .pmc_fuerst
	;--- in RAX seed
	;--- RET RAX rnd
	;--- Fuerst's improvements on Park-Miller-Carta prng
	;--- http://sites.google.com/site/x64lab/home/reloaded-algorithms
.pmc_fuerst:
    mov ecx,16807
    mul ecx
    add eax,eax
    adc edx,edx
    add edx,edx
    add eax,edx
    sbb edx,edx
    shr eax,1
    sub eax,edx
    ret 0
@endusing


@using .xmmcopy
.xmmcopy:
	;--- in RCX source
	;--- in RDX dest
	;--- in R8 len
	;--- RET RAX copied len
	;--- untouched R9
	push rdi
	push rsi
	mov eax,r8d
	xchg rsi,rcx
	push rax
	xchg rdi,rdx

	mov ecx,eax
	mov r8,rsi
	or r8,rdi
	and r8,0Fh
	test r8,r8
	jnz	.xcopyD1

	and ecx,63
	shr eax,6
	jz	.xcopyB
.xcopyA:
	movdqa xmm0,[rsi]
	movdqa xmm1,[rsi+16]
	movdqa xmm2,[rsi+32]
	movdqa xmm3,[rsi+48]
	movdqa [rdi],xmm0
	movdqa [rdi+16],xmm1
	movdqa [rdi+32],xmm2
	movdqa [rdi+48],xmm3
	add rsi,64
	add rdi,64
	dec eax
	jnz .xcopyA
.xcopyB:
	btr ecx,5
	jnc .xcopyC
	movdqa xmm0,[rsi]
	movdqa [rdi],xmm0
	movdqa xmm1,[rsi+16]
	movdqa [rdi+16],xmm1
	add rsi,32
	add rdi,32
.xcopyC:
	btr ecx,4
	jnc	.xcopyD
	movsq
	movsq
.xcopyD:
	btr ecx,3
	jnc	.xcopyD1
	movsq
.xcopyD1:
	rep movsb
	pop rax
	pop rsi
	pop rdi
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                .ZEROMEM  		                     |
	;ö---------------------------------------------------ü

@using .zeromem
	@align 4,0CCh
	;--- IN RCX SIZE	mod 8/16
	;--- IN RDX pointer aligned 8/16
	;--- RET RAX pointer
	;--- RET RCX size
	;--- 64 bytes routine
.zeromem:
	push rcx
	push rdx
	xchg rdi,rdx
	xor rax,rax
	test dil,8
	jz	.M16
	stosq
	sub rcx,8
.M16:
	test cl,8
	setnz al
	shr rcx,4
	jz .L8
	pxor xmm0,xmm0
.M16C:
	sub rcx,4
	jb .M16A
	movdqa [rdi],xmm0
	movdqa [rdi+16],xmm0
	movdqa [rdi+32],xmm0
	movdqa [rdi+48],xmm0
	add rdi,64
	jmp	.M16C
.M16A:
	add rcx,4
	jz	.L8
.M16B:
	movdqa [rdi],xmm0
	add rdi,16
	dec ecx
	jnz	.M16B
.L8:
	mov rcx,rax
	xor al,al
	rep stosq
	pop rax
	xchg rdi,rdx
	pop rcx
	ret 0
@endusing

@using .b2a
	;--- in al byte
.b2a:
	movzx ecx,al
	mov rdx,.b2at
	and eax,0Fh
	shr ecx,4
	mov ah,[rdx+rax]
	mov al,[rdx+rcx]
	ret 0
@endusing

@using .w2u
	;--- in ax word
.w2u:
	xor ecx,ecx
	movzx edx,ax
	mov r8,.b2at
	mov cl,dl
	and eax,0Fh
	mov al,[r8+rax]
	rol rax,16
	mov cl,dl
	shr cl,4
	mov al,[r8+rcx]
	rol rax,16
	mov cl,dh
	and cl,0Fh
	mov al,[r8+rcx]
	rol rax,16
	mov cl,dh
	shr cl,4
	mov al,[r8+rcx]
	ret 0
@endusing

@using .b2at
align 4
.b2at:
	db 30h,31h,32h,33h
	db 34h,35h,36h,37h
	db 38h,39h,41h,42h
	db 43h,44h,45h,46h
@endusing


@using .popcount64
	;--- in RCX memory aligned 64
	;--- in RDX size aligned 64
	;--- return RAX popcount
	;--- return RCX sum of ANDed bytes with 0F_

macro pop64line arg{
	pshufd xmm1,xmm5,11100100b
	movdqa xmm0,xmm4
	pand  xmm0,[rcx+arg]
	paddb xmm3,xmm0
	pshufb xmm1,xmm0
	movdqa xmm0,[rcx+arg]
	psrlw  xmm0,4
	pand  xmm0,xmm4
	movdqa xmm2,xmm5
	pshufb xmm2,xmm0
	paddb xmm2,xmm1
	paddb xmm0,xmm3
	pxor xmm3,xmm3
	psadbw xmm0,xmm3
	psadbw xmm3,xmm2
	paddq xmm6,xmm3	;--- count of bit 1
	paddq xmm7,xmm0	;--- sum of ANDed bytes with 0F_
}

	align 8
.popcount64:
	shr rdx,6
	movdqa xmm4,\
		dqword[.popc64_0F]
	movdqa xmm5,\
		dqword[.popc64_lut]
	pxor xmm3,xmm3
	pxor xmm6,xmm6
	pxor xmm7,xmm7

align 8

.popcount64A:
	prefetchnta [rcx+64*16]
	prefetchnta [rcx+64*31]

	pop64line 0
	pop64line 16
	pop64line 32
	pop64line 48

	add rcx,64
	dec rdx
	jnz	.popcount64A

	mov rdx,rsp
	and rsp,-16
	sub rsp,32
	movdqa [rsp],xmm6
	movdqa [rsp+16],xmm7
	mov rax,[rsp]
	add rax,[rsp+8]
	mov rcx,[rsp+16]
	add rcx,[rsp+24]
	mov rsp,rdx
	ret 0

	align 16
	.popc64_0F	dq 0F0F0F0F'0F0F0F0Fh,0F0F0F0F'0F0F0F0Fh
	.popc64_lut dq 03020201'02010100h,04030302'03020201h
@endusing

	;#---------------------------------------------------ö
	;|     .dreserve/.dfree/.dcommit                     |
	;ö---------------------------------------------------ü
@using .dcommit
.dcommit:
	;--- in RCX pMem
	;--- in RDX block size
	;--- RET RAX 0 or slot
	;--- RET RDX block size
	push rbp
	push rbx
	xor eax,eax
	mov rbp,rcx
	and edx,edx
	jnz	.dcommA
	or edx,10h

.dcommA:
	cmp edx,10h
	jae .dcommA1
	or edx,10h

.dcommA1:
	or edx,8
	and edx,-8
	mov ebx,edx ;--- RDX required quantity

	;--- check for existing marked block
	bsr eax,edx
	jz	.dcommA2
	sub eax,12+4
	sbb ecx,ecx
	and eax,ecx
	add eax,12
	xor ecx,ecx
	lea r8,[rbp+16+rax*4]
	cmp [r8],ecx
	jz	.dcommA2
	mov eax,[r8]
	or edx,1
	lea r9,[rbp+rax]

.dcommA3:
	cmp edx,[rbp+rax-8]
	ja .dcommA4

.dcommA5:
	add rax,rbp
	mov ecx,[rax-4]
	cmp rax,r9
	jnz	.dcommA6
	mov [r8],ecx

.dcommA6:
	xor edx,1
	mov [r9-4],ecx
	mov [rax-8],rdx ;--- set all the slot

	mov ecx,edx
	shr ecx,4
	mov r8,rax
	pxor xmm0,xmm0
	
.dcommA7:
	movdqa [rax],xmm0
	add rax,16
	dec ecx
	jnz .dcommA7
	mov [rax],rcx
	xchg rax,r8
	mov rcx,rdx
	jmp	.dcommD2
	
.dcommA4:
	mov r9,rbp
	add r9,rax
	cmp ecx,[rbp+rax-4]
	jz	.dcommA2
	mov eax,[rbp+r9-4]
	jmp	.dcommA3
	
.dcommA2:
	mov eax,ebx	;--- RDX required quantity
	mov edx,ebx
	add al,8		;--- RAX total quantity
	mov r8d,[rbp+4]
	mov r9,r8
	@nearest 4096,r9
	sub r9,r8
	cmp r9,rax
	jb .dcommB
	add [rbp+4],eax

.dcommC:
	mov edx,ebx
	lea rax,[r8+rbp+8]
	mov [rax-8],ebx
	jmp	.dcommD2

.dcommB:	
	;--- in R8 used mem
	;--- in R9 avail mem on prev page
	;--- in RAX total quantity
	mov edx,eax
	and eax,0FFFh	;--- rest
	xor edx,eax		;--- size * 4k
	shr edx,12		
	jnz	.dcommF
	dec dword[rbp]	;--- reqired mem is on bound and < 0FFFh
	js	.dcommD1
	inc edx
	shl rdx,12
	jmp	.dcommG

.dcommD1:
	inc dword[rbp]
.dcommD:
	xor eax,eax
.dcommD2:
	mov ecx,edx
	pop rbx
	pop rbp
	ret 0

.dcommF:
	cmp edx,[rbp]
	ja .dcommD					;--- not enough pages
	jnz	.dcommE					;--- in range num pages
	cmp eax,r9d						
	ja .dcommD					;--- not enough rest

.dcommE:
	sub dword[rbp],edx
	shl rdx,12
	add [rbp+4],edx

.dcommG:
	add [rbp+4],eax
	push r8
	mov rcx,rbp
	@nearest 4096,r8
	add rcx,r8
	call art.vcommit
	pop r8
	jmp	.dcommC
@endusing



;display_decimal $-.dcommit
;display 13,10

;.dtrunc:
;	;--- in RCX hMem
;	;--- in RDX trunc start
;	cmp rcx,rdx
;	jz	art.vfree

;	@nearest 16,rdx
;	mov r9,rdx
;	mov r8,rcx
;	xor eax,eax
;	mov edx,[rcx+DMEM.used]
;	add rdx,rcx
;	cmp rdx,r9
;	jbe	.dtruncA
;	mov rax,rdx
;	sub rax,r9
;	@nearest 16,rax
;	sub [rcx+DMEM.used],eax
;	shr eax,12
;	add [rcx+DMEM.apages],eax
;	push r8
;	push r9
;	@nearest 4096,r9
;	sub rdx,r9
;	mov rcx,r9
;	call art.vdecommit
;	pop rdx
;	pop rcx
;.dtruncA:
;	ret 0
@using .dfree
.dfree:
	;--- in RCX pMem
	;--- in RDX pMem or pBlock
	;--- RET RAX 0 error or pBlock
	;--- RET RCX blocksize
	cmp rcx,rdx
	jz art.vfree
	;--- mark block as free
	xor rax,rax
	test rcx,rcx
	jz	.dfreeA
	test rdx,rdx
	jz	art.vfree
	mov r8d,[rdx-8]
	test r8l,1
	jnz	.dfreeA
	sub rdx,rcx
	jle .dfreeA
	bsr eax,r8d
	jz	.dfreeA
	push rbp
	push r8
	sub eax,12+4
	sbb r9,r9
	or r8l,1
	mov rbp,rcx
	and eax,r9d
	add eax,12
	push rbx

.dfreeB:
	;--- add item to the ascending sizes-list
	lea r9,[rbp+16+rax*4]
	mov eax,[r9]
	test eax,eax
	jz	.dfreeC
	;--- in RCX RBP pMem
	;--- in RDX block - pMem
	;--- in R8 blocksize or 1
	;--- in R9 pSlot
.dfreeE:
	mov ebx,[rbp+rax-4]
	cmp r8d,[rbp+rax-8]
	jbe .dfreeC
	test ebx,ebx
	jz	.dfreeD1
	
.dfreeD:
	;--- in RAX previous
	;--- in RBX next
	;--- ours > actual
	;--- ours follows actual
	cmp r8d,[rbp+rbx-8]
	jbe .dfreeD2
	;--- ours is > previous and > next
	mov eax,[rbp+rbx-4]
	test eax,eax
	jz	.dfreeD4
	xchg eax,ebx
	jmp	.dfreeD

.dfreeD4:
	;--- our next has no next
	;--- in RAX previous
	;--- in RBX next
	mov [rbp+rbx-4],edx
	xor eax,eax
	jmp .dfreeC1

.dfreeD2:
	;--- our > previous AND < next OK
	;--- in RAX previous
	;--- in RBX next
	mov [rbp+rax-4],edx
	mov eax,ebx
	jmp	.dfreeC1

.dfreeD1:
	;--- ours > actual, no next
	;--- in RAX actual
	mov [rbp+rax-4],edx
	xor eax,eax
	jmp .dfreeC1
	
.dfreeC:
	mov [r9],edx				;--- set base

.dfreeC1:
	or byte[rbp+rdx-8],1
	mov [rbp+rdx-4],eax ;--- set next as offset
	pop rbx
	pop rcx
	mov rax,rbp
	add rax,rdx
	pop rbp

.dfreeA:
	ret 0
@endusing

@using .dreserve
.dreserve:
	;--- in RCX mem to reserve
	;--- ret RAX pMem 1 cpage
	;--- ret RCX allocated size
	@nearest 4096,ecx
	add ecx,4096
	and ecx,ecx
	mov edx,ecx
	push rcx
	call art.vreserve
	test rax,rax
	jnz	@f
	pop rcx
	ret 0
@@:
	mov rcx,rax
	mov edx,1000h
	call art.vcommit	
	pop rdx
	mov ecx,edx
	shr edx,12
	sub ecx,(sizeof.DMEM + 16 )
	dec edx
	mov [rax+DMEM.apages],edx
	mov [rax+DMEM.apages2],edx
	mov [rax+DMEM.amem],ecx
	mov [rax+DMEM.used],\
		sizeof.DMEM
.dreserveA:
	ret 0
@endusing

@using .dclear
.dclear:
	;--- in RCX hMem
	push rcx
	mov edx,[rcx+DMEM.apages2]
	mov [rcx+DMEM.apages],edx
	mov [rcx+DMEM.used],sizeof.DMEM
	shl rdx,12
	add rcx,1000h
	call art.vdecommit
	pop rdx
	mov ecx,4096-16
	add rdx,16	
	call .zeromem
	sub rax,16	
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                LENZ OK                            |
	;ö---------------------------------------------------ü

@using .lenz
.lenz:
	push rsi
	xor eax,eax
	mov rcx,rsi
.lenz1:
	lodsw
	test eax,eax
	jnz .lenz1
	mov rax,rsi
	sub rax,rcx
	shr rax,1
	dec rax
	pop rsi
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                .GET_FNAME		utf16                |
	;ö---------------------------------------------------ü
.get_fname:
	;--- in RCX string
	;--- RET EAX 0,numchars
	;--- RET ECX total len
	;--- RET EDX pname "file.asm"
	;--- RET R8 string
	;--- WORKS with dir too example
	;C:\MYDIR\SUBDIR  EAX=6 /EDX point to "SUBDIR"

	mov rdx,rcx ; path+filename
	xor eax,eax
	mov r8,rdx
	mov r9,rdx
	test rcx,rcx
	jnz	.gfn1
	ret 0

.gfn3:
	add rdx,2
	cmp eax,"\"
	jnz .gfn4
	cmovz rcx,rdx

.gfn4:
	cmp eax,"/"
	jnz .gfn1
	mov rcx,rdx

.gfn1:	
	mov ax,word[rdx]
	test eax,eax
	jnz .gfn3

.gfn2:
	sub r9,rdx
	sub rdx,rcx
	neg r9
	xor eax,eax
	cmp edx,\
		MAX_UTF16_FILE_CPTS*2

	xchg rcx,r9
	cmovb rax,rdx
	cmovb rdx,r9
	ret 0


;@using .copyz
;.copyz:
;	mov rcx,rdi
;	push rsi
;.copyzA:
;	lodsw
;	stosw
;	test al,al
;	jnz	.copyzA
;	sub rdi,rcx
;	pop rsi
;	xchg rdi,rcx
;	xchg rax,rcx
;;	shr eax,1		;<--CODEPOINTS
;	ret 0
;@endusing

	;#---------------------------------------------------ö
	;|               VCOMMIT                             |
	;ö---------------------------------------------------ü
@using .vcommit
	;--- in RCX base address
	;--- in RDX size
.vcommit:
	push [VirtualAlloc]
	xor rax,rax
	mov r9,PAGE_READWRITE
	mov r8,MEM_COMMIT
	test rcx,rcx
	jz	.vcommitA
	test rdx,rdx
	jz	.vcommitA
	jmp	.prolog1
.vcommitA:
	add rsp,8
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               VFREE                               |
	;ö---------------------------------------------------ü
@using .vfree
	;--- in RCX base address
.vfree:
	push [VirtualFree]
	xor rdx,rdx
	xor rax,rax
	mov r8,MEM_RELEASE
	test rcx,rcx
	jnz	.prolog1
	add rsp,8
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               VDECOMMIT                           |
	;ö---------------------------------------------------ü
@using .vdecommit
	;--- in RCX base address
	;--- in RDX size
.vdecommit:
	push [VirtualFree]
	xor rax,rax
	mov r8,MEM_DECOMMIT
	test rcx,rcx
	jz	.vdecommitA
	test rdx,rdx
	jz	.vdecommitA
	jmp .prolog1
.vdecommitA:
	add rsp,8
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               VRESERVE                            |
	;ö---------------------------------------------------ü

@using .vreserve
	;IN RDX size to alloc
.vreserve:
	push [VirtualAlloc]
	xor rax,rax
	xor rcx,rcx
	mov r9,PAGE_READWRITE
	mov r8,MEM_RESERVE
	test rdx,rdx
	jnz	.prolog1
	add rsp,8
	ret 0
@endusing

@using .valloc
	;IN RDX size to alloc
.valloc:
	push [VirtualAlloc]
	xor rax,rax
	xor rcx,rcx
	mov r9,PAGE_READWRITE
	mov r8,MEM_COMMIT or \
		MEM_RESERVE
	test rdx,rdx
	jnz	.prolog1
	add rsp,8
	ret 0
@endusing



	;#---------------------------------------------------ö
	;|                     .A16MALLOC/. A16FREE          |
	;ö---------------------------------------------------ü
@using .a16malloc
	;--- IN RCX = size to alloc (will be 16 aligned too)
	;-- RET RAX=pointer 
	;-- RET RCX=aligned 16 size
.a16malloc:
	@nearest 16,rcx
	mov rax,[_aligned_malloc]
	mov rdx,16
	push rcx
	call .prolog0
	mov rdx,rax
	pop rcx
	call .zeromem
	ret 0
@endusing

@using .a16free
	;IN RCX = pointer
.a16free:
	xor eax,eax
	test rcx,rcx
	jnz .a16freeA
	ret 0

.a16freeA:
	mov rax,[_aligned_free]
	jmp	.prolog0
@endusing


@using .get_api
.get_api:
	;--- in RCX BaseAddress
	;--- in RDX apiname
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push 0

	test rcx,rcx
	jz	.err_get_api
	mov rbx,rcx
	test rdx,rdx
	jz	.err_get_api
	mov rsi,rdx
	
	mov eax,[rbx+3Ch]	;--- PE header
	test eax,eax
	jz	.err_get_api
	add rax,rbx				;--- Add the modules base address
  mov ebp,[rax+88h] ;--- export tables RVA
	test ebp,ebp			;--- is EAT ?
	jz	.err_get_api
	add rbp,rbx				;--- ok EAT
	mov ecx,[rbp+14h]	;--- NumberOfFunctions
	test ecx,ecx
	jz	.err_get_api
	mov edx,[rbp+20h]	
	add rdx,rbx				;--- AddressOfNames

	mov r11,[rsi]
	bswap r11
	mov r12,rsi

.get_apiA:
	lodsb
	test al,al
	jnz .get_apiA
	mov rax,r12
	sub rax,rsi
	neg rax
	mov rsi,r12

	xor r10,r10		;--- RX
	mov r9,rcx		;--- LX
	mov r12,rax		;--- len api

	mov ecx,eax
	sub eax,8
	sbb eax,eax
	and ecx,eax
	shl ecx,3
	xor eax,eax
	dec cl
	inc eax
	ror rax,1
	sar rax,cl
	and r11,rax
	xor ecx,ecx
	xchg r13,rax	;--- mask
	jmp	.get_apiLX

.get_apiRX:
	test r10,r10
	jle	.err_get_api
	add rcx,r9
	shr r10,1
	mov r9,r10
	adc r9,1

.get_apiLX:
	;--- in RCX OFFS
	;--- in R9  LX
	;--- in R10 RX
	mov eax,ecx
	add rax,r9
	dec eax
	shl eax,2
	add rax,rdx
	mov edi,[rax]
	add rdi,rbx
	mov rax,[rdi]
	bswap rax
	and rax,r13
	cmp r11,rax
	ja .get_apiRX
	jz .get_apiB
	shr r9,1
	jz .err_get_api
	mov r10,r9
	adc r9,0
	dec r10
	jmp	.get_apiLX

.get_apiB:
	add r9,rcx
	add r9,r10
	test r9,r9
	jle	.err_get_api
	inc r9
	mov r8,rsi

.get_apiC:
	dec r9
	jz	.err_get_api
	mov rcx,r12
	mov rsi,r8
	mov edi,[rdx+r9*4-4]
	add rdi,rbx
	repe cmpsb
	jnz	.get_apiC
	test ecx,ecx
	jnz	.get_apiC

	mov esi,[rdx+r9*4-4]
	add rsi,rbx
	mov edx,[rbp+1Ch]	;--- AddressOfFunctions
	add rdx,rbx
	mov eax,[rdx+r9*4-4]
	mov [rsp],rax
	add [rsp],rbx

.err_get_api:
	pop rax
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0
@endusing


	;#---------------------------------------------------ö
	;|                     GET_APPNAME                   |
	;ö---------------------------------------------------ü
@using .get_appname
.get_appname:
	;--- IN RCX 0/module filename
	;--- IN RDX buffer to fill; must be MAX_UA_FILELEN
	;--- RET RAX = num codepoints in buffer
	;--- HI/LOW SURROGATES are CODEPOINTS !
	;--- D800 is considered 1 cpt !
	push rdx
	test rcx,rcx
	jz .ganA
	call apiw.get_modh
	mov rcx,rax
	
.ganA:
	mov r8,MAX_UA_FILELEN
	pop rdx
	call apiw.get_modfname
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|               GET_APPDIR		OK                     |
	;ö---------------------------------------------------ü

@using .get_appdir
.get_appdir:
	;IN RCX 0/module filename
	;IN RDX buffer to fill
	;-- RET RDX = appdir
	;-- RET RAX = num cpts
	;--- HI/LOW SURROGATES are CODEPOINTS !
	;--- D800 is considered 1 cpt !
	push rdx
	call .get_appname
	pop rdx
	mov rcx,rax
	push rdi
	std
	xor rax,rax
	mov rdi,rdx
	mov al,"\"
	add rdi,rcx
	add rdi,rcx
	dec rdi
	dec rdi
	repne scasw
	inc rdi
	inc rdi
	xor rax,rax
	stosd
	mov rax,rcx
	pop rdi
	cld
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                .GET_EXT			                     |
	;ö---------------------------------------------------ü

@using .get_ext
.get_ext:
	;--- in RCX uzString: path+file.ext

	;--- RET RAX 0,pExtension	"asm"
	;--- RET RCX numchars	3
	;--- RET RDX original string

	mov rdx,rcx
	mov r9,rcx
	xor eax,eax
	sub rcx,2
	mov r8,rdx
	
.ge2:
	cmp ax,002Eh
	jnz .ge1
	mov rdx,rcx

.ge1:	
	add rcx,2
	mov ax,word[rcx]
	test ax,ax
	jnz .ge2

	sub rcx,rdx
	jz	.ge3
	sub r8,rdx
	jz	.ge3
	sub rcx,2
	jz	.ge3
	cmp ecx,MAX_EXTLEN
	ja	.ge3
	mov rax,rdx
	add rax,2
.ge3:
	mov rdx,r9
	ret 0
@endusing

;	;ü---------------------------------------------------ö
;	;|                GET_PROC			                     |
;	;ä---------------------------------------------------ß

;@using .get_proc
;.get_proc:
;	;in EAX=hModule
;	;in EDX=ordinal/name
;	push edx
;	push eax
;	GetProcAddress
;	ret 0
;@endusing

	;#---------------------------------------------------ö
	;|         .IS_FILE                                  |
	;ö---------------------------------------------------ü

@using .is_file
.is_file:
	;--- IN RCX module filename
	;-- RET RAX = full attribd
	;-- RET ECX= filename
	;-- RET ZF = 1 item doesnt exist,error
	;-- RET CF = 1 readonly
	push rcx
	mov rax,[GetFileAttributesW]
	call .prolog0
	pop rcx
	cdqe
	rol rax,1
	sbb rdx,rdx
	ror rax,1
	xor rdx,rax	;error
	ror rdx,1
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|         .FSIZEX                                   |
	;ö---------------------------------------------------ü
@using .fsizex
	;--- in RCX handle
	;--- OUT RAX 0=error
	;--- OUT RCX size
.fsizex:
	push 0
	mov rax,[GetFileSizeEx]
	mov rdx,rsp
	call .prolog0
	pop rcx
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|         .FWRITE            	                     |
	;ö---------------------------------------------------ü

@using .fwrite
	;--- in RCX handle
	;--- in RDX pmem
	;--- in R8 num byte to write
.fwrite:
	push 0
	xor r10,r10
	mov rax,[WriteFile]
	mov r9,rsp
	call .prologP
	pop rcx
	ret 0
@endusing


	;#---------------------------------------------------ö
	;|         .FREAD             	                     |
	;ö---------------------------------------------------ü

@using .fread
	;--- in RCX handle
	;--- in RDX pmem
	;--- in R8 num byte to read
	;--- ret RAX error/0
	;--- ret RCX read bytes
.fread:
	push 0
	xor r10,r10
	mov rax,[ReadFile]
	mov r9,rsp
	call .prologP
	pop rcx
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|         .FCLOSE            	                     |
	;ö---------------------------------------------------ü

@using .fclose
	;--- in RCX filehandle
.fclose:
	xor rax,rax
	test rcx,rcx
	jnz	.fcloseA
	ret 0
.fcloseA:
	mov rax,[CloseHandle]
	jmp	.prolog0
@endusing


@using .fpoint
	;--- in RCX filehandle
.fpoint:
	;--- 2^32 - 2 bit only size
	mov r9,FILE_BEGIN
	xor r8,r8
	mov rax,[SetFilePointer]
	jmp	.prolog0
@endusing

@using .fend
.fend:
	mov rax,[SetEndOfFile]
	jmp	.prolog0
@endusing

	;#---------------------------------------------------ö
	;|         .FOPEN_RW           	                     |
	;ö---------------------------------------------------ü
if (used .fopen_rw) | \
		(used .fcreate_rw)

.fcreate_rw:
	mov r10,CREATE_ALWAYS
	jmp	.fopen_rwA
	
.fopen_rw:
	;--- in RCX path\filename
	mov r10,OPEN_EXISTING

.fopen_rwA:
	mov r8,FILE_SHARE_READ \
		or FILE_SHARE_WRITE 
	mov edx,GENERIC_READ \
		or GENERIC_WRITE

	push rbp
	mov rbp,rsp
	xor r9,r9
	and rsp,-16
	mov rax,[CreateFileW]
	push r9			;--- pad stack
	push r9
	push FILE_ATTRIBUTE_NORMAL
	push r10
	jmp	.epilog0
end if

	;#---------------------------------------------------ö
	;|         .XSDBM hash         	                     |
	;ö---------------------------------------------------ü
@using .sdbm
	;--- ANSI/UTF8
	;--- in RCX string
	;--- in RDX len
	;--- RET RAX hash
	;--- RET RCX original len

.sdbm:
	xor rax,rax
	mov r11,rdx
	mov r10,rbx
	mov r8,rcx
	mov r9,rdx
	mov rbx,6121
.xsdbmA:
	mov al,[r8]
	mov ecx,ebx
	mov edx,ebx
	shl ecx,17
	shl ebx,6
	inc r8
	add ebx,eax
	add ebx,ecx
	sub ebx,edx
	dec r9
	jnz	.xsdbmA
	xchg ebx,eax
	mov rcx,r11
	xchg rbx,r10
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|         .LOADFILE           	                     |
	;ö---------------------------------------------------ü
@using .fload
.fload:
	;--- in RCX filename
	;--- RET RAX pmem / 0
	;--- RET RCX original file size (aligned 16 and on 4kb page)
	;--- RET RDX error code
	push rbp
	push rbx
	push rdi
	push r12

	xor ebp,ebp			;--- err filename
	xor ebx,ebx
	xor edi,edi

	test rcx,rcx
	jz .exit_floadB
	dec ebp					;--- err opening file -1

	mov r12,rcx
	call .fopen_rw
	test rax,rax
	jle	.exit_floadB

	dec ebp					;--- err filesize -2
	mov rcx,rax
	mov rbx,rax
	call .fsizex
	test eax,eax
	jz	.exit_floadA

	dec ebp					;--- err size is zero -3
	test ecx,ecx
	jz	.exit_floadA
	mov r12,rcx
	@nearest 16,rcx

	dec ebp					;--- err valloc -4
	mov edx,ecx
	call .valloc
	test rax,rax
	jz	.exit_floadA

	dec ebp					;--- err reading -5
	mov r8,r12
	mov rdx,rax
	mov rdi,rax
	mov rcx,rbx
	call .fread
	test rax,rax
	jnz	.exit_floadA

.exit_fload:
	;--- err reading
	mov rcx,rdi
	call .vfree
	xor edi,edi
	
.exit_floadA:
	mov rcx,rbx
	call .fclose

.exit_floadB:
	xchg edx,ebp
	xchg rcx,r12
	xchg rax,rdi
	pop r12
	pop rdi
	pop rbx
	pop rbp
	ret 0
@endusing


	;#---------------------------------------------------ö
	;|           COMMON PROLOG EPILOG                    |
	;ö---------------------------------------------------ü
.prologP:
	;--- max 2 pushes in R10,R11
	push rbp
	mov rbp,rsp
	and rsp,-16
	push r11
	push r10
	jmp	.epilog0

.prolog1:
	pop rax

.prolog0:
	push rbp
	mov rbp,rsp
	and rsp,-16

.epilog0:
	sub rsp,20h
	call rax

.epilog1:
	mov rsp,rbp
	pop rbp
	ret 0

.epilog2:
	;--- in RDX num pushed * 8
	mov rcx,[rbp+8]
	mov rsp,rbp
	pop rbp
	add rsp,rdx
	jmp	rcx


@using .catstrw
.catstrw:
	;-------------UTF16LE--------------------------------
	;--- 110 bytes
	; push 0		;<---- mandatory,terminate parameters
	; push src	
	; push src
	; push dest	;<---- mandatory
	; push 0		;<---- optional,zero first dd of dest str
	; call .catstrw
	; RET EAX = unicode code-points+0 term
	;----------------------------------------------------
	push rbp
	push rbx
	push rdi
	push rsi

	mov rbp,rsp
	lea rdi,[rbp+40]
	mov	rsi,[rbp+48]
	xor rbx,rbx
	mov rax,[rdi]
	xor rcx,rcx
	mov rdx,rdi
	test rsi,rsi	;avoid pair 0term/0set; buffer/0set
	jz	.2
	test rax,rax
	setz bl
	cmovz rdi,rsi
	nop
	mov [rdi],rax
	dec rcx
	mov rdi,[rdx+rbx*8]
	xor rax,rax
	lea rdx,[rdx+rbx*8]

	;--- EDX -> ESP (dest string)
	;--- EBX -> num parameters
	;--- EDI -> eventual zeroed dest string
	;--- ECX -> unicode len

	mov rbp,rdi
	repne scasw
	inc rcx
	not rcx
	mov rdi,rbp
	add rdi,rcx
	add rdi,rcx
	;--- EDI -> last dest zero
	jmp	.0
.1:
	lodsw
	stosw
	test ax,ax
  jnz .1
	sub rdi,2
	inc rbx
	mov rax,rdi
	sub rax,rbp
	shr rax,1
	add rcx,rax
.0:  
	add rdx,8
	mov rbp,rdi
	mov rsi,[rdx]
	test rsi,rsi
	jnz .1
	inc rcx			; +terminal zero codepoint
.2:
	mov rdx,rbx
	add rdx,2		
	mov rax,rcx
	shl rdx,3		; paras * 8
	
	pop rsi
	pop rdi
	pop rbx
	pop rbp

	pop rcx
	add rsp,rdx
	jmp	rcx
@endusing



@using .get_codepoint
@align 4,0CCh
.get_codepoint:
	;--- NOTE : involved regs: RAX/RDX/RCX/RSI
	;--- RET carry on error and RAX = -1 / RAX=sequence RCX=num cpts
	;--- RSI proceed if all OK
	;------- ok 128 2--------------
	mov edx,[rsi]
	xor rcx,rcx
	movzx rax,dl
	inc ecx
	test al,al
	js .gcptD
.gcptA:
	ret 0

.gcptD:
	sub al,0C2h
	jc	.err1
	not al
	cmp al,0CDH
	jc	.err1

	cmp al,0D2h
	adc cl,0
	sub al,0E2h
	adc cl,1
	cbw
	and al,ah
	neg ax

	mov ch,cl
	mov al,[.cpt_table+rax]
	mov ah,al
	shl al,4
	and ax,0F0F0h
	add ax,808Fh
	dec cl

.gcptC:
	ror rdx,8
	cmp dl,ah
	jc .err1
	cmp al,dl
	jc .err1
	mov ax,80BFh
	dec cl
	jnz	.gcptC
	
.err1:
	sbb rax,rax
	jc	.gcptA
	ror rdx,8
	shr ecx,5
	shld rax,rdx,cl
	shr ecx,3
	ret 0

.cpt_table:
	;U+0000..U+007F 		00..7F
	;U+0080..U+07FF 		C2..DF 		80..BF
	;U+0800..U+0FFF 		E0 				A0..BF 80..BF
	;U+1000..U+CFFF 		E1..EC 		80..BF 80..BF
	;U+D000..U+D7FF 		ED 				80..9F 80..BF
	;U+E000..U+FFFF 		EE..EF 		80..BF 80..BF
	;U+10000..U+3FFFF 	F0 				90..BF 80..BF 80..BF
	;U+40000..U+FFFFF 	F1..F3 		80..BF 80..BF 80..BF
	;U+100000..U+10FFFF F4 				80..8F 80..BF 80..BF
	db	03,\
			23h,03,03,03,03,03,03,03,03,03,03,03,03,01,03,03,\
			13h,03,03,03,00
	;display_decimal $ - .get_codepoint
@endusing


@using .cout2XX
.cout2XX:
	;---IN RDX = dd1
	;---IN R8 = dd2
	push rbp
	push rax
	push rcx
	push rdx
	push r8
	push r9
	mov rbp,rsp
	and rsp,-16

	sub rsp,20h
	mov rcx,uzFrm2XX
	call [wprintf]

	mov rsp,rbp
	pop r9
	pop r8
	pop rdx
	pop rcx
	pop rax
	pop rbp
	ret 0
@endusing

@using .cout2XU
.cout2XU:
	;---IN RDX = dd1
	;---IN R8 = dd2
	push rbp
	push rax
	push rcx
	push rdx
	push r8
	push r9
	mov rbp,rsp
	and rsp,-16

	sub rsp,20h
	mov rcx,uzFrm2XU
	call [wprintf]

	mov rsp,rbp
	pop r9
	pop r8
	pop rdx
	pop rcx
	pop rax
	pop rbp
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                  QWORD2A			                     |
	;ö---------------------------------------------------ü

@using .qword2a
@align 16,0CCh
.qword2a_const:
	dq 6766656463626160h
	dq 7675747372716968h
	dq 0F0F0F0F0F0F0F0Fh
	dq 0F0F0F0F0F0F0F0Fh
	dq 3030303030303030h
	dq 3030303030303030h

.qword2a:
	;--- IN RCX number
	;--- IN RDX outbuffer MIN 24 bytes
	;--- RET RAX valid chars
	;--- RET RCX outbuffer
	;--- RET RDX delta to valid bytes 

	xchg rcx,rdx
	xor eax,eax
	movdqa xmm2,\
		dqword [.qword2a_const]
	pxor xmm0,xmm0
	movdqa xmm3,xmm2

	mov [rcx+16],rax
							;--- calculate a delta quantity
	bsr rax,rdx	;--- to reach the beginning of
	shr eax,2		;--- the valid string-number after
	mov [rcx],rax
	sub eax,15	;--- skipping all left-0s in the
	neg eax			;--- destination string
	
	bswap rdx
	movq xmm1,rdx
	punpcklbw xmm0,xmm1
	pand xmm0,\
		dqword[.qword2a_const+16]
	punpcklbw xmm1,xmm1
	psrlw xmm1,4
	pand xmm1,\
		dqword[.qword2a_const+16]
	mov edx,eax
	psrlw xmm1,8
	pshufb xmm2,xmm0
	pshufb xmm3,xmm1
	por xmm2,xmm3
	psubb xmm2,\
		dqword[.qword2a_const+32]
	mov rax,[rcx]
	movhlps xmm1,xmm2
	movq r8,xmm2		;--- HI value
	inc eax
	mov [rcx],r8
	movq r8,xmm1		;--- LO value
	mov [rcx+8],r8
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                    LOCALTIME                      |
	;ö---------------------------------------------------ü

@using .get_ltime
	;--- ret RAX localdate
	;--- ret RDX localtime
.get_ltime:
	push rbp
	mov rbp,rsp
	and rsp,-16
	sub rsp,\
		sizeof.SYSTEMTIME
	mov rcx,rsp
	sub rsp,20h
	call [GetLocalTime]
	mov rax,qword[rsp+20h]
	mov rdx,qword[rsp+20h+8]
	mov rsp,rbp
	pop rbp
	ret 0
@endusing

@using .syst2ft
	;--- in RAX systemdate
	;--- in RDX systemtime
	;--- ret RAX filetime
.syst2ft:
	push rbp
	mov rbp,rsp
	and rsp,-16
	sub rsp,16+\
		sizeof.SYSTEMTIME

	mov rcx,rsp
	mov [rcx+8],rdx
	mov [rcx],rax
	lea rdx,[rsp+16]
	sub rsp,20h
	call [SystemTimeToFileTime]
	mov rcx,\
		qword[rsp+20h+16]
	mov rsp,rbp
	test rax,rax
	pop rbp
	cmovnz rax,rcx
	ret 0
@endusing

@using .ft2syst
	;--- in RAX filetime
	;--- RET RAX systemdate
	;--- RET RDX systemtime
.ft2syst:
	push rbp
	mov rbp,rsp
	and rsp,-16
	sub rsp,16+\
		sizeof.SYSTEMTIME
	mov rcx,rsp

	lea rdx,[rsp+16]
	mov [rcx],rax

	sub rsp,20h
	call [FileTimeToSystemTime]
	mov rax,qword[rsp+20h+16]
	mov rdx,qword[rsp+20h+16+8]
	mov rsp,rbp
	pop rbp
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                   .tstamp                         |
	;ö---------------------------------------------------ü

@using .tstamp
	;--- ret RAX tstamp
.tstamp:
	rdtsc
	ror rax,32
	or rax,rdx
	rol rax,32
	ret 0
@endusing
	
	
	;#---------------------------------------------------ö
	;|                   .stamp2ft                       |
	;ö---------------------------------------------------ü

@using .stamp2ft
	;--- http://src.chromium.org/svn/trunk/src/base/time_win.cc
	;--- The internal representation of Time uses FILETIME, whose epoch is 1601-01-01
	;--- 00:00:00 UTC. ((1970-1601)*365+89)*24*60*60*1000*1000, where 89 is the
	;--- number of leap year days between 1601 and 1970: (1970-1601)/4 excluding
	;--- 1700, 1800, and 1900.
	;--- kTimeTToMicrosecondsOffset 11644473600000000 i.e 019DB1DE'D53E8000h

.stamp2ft:
	;--- in RAX fstamp
	;--- RET RAX = dwHighDateTime | dwLowDateTime
	mov ecx,989680h ;= 10'000'000
	mul ecx
	add eax,0D53E8000h
	adc edx,019DB1DEh
	shl rdx,32
	or rax,rdx
	ret 0
@endusing

	;#---------------------------------------------------ö
	;|                   .FILETIME 2 TSAMP               |
	;ö---------------------------------------------------ü

@using .ft2stamp
	;--- http://www.frenk.com/2009/12/convert-filetime-to-unix-timestamp/
	;--- A UNIX timestamp contains the number of seconds from Jan 1, 1970, 
	;--- while the FILETIME documentation says: Contains a 64-bit value representing 
	;--- the number of 100-nanosecond intervals since January 1, 1601 (UTC).
	;--- Between Jan 1, 1601 and Jan 1, 1970 there are 11644473600 seconds, 
	;--- so we will just subtract that value:

.ft2stamp:
	;--- IN RAX = ftime
	;--- RET EAX = timestamp or ZF or CF
	mov rdx,019DB1DE'D53E8000h
	mov ecx,989680h
	sub rax,rdx
	jle .ft2stampB ;--- skip: div will result 0 or error
	xor rdx,rdx
	div rcx
.ft2stampB:
	ret 0
@endusing


;--- ok new 218 byte ;[Samstag] - 28.Mai.2011 - 01:04:22
@using .u2dq
.u2dq:
	;--- in RCX source string
	;--- ret RAX value /carry on error
	;--- ret RDX valid bytes
	;--- ret RCX past string if ok
	mov rdx,rcx
	mov r8,rsp
	dec rdx
	xor ecx,ecx
	
.u2dqA:
	inc rdx
	movzx rax,byte[rdx]
	cmp al,20h		;--- skip space
	jz	.u2dqA
	cmp al,9h			;--- skip tab
	jz	.u2dqA
	test al,al
	jnz	.u2dqC

.err_u2dqA:
	stc
	jmp	.exit_u2dq

.u2dqF:
	sub al,27h
.u2dqE:
	dec rsp
	mov byte[rsp],al

.u2dqB:
	inc rdx
	mov al,byte[rdx]
	test al,al
	jz	.err_eval

.u2dqC:
	cmp al,"'"
	jz	.u2dqB
	cmp al,"0"
	jb	.err_eval
	cmp al,"9"
	jbe	.u2dqE
	or al,20h
	cmp al,"a"
	jb	.err_eval
	cmp al,"f"
	jbe	.u2dqF
	cmp al,"h"
	jnz	.err_eval

.hex_eval:
	inc rdx
	xor eax,eax
	mov r9,r8

.hex_evalA:
	dec r9
	shl rax,4
	mov cl,[r9]
	and cl,0Fh
	or al,cl
	cmp rsp,r9
	jb .hex_evalA
	jmp	.exit_u2dqA

.err_eval:
	cmp r8,rsp
	jz	.err_u2dqA
	movzx rcx,byte[rsp]
	xor eax,eax
	mov r9,r8
	cmp cl,"b"-27h
	jz	.bin_eval
	cmp cl,"d"-27h
	jnz .dec_eval
	inc rsp

.dec_eval:
	dec r9
	mov cl,[r9]
	and cl,0Fh
	cmp cl,9
	ja	.err_u2dqA
	imul rax,10
	add rax,rcx
	cmp rsp,r9
	jb .dec_eval
	jmp	.exit_u2dqA

.bin_eval:
	inc rsp

.bin_evalA:
	dec r9
	shl rax,1
	mov cl,[r9]
	and cl,0Fh
	cmp cl,1
	ja	.err_u2dqA
	or al,cl
	cmp rsp,r9
	jb .bin_evalA

.exit_u2dqA:
	xor rcx,rcx
	bsr rcx,rax		;pure absolute numberof bytes
	shr rcx,3
	inc rcx
	clc

.exit_u2dq:
	mov rsp,r8
	xchg rcx,rdx
	ret 0
;display_decimal $-.u2dq
@endusing

;	;#---------------------------------------------------ö
;	;|                     SETDIR                        |
;	;ö---------------------------------------------------ü

;@using .setdir
;.setdir:
;	push eax
;	SetCurrentDirectory
;	ret 0
;@endusing

;	;#---------------------------------------------------ö
;	;|                     CREATEDIR                     |
;	;ö---------------------------------------------------ü

;@using .createdir
;	;IN RCX = dirname
;	;RET RAX len
;	;RET RCX dirname
;.createdir:
;	push rbp
;	push rbx
;	mov rbp,rsp
;	mov rbx,rcx
;	and rsp,-16
;	xor rdx,rdx
;	sub rsp,20h
;	call [CreateDirectoryW]
;	xchg rcx,rbx
;	mov rsp,rbp
;	pop rbx
;	pop rbp
;	ret 0
;@endusing


;@using .curdir
;.curdir:
;	push eax
;	push 511
;	call [GetCurrentDirectoryW]
;	ret 0
;@endusing


;	;#---------------------------------------------------ö
;	;|                    GET_DATETIME                   |
;	;ö---------------------------------------------------ü

;@using .get_datetime
;.get_datetime:
;	;IN [ESP+4] pOutBuffer
;	;RET EAX=filled buffer
;	push edi

;	mov edi,dword[esp+8]
;	call .get_localtime

;	push szRetDate.size
;	push szRetDate
;	push szDateFormat
;	push pSysTime
;	push 0
;	push 0;LOCALE_USER_DEFAULT
;	GetDateFormat
;	
;	push szRetTime.size
;	push szRetTime
;	push szTimeFormat
;	push pSysTime
;	push 0
;	push 0;LOCALE_USER_DEFAULT
;	GetTimeFormat

;	xor eax,eax
;	stosb
;	dec edi

;	push eax
;	push szRetTime
;	push szRetDate
;	push edi
;	call shared.catstr
;	mov eax,edi

;	pop edi
;	ret 4
;@endusing



	;#---------------------------------------------------ö
;	;|                    TIME2NAME                      |
;	;ö---------------------------------------------------ü
;@using .time2name
;.time2name:
;	push esi
;	call .get_localtime
;	xor eax,eax
;	mov esi,pSysTime
;	add esi,sizeof.SYSTEMTIME
;	sub esi,2
;	std
;	lodsw				;msecs
;	push eax
;	lodsw				;secs
;	push eax
;	lodsw				;mins
;	push eax
;	lodsw				;hours
;	push eax
;	lodsw				;day
;	push eax
;	lodsw				
;	lodsw				;months
;	push eax
;	lodsw				;years
;	push eax
;	push szFrmTime2Name
;	push szTime2Name
;	cld
;	wsprintf
;	add esp,36
;	mov eax,szTime2Name
;	pop esi
;	ret 0
;@endusing


	;#---------------------------------------------------ö
	;|                .GET_PATHPART                      |
	;ö---------------------------------------------------ü

;@using .get_pathpart
;	;IN ESP+4  ;sourcepath
;	;IN ESP+8  ;buffer for extracted part
;	;RET EDX= type PATH_PATH /PATH_FILE /PATH_DRIVE etc.
;	;RET ECX = len of part
;	;RET EAX = part
;.get_pathpart:
;	mov eax,[esp+4]
;	push esi
;	mov edx,[eax]
;	xor ecx,ecx
;	mov esi,eax

;	test dh,dh
;	jz	.no_gpp
;	test dl,dl
;	jz	.no_gpp

;	cmp dl,"\"
;	jz	.gppA
;	cmp dl,"."
;	jz	.gppB
;	cmp dh,":"
;	jz	.gppE

;.gppF:
;	mov ecx,esi
;	mov edx,eax
;	jmp	.gppB2

;.gppE:
;	shr edx,16
;	test dl,dl
;	jz	.no_gpp
;	cmp dl,"\"
;	jnz	.no_gpp
;	xor edx,edx
;	mov cl,2
;	mov dl,PATH_DRIVE
;	jmp	.gppZ
;	
;.gppA:
;	cmp dh,"\"
;	jz	.gppA1
;	cmp dh,"."
;	jz	.gppA6
;	;---- it could be "\fasmlab\myfile.txt",0 	;ret edx="\" ecx=7
;	;---- it could be "\myfile.txt",0					;ret edx=0 ecx=0
;	dec esi
;	dec eax
;	jmp	.gppB1

;.gppA1:
;	bswap edx
;	;---  it could be "\\?\myfile.txt",0		
;	;---  it could be "\\myserver\myfile",0
;	test dl,dl
;	jz	.no_gpp
;	test dh,dh
;	jz	.no_gpp
;	cmp dx,"\?"
;	jnz	.gppA3

;	xor edx,edx
;	mov cl,3
;	;---  "\\?\myfile.txt",0		
;	mov dl,PATH_LONG
;	jmp	.gppZ

;.no_gpp:
;	xor edx,edx
;	xor ecx,ecx
;	xor eax,eax
;	jmp	.gppZ1


;.gppA3:
;	;---  "\\myserver\myfile",0
;	mov esi,eax
;	mov ecx,eax
;	add esi,2

;.gppA4:
;	lodsb
;	test al,al
;	jz	.no_gpp
;	cmp al,"\"
;	jnz	.gppA4
;	xor edx,edx
;	dec esi
;	mov eax,ecx
;	sub esi,ecx
;	jle	.no_gpp
;	xchg esi,ecx
;	mov dl,PATH_SERVNAME
;	jmp	.gppZ


;.gppA6:
;	;--- it could be   "\..\fasmlab\",0			;ret edx=".." ecx=3
;	;--- it could be   "\..\myfile.txt",0   ;ret edx=".." ecx=3
;	mov ecx,edx
;	bswap edx
;	cmp ecx,edx
;	jnz	.no_gpp
;	test dh,dh
;	jz	.no_gpp
;	test dl,dl
;	jz	.no_gpp
;	xor ecx,ecx
;	inc eax
;	inc ecx
;	jmp	.gppB4

;.gppB:
;	;--- it could be ".\myfile.txt",0			;ret edx=0 ecx=0
;	;--- it could be ".\dirH\",0					;ret edx="\" ecx=4
;	;--- it could be "..\myfile.txt",0		;ret edx=".." ecx=2
;	;--- it could be "..\dirH\",0					;ret edx=".." ecx=2
;	cmp dh,"\"
;	jz	.gppB1
;	cmp dh,"."
;	jnz	.no_gpp

;.gppB3:
;	;--- it could be "..\myfile.txt",0		;ret edx=".." ecx=2
;	;--- it could be "..\dirH\",0					;ret edx=".." ecx=2
;	xor ecx,ecx
;	shr edx,16
;	test dl,dl
;	jz	.no_gpp
;	cmp dl,"\"
;	jnz	.no_gpp

;.gppB4:
;	inc ecx
;	xor edx,edx
;	inc ecx
;	mov dl,PATH_REL

;.gppZ:
;	push edi
;	push ecx
;	mov edi,dword[esp+20]
;	mov esi,eax
;	push edi
;	rep movsb
;	xor eax,eax
;	stosb
;	pop eax
;	pop ecx
;	pop edi

;.gppZ1:
;	pop esi
;	ret 8

;.gppB1:
;	;--- it could be ".\myfile.txt",0			;ret edx=0 ecx=0
;	;--- it could be ".\dirH\",0					;ret edx="\" ecx=4
;	add esi,2
;	add eax,2
;	mov ecx,esi
;	mov edx,eax

;.gppB2:
;	lodsb
;	test al,al
;	jz	.gppB5
;	cmp al,"\"
;	jnz	.gppB2
;	push PATH_PATH

;.gppB6:	
;	xchg eax,edx
;	sub ecx,esi
;	pop edx
;	not ecx
;	jmp	.gppZ

;.gppB5:
;	push PATH_FILE
;	jmp	.gppB6
;@endusing



;	;#---------------------------------------------------ö
;	;|                       				                     |
;	;ö---------------------------------------------------ü

;@using .get_errstr
;proc .get_errstr \
;	_pbuffer,\
;	_bufsize,\
;	_flags,\
;	_hmodule,\
;	_ids
;	; RET EAX=numchars/0
;	; RET EDX= id error/string
;	; RET buffer/0 (error)
;	
;	push ebx
;	push edi
;	push esi

;	mov edi,[_bufsize]
;	mov esi,[_pbuffer]
;	
;	mov ebx,[_flags]
;	test ebx,USE_SYSERRSTR
;	jz	.ges3
;	GetLastError
;	push eax
;	push 0
;	push edi
;	push esi
;	push LANG_NEUTRAL
;	push eax
;	push 0
;	push FORMAT_MESSAGE_IGNORE_INSERTS \
;			 or FORMAT_MESSAGE_FROM_SYSTEM
;	FormatMessage
;	jmp .ges4

;.ges3:
;	mov eax,[_ids]
;	test ebx,USE_DLGERRSTR
;	jz	.ges1
;	CommDlgExtendedError
;	push eax
;	test eax,eax
;	jz	.ges4
;	pop eax	

;.ges1:
;	push eax

;	push edi
;	push esi
;	push eax
;	push [_hmodule]
;	LoadString
;	
;.ges4:		
;	pop edx

;	pop esi
;	pop edi
;	pop ebx
;	ret
;endp
;@endusing

