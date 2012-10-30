  
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


win:

.controls:
	;--- in RCX hMain
	push rbp
	push r12
	push r13
	mov rbp,rsp
	and rsp,-16

	mov rbx,rcx
	sub rsp,\
		FILE_BUFLEN

	mov rsi,[hInst]
	mov rdi,rsp
	mov r12,[CreateWindowExW]

	mov rdx,hsmSysList
	mov rcx,hlaSysList
	call [Shell_GetImageLists]
	mov rax,[hsmSysList]

	mov rdx,CLR_NONE
	mov rcx,rax
	call iml.set_bkcol

	;--- create tooltip ------
	mov rcx,rbx
	call tip.create
	mov [hTip],rax

	mov rax,SWP_NOMOVE \
		or SWP_NOSIZE \
		or SWP_NOACTIVATE
	mov rdx,HWND_TOPMOST
	mov rcx,[hTip]
	call apiw.set_wpos
	;--------------------------

	mov rcx,rbx
	call float.create
	mov [hFloat],rax

	xor eax,eax
	mov [rdi+58h],rax
	mov [rdi+50h],rsi
	mov [rdi+48h],rax
	mov [rdi+40h],rbx

	mov [rdi+38h],rax
	mov [rdi+30h],rax
	mov [rdi+28h],rax
	mov [rdi+20h],rax
	mov r9,WS_CHILD\
		or WS_VISIBLE\
		or TVS_HASLINES\
		or TVS_LINESATROOT\
		or TVS_EDITLABELS\
		or TVS_HASBUTTONS	;or TVS_SHOWSELALWAYS
	xor r8,r8
	mov rdx,uzTreeClass
	mov rcx,WS_EX_WINDOWEDGE
	call r12
	test rax,rax
	jz .controlsE
	mov [hTree],rax

	xor eax,eax
	mov [rdi+58h],rax
	mov [rdi+50h],rsi
	mov [rdi+48h],rax
	mov [rdi+40h],rbx

	mov [rdi+38h],rax
	mov [rdi+30h],rax
	mov [rdi+28h],rax
	mov [rdi+20h],rax
	mov r9,WS_CHILD\
		or WS_VISIBLE\
		or LVS_REPORT
	;mov r9,0x50810105
	xor r8,r8
	mov rdx,uzLvwClass
	mov rcx,0;WS_EX_WINDOWEDGE;;WS_EX_CLIENTEDGE;WS_EX_STATICEDGE;0;
	call r12
	test rax,rax
	jz .controlsE
	mov [hDocs],rax

	;--- load [config\docking.bin]
	push 0
	push uzBinExt
	push uzDocking
	push uzSlash
	push uzConfName
	push rdi
	push 0
	call art.catstrw	

	;--- in RCX hwnd
	;--- in RDX hInstance
	;--- in R8 filename

	mov r8,rdi
	mov rdx,rsi
	mov rcx,rbx
	call [dock64.load]
	test eax,eax
	jnz	.controlB

	;--- start default docking settings
	mov ecx,\
		sizeof.DOCKITEM*(1+5)
	sub rsp,rcx

	mov rdx,rsp
	call art.zeromem

	mov rax,rsp
	mov ecx,\
		sizeof.DOCKITEM
	;------------------------
	mov [rax+\
		DOCKITEM.id],41A7h
	add rax,rcx

	;------------------------
	mov [rax+\
		DOCKITEM.id],\
	CFG_MPURP_DOCK_ID
	mov [rax+\
		DOCKITEM.flags],\
	CFG_MPURP_FLAGS
	mov [rax+\
		DOCKITEM.pack_rc],\
	CFG_MPURP_POS
	add rax,rcx

	;------------------------
	mov [rax+\
		DOCKITEM.id],\
	CFG_WSPACE_DOCK_ID
	mov [rax+\
		DOCKITEM.flags],\
	CFG_WSPACE_FLAGS
	mov [rax+\
		DOCKITEM.pack_rc],\
	CFG_WSPACE_POS
	add rax,rcx

	;------------------------
	mov [rax+\
		DOCKITEM.id],\
	CFG_CONS_DOCK_ID
	mov [rax+\
		DOCKITEM.flags],\
	CFG_CONS_FLAGS
	mov [rax+\
		DOCKITEM.pack_rc],\
	CFG_CONS_POS
	add rax,rcx

	;------------------------
	mov [rax+\
		DOCKITEM.id],\
	CFG_DOCS_DOCK_ID
	mov [rax+\
		DOCKITEM.flags],\
	CFG_DOCS_FLAGS
	mov [rax+\
		DOCKITEM.pack_rc],\
	CFG_DOCS_POS
	add rax,rcx

	;------------------------
	mov [rax+\
		DOCKITEM.id],\
	CFG_EDIT_DOCK_ID
	mov [rax+\
		DOCKITEM.flags],\
	CFG_EDIT_FLAGS
	mov [rax+\
		DOCKITEM.pack_rc],\
	CFG_EDIT_POS

	;--- load default layout
	mov r9,1+5
	mov r8,rsp
	mov rdx,rsi
	mov rcx,rbx
	call [dock64.loadmem]
	test eax,eax
	jz	.controlsE
	add rsp,\
		sizeof.DOCKITEM*(1+5)

.controlB:
	mov [hDocker],rax
	push 0
	;---------------------
	mov r10,0
	mov r9,edit.proc
	mov r8,rbx
	mov rdx,EDIT_DLG
	mov rcx,rsi
	call apiw.cdlgp

	push rax
	push CFG_EDIT_DOCK_ID
	push UZ_EDIT_PANE

	push [hDocs]
	push CFG_DOCS_DOCK_ID
	push MI_FI_OPEN

	mov r10,[pCons]
	mov r9,console.proc
	mov r8,rbx
	mov rdx,CONS_DLG
	mov rcx,rsi
	call apiw.cdlgp

	push rax
	push CFG_CONS_DOCK_ID
	push UZ_CONS_WIN

	;---	mov rax,[perAlfa]
	;---	mov edx,PER_ALFA
	;---	mov [rax+\
	;---		PLUGGER.id],edx
	;---	mov r10,rax
	;---	mov r9,plug.proc
	;---	mov r8,rbx
	;---	mov rcx,rsi
	;---	call apiw.cdlgp

	;---	push rax
	;---	push CFG_CONS_DOCK_ID
	;---	push UZ_CONS_WIN
	;-------------------------------
	push [hTree]
	push CFG_WSPACE_DOCK_ID
	push UZ_WSPACE

	;---	mov r10,0
	;---	mov r9,mpurp.proc
	;---	mov r8,rbx
	;---	mov rdx,MPURP_DLG
	;---	mov rcx,rsi
	;---	call apiw.cdlgp

	;---	push rax
	;---	push CFG_MPURP_DOCK_ID
	;---	mov ecx,UZ_MPWIN

	mov rax,[pMp]
	mov edx,PER_MPURP
	mov [rax+\
		PLUGGER.id],edx
	mov r10,rax
	mov r9,plug.proc
	mov r8,rbx
	mov rcx,rsi
	call apiw.cdlgp

	push rax
	push CFG_MPURP_DOCK_ID
	mov ecx,UZ_MPWIN

.controlsA:
	mov r8,rdi
	mov edx,U16
	call [lang.get_uz]

	pop rdx
	pop r8
	mov rcx,[hDocker]
	call [dock64.bind]
	mov r13,rax
	
	mov r9,rdi
	mov rcx,[rax+\
		PNL.hwnd]
	call .set_text

	pop rcx
	test rcx,rcx
	jnz	.controlsA

	;--- last is the Editor Panel
	mov rdx,[pEdit]
	mov [rdx+\
		EDIT.pPanel],r13

	call wspace.setup
	
.controlsE:
	mov rsp,rbp
	pop r13
	pop r12
	pop rbp
	ret 0

.set_text:
	xor r8,r8
	mov edx,WM_SETTEXT
	jmp	apiw.sms

.get_text:
	;--- in R9 buf512
	mov r8,100h
	mov edx,WM_GETTEXT
	jmp	apiw.sms

   ;ü------------------------------------------ö
   ;|   IMAGELIST                              |
   ;#------------------------------------------ä
iml:

.set_bkcol:
	;--- in RCX hImagelist
	;--- in RDX color
	mov rax,\
		[ImageList_SetBkColor]
	jmp	apiw.prolog0

.create:
	mov rax,\
		[ImageList_Create]
	jmp	apiw.prologP

.destroy:
	mov rax,\
		[ImageList_Destroy]
	jmp	apiw.prologP

.add_masked:
	mov rax,\
		[ImageList_AddMasked]
	jmp	apiw.prolog0

.get_count:
	mov rax,\
		[ImageList_GetImageCount]
	jmp	apiw.prolog0

.load_bmp:
	;--- in R11 flags
	push rbp
	mov rbp,rsp
	and rsp,-16
	push 0			;--- hold align 16
	push r11
	mov rax,\
		[ImageList_LoadImageW]
	xor r11,r11	;--- uType IMAGE_BITMAP = 0
	jmp	apiw.prologQ

.draw:
	mov rax,\
		[ImageList_Draw]
	jmp	apiw.prologP

   ;ü------------------------------------------ö
   ;|   TOOLTIP                                |
   ;#------------------------------------------ä

tip:
.create:
	;--- in RCX parent
	push rbp
	mov rbp,rsp
	and rsp,-16
	sub rsp,60h
	lea rdx,[rsp+20h]
	xor eax,eax

	mov r8,[hInst]
	mov [rdx+38h],rax
	mov [rdx+30h],r8
	mov [rdx+28h],rax
	mov [rdx+20h],rcx
	mov [rdx+18h],rax
	mov [rdx+10h],rax
	mov [rdx+8h],rax
	mov [rdx],rax
	mov rdx,uzTipClass
	mov r9,WS_POPUP or \
		TTS_ALWAYSTIP or\
		TTS_BALLOON
	xor r8,r8
	xor ecx,ecx
	call [CreateWindowExW]
	mov rsp,rbp
	pop rbp
	ret 0

.addtool:
	mov edx,TTM_ADDTOOLW
	jmp apiw.sms

	;---.update:
	;---	mov edx,TTM_UPDATE
	;---	jmp apiw.sms

.popup:
	mov edx,TTM_POPUP
	jmp apiw.sms

.add:
	;--- in RCX hTip
	;--- in RDX parent container of the tool
	;--- in R8 hTool
	;--- in R9 text
	push rbp
	push rbx
	push rdi

	mov rbx,rcx
	mov rbp,rsp

	mov ecx,\
		sizeof.TOOLINFO
	xor eax,eax
	sub rsp,rcx
	mov r11,rcx
	mov rdi,rsp
	shr ecx,3
	rep stosq

	mov [rsp+\
		TOOLINFO.cbSize],r11d
	mov [rsp+\
		TOOLINFO.hwnd],rdx ;--- parent container of the tool
	mov [rsp+\
		TOOLINFO.uFlags],\
			TTF_IDISHWND or \
			TTF_SUBCLASS
	mov [rsp+\
		TOOLINFO.uId],r8 	;--- tool
	mov [rsp+\
		TOOLINFO.lpszText],r9

	xor r8,r8
	mov r9,rsp
	mov rcx,rbx
	call .addtool

	mov rsp,rbp
	pop rdi
	pop rbx
	pop rbp
	ret 0


   ;ü------------------------------------------ö
   ;|   TOOL  BAR                              |
   ;#------------------------------------------ä
tlb:
.get_but:
	;--- in R9 toolbutton
	;--- in R8 idx
	mov edx,TB_GETBUTTON
	jmp apiw.sms


.set_iml:
	mov edx,\
		TB_SETIMAGELIST
	jmp apiw.sms

.ins_but:
	;--- in RAX iButton
  ;--- in RDX iBitmap
	;--- in R8 idCommand
	;--- in R9H	fsState
	;--- in R9L fsStyle
	;--- in R10 dwData
	;--- in R11 iString
	sub rsp,\
		sizeof.TBBUTTON
	mov [rsp+\
		TBBUTTON.idCommand],r8d
	mov [rsp+\
		TBBUTTON.iBitmap],edx
	mov [rsp+\
		TBBUTTON.fsStyle],r9l
	shr r9,8
	mov [rsp+\
		TBBUTTON.fsState],r9l
	mov [rsp+\
		TBBUTTON.dwData],r10
	mov [rsp+\
		TBBUTTON.iString],r11

	mov r8,rax
	mov edx,\
		TB_INSERTBUTTONW
	mov r9,rsp
	call apiw.sms
	add rsp,\
		sizeof.TBBUTTON
	ret 0


;---.addbmp:
;---	;--- in R8 nButtons 
;---	;--- in R9 hInst from TBADDBITMAP
;---	;--- in R10 id from TBADDBITMAP
;---	sub rsp,\
;---		sizeof.TBADDBITMAP
;---	mov [rsp+\
;---		TBADDBITMAP.hInst],r9
;---	mov [rsp+\
;---		TBADDBITMAP.nID],r10d
;---	mov edx,\
;---		TB_ADDBITMAP
;---	mov r9,rsp
;---	call apiw.sms
;---	add rsp,\
;---		sizeof.TBADDBITMAP
;---	ret 0

   ;ü------------------------------------------ö
   ;|   STATUSBAR                              |
   ;#------------------------------------------ä

statb:
;.create:
;	;--- in RCX parent
;	push rbp
;	mov rbp,rsp
;	and rsp,-16
;	sub rsp,60h
;	lea rdx,[rsp+20h]
;	xor eax,eax

;	mov r8,[hInst]
;	mov [rdx+38h],rax
;	mov [rdx+30h],r8
;	mov [rdx+28h],rax
;	mov [rdx+20h],rcx
;	mov [rdx+18h],rax
;	mov [rdx+10h],rax
;	mov [rdx+8h],rax
;	mov [rdx],rax
;	mov rdx,uzStbClass
;	mov r9,WS_CHILD \
;		or WS_VISIBLE
;	xor r8,r8
;	xor ecx,ecx
;	call [CreateWindowExW]
;	mov rsp,rbp
;	pop rbp
;	ret 0

.set_parts:
	;--- in R8 parts
	;--- in R9 array edges
	mov edx,SB_SETPARTS
	jmp	apiw.sms

.set_text:
	;--- in R8 part/flags
	;--- in R9 text
	mov edx,SB_SETTEXTW
	jmp	apiw.sms

.get_text:
	;--- in R8 part/flags
	;--- in R9 buffer
	mov edx,SB_GETTEXTW
	jmp	apiw.sms

   ;ü------------------------------------------ö
   ;|   PROGRESSBAR                            |
   ;#------------------------------------------ä

pbar:
.setstep:
	;--- in R8 step
	mov edx,\
		PBM_SETSTEP
	jmp	apiw.sms

.step:
	mov edx,\
		PBM_STEPIT 
	jmp	apiw.sms

.pos:
	;--- in R8 pos
	mov edx,\
		PBM_SETPOS
	jmp	apiw.sms

.setrange:
	;--- in R8 min
	;--- in R9 max
	mov edx,\
		PBM_SETRANGE32
	jmp	apiw.sms


   ;ü------------------------------------------ö
   ;|   TAB                                    |
   ;#------------------------------------------ä
tab:
.add_tab:
	;--- in RCX hTab
	;--- in RDX string
	;--- in R8 imgindex -1,index
	;--- in R9 param
	;--- in R10 index		-1,index
	push rbp
	mov rbp,rsp
	and rsp,-16

	sub rsp,\
		sizea16.TCITEMW
	xor r11,r11
	test rdx,rdx
	jz	@f
	mov [rsp+\
		TCITEMW.pszText],rdx
	or r11,TCIF_TEXT
@@:
	test r9,r9
	jz	@f
	or ecx,TCIF_PARAM
	mov [rsp+\
		TCITEMW.lParam],r9
@@:
	inc r8
	jz	@f
	dec r8
	mov [rsp+\
		TCITEMW.iImage],r8d
	or r11,TCIF_IMAGE
@@:		
	mov r8,r10
	mov [rsp+\
		TCITEMW.mask],r11d
	inc r10
	jnz	@f

	push rcx
	call .get_numtabs
	pop rcx
	mov r8,rax
@@:		
	mov r9,rsp
	call .ins_item
	mov rsp,rbp
	pop rbp
	ret 0

.get_cursel:
	mov rdx,\
		TCM_GETCURSEL
	jmp	apiw.sms

.set_cursel:
	mov rdx,\
		TCM_SETCURSEL
	jmp	apiw.sms

.ins_item:
	mov rdx,\
		TCM_INSERTITEMW
	jmp	apiw.sms

.get_numtabs:
	mov rdx,\
		TCM_GETITEMCOUNT
	xor r8,r8
	xor r9,r9
	jmp apiw.sms

.adj_rect:
	mov rdx,\
		TCM_ADJUSTRECT
	jmp apiw.sms

.set_iml:
	xor r8,r8
	mov edx,\
		TCM_SETIMAGELIST
  jmp apiw.sms

.get_irect:
	mov edx,\
		TCM_GETITEMRECT
	jmp	apiw.sms

;.get_numtabs:
;	push 0
;	push 0
;	push TCM_GETITEMCOUNT

;.tab_sendmessage:
;	push eax
;	SendMessage
;	ret 0

;.setilist:
;	push edx
;	push 0
;	push TCM_SETIMAGELIST
;	jmp .tab_sendmessage

;.del_item:
;	push 0
;	push edx
;	push TCM_DELETEITEM
;	jmp .tab_sendmessage
;	
;.get_item:
;	push edx
;	push ecx
;	push TCM_GETITEM
;	jmp .tab_sendmessage

;.get_rows:
;	push 0
;	push 0
;	push TCM_GETROWCOUNT
;	jmp .tab_sendmessage

;proc .getlparam
;	;RET EDX=pflfile
;	; IN EAX=htab
;	; IN ECX=item
;	local .tci:TC_ITEM
;	lea edx,[.tci]	
;	mov [edx+TC_ITEM.mask],TCIF_PARAM	
;	call .get_item
;	mov eax,[.tci.lParam]
;	ret
;endp

   ;ü------------------------------------------ö
   ;|   LISTVIEW                               |
   ;#------------------------------------------ä

lvw:
.ins_col:
	mov edx,LVM_INSERTCOLUMNW
	jmp	apiw.sms

.edit_lab:
	xor r9,r9
	mov edx,LVM_EDITLABELW
	jmp	apiw.sms

.set_xstyle:
	mov edx,\
	LVM_SETEXTENDEDLISTVIEWSTYLE
	jmp	apiw.sms

.set_iml:
	mov edx,LVM_SETIMAGELIST
	jmp	apiw.sms

.ins_item:
	xor r8,r8
	mov edx,LVM_INSERTITEMW
	jmp	apiw.sms

.del_item:
	;--- in R8 item -----
	xor r9,r9
	mov edx,LVM_DELETEITEM
	jmp	apiw.sms

.del_all:
	xor r9,r9
	xor r8,r8
	mov edx,LVM_DELETEALLITEMS
	jmp	apiw.sms

.get_next:
	;--- in r8 iItem/-1
	;--- in r9 flags
	mov edx, LVM_GETNEXTITEM
	jmp	apiw.sms
	
.get_count:
	xor r8,r8
	xor r9,r9
	mov edx,LVM_GETITEMCOUNT
	jmp	apiw.sms

.get_param:
	;--- in RCX hLvw
	;--- in R9 LVITEMW
	mov [r9+LVITEMW.mask],\
		LVIF_PARAM
	jmp	.get_item

.get_item:
	;--- in R9 TVITEM
	;--- in RCX hLvw
	xor r8,r8
	mov edx,LVM_GETITEMW
	jmp	apiw.sms

.set_item:
	;--- in R9 TVITEM
	;--- in RCX hLvw
	mov edx,LVM_SETITEMW
	jmp	apiw.sms

.set_itext:
	;--- in R9 TVITEM
	;--- in R8 idx item
	mov edx,LVM_SETITEMTEXTW
	jmp	apiw.sms

.set_bkcol:
	;--- in R9 color
	mov edx,LVM_SETBKCOLOR
	jmp	apiw.sms

.set_txtbkcol:
	;--- in R9 color
	mov edx,LVM_SETTEXTBKCOLOR	
	jmp	apiw.sms

.set_view:
	;--- in R8 view type	
	mov edx,LVM_SETVIEW
	jmp	apiw.sms

.set_icon:
	;--- in RDX iItem
	;--- in R8 idx image
	;--- in R9 TVITEM
	mov [r9+LVITEMW.mask],\
		LVIF_IMAGE
	mov [r9+\
		LVITEMW.iImage],r8d
	mov [r9+\
		LVITEMW.iItem],edx
	jmp	.set_item

.is_param:
	;--- in RCX hLvw
	;--- in RDX lParam to match
	;--- ret RAX 0,our lparam
	;--- ret RCX prev lparam
	;--- ret RDX idx
	push rbx
	push rdi
	push rsi
	push r12
	push r13

	sub rsp,\
		sizeof.LVITEMW
	xor r13,r13
	xor r12,r12

	mov [rsp+\
		LVITEMW.lParam],r12

	mov [rsp+\
		LVITEMW.iItem],r12d

	mov rsi,rdx
	mov rbx,rcx
	call .get_count
	mov edi,eax
	test eax,eax
	jz	.is_paramE
	mov r13,rax

.is_paramA:
	mov eax,r13d
	neg eax
	add eax,edi
	xor edx,edx

	mov r9,rsp
	mov [rsp+\
		LVITEMW.lParam],rdx
	mov [rsp+\
		LVITEMW.iItem],eax
	mov [rsp+\
		LVITEMW.iSubItem],edx
	mov rcx,rbx
	call .get_param
	test eax,eax
	jz	.is_paramB	;--- skip int. err.

	cmp rsi,[rsp+\
		LVITEMW.lParam]
	jz	.is_paramE

.is_paramB:
	mov r12,[rsp+\
		LVITEMW.lParam]
	dec r13d
	jnz	.is_paramA
	mov [rsp+\
		LVITEMW.lParam],r13

.is_paramE:
	mov rcx,r12
	mov edx,[rsp+\
		LVITEMW.iItem]

	mov rax,[rsp+\
		LVITEMW.lParam]

	add rsp,\
		sizeof.LVITEMW
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	ret 0


   ;ü------------------------------------------ö
   ;|   COMBOBOXEXT                            |
   ;#------------------------------------------ä

cbex:
.get_count:
	xor r8,r8
	xor r9,r9
	mov edx,CB_GETCOUNT
	jmp	apiw.sms

.sel_item:
	;--- in R8 index
	xor r9,r9
	mov edx,CB_SETCURSEL
	jmp	apiw.sms

.set_iml:
	xor r8,r8
	mov edx,CBEM_SETIMAGELIST
	jmp	apiw.sms

.get_cursel:
	xor r9,r9
	xor r8,r8
	mov edx,CB_GETCURSEL
	jmp	apiw.sms

.get_edit:
	xor r9,r9
	xor r8,r8
	mov rdx,CBEM_GETEDITCONTROL
	jmp	apiw.sms

.get_param:
	;--- in RCX hCbx
	;--- in RDX item
	;--- ret RDX param
	;--- ret RAX -1/index

	sub rsp,\
		sizeof.COMBOBOXEXITEMW
	mov r9,rsp

	mov [r9+\
		COMBOBOXEXITEMW.iItem],rdx

	mov [r9+\
		COMBOBOXEXITEMW.mask],\
		CBEIF_LPARAM

	push rdx
	xor r8,r8
	mov edx,CBEM_GETITEMW
	call apiw.sms
	xor edx,edx
	pop r8
	dec eax
	mov r9,[rsp+\
		COMBOBOXEXITEMW.lParam]
	cmovge rax,r8
	cmovge rdx,r9
	add rsp,\
		sizeof.COMBOBOXEXITEMW
	ret 0



.reset:
	xor r9,r9
	xor r8,r8
	mov edx,CB_RESETCONTENT
	jmp	apiw.sms


.ins_item:
	;--- in RCX hCb
	;--- in RDX string
	;--- in R8 imgindex
	;--- in R9 param
	;--- in R10 indent r10b,index overlay rest R10)
	;--- in R11 selimage
	sub rsp,\
		sizeof.COMBOBOXEXITEMW

	mov [rsp+\
		COMBOBOXEXITEMW.pszText],rdx
	mov rax,r10

	mov edx,CBEIF_TEXT or \
		CBEIF_INDENT
	and r10,0Fh
	shr eax,8
	mov [rsp+\
		COMBOBOXEXITEMW.iIndent],r10d
	test eax,eax
	jz	@f
	or edx,CBEIF_OVERLAY
	mov [rsp+\
		COMBOBOXEXITEMW.iOverlay],eax
@@:
	test r9,r9
	jz @f
	or edx,CBEIF_LPARAM
	mov [rsp+\
		COMBOBOXEXITEMW.lParam],r9
@@:
	inc r8
	jz	@f
	dec r8
	or edx,CBEIF_IMAGE
	mov [rsp+\
		COMBOBOXEXITEMW.iImage],r8d
@@:
	inc r11
	jz	@f
	dec r11
	or edx,CBEIF_SELECTEDIMAGE
	mov [rsp+\
		COMBOBOXEXITEMW.iSelectedImage],r11d
@@:	
	or [rsp+\
		COMBOBOXEXITEMW.iItem],-1

	mov [rsp+\
		COMBOBOXEXITEMW.mask],edx

	xor r8,r8
	mov r9,rsp
	mov rdx,\
		CBEM_INSERTITEMW
	call apiw.sms
	add rsp,\
		sizeof.COMBOBOXEXITEMW
	ret 0

.del_item:
	xor r9,r9
	mov edx,CBEM_DELETEITEM
	jmp	apiw.sms

	
;.get_itemh:
;	xor r9,r9
;	mov edx,CB_GETITEMHEIGHT
;	jmp	apiw.sms


.is_param:
	;--- in RCX hCb
	;--- in RDX lParam to match
	;--- ret RAX index,-1
	;--- ret RDX LPARAM
	push rbp
	push rbx
	push rdi
	push rsi
	mov rbp,rsp
	sub rsp,\
		FILE_BUFLEN

	mov rsi,rdx
	mov rbx,rcx
	call .get_count
	mov rdi,rax
	test rax,rax
	jl	.is_paramC

.is_paramB:
	dec rdi
	mov rax,rdi
	js .is_paramC
	mov r8,rsp
	mov rdx,rdi
	mov rcx,rbx
	call .get_item
	test rax,rax
	jl .is_paramC
	cmp rdx,rsi
	jnz	.is_paramB

.is_paramC:
	mov rsp,rbp
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0

;.get_cb:
;	xor r8,r8
;	xor r9,r9
;	mov edx,CBEM_GETCOMBOCONTROL
;	jmp	apiw.sms


.get_item:
	;--- in RCX hCb
	;--- in RDX iItem
	;--- in R8 buf512

	;--- RET RAX index,-1
	;--- RET RCX pText
	;--- RET RDX LPARAM
	;--- RET R9 index image
	sub rsp,\
		sizeof.COMBOBOXEXITEMW
	mov rax,rsp
	mov [rax+\
		COMBOBOXEXITEMW.iItem],rdx
	mov [rax+\
		COMBOBOXEXITEMW.cchTextMax],100h
	mov [rax+\
		COMBOBOXEXITEMW.pszText],r8
	mov [rax+\
		COMBOBOXEXITEMW.mask],\
		CBEIF_TEXT or \
		CBEIF_LPARAM or \
		CBEIF_IMAGE
	xor r8,r8
	mov r9,rax
	mov edx,CBEM_GETITEMW
	call apiw.sms

	test rax,rax
	jz	.get_itemA

	mov rax,[rsp+\
		COMBOBOXEXITEMW.iItem]
	mov rcx,[rsp+\
		COMBOBOXEXITEMW.pszText]
	inc rax
	mov rdx,[rsp+\
		COMBOBOXEXITEMW.lParam]
	mov r9d,[rsp+\
		COMBOBOXEXITEMW.iImage]

.get_itemA:
	dec rax
	add rsp,sizeof.COMBOBOXEXITEMW
	ret 0

;;	;1) --- create back color console panel
;;;	mov rcx,00AABBCCh
;;;	call shared.create_sbrush
;;;	mov [hBkColConsPanel],rax
;;@break

;;	xor r8,r8
;;	xor r9,r9
;;	or rax,-1
;;	mov rdx,uzTreeClass
;;	mov rcx,[hEditTab]
;;	call tab.addtab

;.setp1:
;	push eax
;	push SBT_POPOUT or STATUSLINEPART
;	jmp .msg1

;.setp3:
;	push eax
;	push SBT_POPOUT or STATUSDIRPART

;.msg1:
;	push SB_SETTEXT
;.msg:
;	push [hStatus]
;	SendMessage
;	ret 0

;.getrect:
;	;IN EAX=part
;	;IN EDX=pRect
;	push edx
;	push eax
;	push  SB_GETRECT
;	jmp	.msg

;.gettext:
;	;IN EAX=part
;	;IN EDX=pText
;	push edx
;	push eax
;	push SB_GETTEXT
;	jmp	.msg
