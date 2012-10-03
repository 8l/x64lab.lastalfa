  
  ;#-------------------------------------------------ß
  ;|          top64  MPL 2.0 License                 |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

top64:
	virtual at rdi
		.titem TITEM
	end virtual

	virtual at r12
		.thead THEADER
	end virtual

	;ü------------------------------------------ö
	;|     LOCATE                               |
	;#------------------------------------------ä

.locate:
	;--- in RCX base pmem
	;--- in RDX current object
	;--- in R8 itemtext
	;--- search only in object level

	;--- RET RAX 0/pobject
	;--- RET RCX hash
	;--- RET RDX original object
	;--- RET R8  utf8string
	;--- RET R9 item len
	xor eax,eax

	push rcx
	push rax
	push r8
	push rdx
	push rax

	test rcx,rcx
	jz	.ok_locate
	test rdx,rdx
	jz	.ok_locate
	test r8,r8
	jz	.ok_locate

	mov rcx,r8
	call utf8.zsdbm
	and eax,eax
	mov [rsp],rax
	mov r9,[rsp+8]
	mov [rsp+24],rdx
	mov r8,[rsp+32]

.locateD:
	cmp eax,[r9+TITEM.hash]
	jnz	.locateB

.locateA:
	cmp dx,[r9+TITEM.len]
	jz	.locateC

.locateB:
	mov ecx,[r9+TITEM.next]
	mov r9d,ecx
	add r9,r8
	test ecx,ecx
	jnz	.locateD
	xchg r9,rcx

.locateC:
	mov rax,r9

.ok_locate:
	pop rcx
	pop rdx
	pop r8
	pop r9
	pop r10
	ret 0

			;ü------------------------------------------ö
			;|     PARSE                                |
			;#------------------------------------------ä

.parse:
	;--- IN RCX filename
	;--- RET RAX 0 / pmem
	;--- RET RCX datasize
	;--- RET RDX numitems
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

	xor r14,r14		;--- current item pointer
	sub rsp,sizeof.THEADER
	mov r12,rsp
	mov	rdx,rcx
	xor eax,eax
	xor ebx,ebx
	mov rdi,rsp
	mov rcx,sizeof.THEADER / 8
	rep stosq
	
	mov rcx,rdx
	call art.fload
	test rax,rax
	jz .exit_parseA

	mov rsi,rax
	mov rdx,rcx
	shl rdx,4
	add rcx,rdx
	@nearest 64,rcx

	@frame rcx
	mov rdi,rax
	mov rdx,rax
	call art.zeromem

	xor rbx,rbx		;--- flags
	mov [.thead.psrc],rsi
	mov [.thead.pmem],rdi
	push rsi
	push r14
	mov rcx,rdi		;--- root pointer
	call .read
	pop r14
	pop rsi
	jc	.exit_parse

	mov rcx,rdi
	sub rcx,[.thead.pmem]
	mov r15,rcx
	call art.a16malloc
	test rax,rax
	jz	.exit_parse

	mov r8,r15
	mov rdx,rax
	mov r14,rax
	mov r15,rsi
	mov rcx,[.thead.pmem]
	call art.xmmcopy
	xchg rsi,r15

.exit_parse:
	test rsi,rsi
	jz	.exit_parseA
	mov rcx,rsi
	call art.vfree
	
.exit_parseA:
;@break
	xchg rax,r14
	mov ecx,[.thead.dsize]
	mov edx,[.thead.items]
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

.read:
	;--- in RCX parent item
	;--- RSI source
	;--- RDI dest
	;--- R12 header
	;--- R13 parent item
	;--- R14 current value
	;--- R15 eventual item as object
	;--- BL flags,in BH level
	xor r14,r14
	mov r13,rcx
	mov r15,rcx
	xor ecx,ecx
	
.readA1:
	add rsi,rcx

.readA:
	call art.get_codepoint
	jc	.err_cpt
	cmp eax,CR_UTF8
	jz	.readA1
	cmp eax,LF_UTF8
	jnz	.readB
	inc [.thead.lines]
	jmp .readA1
	
.readB:
	cmp eax,OPAR_UTF8
	jz	.readOP
	cmp eax,CPAR_UTF8
	jz	.readCP
	cmp eax,SPACE_UTF8
	jz	.readA1
	cmp eax,TAB_UTF8
	jz	.readA1
	cmp eax,COMMENT_UTF8
	jz	.readC
	test eax,eax
	jz	.eof

.readL:
	;ü------------------------------------------ö
	;|     LABEL                                |
	;#------------------------------------------ä
	cmp eax,DDOT_UTF8
	jz	.err_name

	test bl,F_NAME
	jnz	.err_name

	mov bl,F_NAME
	mov [.titem.level],bh
	mov [.titem.type],TLABEL
	mov rax,rsi
	sub rax,[.thead.psrc]
	mov [.titem.value],eax
	inc [.thead.items]

.readL1:
	add rsi,rcx

.readL2:
	xor ecx,ecx
	call art.get_codepoint
	jc	.err_cpt
	cmp eax,CR_UTF8
	jz	.err_name
	cmp eax,LF_UTF8
	jz	.err_name
	cmp eax,DQUOTE_UTF8	;--- allow only SQUOTE (1'0001 numbers as LABEL)
	jz	.err_name
	cmp eax,OPAR_UTF8
	jz	.err_name
	cmp eax,CPAR_UTF8
	jz	.err_name
	cmp eax,SPACE_UTF8
	jz	.err_name
	cmp eax,TAB_UTF8
	jz	.err_name
	cmp eax,COMMENT_UTF8
	jz	.err_name
	cmp eax,DDOT_UTF8
	jnz	.readL1

.readL3:
	mov rax,rsi
	sub rax,[.thead.psrc]
	sub eax,[.titem.value]
	mov [.titem.len],ax
	add [.thead.dsize],eax
	mov r15,rdi

	mov r8,rsi
	add r8,rcx

	mov esi,[.titem.value]
	add rsi,[.thead.psrc]
	lea rdi,[.titem.value]

	mov ecx,eax
	rep movsb
	xor eax,eax
	stosb
	@nearest 4,rdi
	xchg rsi,r8

.setchild:
	;--- in R13 parent
	;--- in R15 child

	cmp r13,r15			;--- parent is root
	jz	.ok_setchild

.setchildA:
	;--- R13/R15 siblings
	mov al,[r15+TITEM.level]
	sub al,[r13+TITEM.level]
	jnz	.setchildB
	mov rax,r15
	sub rax,[.thead.pmem]
	mov [r13+TITEM.next],eax

	mov eax,[r13+TITEM.parent]
	mov [r15+TITEM.parent],eax
	mov r13,r15
	jmp	.ok_setchild

.setchildB:
	;--- R13/R15 parent/child
	mov rcx,r13
	mov rdx,r15
	xor eax,eax
	sub rcx,[.thead.pmem]
	mov [r15+TITEM.parent],ecx

	cmp eax,[r13+TITEM.child]
	jz	.setchildB2
	mov edx,[r13+TITEM.child]

.setchildB1:
	add rdx,[.thead.pmem]
	cmp eax,[rdx+TITEM.next]
	jz	.setchildB3
	mov edx,[rdx+TITEM.next]
	jmp	.setchildB1

.setchildB3:
	mov rax,r15
	sub rax,[.thead.pmem]
	mov [rdx+TITEM.next],eax
	jmp	.ok_setchild
	
.setchildB2:
	sub rdx,[.thead.pmem]
	mov [r13+TITEM.child],edx

.ok_setchild:
	;--- set hash -------------
	movzx edx,[r15+TITEM.len]
	lea rcx,[r15+TITEM.value]
	call art.sdbm
	mov [r15+TITEM.hash],eax

.readV:
	xor ecx,ecx

	;ü------------------------------------------ö
	;|     VALUE                                |
	;#------------------------------------------ä
.readV1:
	add rsi,rcx

.readV2:
	xor ecx,ecx
	call art.get_codepoint
	jc	.err_cpt
	cmp eax,SPACE_UTF8
	jz	.readV1
	cmp eax,TAB_UTF8
	jz	.readV1
	cmp eax,DQUOTE_UTF8
	jz	.readS
	cmp eax,SQUOTE_UTF8
	jz	.readS
	cmp eax,OPAR_UTF8
	jz	.readOP
	cmp eax,CPAR_UTF8
	jz	.readCP
	cmp eax,BSLASH_UTF8
	jnz	.readV4
	or bl,F_LINE
	jmp	.readV1

.readV6:
	test bl,F_VALUE \
		or F_LINE
	jnz	.readV1
	xor bl,bl
	xor r14,r14
	jmp	.readA1

.readV4:
	cmp eax,COMMA_UTF8
	jnz	.readV3
	xor r14,r14
	or bl,F_COMMA
	jmp .readV1

.readV3:
	cmp eax,CR_UTF8
	;jz	.readV1
	jz	.readV6
	or bl,F_VALUE


;	;--- TODO: comment between item and value
;	;--- number
	push rax
	push rcx
	mov rcx,rsi
	call art.u2dq
	mov r9,rcx
	mov r8,rax
	pop rcx
	pop rax
	jc	.readV5

.readN:
	mov rsi,r9

;	mov rax,r15
;	sub rax,[.thead.pmem]
;	mov [.titem.parent],eax
inc [.thead.items]
add [.thead.dsize],edx

	mov [.titem.level],bh
	mov [.titem.len],dx
	mov [.titem.type],TNUMBER
	mov qword[.titem.lo_dword],r8

	call .setvalue

	and bl,F_NAME or F_VALUE
	add rdi,sizeof.TITEM
	xor r14,r14
	jmp	.readV
	
.readV5:
	cmp eax,LF_UTF8
	jnz	.err_value
	inc [.thead.lines]
	test bl,F_LINE
	jnz	.readV1
	xor bl,bl
	xor r14,r14
	jmp	.readA1

.setvalue:
	;--- in RDI value
	;--- in R15 parent

	mov rax,r15
	mov rdx,r15
	sub rax,[.thead.pmem]
	mov [.titem.parent],eax

	;--- must be the same level for now,
	;--- p:1 (.a:),"qqq" not allowed

	movzx eax,[.titem.level]
	sub al,[r15+TITEM.level]
	jnz	.ok_setvalue

	cmp eax,[r15+TITEM.attrib]
	jz	.setvalueA
	mov edx,[r15+TITEM.attrib]

.setvalueB:
	add rdx,[.thead.pmem]
	cmp eax,[rdx+TITEM.attrib]
	jz	.setvalueA
	mov edx,[rdx+TITEM.attrib]
	jmp	.setvalueB
	
.setvalueA:
	mov rax,rdi
	sub rax,[.thead.pmem]
	mov [rdx+TITEM.attrib],eax

.ok_setvalue:	
	ret 0
	
.readS:
	;--- specify item i: in i:"string"
	or bl,F_VALUE
	add rsi,rcx
	mov r8,rax		;--- save "'
	xor ecx,ecx

	test r14,r14
	jnz .readS1

;	mov rax,r15
;	sub rax,[.thead.pmem]
;	mov [.titem.parent],eax

	inc [.thead.items]
	mov [.titem.level],bh
	mov [.titem.type],TQUOTED
	mov r14,rdi
	call .setvalue

.readS1:
	mov rax,rsi
	sub rax,[.thead.psrc]
	mov [r14+TITEM.tmpcat],eax
	
.readS2:
	add rsi,rcx
	call art.get_codepoint
	jle	.err_cpt
	cmp eax,CR_UTF8
	jz	.err_value
	cmp eax,r8d
	jnz	.readS2

.readS3:
	mov rax,rsi
	mov rdi,r14
	sub rax,[.thead.psrc]
	sub eax,[.titem.tmpcat]
	mov r10,rdi
	mov r9,rax

	mov r8,rsi
	add r8,rcx

	movzx edx,[.titem.len]
	mov esi,[.titem.tmpcat]
	add rsi,[.thead.psrc]
	lea rdi,[.titem.value]
	add rdi,rdx
	
	mov ecx,eax
	rep movsb
	xor eax,eax
	stosb
	mov [r10+TITEM.tmpcat],eax
	@nearest 4,rdi
	xchg rsi,r8
	add [r10+TITEM.len],r9w
	add [.thead.dsize],r9d

	;---
	and bl,F_NAME  or F_VALUE
	jmp	.readV

.readOP:
	add rsi,rcx
	inc bh
	jz .err_level
	test bl,F_NAME
	jz .err_name

.readOPA:
	push r13
	push r15
	mov r13,r15

	or [r13+TITEM.type],\
		TOBJECT
	xor bl,bl
	mov rcx,r13
	call .read
	pop r15
	pop r13
	test eax,eax
	jz .err_object	
	jmp	.readA

.readCP:
	add rsi,rcx
	dec bh
	jl	.err_level
	xor bl,bl
	mov rax,r12
	ret 0

	;ü------------------------------------------ö
	;|     SETUP COMMENT                        |
	;#------------------------------------------ä
.readC:
	;--- read comment
	add rsi,rcx
	call art.get_codepoint
	jz	.eof
	jl	.err_cpt
	cmp eax,CR_UTF8
	jnz	.readC
	jmp	.readA1

.err_cpt:		;--- error on codepoint
.err_len:		;--- error in string parsing
.err_state:	;--- error state flag
.err_comma:	;--- error comma withouth value
.err_quote: ;--- error quoted string
.err_value:
.err_name:	;--- : without name
.err_noname:
.err_nest:	;--- error closing par
.err_level:
.err_object:
	xor eax,eax
	stc
	ret 0

.eof:
	test bh,bh
	jnz	.err_level
	add rdi,sizeof.TITEM
	@nearest 16,rdi
	clc
	mov rax,r12
	ret 0

	;ü------------------------------------------ö
	;|     FREEE                                |
	;#------------------------------------------ä

.free:
	;--- in RCX mem to be freed
	jmp art.a16free

;display_decimal $-.parse
