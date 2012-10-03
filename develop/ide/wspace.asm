  
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

wspace:
	virtual at rbx
		.labf LABFILE
	end virtual

	virtual at rbx
		.dir DIR
	end virtual

	virtual at rbx
		.conf CONFIG
	end virtual

	virtual at rdi
		.lvc	LVCOLUMNW
	end virtual

	virtual at rsi
		.pEdit EDIT
	end virtual

	virtual at rsi
		.io	IODLG
	end virtual

.check:
	;--- RET EAX = -1 errror
	;--- RET EAX = 0 cannot close/abort operation
	;--- RET EAX = 1 no need to save/saved ok
	push rbp
	push rbx
	push rdi
	mov rbp,rsp

	sub rsp,\
		FILE_BUFLEN*2
	mov rdi,rsp

	mov rdx,[hRootWsp]
	mov rcx,\
		.close_asksave
	call .list

	test eax,eax
	jle .checkE

	mov rbx,[pLabfWsp]

	test [.labf.type],\
		LF_MODIF
	jz	.checkB;.checkA

	mov rax,[.labf.dir]
	lea rcx,[rax+DIR.dir]
	lea rdx,[rbx+\
		sizeof.LABFILE]

	push 0
	push rdx
	push uzSlash
	push rcx
	push rdi
	push 0
	call art.catstrw
	
	lea r8,[rdi+\
		FILE_BUFLEN]
	mov edx,U16
	mov ecx,UZ_IO_SAVEWSP
	call [lang.get_uz]

	lea r8,[rdi+\
		FILE_BUFLEN]
	mov rdx,rdi
	mov rcx,[hMain]
	call apiw.msg_ync

	mov ecx,eax
	xor eax,eax
	cmp ecx,IDCANCEL
	jz .checkE
	cmp ecx,IDNO
	jz .checkB

.checkA:
	call wspace.save_wsp

.checkB:
	mov rdx,[hRootWsp]
	mov rcx,\
		.discard
	call .list

.checkE:
	mov rsp,rbp
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|               Save open docs                      |
	;ö---------------------------------------------------ü
.save_docs:
	;--- in RCX How
	;--- RET EAX = -1 errror
	;--- RET EAX = 0 cannot close/abort operation
	;--- RET EAX = 1 no need to save/saved ok
	push rbp
	push rbx
	push rdi
	push rsi
	push r13
	mov rbp,rsp

	mov rsi,rcx
	xor r13,r13

	sub rsp,\
		sizea16.LVITEMW

	mov rcx,[hDocs]
	call lvw.get_count
	mov r13,rax
	test rax,rax
	jnz	.save_docsA
	inc eax
	jmp .save_docsE

.save_docsA:
	xor eax,eax
	inc eax
	dec r13
	js .save_docsE

	mov r9,rsp
	dec eax
	mov [r9+\
		LVITEMW.iItem],r13d
	mov [r9+\
		LVITEMW.iSubItem],eax
	mov rcx,[hDocs]
	call lvw.get_param
	dec eax
	js	.save_docsE

	or rax,-1
	mov rbx,[rsp+\
		LVITEMW.lParam]
	test rbx,rbx
	jz	.save_docsE

.save_docsA1:
	mov rdx,rsi
	mov rcx,rbx
	call .save_file

.save_docsA3:
	test rax,rax
	jg	.save_docsA
	
.save_docsE:
	mov rsp,rbp
	pop r13
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|                   WSPACE.CLOSE_FILE               |
	;ö---------------------------------------------------ü
.close_file:
	;--- in RCX labf
	;--- in RDX how
	;--- RET EAX = -1 errror
	;--- RET EAX = 0 cannot close/abort operation
	;--- RET EAX = 1 no need to save/saved ok
	xor eax,eax
	test rcx,rcx
	jnz	.close_fileA
	ret 0

.close_fileA:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	mov rbp,rsp

	sub rsp,\
		FILE_BUFLEN*2

	mov rbx,rcx
	mov r12,rdx

	movzx eax,\
		[.labf.type]

	cmp r12,ASK_SAVE
	jnz .close_fileNA

	test eax,LF_MODIF
	jz	.close_fileNA
	
;	test eax,LF_BLANK
;	jnz .mi_fi_closeC

	mov rdx,r12
	mov rcx,rbx
	call wspace.save_file

	test eax,eax
	jle .close_fileE

.close_fileNA:
	;--- check for idx and prev item
	;--- in open docs list
	mov rdx,rbx
	mov rcx,[hDocs]
	call lvw.is_param
	dec rax
	js	.close_fileE	;--- internal error

	inc rax
	mov rdi,rcx			;--- save prev labf
	mov rsi,rdx			;--- save our idx

	test rdi,rdi
	jnz	.close_fileC

	mov r9,LVNI_ALL
	mov r8,rdx
	mov rcx,[hDocs]
	call lvw.get_next

	inc rax
	jz	.close_fileC
	dec rax

	mov r9,rsp
	mov [r9+LVITEMW.iItem],eax

	xor r10,r10
	mov [r9+\
		LVITEMW.iSubItem],r10d

	mov rcx,[hDocs]
	call lvw.get_param

	test rax,rax
	jz	.close_fileC

	mov rdi,[rsp+\
		+LVITEMW.lParam]

.close_fileC:
	mov r8,rsi
	mov rcx,[hDocs]
	call lvw.del_item

	mov rcx,rbx
	call edit.close

	mov rdx,[.labf.hItem]
	test edx,edx
	jz	.close_fileD

	mov r8,FALSE
	mov rcx,[hTree]
	call tree.set_bold

.close_fileD:
	and [.labf.type],\
		not (LF_OPENED or LF_MODIF)

	test [.labf.type],\
		LF_BLANK
	jz .close_fileB

	;--- delete items when blanks
	;--- and untouched ----------

	;	and [.labf.type],\
	;		not LF_BLANK
	;	mov r9,[.labf.hItem]
	;	test r9,r9
	;	jz	.close_fileB

	;	mov rcx,[hTree]
	;	call tree.del_item

	;.close_fileF:	
	mov rcx,rbx
	call art.a16free

.close_fileB:
	mov rcx,rdi
	call edit.view

	xor eax,eax
	inc eax

.close_fileE:
	mov rsp,rbp
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|                   WSPACE.save_file                |
	;ö---------------------------------------------------ü
.save_file:
	;--- in RCX labf
	;--- in RDX how
	;--- RET EAX = -1 errror
	;--- RET EAX = 0 cannot close/abort operation
	;--- RET EAX = 1 no need to save/saved ok

	push rbx
	push rdi
	push rsi
	push r12

	mov rbx,rcx
	mov r12,rdx

	sub rsp,\
		FILE_BUFLEN*2

	movzx eax,[.labf.type]
	mov rsi,[pIo]
	mov edi,eax

	test eax,LF_MODIF
	jz	.save_file1

	test eax,LF_TXT
	jz	.save_fileF		;--- TODO: err for now
	
	test eax,LF_BLANK
	jnz .save_fileG1

	cmp r12,NOASK_SAVE
	jz	.save_fileG
	
.save_fileG1:
	mov rcx,rbx
	call edit.view

.save_fileG:
	mov r8,rsp
	mov rax,[.labf.dir]
	lea rdx,[rbx+\
		sizeof.LABFILE]
	lea rcx,[rax+DIR.dir]
	mov r9,[rax+DIR.rdir]

	test [rax+DIR.type],\
		DIR_HASREF
	jz	@f
	lea rcx,[r9+DIR.dir]
@@:
	push 0
	push rdx
	push uzSlash
	push rcx
	push r8
	push 0
	call art.catstrw

	mov eax,edi
	mov rdi,rsp

	test eax,LF_BLANK
	jnz .save_fileBT

	cmp r12,NOASK_SAVE
	jz	.save_fileA

.save_fileBT:
	;--- 2) prompt user for file to be saved
	lea r8,[rdi+\
		FILE_BUFLEN]
	mov edx,U16
	mov ecx,UZ_FSAVE
	call [lang.get_uz]

	lea r8,[rdi+\
		FILE_BUFLEN]
	mov rdx,rdi
	mov rcx,[hMain]
	call apiw.msg_ync

	cmp eax,IDCANCEL
	jz .save_file0
	cmp eax,IDYES
	jnz .save_file1

.save_fileBT1:
	;--- save BLANK TEXT file -------
	test [.labf.type],\
		LF_BLANK
	jz	.save_fileA

.save_fileBT2:
	mov rdx,rbx
	mov rcx,IO_SAVECUR
	call iodlg.start
	cmp eax,IDCANCEL
	jz	.save_file0

	lea rdx,[.io.buf]
	mov rax,[.io.ldir]
	test rax,rax
	jz .save_fileE
	lea rcx,[rax+DIR.dir]

	push 0
	push rdx
	push uzSlash
	push rcx
	push rdi
	push 0
	call art.catstrw

	mov rcx,rdi
	call art.is_file
	jz	.save_fileA

	lea r8,[rdi+\
		FILE_BUFLEN]
	mov edx,U16
	mov ecx,UZ_OVERWFILE
	call [lang.get_uz]

.save_fileC:
	lea r8,[rdi+\
		FILE_BUFLEN]
	mov rdx,rdi
	mov rcx,[hMain]
	call apiw.msg_ync

	;--- propmt user OVERWRITE FILE
	cmp eax,IDCANCEL
	jz .save_file0
	cmp eax,IDNO
	jz	.save_fileBT2
	
.save_fileA:
	xor r8,r8
	mov rdx,rdi
	mov rcx,[.labf.hView]
	call sci.save

	test eax,eax
	jz .save_fileF

	;--- after saving setup GUI ----
	movzx eax,[.labf.type]
	and [.labf.type],\
		not (LF_BLANK or LF_MODIF)

	test ax,LF_BLANK
	jz	.save_file1

	;1) --- update labfile on len filename
	movzx eax,[.labf.alen]
	sub eax,2
	cmp ax,[.io.buflen]
	jb .save_fileF			;--- cannot update filename in tree

	lea rcx,[.io.buf]
	lea rdx,[rbx+\
		sizeof.LABFILE]
	call utf16.copyz

	mov rax,[.io.ldir]
	mov [.labf.dir],rax

	;2) --- update open docs
	mov rdx,rbx
	mov rcx,[hDocs]
	call lvw.is_param
	test eax,eax
	jz	.save_fileF	;--- internal error
	mov r8,rdx
	mov r9,rsp
	xor ecx,ecx

	push r8		;--- index item
	lea rdx,[.io.buf]
	mov [r9+\
		LVITEMW.iSubItem],ecx
	mov [r9+\
		LVITEMW.pszText],rdx
	mov rcx,[hDocs]
	call lvw.set_itext

	;--- set icon for prev LF_BLANK
	mov rcx,rbx
	call .get_icon
	mov [.labf.iIcon],eax
	mov [.labf.hIcon],rdx

	pop rdx		;--- index item
	xor ecx,ecx
	mov r9,rsp
	mov r8,rax
	mov [r9+\
		LVITEMW.iSubItem],ecx
	mov rcx,[hDocs]
	call lvw.set_icon

	;--- set new view for prev LF_BLANK
	mov rcx,rbx
	call edit.view

	;--- apply Sci class on prev LF_BLANK
	mov rcx,rbx
	add rcx,\
		sizeof.LABFILE
	call ext.load
	test eax,eax
	jz	.save_file1
	
	mov rdx,rbx
	mov rcx,rax
	call ext.apply

.save_file1:
	xor eax,eax
	inc eax
	jmp .save_fileE

.save_file0:
	xor eax,eax
	jmp .save_fileE

.save_fileF:
	or rax,-1

.save_fileE:
	add rsp,\
		FILE_BUFLEN*2
	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|               list for actions to be executed     |
	;ö---------------------------------------------------ü
.list:
	;--- in RCX howlabel
	;--- in RDX starting hItem
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13

	mov rbp,rsp

	mov r12,rcx
	mov r13,rdx

	mov rcx,[hTree]
	call tree.countall
	test eax,eax
	jz .list1

	inc eax
	inc eax		;--- zero term

	shl eax,3
	@frame rax
	mov rdx,rax
	call art.zeromem

	xor ebx,ebx	;--- setup level
	xor esi,esi	;--- datalen text of labf
	mov rdi,rax	;--- setup buffer
	mov rdx,r13;[hRootWsp]
	call tree.list

	mov rbx,rsi	;--- save datasize
	mov rsi,rsp	;--- RSI point to labf,last is 0
	jmp	r12

	;--- list to close items in treeview
	;--- ASK save ---------------------
.askscC:
	xor eax,eax
	test [.labf.type],\
		LF_OPENED
	jz	.close_asksave

	;--- because treeitems have been 
  ;--- already asked/saved from wspace.save_docs
	cmp rax,[.labf.hItem]
	jnz	.close_asksave

	test [.labf.type],\
		LF_MODIF
	jz	.close_asksave

.close_asksaveA:
	mov edx,ASK_SAVE
	call .close_file
	test eax,eax
	jle	.listE

.close_asksave:
	pop rcx
	test rcx,rcx
	mov rbx,rcx
	jnz .askscC
	jmp	.list1

	;--- list to close items 
	;--- by user deleting them on WSP
.askscD:
	test [.labf.type],\
		LF_FILE
	jz	.close_delitem

	test [.labf.type],\
		LF_OPENED
	jz	.close_delitem

	test [.labf.type],\
		LF_MODIF
	jz	.close_delitem

	mov edx,ASK_SAVE
	call .close_file
	test eax,eax
	jle	.listE

.close_delitem:
	pop rcx
	test rcx,rcx
	mov rbx,rcx
	jnz .askscD
	jmp	.list1


	;--- list to discard items in treeview
.discard:
	mov r9,TVI_ROOT
	mov rcx,[hTree]
	call tree.del_item

	xor eax,eax
	mov rcx,[pConf]
	mov [hRootWsp],rax
	mov [pLabfWsp],rax
	jmp	.discardD


	;--- list to discard items in treeview
	;--- by user deleting them
.discard_delitem:
	mov r9,r13
	mov rcx,[hTree]
	call tree.del_item
	jmp	.discardD

.discardC:
	test [.labf.type],\
		LF_OPENED
	jz	.discardA
	xor edx,edx
	call .close_file

.discardA:
	;	mov r9,[.labf.hItem]
	;	mov rcx,[hTree]
	;	call tree.del_item
	mov rcx,rbx
	call art.a16free

.discardD:
	pop rcx
	test rcx,rcx
	mov rbx,rcx
	jnz .discardC
	
.list1:
	xor eax,eax
	inc eax

.listE:	
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|               Save Workspace                      |
	;ö---------------------------------------------------ü

.save_wsp:
	;--- RET EAX = -1 errror
	;--- RET EAX = 0 cannot close/abort operation
	;--- RET EAX = 1 no need to save/saved ok

	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	mov rbp,rsp

	mov rbx,[pLabfWsp]
	test [.labf.type],\
		LF_BLANK
	jz	.save_wspA

	sub rsp,\
		FILE_BUFLEN*2
	mov rdi,rsp
	mov rsi,[pIo]

.save_wspC1:
	mov rdx,[projDir]
	mov rcx,IO_SAVEWSP
	add rsi,rcx
	mov [rsi+IODLG.ldir],rdx
	call iodlg.start

	mov ecx,eax
	xor eax,eax
	cmp ecx,IDCANCEL
	jz	.save_wspE
	
	lea rdx,[.io.buf]
	mov rax,[.io.ldir]
	test rax,rax
	jz .save_wspE

	lea rcx,[rax+DIR.dir]

	push 0
	push rdx
	push uzSlash
	push rcx
	push rdi
	push 0
	call art.catstrw

	mov rcx,rdi
	call art.is_file
	jz	.save_wspB

	lea r8,[rdi+\
		FILE_BUFLEN]
	mov edx,U16
	mov ecx,UZ_OVERWFILE
	call [lang.get_uz]

.save_wspC:
	lea r8,[rdi+\
		FILE_BUFLEN]
	mov rdx,rdi
	mov rcx,[hMain]
	call apiw.msg_ync

	mov ecx,eax
	xor eax,eax

	;--- propmt user OVERWRITE WSP FILE
	cmp ecx,IDCANCEL
	jz .save_wspE
	cmp ecx,IDNO
	jz	.save_wspC1
	
.save_wspB:
	;--- copy path+name to cfg wsp

	mov r8,[pConf]
	lea rdx,[r8+\
		CONFIG.wsp]
	mov rcx,rdi
	call utf16.copyz
	add rsp,\
		FILE_BUFLEN*2

.save_wspA:
	mov rcx,[hTree]
	call tree.countall

	xor ebx,ebx			;--- RBX later for data size
	mov r12,rax
	test eax,eax
	jz .save_wspE		;--- err cannot be no items

	dec r12
	jz .save_wspKE	;--- only root item
	inc r12
	inc eax		;--- zero term
	inc eax		;--- zero term

	shl eax,3
	@frame rax
	mov rdx,rax
	call art.zeromem

	xor ebx,ebx	;--- 
	xor esi,esi	;--- datalen text of labf
	mov rdi,rax	;--- setup buffer
	mov rdx,[hRootWsp]
	call tree.list

	;--- calculate num known dirs/ datasize ------

	mov rbx,rsi	;--- save datasize
	mov rsi,rsp	;--- RSI point to labf,last is 0
	xor eax,eax
	push 0			;--- zero term

.save_wspK:
	lodsq
	and al,0FCh
	test rax,rax
	jz	.save_wspKE

	mov rdx,[rax+\
		LABFILE.dir]
	mov r8,rsp

.save_wspK2:
	mov rax,[r8]
	test rax,rax
	jnz	.save_wspK3

	inc r12
	push rdx
	add ebx,[rdx+\
		DIR.len]
	jmp	.save_wspK

.save_wspK3:
	cmp rax,rdx
	jz .save_wspK
	add r8,8
	jmp	.save_wspK2

.save_wspKE:
	;--- RSP point to avail KDIR ------
	;--- RBX data size
	;--- R12 num items
	;--- typical item   04 : 0F639768B040DF0D0h , " attach.txt " ( ) . 
	;--- ~64 -------  32 2 1 1       16       1 1 1            1 1 1 1

	mov r13,rsp 		;--- src items
	shl r12,7				;--- safer 128
	add rbx,r12
	add rbx,\
		FILE_BUFLEN+\	;--- temp buffer
		1024					;--- extra text
	@nearest 4096,rbx
	@frame rbx

	mov rbx,rax			;--- RBX temp buffer
	mov r14,rax			;--- temp buffer+text
	lea rdi,[rax+\	;--- RDI start dest text
		FILE_BUFLEN]
	
	mov al,09
	stosb
	;--- insert utf8 warning -------
	xor edx,edx
	mov ecx,UZ_INFO_UTF8
	call [lang.get_uz]
	mov rsi,rax
	rep movsb
	@do_eol
	
	mov al,09
	stosb
	;--- insert top info -------
	xor edx,edx
	mov ecx,UZ_INFO_TOP
	call [lang.get_uz]
	mov rsi,rax
	rep movsb
	@do_eol

	mov al,09
	stosb
	;--- insert copyright -------
	xor edx,edx
	mov ecx,UZ_INFO_COPYR
	call [lang.get_uz]
	mov rsi,rax
	rep movsb
	@do_eol
	@do_eol

	;--- in RSP found kdirs
	test r12,r12
	jz .save_wspF

	mov rsp,r13
	mov eax,"	k:("
	stosd

.save_wspD:
	pop r13
	test r13,r13
	jz	.save_wspDE

	mov rdx,rbx
	lea rcx,[r13+\
		DIR.dir]
	call utf16.to8
	mov ecx,eax

	@do_eol
	mov al,09h
	stosb
	mov eax,'	.:"'
	stosd
	mov rsi,rbx
	rep movsb
	mov al,'"'
	stosb
	jmp .save_wspD

.save_wspDE:
	@do_eol
	mov ax,"	)"
	stosw
	@do_eol

	mov r9,[hRootWsp]
	mov rcx,[hTree]
	call tree.get_child	
	test rax,rax
	jz	.save_wspF

	xor r12,r12	;--- level
	mov rdx,rax
	mov r13,rbx	;--- tmp buflen to r13
	push .save_wspF

	;-------------------------------

.save_wspL:
	sub rsp,\
		sizeof.TVITEMW
	inc r12

.save_wspLA:
	@do_eol
	mov rcx,r12
	@do_indent

	mov r9,rsp
	mov rcx,[hTree]
	call tree.get_param
	test eax,eax
	jz	.save_wspLD

	mov rbx,[rsp+\
		TVITEMW.lParam]
	test rbx,rbx
	jz	.save_wspLD
	call .save_wspT
	
	mov ecx,[rsp+\
		TVITEMW.cChildren]
	and ecx,1

	mov rdx,[rsp+\
		TVITEMW.hItem]
	dec ecx
	js .save_wspLC

.save_wspLB:
	mov al,"("
	stosb
	push rdx
	mov r9,rdx
	mov rcx,[hTree]
	call tree.get_child
	mov rdx,rax
	call .save_wspL
	pop rdx
	mov rcx,r12
	@do_indent
	mov al,")"
	stosb
	jmp	.save_wspLC1

.save_wspLC:
	;--- check .sibling ----
	test [.labf.type],\
		LF_FILE
	jnz	.save_wspLC1
	mov ax,"()"
	stosw

.save_wspLC1:
	mov r9,rdx
	mov rcx,[hTree]
	call tree.get_sibl
	mov rdx,rax
	test eax,eax
	jnz	.save_wspLA

.save_wspLD:
	add rsp,\
		sizeof.TVITEMW
	dec r12
	@do_eol
	ret 0

.save_wspT:
	;--- in RDI dest buffer
	;--- in RBX labf
	movzx eax,\
		[.labf.type]

	and eax,\
		LF_PRJ or\
		LF_FILE or\
		LF_LNK
	or al,[.labf.state]
	call art.b2a
	stosw
	mov ax,":0"
	stosw
	mov rax,[.labf.dir]
	mov rcx,[rax+DIR.hash]
	mov rdx,rdi
	call art.qword2a

	add rdi,rax
	mov ax,"h,"
	stosw
	mov al,'"'
	stosb

	mov rdx,r13
	lea rcx,[rbx+\
		sizeof.LABFILE]
	call utf16.to8

	mov ecx,eax
	mov rsi,r13
	rep movsb
	mov al,'"'
	stosb
	ret 0

.save_wspF:
	;--- in R14 pointer to buflen
	;--- text begins at R14+FILE_BUFLEN
	;--- RDI - R14 + FILE_BUFLEN= size

	;--- finalize writing to file -----------
	;--- 1) check wsp newblank/existent
	mov rsp,r14

	mov rdx,[pConf]
	lea rcx,[rdx+\
		CONFIG.wsp]

	sub rsp,\
		FILE_BUFLEN*2

	mov rdx,rsp
	call apiw.exp_env
	
	mov rcx,rdx
	call art.fcreate_rw

	mov rsp,r14
	test rax,rax
	jle	.save_wspE
	mov rbx,rax				;--- file handle

	mov r8,rdi
	lea rdx,[r14+\
		FILE_BUFLEN]
	mov rcx,rax
	sub r8,rdx
	call art.fwrite

	mov rcx,rbx
	call art.fclose

	mov rbx,[pLabfWsp]
	and [.labf.type],\
			not LF_MODIF

	test [.labf.type],\
		LF_BLANK
	jz .save_wspE

	and [.labf.type],\
		not LF_BLANK

	mov rsi,[pIo]
	add rsi,IO_SAVEWSP
	mov rax,[.io.ldir]
	mov [.labf.dir],rax

	lea rcx,[.io.buf]
	lea rdx,[rbx+\
		sizeof.LABFILE]
	call utf16.copyz

	sub rsp,\
		sizeof.TVITEMW
	mov r9,rsp

	lea rax,[rbx+\
		sizeof.LABFILE]

	mov [r9+TVITEMW.pszText],\
		LPSTR_TEXTCALLBACK
	mov rax,[.labf.hItem]

	mov [r9+TVITEMW.hItem],rax
	mov [r9+TVITEMW.lParam],rbx
	mov [r9+TVITEMW.mask],\
		TVIF_TEXT or \
		TVIF_HANDLE or \
		TVIF_PARAM

	mov rcx,[hTree]
	call tree.set_item

	xor eax,eax
	inc eax

.save_wspE:
	mov rsp,rbp
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0


	;#---------------------------------------------------ö
	;|                   WSPACE.OPEN_FILE                |
	;ö---------------------------------------------------ü

.open_file:
	;--- in RCX labf
	;--- RET EAX = 0 error,labf
	xor eax,eax
	test rcx,rcx
	jnz	.open_fileA
	ret 0

.open_fileA:
	call edit.open
	test rax,rax
	jnz	.open_fileB
	ret 0

.open_fileB:
	push rbx
	push rsi

	mov rbx,rax
	mov rsi,[pEdit]

	mov r8,TRUE
	mov rdx,[.labf.hItem]
	mov rcx,[hTree]
	call tree.set_bold

;	mov rcx,rbx
;	call edit.view

	mov rcx,rbx
	call .ins_doc

	mov r9,[.labf.hItem]
	mov rcx,[hTree]
	call tree.sel_item

	mov rax,rbx

	pop rsi
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|             WSPACE.new_bt                         |
	;ö---------------------------------------------------ü

.new_bt:
	push rbx
	
	mov edx,\
		LF_TXT or \
		LF_BLANK or \
		LF_FILE

	xor ecx,ecx
	call edit.new
	test rax,rax
	jz	.new_btE

	mov rbx,rax
	or [.labf.type],\
		LF_OPENED

	;--- insert doc in LVW ----
	mov rcx,rax
	call wspace.ins_doc

	;--- view new doc ----
	mov rcx,rbx
	call edit.view
	mov rax,rbx

.new_btE:
	pop rbx
	ret 0
	
	;#---------------------------------------------------ö
	;|             WSPACE.new_file                       |
	;ö---------------------------------------------------ü

.new_file:
	;--- in RCX reference labf/0
	;--- in RDX type
	;--- RET RAX 0,labf
	push rbx
	push rsi
	push rdi
	push r12
	push r13
	push r14
	push r15

	sub rsp,\
		FILE_BUFLEN*2

	xor r12,r12
	mov r14,rdx
	xor eax,eax
	test ecx,ecx
	jz	.new_fileE

	mov rdi,rsp
	mov rbx,rcx
	mov rsi,[pIo]

	;--- ask to save it first -------

.new_fileA:
	mov rdx,[.labf.dir]
	mov rcx,IO_NEWNAME
	add rsi,rcx
	mov [rsi+IODLG.ldir],rdx
	call iodlg.start

	cmp eax,IDCANCEL
	jz	.new_fileE

	lea rdx,[.io.buf]
	mov rax,[.io.ldir]
	test rax,rax
	jz .new_fileE

	lea rcx,[rax+DIR.dir]
	mov r8,[rax+DIR.rdir]
	test [rax+DIR.type],\
		DIR_HASREF
	jz	@f
	lea rcx,[r8+DIR.dir]

@@:
	mov r13,rcx
	push 0
	push rdx
	push uzSlash
	push rcx
	push rdi
	push 0
	call art.catstrw

	mov rcx,rdi
	call art.is_file
	jz	.new_fileD

	lea r8,[rdi+\
		FILE_BUFLEN]
	mov edx,U16
	mov ecx,UZ_OVERWFILE
	call [lang.get_uz]

.new_fileC:
	lea r8,[rdi+\
		FILE_BUFLEN]
	mov rdx,rdi
	mov rcx,[hMain]
	call apiw.msg_ync

	;--- user choice SAVE/OVERWRITE FILE --
	cmp eax,IDCANCEL
	jz .new_fileE
	cmp eax,IDNO
	jz	.new_fileA

.new_fileD:
	mov r8,r14
	lea rdx,[.io.buf]
	mov rcx,r13
	call .new_labf
	test rax,rax
	jz	.new_fileE
	mov r15,rax
	
.new_fileF:
	mov rcx,rdi
	call art.fcreate_rw
	test rax,rax
	jg	.new_fileF2

.new_fileF1:
	mov rcx,r15
	call art.a16free
	jmp	.new_fileE

.new_fileF2:
;	push rax
;	push rdi
;	mov rbx,rax				;--- file handle
;	mov r8,rdi
;	lea rdx,[r13+\
;		FILE_BUFLEN]
;	mov rcx,rax
;	sub r8,rdx
;	call art.fwrite

	mov rcx,rax
	call art.fclose
	
	mov rcx,rbx
	call tree.get_paraft
	
	;--- in RCX labf
	;--- in RDX parent
	;--- in R8 insafter
	mov rcx,r15
	call tree.insert
	test rax,rax
	jz	.new_fileF1

	mov r9,rax
	mov rcx,[hTree]
	call tree.sel_item
	mov r12,r15

.new_fileE:
	add rsp,\
		FILE_BUFLEN*2
	mov rax,r12
	pop r15
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0


	;#---------------------------------------------------ö
	;|                   WSPACE.INS_DOC                  |
	;ö---------------------------------------------------ü

.ins_doc:
	;--- insert an item in the lvw hDocs
	;--- in RCX labf
	push rbx
	mov rbx,rcx

	sub rsp,\
		sizeof.LVITEMW

	mov rcx,[hDocs]
	call lvw.get_count

	mov [rsp+\
		LVITEMW.iItem],eax

	mov [rsp+\
		LVITEMW.mask],\
		LVIF_TEXT	or \
		LVIF_IMAGE or \
		LVIF_PARAM

	xor eax,eax
	mov [rsp+\
		LVITEMW.iSubItem],eax

	mov [rsp+\
		LVITEMW.lParam],rbx

	mov eax,[.labf.iIcon]
	mov [rsp+\
		LVITEMW.iImage],eax

	lea rdx,[rbx+\
		sizeof.LABFILE]
	mov [rsp+\
		LVITEMW.pszText],rdx

	mov r9,rsp
	mov rcx,[hDocs]
	call lvw.ins_item

	add rsp,\
		sizeof.LVITEMW
	pop rbx
	ret 0

	;#---------------------------------------------------ö
	;|                   LOAD WORKSPACE                  |
	;ö---------------------------------------------------ü

.load_wsp:
	;--- in RCX path+filename
	;--- ret RAX 0,wsp labf
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	mov rbp,rsp
	and rsp,-16

	xor r13,r13
	mov [pLabfWsp],r13
	mov [hRootWsp],r13

	sub rsp,\
		FILE_BUFLEN*2+20h

	mov rsi,rcx
	call art.is_file
	jz .load_wspD

.load_wspA:
	;--- file exists ok
	mov rcx,rsi
	call art.get_fname
	test eax,eax		;--- err get_fname
	jz	.load_wspD

	mov rdi,rdx
	cmp eax,ecx
	jz	.load_wspD	;--- nopath

	sub rdx,rsi
	mov rcx,rsi
	mov r8,rdx
	mov rdx,rsp
	call art.xmmcopy

	xor edx,edx
	mov rcx,rsp
	xor r8,r8
	mov [rax+rsp-2],edx
	call .set_dir
	test rax,rax
	jz	.load_wspD	;--- err setting dir
	
	mov rdx,rdi			;--- text
	lea rcx,[rax+DIR.dir]
	xor r8,r8
	jmp	.load_wspD2

.load_wspD:
	;--- load default wsp
	mov r8,\
		LF_BLANK
	xor ecx,ecx
	xor edx,edx

.load_wspD2:
	or r8,LF_WSP
	call .new_labf
	mov r13,rax
	test rax,rax
	jz	.load_wspE

	mov r8,TVI_ROOT		;--- insafter
	mov rdx,TVI_ROOT	;--- parent
	mov rcx,rax
	;--- in RCX labf
	;--- in RDX parent
	;--- in R8 insafter	
	call tree.insert
	test eax,eax
	jnz	.load_wspD1

	;--- err insert titem
	mov rcx,r13
	call art.a16free

	xor edx,edx
	xor eax,eax
	xor r13,r13

.load_wspD1:
	mov r13,rdx
	mov [pLabfWsp],rdx
	mov [hRootWsp],rax

	test r13,r13
	jz	.load_wspE

	mov r12,rax	;--- root tree item

	mov rcx,rsi
	call [top64.parse]
	test rax,rax
	jz	.load_wspE

	;--- known dirs as first node -------
	mov rbx,rax	;--- in RBX pmem
	mov rdi,rsp	;--- work buffer
	mov rsi,rax	;--- current pmem item
	call .load_kdirs

	mov esi,\
		[rbx+TITEM.next]
	add rsi,rbx	
	cmp rsi,rbx
	jz	.load_wspF

	;--- other following nodes -------
	call .load_items

.load_wspF:
	mov rcx,rbx
	call [top64.free]

.load_wspE:
	mov rax,r13
	mov rsp,rbp
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;ü------------------------------------------ö
	;|     WSPACE.load_items                    |
	;#------------------------------------------ä

.load_items:
	;--- in RBX pmem base
	;--- in RDI work buffer
	;--- in RSI pmem current item
	;--- in R12 hItem parent
	push rsi
	push r12

.load_itemsA:
	cmp [rsi+TITEM.len],2
	jnz	.load_itemsN

	call .load_descr
	test eax,eax
	jz	.load_itemsN

	test [rsi+\
		TITEM.type],TOBJECT
	jnz	.load_itemsA2

	;--- check for no hashpath
	;--- no hash
	mov rcx,[rdi+8]	;--- hash
	test rcx,rcx
	jz .load_itemsN

	;--- check invalid hash ----------
	call .is_dhash
	jnc .load_itemsN
	
	;--- TODO: check for no path+file
	mov r9,rax
	jmp .load_itemsA1

.load_itemsA2:
	mov rcx,[rdi+8]	;--- hash
	test rcx,rcx

	cmovz r9,[projDir]
	jz	.load_itemsA1
	call .is_dhash
	mov r9,rax
	cmovnc r9,[projDir]
	
.load_itemsA1:
;@break
	mov r8,[rdi]
	lea rdx,[rdi+16]
	lea rcx,[r9+DIR.dir]
	call .new_labf

	test eax,eax
	jz	.load_itemsE

	mov rcx,rax			;--- labf
	mov rdx,r12
	mov rax,[rdi]

	cmp [rsi+\
		TITEM.type],TLABEL
	jz	.load_item

.load_obj:
	test [rsi+\
		TITEM.type],TOBJECT
	jz	.load_itemsN

	and eax,LF_PRJ\
		or LF_LNK

	xor r9,r9
;	test eax,LF_PRJ
;	cmovnz rdx,[hRootWsp]
	mov rdx,r12
	jmp	.load_itemA
	
.load_item:
	and eax,LF_FILE

.load_itemA:
	mov [rcx+\
		LABFILE.type],ax
	mov r8,TVI_LAST
	call tree.insert
	test eax,eax
	jz .load_itemsE

	test [rsi+\
		TITEM.type],TOBJECT
	jz	.load_itemsN

	mov edx,[rsi+\
		TITEM.child]
	add rdx,rbx
	cmp rdx,rbx
	jz	.load_itemsN

	push r12
	push rsi
	push rax
	push qword[rdi]

	mov r12,rax
	mov rsi,rdx
	call .load_items

	pop r8
	pop r9
	pop rsi
	pop r12

	and r8,1
	test rax,rax
	jz .load_itemsE

	inc r8
	;--- TVE_EXPAND = 2
	;--- TVE_COLLAPSE	=1
	mov rcx,[hTree]
	call tree.exp_item

.load_itemsN:
	mov esi,[rsi+\
		TITEM.next]
	add rsi,rbx
	cmp rsi,rbx
	jnz	.load_itemsA
	mov rax,r12

.load_itemsE:
	pop r12
	pop rsi
	ret 0

	;ü------------------------------------------ö
	;|     WSPACE.load_descr                    |
	;#------------------------------------------ä

.load_descr:
	;--- load description
	;--- ITEM name as str. integer of 2 bytes
	xor ecx,ecx
	mov eax,[rsi+\
		TITEM.value]
	push rsi

	mov [rdi],rcx
	mov [rdi+8],rcx
	mov [rdi+16],rcx

	and eax,0FFFFh
	test eax,eax
	jz .load_descrE

	;--- 1 TNUMBER
	;--- 1 TQUOTED
	;------ RDI	TYPE 
	;------ RDI+8	HASH
	;------ RDI+16 STRING
	mov esi,[rsi+\
		TITEM.attrib]
	add rsi,rbx
	cmp rsi,rbx
	jz	.load_descrE
	
	;--- a2b -----------
	rol ax,8
	mov cx,ax
	and cx,4040h
	and ax,0F0Fh
	ror cx,6
	add ax,cx
	rol cx,3
	add cx,ax
	mov al,cl
	shr cx,4
	or al,cl
	and ax,0FFh
	mov [rdi],rax

	cmp [rsi+\
		TITEM.type],TNUMBER
	jnz	.load_descrE

	mov rax,qword[rsi+\
		TITEM.qword_val]
	mov [rdi+8],rax

	mov esi,[rsi+\
		TITEM.attrib]
	add rsi,rbx
	cmp rsi,rbx
	jz	.load_descrE

	cmp ax,[rsi+\
		TITEM.len]
	jz	.load_descrE

	lea rdx,[rdi+16]
	lea rcx,[rsi+\
		TITEM.value]
	call utf8.to16

	jnc	.load_descrE1

.load_descrE:
	xor eax,eax
	mov [rdi],rax

.load_descrE1:
	pop rsi
	ret 0

	;ü------------------------------------------ö
	;|     WSPACE.load_kdirs                    |
	;#------------------------------------------ä

.load_kdirs:
	;--- load known dirs first -------
	;--- ret RAX 0,num dirs
	xor eax,eax
	push rsi
	push rax
	cmp [rsi+TITEM.len],1
	jnz	.load_kdirsE

	cmp [rsi+\
		TITEM.type],\
			TLABEL or TOBJECT
	jnz	.load_kdirsE

	cmp byte [rsi+\
		TITEM.value],"k"
	jnz	.load_kdirsE

	cmp eax,[rsi+\
		TITEM.child]
	jz	.load_kdirsE

	mov esi,\
		[rsi+TITEM.child]
	add rsi,rbx
	cmp rsi,rbx
	jz	.load_kdirsE

.load_kdirsA:	
	cmp [rsi+TITEM.len],1
	jnz	.load_kdirsE

	xor eax,eax
	mov edx,[rsi+\
		TITEM.attrib]
	add rdx,rbx
	cmp rdx,rbx
	jz	.load_kdirsB

	cmp [rdx+\
		TITEM.type],TQUOTED
	jnz	.load_kdirsB

	cmp ax,[rdx+\
		TITEM.len]
	jz	.load_kdirsB	;--- err: invalid string

	lea rcx,qword[rdx+\
		TITEM.value]
	mov rdx,rdi
	call utf8.to16

	xor r8,r8
	xor edx,edx
	mov rcx,rdi
	call .set_dir
	;	test eax,eax
	;	jnz	.load_kdirsB
	inc qword[rsp]

	;-----------------------------
	 mov r8,rdi         
	 mov rdx,r9
	 call art.cout2XU
	;-----------------------------

.load_kdirsB:
	mov esi,\
		[rsi+TITEM.next]
	add rsi,rbx
	cmp rsi,rbx
	jnz	.load_kdirsA

.load_kdirsE:
	pop rax
	pop rsi
	ret 0
	
	;ü------------------------------------------ö
	;|     WSPACE.SET_DIR                       |
	;#------------------------------------------ä

.set_dir:
	;--- IN RCX basedir
	;--- IN RDX name
	;--- IN r8 true/false createdir
	;--- RET RAX dir slot
	;--- RET RCX len block
	;--- RET R8 cpts
	;--- RET R9 hash
	push rbp
	push rbx
	push rdi
	push rsi
	push r12

	xor r12,r12
	mov rbp,rsp
	and rsp,-16

	mov eax,\
		sizeof.DIR+\
		sizea16.SHFILEINFOW

	sub rsp,rax
	mov rdi,r8
	mov rbx,rsp

	push 0
	test edx,edx
	jz	.set_dirA
	push rdx
	push uzSlash

.set_dirA:
	push rcx

	mov rdx,rbx
	mov rcx,rax
	call art.zeromem

	lea rsi,[.dir.dir]
	xor eax,eax

	push rsi
	push rax
	call art.catstrw
	mov [.dir.cpts],ax

	@nearest 16,eax
	add eax,eax
	add eax,16+DIR.dir
	mov [.dir.len],eax

	;--- check for existence securely
	mov rcx,rsi
	call art.is_file
	jnz	.set_dirB

	;--- try expanding dir 
	sub rsp,FILE_BUFLEN
	mov rdx,rsp
	mov rcx,rsi
	call apiw.exp_env

	test eax,eax
	jz	.set_dirF
	cmp eax,\
		MAX_UTF16_FILE_CPTS
	ja	.set_dirF

.set_dirC:
	mov r9,rdi
	mov r10,rsi
	mov rcx,rax
	mov rdi,rsp
	repe cmpsw
	mov rdi,r9
	mov rsi,r10
	jnz	.set_dirC1

	;--- dir matches exp
	test edi,edi
	jz	.set_dirF
	xor edx,edx
	mov rcx,rsi
	call apiw.createdir
	jmp	.set_dirB

.set_dirC1:
	;--- dir,exp are different
	test edi,edi
	jnz	.set_dirC3

.set_dirC2:
	;--- no create + try exp
	mov rcx,rsp
	call art.is_file
	jz	.set_dirF	;--- error if exp does not exist

.set_dirC3:
	;--- no create + exp exist
	mov rcx,rsp
	xor edx,edx
	mov r8,rdi
	call .set_dir

	mov edx,[rax+DIR.iIcon]
	mov [.dir.rdir],rax

	or [.dir.type],DIR_HASREF
	mov [.dir.iIcon],edx
	jmp	.set_dirB1

.set_dirB:
	;--- dir EXISTs now
	lea rdi,\
		[rbx+sizeof.DIR]

	mov r10,\
		SHGFI_SYSICONINDEX\
		or SHGFI_SMALLICON\
		or SHGFI_USEFILEATTRIBUTES\
		or SHGFI_TYPENAME

	mov edx,\
		FILE_ATTRIBUTE_DIRECTORY

	mov r9,\
		sizeof.SHFILEINFOW

	mov rcx,rsi
	mov r8,rdi
	call apiw.sfinfo
	mov eax,\
		[rdi+SHFILEINFOW.iIcon]
	mov [.dir.iIcon],eax

.set_dirB1:
	mov rcx,rsi
	call .dir2hash

	mov r12,rax
	jc	.set_dirE
	mov [.dir.hash],r9

	;--- in R8 len
	;--- in R9 hash
	;--- in RAX field/hashtable/lastvalid
	mov rsi,rax
	mov ecx,[.dir.len]
	call art.a16malloc

	xor r12,r12
	test rax,rax
	jz	.set_dirF
	mov r12,rax

	mov r9,rax
	mov rdx,rax
	mov r8d,[.dir.len]
	mov rcx,rbx
	call art.xmmcopy
	mov [rsi],r9
	mov rax,r9
	movzx r8,[.dir.cpts]
	mov r9,[.dir.hash]

.set_dirE:
	;--- directory exists as slot
	;--- in R8 len
	;--- in R9 hash
	;--- in RAX pSlot
	mov ecx,[rax+DIR.len]

.set_dirF:
	xchg rax,r12
	mov rsp,rbp
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|             WSPACE.new_labf                       |
	;ö---------------------------------------------------ü
.new_labf:
	;--- create a new LABFILE
	;--- in RCX 0=curpath,path
	;--- in RDX text
	;--- in R8 type
	;--- RET RAX 0,labfile
	push rbp
	push rbx
	push rdi
	push rsi
	push r12

	mov rdi,rcx
	mov rsi,rdx
	mov r12,r8

	mov ecx,\
		sizeof.LABFILE+\
		FILE_BUFLEN

	mov rbp,rsp
	and rsp,-16
	sub rsp,rcx

	mov rdx,rsp
	call art.zeromem

	test r12,LF_FILE
	jnz	.new_labfF

	test r12,LF_LNK
	jnz	.new_labfL

	test r12,LF_PRJ
	jnz	.new_labfP

	test r12,r12
	jnz	.new_labfA

	;--- LF_NULL ---------
	mov rdx,[appDir]
	mov rcx,uzAppName

.new_labfA1:
	mov [rsp+\
		LABFILE.dir],rdx
	
	lea rdx,[rsp+\
		sizeof.LABFILE]
	jmp	.new_labfB1

.new_labfA:
	xor eax,eax
	test r12,LF_WSP
	jz	.new_labfE

	mov [rsp+\
		LABFILE.type],r12w
;		LF_WSP or \
;		LF_BLANK

	;--- LF_WSP ----------
	mov rdx,[projDir]
	mov rcx,uzDefault

	test rdi,rdi
	jz	.new_labfA1

	test rsi,rsi
	jz	.new_labfE
	
	xor r8,r8
	xor edx,edx
	mov rcx,rdi
	call .set_dir

	test rax,rax
	jz	.new_labfE

	and [rsp+\
		LABFILE.type],\
		LF_WSP

	mov rdx,rax
	mov rcx,rsi
	jmp	.new_labfA1

.new_labfF:
	;--- LF_FILE ----------
	test r12,LF_BLANK
	jnz	.new_labfF1

	xor eax,eax
	test rdi,rdi
	jz	.new_labfE

	test rsi,rsi
	jz	.new_labfE

	xor r8,r8
	xor edx,edx
	mov rcx,rdi
	call .set_dir

	test rax,rax
	jz	.new_labfE

	mov [rsp+\
		LABFILE.type],\
		LF_FILE

	mov rcx,rsi
	mov rdx,rax
	jmp	.new_labfA1

.new_labfF1:	
	;--- LF_BLANK --------
	mov [rsp+\
		LABFILE.type],\
		LF_FILE or LF_BLANK

	mov rcx,[projDir]
	test rdi,rdi
	jz	.new_labfF2

	mov rcx,rdi
	xor r8,r8
	xor edx,edx
	call .set_dir

	test rax,rax
	jz	.new_labfE
	mov rcx,rax

.new_labfF2:
	;--- LF_BLANK NO DIR --------
	mov [rsp+\
		LABFILE.dir],rcx

	lea rsi,[rsp+\
		sizeof.LABFILE]
	mov r8,rsi
	mov edx,U16
	mov ecx,UZ_EDIT_UNTL
	call [lang.get_uz]

	shr eax,1
	mov [rsp+\
		LABFILE.cpts],ax
	add eax,eax
	jmp	.new_labfC

.new_labfL:
.new_labfP:
	xor eax,eax
	and r12,LF_LNK\
		or LF_PRJ

	mov [rsp+\
		LABFILE.type],r12w
	test rsi,rsi
	jz	.new_labfE

	mov rcx,[projDir]
	test rdi,rdi
	jz	.new_labfG
	
	xor r8,r8
	xor edx,edx
	mov rcx,rdi
	call .set_dir

	test rax,rax
	jz	.new_labfE
	mov rcx,rax

.new_labfG:
	mov [rsp+\
		LABFILE.dir],rcx
	lea rdx,[rsp+\
		sizeof.LABFILE]
	mov rcx,rsi

.new_labfB1:
	call utf16.copyz
	shr eax,1
	mov [rsp+\
		LABFILE.cpts],ax
	add eax,eax
	
.new_labfC:
	inc eax			;--- safer zero	
	add eax,64	;--- space for rename
	mov ecx,\
		sizeof.LABFILE

	@nearest 16,eax
	mov [rsp+\
		LABFILE.alen],ax ;--- max space for rename
	add ecx,eax
	mov rdi,rcx
	call art.a16malloc
	test rax,rax
	jz	.new_labfE

	mov rsi,rax
	mov r8,rdi
	mov rdx,rax
	mov rcx,rsp
	call art.xmmcopy
	mov rbx,rsi

	mov rcx,rbx
	call .get_icon
	mov [.labf.iIcon],eax
	mov [.labf.hIcon],rdx
	mov rax,rbx

.new_labfE:
	mov rsp,rbp
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|             WSPACE.get_icon                       |
	;ö---------------------------------------------------ü

.get_icon:
	;--- in RCX labfile
	;--- RET RAX iIcon
	;--- RET RDX hIcon
	push rbx
	push rdi
	push rsi

	sub rsp,\
		FILE_BUFLEN+\
		sizea16.SHFILEINFOW

	mov rbx,rcx
	xor esi,esi
	movzx eax,[.labf.type]
	mov rdi,rsp

	test eax,LF_FILE
	jnz	.get_iconF
	test eax,LF_WSP
	jnz	.get_iconW

	mov esi,\
		FILE_ATTRIBUTE_DIRECTORY

.get_iconF:
	mov rax,[.labf.dir]
	lea rdx,[rbx+\
		sizeof.LABFILE]
	lea rcx,[rax+\
		DIR.dir]
	jmp	.get_iconA

.get_iconW:
;@break
	mov rcx,[appDir]
	lea rcx,[rcx+\
		DIR.dir]

	push 0
	push uzExeExt
	mov rdx,uzAppName
	jmp	.get_iconA2

.get_iconA:
	push 0

.get_iconA2:
	push rdx
	push uzSlash
	push rcx

.get_iconA1:
	push rdi
	push 0
	call art.catstrw

	mov edx,esi
	mov r10,\
		SHGFI_SYSICONINDEX\
		or SHGFI_ICON\
		or SHGFI_SMALLICON\
		or SHGFI_USEFILEATTRIBUTES\
		or SHGFI_TYPENAME

	lea r8,[rdi+\
		FILE_BUFLEN]
	mov rcx,rdi
	call apiw.sfinfo
	test rax,rax
	jz	.get_iconE

	lea rbx,[rdi+\
		FILE_BUFLEN]

	mov eax,[rbx+\
		SHFILEINFOW.iIcon]
	mov rdx,[rbx+\
		SHFILEINFOW.hIcon]

.get_iconE:
	add rsp,\
		FILE_BUFLEN+\
		sizea16.SHFILEINFOW
	pop rsi
	pop rdi
	pop rbx
	ret 0



	
.env2hash:
	;--- in RCX env
	;--- RET R8 len
	;--- RET additional data from .is_dhash
	push .is_ehash
	jmp	.dir2hashA

.dir2hash:
	;--- in RCX path
	;--- RET R8 len
	;--- RET additional data from .is_dhash
	push .is_dhash

.dir2hashA:
	call utf16.zsdbm
	xchg rdx,[rsp]
	mov rcx,rax
	call rdx
	pop r8
	ret 0

.is_ehash:
	mov r9,rcx
	mov rdx,[envHash]
	and ecx,7Fh
	jmp	.is_dhashE

.is_dhash:
	;--- in RCX hash
	;--- RET R9 hash
	;--- RET (CF=1,RAX slot DIR) 
	;--- RET (CF=0 RAX = field/hashtable/lastvalid
	mov r9,rcx
	mov rdx,[dirHash]
	and ecx,3FFh

.is_dhashE:
	xor eax,eax
	lea r8,[rdx+rcx*8]
	cmp rax,[r8]
	jz	.is_dhashB
	mov rax,[r8]
	xor ecx,ecx
	jmp	.is_dhashA

.is_dhashC:
	cmp rcx,[rax+\
		DIR.hnext]
	jz	.is_dhashD
	mov rax,[rax+\
		DIR.hnext]

.is_dhashA:
	cmp r9,[rax+\
		DIR.hash]
	jnz	.is_dhashC
	stc
	ret 0

.is_dhashD:
	lea r8,[rax+\
		DIR.hnext]
.is_dhashB:
	clc
	xchg rax,r8
	ret 0

	;#---------------------------------------------------ö
	;|                   WSPACE.LIST_DIR                 |
	;ö---------------------------------------------------ü
.list_dir:
	;--- in RCX pCallback
	;--- in RDX user param
	;--- RET RCX dir
	;--- stop callback listing at EAX = 0
	sub rsp,40
	xor eax,eax
	test rcx,rcx
	jz	.list_dirE

	mov r8,400h
	mov r9,[dirHash]
	
	mov [rsp],rcx
	mov [rsp+8],rdx
	mov [rsp+16],r8
	mov [rsp+24],r9
	mov [rsp+32],rax

.list_dirB:
	cmp rax,[r9]
	jz .list_dirA
	mov rcx,[r9]
	
.list_dirC:
	mov [rsp+32],rcx
	mov r10,[rsp]
	mov rdx,[rsp+8]
	mov [rsp+16],r8
	mov [rsp+24],r9
	call r10
	test eax,eax
	jz	.list_dirE
	mov r10,[rsp+32]
	xor eax,eax
	mov rcx,[r10+DIR.hnext]
	mov r9,[rsp+24]
	mov r8,[rsp+16]
	test rcx,rcx
	jnz .list_dirC

.list_dirA:	
	add r9,8
	dec r8
	jnz	.list_dirB

.list_dirE:
	add rsp,40
	ret 0


	;#---------------------------------------------------ö
	;|            WSPACE.SETUP                           |
	;ö---------------------------------------------------ü

.setup:
	push rbp
	push rbx
	push rdi
	push rsi
	mov rbp,rsp

	sub rsp,\
		FILE_BUFLEN+\
		sizea16.LVCOLUMNW
	mov rdi,rsp

	mov rbx,[pConf]
	mov r9d,[.conf.wspace.bkcol]
	mov rcx,[hTree]
	call tree.set_bkcol

	mov r9,[hsmSysList]
	mov r8,TVSIL_NORMAL
	mov rcx,[hTree]
	call tree.set_iml

	mov r9d,[.conf.docs.bkcol]
	mov rcx,[hDocs]
	call lvw.set_bkcol

	mov r9d,[.conf.docs.bkcol]
	mov rcx,[hDocs]
	call lvw.set_txtbkcol

	mov r9,\
		LVS_EX_CHECKBOXES or\
		LVS_EX_BORDERSELECT 
		;0
		;	LVS_EX_GRIDLINES or \
		;	0;LVS_EX_AUTOSIZECOLUMNS

	;LVS_EX_HEADERINALLVIEWS
	;	LVS_EX_JUSTIFYCOLUMNS
	;	LVS_EX_FLATSB or \
	;	LVS_EX_DOUBLEBUFFER

	xor r8,r8
	mov rcx,[hDocs]
	call lvw.set_xstyle

	mov r9,[hsmSysList]
	mov r8,LVSIL_SMALL
	mov rcx,[hDocs]
	call lvw.set_iml

	lea rsi,[rsp+\
		sizea16.LVCOLUMNW]

;	push 0
;	push 3
;	push UZ_INFO_CDATE
;	push 2
;	push UZ_INFO_SIZE
;	push 1
;	push UZ_INFO_TYPE
;	push 0
;	push UZ_INFO_BUF

;.setupB:
;	pop rcx
;	test rcx,rcx
;	jz	.setupE

.setupA:
	mov r8,rsi
	mov edx,U16
	mov ecx,UZ_INFO_BUF
	call [lang.get_uz]

	mov [.lvc.pszText],rsi
	shl edx,5
	mov [.lvc.cx],edx
	mov [.lvc.mask],\
		LVCF_TEXT or \
		LVCF_FMT or \
		LVCF_WIDTH ;or \
		;LVCF_SUBITEM

	;pop rax
	xor eax,eax
	mov [.lvc.fmt],LVCFMT_LEFT
	mov [.lvc.iSubItem],eax

	mov r9,rdi
	mov r8,rax
	mov rcx,[hDocs]
	call lvw.ins_col
	;jmp	.setupB

.setupE:
	mov rsp,rbp
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

	;#---------------------------------------------------ö
	;|      WSPACE.LVW_NOTIFY                            |
	;ö---------------------------------------------------ü

.docs_notify:
	mov edx,[r9+NMHDR.code]
	cmp edx,\
		LVN_ITEMCHANGING
	jz	.docs_schged
	cmp edx,NM_DBLCLK
	jz	.docs_dblclk
	jmp winproc.ret0

.docs_schged:
	mov rcx,\
		[r9+NM_LISTVIEW.lParam]
	test rcx,rcx
	jz	winproc.ret0

	test [r9+\
		NM_LISTVIEW.uNewState],\
		LVIS_FOCUSED \
		or LVIS_SELECTED ;or LVIS_FOCUSED
	jz	winproc.ret0

	mov rsi,[pEdit]
	cmp rcx,[.pEdit.curlabf]
	jz	winproc.ret0

	call edit.view
	jmp winproc.ret0

.docs_dblclk:
	mov edx,[r9+\
		NMITEMACTIVATE.iItem]
	inc edx
	jz	winproc.ret0

	dec edx
	xor eax,eax

	sub rsp,\
		sizea16.LVITEMW

	mov r9,rsp
	mov [r9+\
		LVITEMW.iItem],edx
	mov [r9+\
		LVITEMW.iSubItem],eax
	mov rcx,[hDocs]
	call lvw.get_param

	mov rbx,[rsp+LVITEMW.lParam]
	test rbx,rbx
	jz winproc.ret0
	jmp .tree_dblclkA

	;#---------------------------------------------------ö
	;|      WSPACE.TREE_NOTIFY                           |
	;ö---------------------------------------------------ü

.tree_notify:
	mov edx,[r9+NMHDR.code]

	cmp edx,NM_DBLCLK
	jz	.tree_dblclk

	cmp edx,NM_KILLFOCUS
	jz	.tree_killfoc

	cmp edx,\
		TVN_ITEMEXPANDEDW
	jz	.tree_exped

	cmp edx,\
		TVN_GETDISPINFOW
	jz	.tree_gdinfo

	cmp edx,\
		TVN_SELCHANGEDW
	jz	.tree_schged
	jmp	winproc.ret0

	;	cmp edx,TVN_ENDLABELEDITW
	;	jz	.tree_gdinfo
	; cmp edx,NM_RCLICK
	;	jz	.tree_rclick


.tree_killfoc:
	;--- workaround when selecting
	;--- the same/other item after
  ;--- gaining focus
	xor r9,r9
	mov rcx,[hTree]
	call tree.sel_item
	jmp	winproc.ret0

	;#---------------------------------------------------ö
	;|      WSPACE.TREE_EXPED                            |
	;ö---------------------------------------------------ü
.tree_exped:
	mov eax,[r9+\
		NMTREEVIEWW.action]
	and eax,TVE_TOGGLE
	shr eax,1

	mov rbx,[r9+\
		NMTREEVIEWW.itemNew.lParam]
	test rbx,rbx
	jz	winproc.ret0

	mov [.labf.state],al
	;mov rdx,[pLabfWsp]

	;test [.labf.type],\
	;	LF_FILE
	;jnz winproc.ret1
	;or [edx+LABFILE.type],\
	;	LF_MODIF
	;TVE_COLLAPSE		= 0001h
	;TVE_EXPAND	  		= 0002h
	;TVE_EXPANDPARTIAL = 4000h
	;TVE_COLLAPSERESET = 8000h
	jmp	winproc.ret0

	;#---------------------------------------------------ö
	;|      WSPACE.TREE_DBLCLK                           |
	;ö---------------------------------------------------ü

.tree_dblclk:
	;--- in RDX hTree
	mov rdi,[hTree]
	sub rsp,\
		sizea16.TVITEMW+\
		FILE_BUFLEN

	mov rcx,rdi
	call tree.get_sel
	test rax,rax
	jz	winproc.exit

	;--- in RCX hTree
	;--- in RDX hItem
	;--- in R9 TVITEM
	mov r9,rsp
	mov rdx,rax
	mov rcx,rdi
	call tree.get_param
	test rax,rax
	jz winproc.exit

	mov rbx,[rsp+\
		TVITEMW.lParam]
	test rbx,rbx
	jz winproc.ret0

.tree_dblclkA:
	movzx eax,\
		[.labf.type]

	;--- no action on WSP
	test ax,LF_WSP
	jnz	winproc.ret1

	;--- no action on LNK
	test ax,LF_LNK
	jnz	winproc.ret1

	;--- no action on PRJ
	test ax,LF_PRJ
	jnz	winproc.ret1

	test eax,LF_OPENED
	jnz	.tree_dblclkO

.tree_dblclkC:
	;--- document is closed ---
	mov rcx,rbx
	call .open_file
	jmp	winproc.ret0

.tree_dblclkO:
	;--- document is open ---
	jmp	winproc.mi_fi_closeA
;	mov rcx,rbx
;	call .close_file
;	jmp	winproc.ret0

	;#---------------------------------------------------ö
	;|      WSPACE.TREE_GDINFO                           |
	;ö---------------------------------------------------ü

.tree_gdinfo:
;@break
	lea rcx,[r9+\
		TVDISPINFOW.item]
	mov eax,[rcx+\
		TVITEMW.mask]
	test eax,TVIF_TEXT
	jz	winproc.ret0
	mov rbx,[rcx+\
		TVITEMW.lParam]
	test ebx,ebx
	jz	winproc.ret0
	lea rax,[rbx+\
		sizeof.LABFILE]
	mov [rcx+\
		TVITEMW.pszText],rax
	jmp	winproc.ret0

	;#---------------------------------------------------ö
	;|      WSPACE.TREE_SCHGED                           |
	;ö---------------------------------------------------ü

.tree_schged:
	mov rax,r9
	mov rcx,[r9+\
		NMTREEVIEWW.itemOld.lParam]
	mov rdx,[r9+\
		NMTREEVIEWW.itemNew.lParam]

;	push rdx
;	push rcx
;	push rax
;	push r9

;	mov r8,rdx
;	mov rdx,rcx
;	call art.cout2XX

;	pop r9
;	pop rax
;	pop rcx
;	pop rdx

	test rdx,rdx
	jz	winproc.ret0

;	test rdx,rdx
;	jnz	.tree_schgedA

;	test rcx,rcx
;	jz	winproc.ret0

;	mov rdx,rcx
;	jmp	.tree_schgedA

	cmp rcx,rdx
	jz	winproc.ret0

	lea r8,[rax+\
		NMTREEVIEWW.itemOld]
	lea r9,[rax+\
		NMTREEVIEWW.itemNew]

	;--- in RCX old labfile
	;--- in RDX new labfile
	;--- in R8 old item
	;--- in r9 new item
	test rdx,rdx
	jnz	.tree_schgedA
	jmp	winproc.ret0

.tree_schgedA:
	mov rbx,rdx
	test [.labf.type],\
		LF_OPENED
	jz	.tree_schgedB

	mov rcx,rdx
	call edit.view
	
.tree_schgedB:
	mov rcx,[.labf.dir]
	call mnu.set_dir
	jmp	winproc.ret0



.spawn:
	;--- in RCX appname
	;--- in RDX cmdline

	push rbp
	push rdi
	push rsi

	mov rsi,rcx
	mov rbp,rsp
	and rsp,-16

	sub rsp,\
		sizea16.STARTUPINFO+\
		sizea16.PROCESS_INFORMATION

	mov rdi,rsp
	mov ecx,(sizea16.STARTUPINFO+\
		sizea16.PROCESS_INFORMATION) / 8
	xor eax,eax
	rep stosq

	mov rdi,rdx

	mov rax,rsp
	lea rdx,[rsp+\
		sizea16.STARTUPINFO]

	mov [rax+\
		STARTUPINFO.cb],\
		sizeof.STARTUPINFO

	mov [rax+\
		STARTUPINFO.dwFlags],\
	STARTF_USESHOWWINDOW

	mov [rax+\
		STARTUPINFO.wShowWindow],\
	SW_SHOWNORMAL
	
	xor ecx,ecx

	push rdx ;--- PROCESS_INFORMATION
	push rax ;--- STARTUPINFO
	push rcx ;--- lpCurrentDirector
	push rcx ;--- lpEnvironment
	push rcx ;--- dwCreationFlags
	push rcx ;--- bInheritHandles

	xor r9,r9
	xor r8,r8
	mov rdx,rdi
	mov rcx,rsi
	sub rsp,20h
	call [CreateProcessW]

	mov rsp,rbp
	pop rsi
	pop rdi
	pop rbp
	ret 0