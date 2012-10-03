  
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

ext:
	virtual at rbx
		.extc EXT_CLASS
	end virtual

	;#---------------------------------------------------ö
	;|             EXT.SETUP                             |
	;ö---------------------------------------------------ü

.setup:
	push rbp
	push rdi
	mov rbp,rsp

	sub rsp,\
	 FILE_BUFLEN
	
	xor edx,edx
	mov rdi,rsp

	mov ax,"*"
	stosw
	mov rax,qword[uzUtf8Ext]
	stosq
	xor eax,eax
	stosw

	mov rax,rdi

	;--- check for [ext\*.utf8] files
	push rdx
	push uzExtName
	push rax
	push rdx
	call art.catstrw

	;---	in RCX upath		;--- example "E:" or "E:\mydir"
	;---	in RDX uattr		;--- FILE_ATTRIBUTE_HIDDEN
	;---	in R8  ulevel		;--- nesting level to stop search 0=all
	;---	in R9  ufilter	;--- "*.asm"
	;---	in R10 ucback   ;--- address of a calback
	;---	in R11 uparam   ;--- user param
	;---------------------------------------------------

	xor r11,r11
	mov r10,.cb_classes
	mov r9,rsp
	xor r8,r8
	xor edx,edx
	mov rcx,rdi
	call [bk64.listfiles]

	mov rsp,rbp
	pop rdi
	pop rbp
	ret 0


.cb_classes:
	;---  the calback receives those args
	;--- in RCX path
	;--- in RDX w32fnd 
	;--- in R8h lenpath
	;--- in R9 uparam
	;--- ret RAX = 1 continue, 0 stop search

	test rdx,rdx
	jz	.cb_classesA

	;--- TODO: overflow on max len of .extc.name
	lea rcx,[rdx+\
		WIN32_FIND_DATA.cFileName]
	call .setup_class

.cb_classesA:
	xor eax,eax
	inc eax
	ret 0


	;#---------------------------------------------------ö
	;|             EXT.SETUP_CLASS                       |
	;ö---------------------------------------------------ü
.setup_class:
	;--- in RCX class file [assembly.utf8]
	push rbx
	push rdi

	mov rdi,rcx
	xor ebx,ebx

	;--- check for class ID if already there
	call .fn2hash
	test eax,eax
	jz .setup_classE
	mov rbx,rax

	mov rcx,rax
	call .is_class
	test rax,rax
	jnz .setup_classE

	mov ecx,\
		sizeof.EXT_CLASS
	call art.a16malloc
	test eax,eax
	jz	.setup_classE

	mov rdx,rbx
	push [pExtClass]
	mov rbx,rax
	pop [rax+\
		EXT_CLASS.next]
	mov [pExtClass],rax
	mov [.extc.id],rdx

	mov rcx,rdi
	lea rdx,[.extc.name]
	call utf16.copyz
	mov rax,rbx

.setup_classE:	
	pop rdi
	pop rbx
	ret 0
	
	;#---------------------------------------------------ö
	;|             EXT.FN/FE/2HASH                       |
	;ö---------------------------------------------------ü

.fn2hash:
	;--- in RCX class name [assembly.utf8]
	;--- or filename of an ext slot [inc.assembly]
	;--- or filename [myfile.asm]
	;--- ret RAX 0,hash
	;--- ret RCX point to part
	push 0
	jmp	.ff2hash

.fe2hash:
	push 1
	
.ff2hash:
	call art.get_ext
	pop r9
	test eax,eax
	jnz .ff2hashA
	ret 0

.ff2hashA:
	;--- RAX 0,pExtension	"asm"
	;--- RCX numchars	3
	;--- RDX original string
	mov rcx,rax
	sub rsp,16
	mov word[rax-2],0
	mov [rsp],rax
	test r9,r9
	cmovz rcx,rdx
	mov [rsp+8],rcx

	call utf16.zsdbm
	mov r9,[rsp]
	mov rcx,[rsp+8]
	mov word[r9-2],"."
	add rsp,16
	ret 0

	;#---------------------------------------------------ö
	;|             EXT.LOAD                              |
	;ö---------------------------------------------------ü

.load:
	;--- in RCX filename
	;--- ret RAX 0, eslot
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15
	mov rbp,rsp
	mov rsi,rcx

	sub rsp,\
		FILE_BUFLEN*2

	;--- get "asm" hash from [myfile.asm]
	call .fe2hash
	test eax,eax
	jz	.loadE

	mov rdi,rcx	;--- save ppart "asm"
	mov r12,rax	;--- save hash "asm"
	mov r13,rcx

	;--- check for EXT_SLOT "asm" hash
	mov rcx,rax
	call .is_ext

	test eax,eax
	jnz	.loadA

	mov rcx,rdi
	mov rdx,rsp
	call utf16.copyz

	mov rdi,rsp
	add rdi,rax
	mov ax,"."
	stosw
	mov ax,"*"
	stosw
	xor eax,eax
	stosw
	@nearest 16,rdi

	;--- check for config\ext\asm.* files
	xor edx,edx
	push rdx
	push uzExtName
	push rdi
	push rdx
	call art.catstrw

	;---	in RCX upath		;--- example "E:" or "E:\mydir"
	;---	in RDX uattr		;--- FILE_ATTRIBUTE_HIDDEN
	;---	in R8  ulevel		;--- nesting level to stop search 0=all
	;---	in R9  ufilter	;--- "*.asm"
	;---	in R10 ucback   ;--- address of a calback
	;---	in R11 uparam   ;--- user param

	xor r8,r8
	lea r11,[rsp+\
		FILE_BUFLEN]
	mov [r11],r8
	mov r10,.cb_item
	mov r9,rsp
	inc r8
	xor edx,edx
	mov rcx,rdi
	call [bk64.listfiles]

	;--- check for only ONE found item [asm.assembly]
	lea rcx,[rsp+\
		FILE_BUFLEN]
	movzx eax,word[rcx]
	test eax,eax
	jz	.loadE
	
	;--- get class id [assembly] from [asm.assembly]
	call .fe2hash
	test eax,eax
	jz	.loadE
	mov r15,rcx	;--- save ppart "assembly"
	mov r14,rax	;--- save hash "assembly"

	;--- check for EXT_SLOT "assembly" hash
	mov rcx,rax
	call .is_class

	test eax,eax
	jz	.loadE
	mov rbx,rax	;--- in RBX class

	;--- create a slot for "asm" extension
	mov ecx,\
		sizeof.EXT_SLOT
	call art.a16malloc
	test eax,eax
	jz	.loadE
	mov rdi,rax

	mov rcx,r12
	and ecx,0FFh
	mov rdx,[extHash]
	mov rax,[rdx+rcx*8]

	mov [rdi+\
		EXT_SLOT.hash],r12
	mov [rdi+\
		EXT_SLOT.clsid],r14
	mov [rdi+\
		EXT_SLOT.next],rax
	mov [rdx+rcx*8],rdi
	mov rax,rdi

.loadA:
	;--- EXT_SLOT "asm" hash exists

.loadE:
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

.cb_item:
	;---  the calback receives those args
	;--- in RCX path
	;--- in RDX w32fnd 
	;--- in R8h lenpath
	;--- in R9 uparam
	;--- ret RAX = 1 continue search, 0 stop search
	test rdx,rdx
	jz	.cb_itemA

	lea rcx,[rdx+\
		WIN32_FIND_DATA.cFileName]
	mov rdx,r9
	call utf16.copyz

.cb_itemA:
	xor eax,eax
	ret 0


	;#---------------------------------------------------ö
	;|             EXT.IS_CLASS                          |
	;ö---------------------------------------------------ü

.is_class:
	;--- check for class ID
	;--- in RCX hash class
	;--- ret RAX 0,class slot

	mov rdx,[pExtClass]
	xor eax,eax
	test edx,edx
	jz	.is_classE

.is_classC:
	cmp rcx,[rdx+\
		EXT_CLASS.id]
	jz	.is_classB

	mov rax,[rdx+\
		EXT_CLASS.next]
	test eax,eax
	jz	.is_classE

	mov rdx,rax
	jmp	.is_classC

.is_classB:
	mov rax,rdx

.is_classE:
	ret 0

	;#---------------------------------------------------ö
	;|             EXT.IS_EXT                            |
	;ö---------------------------------------------------ü
.is_ext:
	;--- in RCX hash
	;--- ret RAX 0,slot
	;--- ret R9 original hash

	mov r9,rcx
	mov rdx,[extHash]
	xor eax,eax
	and ecx,0FFh

.is_extA:
	mov r8,[rdx+rcx*8]
	jmp	.is_extB

.is_extD:
	mov r8,[r8+\
		EXT_SLOT.next]

.is_extB:
	test r8,r8
	jnz	.is_extC
	ret 0

.is_extC:
	cmp r9,[r8+\
		EXT_SLOT.hash]
	jnz	.is_extD
	mov rax,r8
	ret 0

	;#---------------------------------------------------ö
	;|             EXT.DISCARD                           |
	;ö---------------------------------------------------ü

.discard:
	;--- discard all EXT_CLASS
	;--- discard all mem in EXT_CLASS
	push rbx
	push rdi
	xor ebx,ebx
	call .discard_slot
	xchg rbx,[pExtClass]

.discardB:
	test ebx,ebx
	jz .discardE

	mov rcx,[.extc.top]
	test rcx,rcx
	jz	.discardA
	call [top64.free]

.discardA:	
	mov rdi,[.extc.next]
	mov rcx,rbx
	call art.a16free
	mov rbx,rdi
	jmp	.discardB

.discardE:
	pop rdi
	pop rbx
	ret 0


	;#---------------------------------------------------ö
	;|             EXT.DISCARD_SLOT                      |
	;ö---------------------------------------------------ü

.discard_slot:
	push rbx
	push rdi
	push r12
	mov rbx,[extHash]
	mov r12,100h

.discard_slotB:
	mov rcx,[rbx]
	test rcx,rcx
	jz	.discard_slotA

	mov rdi,[rbx+\
		EXT_SLOT.next]
	call art.a16free

.discard_slotC:
	mov rcx,rdi
	test rdi,rdi
	jz .discard_slotA
	call art.a16free

	mov rdi,[rdi+\
		EXT_SLOT.next]
	jmp	.discard_slotC
	
.discard_slotA:
	add rbx,8
	dec r12
	jnz	.discard_slotB

	mov rdx,[extHash]
	mov ecx,100h*8
	call art.zeromem

	pop r12
	pop rdi
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|             EXT.APPLY                             |
	;ö---------------------------------------------------ü

.apply:
	;--- in RCX eslot
	;--- in RDX labf
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15

	mov rbp,rsp
	sub rsp,\
		FILE_BUFLEN

	xor eax,eax
	mov r13,rdx

	test rcx,rcx
	jz	.applyE

	mov rcx,[rcx+\
		EXT_SLOT.clsid]

	test ecx,ecx
	jz	.applyE

	call .is_class
	test rax,rax
	jz	.applyE

	mov rbx,rax
	mov rax,[.extc.top]
	test rax,rax
	jnz .applyB

	mov rdx,rsp
	lea rcx,[.extc.name]

	push rax
	push rcx
	push uzSlash
	push uzExtName
	push rdx
	push rax
	call art.catstrw

	mov rcx,rsp
	call [top64.parse]
	test rax,rax
	jz	.applyE

	;--- RET RCX datasize
	;--- RET RDX numitems

	mov [.extc.top],rax
	mov [.extc.dsize],ecx
	mov [.extc.items],edx
	
.applyB:
	mov rsi,rax
	mov r12,rax	;--- base
	xor r14,r14	;--- current style index
	jmp	.applyM

.applyN:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,r12
	cmp rsi,r12
	jz	.applyF
	
.applyM:
	mov eax,[rsi+\
		TITEM.hash]

	mov edx,[rsi+\
		TITEM.attrib]

	;---------------------
	cmp eax,\
		HASH_style
	jz .apply_style

	cmp eax,\
		HASH_back
	jz .apply_backcolor

	cmp eax,\
		HASH_fore
	jz .apply_forecolor

	cmp eax,\
		HASH_font
	jz .apply_font
	
	cmp eax,\
		HASH_fontsize
	jz .apply_fontsize

	cmp eax,\
		HASH_bold
	jz .apply_bold

	cmp eax,\
		HASH_italic
	jz .apply_italic

	cmp eax,\
		HASH_keyword
	jz .apply_keyword

	;-------------------
	cmp eax,\
		HASH_commline
	jz	.set_commline

	cmp eax,\
		HASH_clearall
	jz .apply_clearall

	cmp eax,\
		HASH_stylebits
	jz .apply_stylebits

	cmp eax,\
		HASH_multisel
	jz .apply_multisel

	cmp eax,\
		HASH_tabwidth
	jz .apply_tabwidth

	cmp eax,\
		HASH_selback
	jz .apply_selback

	cmp eax,\
		HASH_lexer
	jz .apply_lexer
	jmp	.applyN

	;--------------------
.set_commline:
	mov r8,rdx
	test edx,edx
	jz .applyN

	add rdx,r12
	xor eax,eax

	cmp [rdx+\
		TITEM.type],TQUOTED
	jnz	.applyN

	cmp ax,[rdx+\
		TITEM.len]
	jz	.applyN

	mov [.extc.top_comml],eax
	cmp [rdx+\
		TITEM.len],MAX_COMMLINE_LEN
	ja .applyN
	mov [.extc.top_comml],r8d
	jmp	.applyN

.apply_font:
	mov r10,\
		sci.set_font
		jmp	.apply_R8styleNS

.apply_bold:
	mov r10,\
		sci.set_bold
	jmp	.apply_R8styleNN

.apply_italic:
	mov r10,\
		sci.set_italic
	jmp	.apply_R8styleNN

.apply_fontsize:
	mov r10,\
		sci.set_fontsize
	jmp	.apply_R8styleNN
	
.apply_forecolor:
	mov r10,\
		sci.set_forecolor
		jmp	.apply_R8styleNN
	
.apply_backcolor:
	mov r10,\
		sci.set_backcolor
		jmp	.apply_R8styleNN

.apply_R8styleNS:
	mov r8,r14
	test edx,edx
	jz .applyN

	add rdx,r12
	cmp [rdx+\
		TITEM.type],TQUOTED
	jnz	.applyN
	
	lea r9,[rdx+\
		TITEM.value]
	jmp	.apply_call


.apply_R8styleNN:
	mov r8,r14

	test edx,edx
	jz .applyN

	add rdx,r12
	cmp [rdx+\
		TITEM.type],TNUMBER
	jnz	.applyN
	
	mov r9d,[rdx+\
		TITEM.lo_dword]
	jmp	.apply_call

.apply_clearall:
	xor r8,r8
	xor r9,r9
	mov r10,\
		sci.style_clearall
	jmp	.apply_call

.apply_style:
	test edx,edx
	jz .applyN

	add rdx,r12
	cmp [rdx+\
		TITEM.type],TNUMBER
	jnz	.applyN
	
	mov r14d,[rdx+\
		TITEM.lo_dword]
	and r14d,03Fh
	jmp	.applyN

.apply_tabwidth:
	mov r10,\
	sci.set_tabwidth
	jmp	.apply_R8N
	
.apply_multisel:
	mov r10,\
	sci.set_multisel
	jmp	.apply_R8N
	
.apply_stylebits:
	mov r10,\
	sci.set_stylebits
	jmp	.apply_R8N

.apply_lexer:
	mov r10,\
		sci.set_lexer

.apply_R8N:
	test edx,edx
	jz .applyN

	add rdx,r12
	cmp [rdx+\
		TITEM.type],TNUMBER
	jnz	.applyN
	
	mov r8d,[rdx+\
		TITEM.lo_dword]
	and r8d,0FFh

.apply_call:
	mov rcx,[r13+\
		LABFILE.hSci]
	call r10
	jmp	.applyN

.apply_selback:
	mov r10,\
		sci.set_selback
	jmp	.apply_R8R9NN

.apply_R8R9NN:
	test edx,edx
	jz .applyN

	add rdx,r12
	cmp [rdx+\
		TITEM.type],TNUMBER
	jnz	.applyN
	
	mov r8d,[rdx+\
		TITEM.lo_dword]
	
	mov eax,[rdx+\
		TITEM.attrib]
	test eax,eax
	jz .applyN

	add rax,r12
	cmp [rax+\
		TITEM.type],TNUMBER
	jnz	.applyN
	
	mov r9d,[rax+\
		TITEM.lo_dword]
	jmp	.apply_call

.apply_keyword:
	mov r10,\
		sci.set_keyword
	jmp	.apply_R8R9NS

.apply_R8R9NS:
	test edx,edx
	jz .applyN

	add rdx,r12
	cmp [rdx+\
		TITEM.type],TNUMBER
	jnz	.applyN
	
	mov r8d,[rdx+\
		TITEM.lo_dword]
	
	mov eax,[rdx+\
		TITEM.attrib]
	test eax,eax
	jz .applyN

	add rax,r12
	cmp [rax+\
		TITEM.type],TQUOTED
	jnz	.applyN
	
	lea r9,[rax+\
		TITEM.value]
	jmp	.apply_call

.applyF:

	
.applyE:
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

