  
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

tree:
	virtual at rdi
		.tvis TVINSERTSTRUCTW
	end virtual

	virtual at rbx
		.labf LABFILE
	end virtual

	;#-------------------------------------------------ö
	;|          GET_PARAFTER
	;ö-------------------------------------------------ü

.get_paraft:
	;--- get parent item and after
	;--- in RCX labf
	;--- RET RDX parent
	;--- RET R8 insafter (as TVI_FIRST or item)
	xor eax,eax
	test ecx,ecx
	jnz	.get_paraftA
	ret 0

.get_paraftA:
	movzx eax,[rcx+\
		LABFILE.type]

	mov r9,[rcx+\
		LABFILE.hItem]

	test eax,LF_FILE
	jnz	.get_paraftF

	mov rdx,[hRootWsp]
	mov r8,TVI_FIRST

	test eax,LF_WSP
	jnz .get_paraftE

	mov rdx,[rcx+\
		LABFILE.hItem]

.get_paraftE:
	ret 0

.get_paraftF:
	push r9
	mov rcx,[hTree]
	call tree.get_parent
	mov rdx,rax
	pop r8
	ret 0


	;#-------------------------------------------------ö
	;|          INSI insert item in treeview
	;ö-------------------------------------------------ü
.insert:
	;--- in RCX labf
	;--- in RDX parent
	;--- in R8 insafter

	;--- RET RAX hItem
	;--- RET RCX dir
	;--- RET RDX labf
	push rbx
	push rdi

	xor eax,eax
	sub rsp,\
		sizea16.TVINSERTSTRUCTW
	test rcx,rcx
	jz	.insertE

	mov rdi,rsp
	mov rbx,rcx

	mov [.tvis.item.pszText],\
		LPSTR_TEXTCALLBACK
	mov [.tvis.hParent],rdx
	mov [.tvis.hInsertAfter],r8
	mov [.tvis.item.lParam],rbx

  mov [.tvis.item.mask],\
		TVIF_TEXT or \
		TVIF_PARAM or \
		TVIF_IMAGE or \
		TVIF_SELECTEDIMAGE

	mov eax,[.labf.iIcon]
	mov [.tvis.item.iImage],eax
	mov [.tvis.item.iSelectedImage],eax

	mov r9,rdi
	mov rcx,[hTree]
	call .ins_item
	test rax,rax
	jz	.insertE

	mov [.labf.hItem],rax
	mov rdx,rbx
	mov rcx,[.labf.dir]

.insertE:
	add rsp,\
		sizea16.TVINSERTSTRUCTW
	pop rdi
	pop rbx
	ret 0

	;#-------------------------------------------------ö
	;|                   SETBOLD
	;ö-------------------------------------------------ü
	
.set_bold:
	;--- in RCX hTree
	;--- in RDX hItem
	;--- in R8 bold TRUE/FALSE
	xor eax,eax
	sub rsp,sizeof.TVITEMW
	shl r8,4
	or eax,TVIF_STATE
	mov [rsp+TVITEMW.stateMask],TVIS_BOLD
	mov [rsp+TVITEMW.state],r8d
	jmp	.set_itemA
	
.set_itemA:	
	mov [rsp+TVITEMW.hItem],rdx
	mov [rsp+TVITEMW.mask],eax
	mov r9,rsp
	call .set_item
	mov rcx,[rsp+TVITEMW.hItem]
	add rsp,sizeof.TVITEMW
	ret 0

.set_olay:
	;--- in RCX hTree
	;--- in RDX hItem
	;--- in R8 index
	xor eax,eax
	sub rsp,sizeof.TVITEMW
	shl r8,8
	or eax,TVIF_STATE
	mov [rsp+\
		TVITEMW.stateMask],\
		TVIS_OVERLAYMASK
	mov [rsp+\
		TVITEMW.state],r8d
	jmp	.set_itemA

	;#-------------------------------------------------ö
	;|          helper TREEVIEW                        |
	;ö-------------------------------------------------ü

.get_param:
	;--- in RCX hTree
	;--- in RDX hItem
	;--- in R9 TVITEM
	mov eax,\
		TVIF_PARAM or \
		TVIF_HANDLE or \
		TVIF_CHILDREN
	xor r8,r8
	jmp	.get_itemA	

.get_item:
	;--- in RCX hTree
	;--- in RDX hItem
	;--- in R8 textbuf 100h cpts
	;--- in R9 TVITEM
	mov eax,TVIF_TEXT or \
		TVIF_PARAM or \
		TVIF_IMAGE or \
		TVIF_STATE or \
		TVIF_HANDLE	or \
		TVIF_CHILDREN

	mov [r9+\
		TVITEMW.pszText],r8
	mov [r9+\
		TVITEMW.cchTextMax],100h
	;--- in R9 TVITEM

.get_itemA:
	mov [r9+\
		TVITEMW.hItem],rdx
	mov [r9+\
		TVITEMW.mask],eax
	mov edx,TVM_GETITEMW
	jmp	apiw.sms

.sel_item:
	mov r8,TVGN_CARET
	mov rdx,TVM_SELECTITEM
	jmp apiw.sms

.exp_item:
	;--- in R9 hItem
	;--- in R8 TVE_COLLAPSE,TVE_EXPAND
	mov edx,TVM_EXPAND
	jmp	apiw.sms

.del_item:
	xor r8,r8
	mov edx,TVM_DELETEITEM
	jmp	apiw.sms

.ins_item:
	;--- in R9 TVINSEERTSTRUCT
	mov edx,TVM_INSERTITEMW
	xor r8,r8
	jmp apiw.sms

.set_bkcol:
	;--- in R9 color
	mov edx,TVM_SETBKCOLOR
	xor r8,r8
	jmp apiw.sms

.set_item:
	;--- in R9 
	mov edx,TVM_SETITEMW
	xor r8,r8
	jmp apiw.sms

.set_iml:
	mov edx,TVM_SETIMAGELIST
	jmp apiw.sms

.countall:
	xor r8,r8
	xor r9,r9
	mov edx,TVM_GETCOUNT
	jmp apiw.sms

.get_parent:
	mov r8,TVGN_PARENT	
	jmp .get_next

.get_root:
	xor r9,r9
	mov r8,TVGN_ROOT	
	jmp .get_next

.get_next:
	mov edx,TVM_GETNEXTITEM
	jmp apiw.sms

.get_child:	
	mov r8,TVGN_CHILD
	jmp	.get_next

.get_sibl:
	mov r8,TVGN_NEXT	
	jmp .get_next

.get_sel:
	mov r9,TVI_ROOT
	;xor r9,r9
	mov r8,TVGN_CARET
	jmp	.get_next

	
	;#-----------------------------------------ö
	;|             LIST (item-params)          |
	;ä-----------------------------------------ü

.list:
	;--- uses RBX level check
	;--- uses RDX startitem
	;--- uses RDI capable buffer nItems * 8
	;--- uses RSI datalen of text
	sub rsp,\
		sizeof.TVITEMW
	inc ebx

.listD:
	mov r9,rsp
	mov rcx,[hTree]
	call .get_param
	test eax,eax
	jz	.listE

	mov rax,[rsp+\
		TVITEMW.lParam]
	
	mov ecx,[rsp+\
		TVITEMW.cChildren]
	and ecx,1

	mov rdx,[rsp+\
		TVITEMW.hItem]
	
	test rax,rax
	jz	.listE

	movzx r8,[rax+\
		LABFILE.alen]
	add rsi,r8
	stosq
	dec ecx
	js .listA

.listC:
	push rdx
	mov r9,rdx
	mov rcx,[hTree]
	call .get_child
	mov rdx,rax
	call .list
	pop rdx

.listA:
	mov eax,ebx
	dec eax
	jz	.listE

	;--- check .sibling
	mov r9,rdx
	mov rcx,[hTree]
	call .get_sibl
	mov rdx,rax
	test eax,eax
	jnz	.listD

.listE:
	add rsp,\
		sizeof.TVITEMW
	dec ebx
	ret 0


;;------------------------MISC---------------------
;align 4
;.getitemrect:
;	push eax
;	push FALSE
;	push TVM_GETITEMRECT
;	jmp	 .sendmessagetree

;.createdragimg:
;	push eax
;	push 0
;	push TVM_CREATEDRAGIMAGE
;	jmp	 .sendmessagetree

;.getbkcolor:
;	push 0
;	push 0
;	push TVM_GETBKCOLOR
;	jmp	 .sendmessagetree


;.settextcolor:
;	push eax
;	push 000000FFh
;	push TVM_SETTEXTCOLOR
;	jmp	 .sendmessagetree
;	

;.sortitem:
;	push eax
;	push 0
;	push TVM_SORTCHILDREN
;	jmp .sendmessagetree

;.getselected:
;	push 0
;	push TVGN_CARET
;	jmp .getnext
;		

;.getparent:
;	push eax
;	push TVGN_PARENT
;	jmp .getnext
;	
;.getprevvis:
;	push eax
;	push TVGN_PREVIOUSVISIBLE
;	jmp .getnext

;.getprev:
;	push eax
;	push TVGN_PREVIOUS
;	jmp .getnext
;	
;.getsibling:
;	push eax
;	push TVGN_NEXT	
;	jmp .getnext

;.getnextvisible:
;	push eax
;	push TVGN_NEXTVISIBLE
;	jmp .getnext


;.ensure_item:
;	push eax
;	push 0
;	push TVM_ENSUREVISIBLE
;	jmp .sendmessagetree

;.toggle_item:
;	push eax
;	push TVE_TOGGLE
;	jmp	.expandA

;.expand_item:
;	push eax
;	jmp .expand
;.expand:
;	push TVE_EXPAND
;.expandA:
;	push TVM_EXPAND
;	jmp .sendmessagetree
;	
;.countall:
;	push 0
;	push 0
;	push TVM_GETCOUNT
;	jmp .sendmessagetree	


;;---------------------------
;.setitem1:	
;	push eax
;	push 0
;	push ecx
;	jmp .sendmessagetree

;.setitem:
;	mov ecx,TVM_SETITEM
;	jmp .setitem1

;	
;.insertitem:
;	mov ecx,TVM_INSERTITEM
;	jmp .setitem1

;.getitem:	
;	mov ecx,TVM_GETITEM
;	jmp .setitem1

;.hittest:
;	mov ecx,TVM_HITTEST
;	jmp .setitem1

		
;.notify:
;	push eax
;	push ecx 		
;	push WM_NOTIFY
;	push [hMain]
;	jmp .sendmessage
