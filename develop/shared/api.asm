  
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


apiw:

	;#---------------------------------------------------ö
	;|           COMMON PROLOG EPILOG                    |
	;ö---------------------------------------------------ü
.prologI:
	;--- call to interfaces
	;--- RCX = always this
	;--- RAX = proc
	;--- RDX/R8/R9/R10/R11 paras (isnt it enough !?)
	mov rax,[rax]

.prologP:
	;--- max 2 pushes in R10,R11
	push rbp
	mov rbp,rsp
	and rsp,-16

.prologQ:
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

@using .mnu_del
.mnu_del:
	mov rax,[DeleteMenu]
	jmp	.prolog0
@endusing


@using .mnu_create
.mnu_create:
	mov rax,[CreateMenu]
	jmp	.prolog0
@endusing

@using .mnu_set
.mnu_set:
	mov rax,[SetMenu]
	jmp	.prolog0
@endusing

@using .mnu_setinfo
.mnu_setinfo:
	mov rax,[SetMenuInfo]
	jmp	.prolog0
@endusing

@using .mnu_getinfo
.mnu_getinfo:
	mov rax,[GetMenuInfo]
	jmp	.prolog0
@endusing


@using .mnp_create
.mnp_create:
	mov rax,[CreatePopupMenu]
	jmp	.prolog0
@endusing

@using .mnu_destroy
.mnu_destroy:
	mov rax,[DestroyMenu]
	jmp	.prolog0
@endusing

;--------------------------------
@using .mni_set_byid
.mni_set_byid:
	push 0
	mov [r9+\
		MENUITEMINFOW.wID],edx
	jmp	.mni_set
@endusing

@using .mni_set_bypos
.mni_set_bypos:
	push 1
	jmp	.mni_set
@endusing

;;--------------------------------
@using .mni_get_byid
.mni_get_byid:
	push 0
	mov [r9+\
		MENUITEMINFOW.wID],edx
	jmp	.mni_get
@endusing

@using .mni_get_bypos
.mni_get_bypos:
	push 1
	jmp	.mni_get
@endusing

;--------------------------------
@using .mni_ins_bypos,\
	.mni_ins_byid,\
	.mni_set_byid,\
	.mni_set_bypos,\
	.mni_get_byid,\
	.mni_get_bypos

.mni_ins_byid:
	or r8,-1
	mov [r9+\
		MENUITEMINFOW.wID],edx
	jmp	.mni_do

.mni_set:
	pop r8
	mov rax,[SetMenuItemInfoW]
	jmp	.mni_doA
	
.mni_get:
	pop r8
	mov rax,[GetMenuItemInfoW]
	jmp	.mni_doA

.mni_ins_bypos:
	xor r8,r8

.mni_do:
	inc r8
	mov rax,[InsertMenuItemW]

.mni_doA:
	mov [r9+\
		MENUITEMINFOW.cbSize],\
		sizeof.MENUITEMINFOW
	jmp	.prolog0
@endusing

@using .mnu_loadi
.mnu_loadi:
	mov rax,[LoadMenuIndirectW]
	jmp	.prolog0
@endusing

@using .mnu_load
.mnu_load:
	mov rax,[LoadMenuW]
	jmp	.prolog0
@endusing

@using .get_submnu
.get_submnu:
	mov rax,[GetSubMenu]
	jmp	.prolog0
@endusing

@using .mnu_draw
.mnu_draw:
	mov rax,[DrawMenuBar]
	jmp	.prolog0
@endusing

@using .get_mnuicount
.get_mnuicount:
	mov rax,[GetMenuItemCount]
	jmp	.prolog0
@endusing

@using .track_pmnu
.track_pmnu:
	push rbp
	mov rbp,rsp
	xor eax,eax
	and rsp,-16
	sub rsp,40h
	mov [rsp+20h],rax
	mov [rsp+28h],r10
	mov [rsp+30h],r11

  ;--- in RCX hMenu
  ;--- in RDX uFlags
	;--- in R8 x
	;--- in R9 y 
	;--- in R10 hwnd
	;--- in R11 rect

	;--- original --------------------------
  ;--- in RCX hMenu
  ;--- in RDX uFlags
  ;--- in R8 x  horz pos, in screen coord
  ;--- in R9 y  vert pos, in screen coord
  ;--- in R10 nReserved
  ;--- in R11 hWnd	handle of owner window
  ;--- in RSP prcRect	RECT no-dismissal area

	call [TrackPopupMenu]
	jmp	.epilog1
@endusing



	;#---------------------------------------------------ö
	;|           THEMES                                  |
	;ö---------------------------------------------------ü

@using .th_open
.th_open:
	mov rax,[OpenThemeData]
	jmp .prolog0
@endusing


@using .th_close
.th_close:
	mov rax,[CloseThemeData]
	jmp .prolog0
@endusing

@using .th_drawbkg
.th_drawbkg:
	mov rax,[DrawThemeBackground]
	jmp .prologP
@endusing

	;#---------------------------------------------------ö
	;|           ENV and VARIALBLES                      |
	;ö---------------------------------------------------ü

@using .set_env
	;IN RCX = envname
	;IN RDX = envvalue
.set_env:
	mov rax,[SetEnvironmentVariableW]
	jmp	.prolog0
@endusing


@using .get_env
	;IN RCX = envname
	;IN RDX = envvalue
	;IN R8 = maxsize
.get_env:
	mov rax,[GetEnvironmentVariableW]
	jmp	.prolog0
@endusing

@using .exp_env
;	;--- IN RCX str %variableName%
;	;--- IN RDX output
;	;--- RET EAX copied cpts
;	;--- RET ECX str variable
;	;--- RET EDX output
.exp_env:
	push rcx
	push rdx
	mov rax,[ExpandEnvironmentStringsW]
	mov r8,MAX_UTF16_FILE_CPTS
	call .prolog0
	pop rdx
	pop rcx
	ret 0
;	mov rax,[ExpandEnvironmentStringsW]
;	jmp	.prolog0
@endusing

@using .set_wl
.set_wl:
	;--- IN RCX hwnd
	;--- IN RDX index
	mov rax,[SetWindowLongPtrW]
	jmp	.prolog0
@endusing

@using .set_wlproc
.set_wlproc:
	mov rdx,GWL_WNDPROC
	jmp	.set_wl
@endusing

@using .set_wlxstyle
.set_wlxstyle:
	mov rdx,GWLP_EXSTYLE
	jmp	.set_wl
@endusing

@using .set_wlstyle
.set_wlstyle:
	mov rdx,GWLP_STYLE
	jmp	.set_wl
@endusing

@using .set_wldata
.set_wldata:
	mov rdx,GWLP_USERDATA
	jmp	.set_wl
@endusing
	
@using .get_wl
.get_wl:
	;--- IN RCX hwnd
	;--- IN RDX index
	mov rax,[GetWindowLongPtrW]
	jmp	.prolog0
@endusing

@using .get_wlstyle
.get_wlstyle:
	;--- in RCX hwnd
	mov rdx,GWLP_STYLE	
	jmp	.get_wl
@endusing

@using .get_wldata
.get_wldata:
	;--- in RCX hwnd
	mov rdx,GWLP_USERDATA
	jmp	.get_wl
@endusing

	;#---------------------------------------------------ö
	;|                LOADLIB /FREELIB                   |
	;ö---------------------------------------------------ü

@using .get_modfname
.get_modfname:
	;--- in RCX hModule/0
	;--- in RDX buffer path/filename
	;--- in R8 buffersize
	mov rax,[GetModuleFileNameW]
	jmp	.prolog0
@endusing

@using .get_modh
.get_modh:
	;--- in RCX module name
	mov rax,[GetModuleHandleW]
	jmp	.prolog0
@endusing

@using .freelib_exitt
.freelib_exitt:
	mov rax,[FreeLibraryAndExitThread]
	jmp	.loadlibB
@endusing

@using .freelib
.freelib:
	;--- in RCX hModule
	mov rax,[FreeLibrary]
	jmp	.prolog0
@endusing

@using .loadlib
.loadlib:
	;in RDX = 0/flags
	;in RCX = path/filename
	xchg rdx,r8
	mov rax,[LoadLibraryExW]
	xor rdx,rdx
	jmp	.prolog0
@endusing

   ;ü------------------------------------------ö
   ;|   file or directory                      |
   ;#------------------------------------------ä

@using .set_curdir
.set_curdir:
	;--- in RCX path
	mov rax,[SetCurrentDirectoryW]
	jmp	.prolog0
@endusing

@using .get_curdir
.get_curdir:
	;--- in RCX len buffer
	;--- in RDX buffer
	mov rax,[GetCurrentDirectoryW]
	jmp	.prolog0
@endusing

@using .createdir
.createdir:
	;--- in RCX pathname
	;--- in RDX securityattr
	mov rax,[CreateDirectoryW]
	jmp	.prolog0
@endusing

@using .copyf
.copyf:
	mov rax,[CopyFileW]
	jmp	.prolog0
@endusing


   ;ü------------------------------------------ö
   ;|   thread and process                     |
   ;#------------------------------------------ä

@using .tproc
	;--- in RCX pAddress
	;--- in RDX stacksize
	;--- in R8 params
.tproc:
	mov rax,[_beginthread]
	jmp	.prolog0
@endusing

@using .exitp
.exitp:
	mov rax,[ExitProcess]
	jmp	.prolog0
@endusing

   ;ü------------------------------------------ö
   ;|   GDI etc                                 |
   ;#------------------------------------------ä

@using .beg_paint
.beg_paint:
	mov rax,[BeginPaint]
	jmp	.prolog0
@endusing

@using .create_compbmp
.create_compbmp:
	mov rax,[CreateCompatibleBitmap]
	jmp	.prolog0
@endusing

@using .create_bmp
.create_bmp:
	xor r11,r11
	mov rax,[CreateBitmap]
	jmp	.prologP
@endusing

@using .create_compdc
.create_compdc:
	mov rax,[CreateCompatibleDC]
	jmp	.prolog0
@endusing

@using .create_sbrush
.create_sbrush:
	mov rax,[CreateSolidBrush]
	jmp	.prolog0
@endusing

@using .create_pbrush
.create_pbrush:
	mov rax,[CreatePatternBrush]
	jmp	.prolog0
@endusing

@using .delobj
.delobj:
	mov rax,[DeleteObject]
	jmp	.prologP
@endusing

@using .draw_edge
.draw_edge:
	mov rax,[DrawEdge]
	jmp	.prolog0
@endusing

@using .draw_fctrl
.draw_fctrl:
	mov rax,[DrawFrameControl]
	jmp	.prolog0
@endusing

@using .get_dc
.get_dc:
	mov rax,[GetDC]
	jmp	.prolog0
@endusing

@using .get_txtmetr
.get_txtmetr:
	mov rax,[GetTextMetricsW]
	jmp	.prolog0
@endusing

@using .get_devcaps
.get_devcaps:
	mov rax,[GetDeviceCaps]
	jmp	.prolog0
@endusing

@using .rel_dc
.rel_dc:
	mov rax,[ReleaseDC]
	jmp	.prolog0
@endusing

@using .patblt
  ;--- in RCX hdc
  ;--- in RDX nXLeft
  ;--- in R8  nYLeft
  ;--- in R9  nWidth
  ;--- in R10 nHeight
  ;--- in R11 dwRop
.patblt:
	mov rax,[PatBlt]
	jmp	.prologP
@endusing

@using .cfonti
.cfonti:
	mov rax,[CreateFontIndirectW]
	jmp .prolog0
@endusing
	
;---	;--- in RCX bold-wi-hi <----
;---	;--- in RDX st-un-it-ch <---
;---	;--- in R8	font name
;---	;--- in R9 pitch
;---	sub rsp,sizea16.LOGFONTW
;---	movzx eax,cl
;---	mov [rsp+LOGFONTW.lfHeight],eax
;---	movzx eax,ch
;---	mov [rsp+LOGFONTW.lfWidth],eax
;---	xor eax,eax
;---	shr rcx,16
;---	mov [rsp+LOGFONTW.lfEscapement],eax
;---	mov [rsp+LOGFONTW.lfOrientation],eax
;---	mov [rsp+LOGFONTW.lfWeight],ecx

;---	;-------------------------------------
;---	mov [rsp+LOGFONTW.lfCharSet],dl
;---	mov [rsp+LOGFONTW.lfItalic],dh
;---	shr edx,16
;---	mov [rsp+LOGFONTW.lfUnderline],dl
;---	mov [rsp+LOGFONTW.lfStrikeOut],dh
;---	;-------------------------------------
;---	or r9,FF_DONTCARE
;---	mov [rsp+LOGFONTW.lfPitchAndFamily],\
;---		r9l
;---;		DEFAULT_PITCH or FF_DONTCARE	

;---	mov [rsp+LOGFONTW.lfOutPrecision],\
;---		OUT_DEFAULT_PRECIS	

;---	mov [rsp+LOGFONTW.lfClipPrecision],\
;---		CLIP_DEFAULT_PRECIS	

;---	mov [rsp+LOGFONTW.lfQuality],\
;---		DEFAULT_QUALITY


;---	mov r9,rdi
;---	xchg r8,rsi
;---	lea rdi,[rsp+LOGFONTW.lfFaceName]
;---@@:
;---	lodsw
;---	stosw
;---	test ax,ax
;---	jnz	@b

;---	xchg r9,rdi
;---	xchg r8,rsi
;---	mov rcx,rsp
;---	mov rax,[CreateFontIndirectW]
;---	call .prolog0
;---	add rsp,sizea16.LOGFONTW
;---	ret 0
;---@endusing

@using .get_tep32
;	in R9 LPSIZE lpSize 	// address of structure for string size  
;	in R8 cbString
;	in RDX lpString
;	in RCX hdc
.get_tep32:
	mov rax,[GetTextExtentPoint32W]
	jmp	.prolog0
@endusing

@using .selobj
.selobj:
	mov rax,[SelectObject]
	jmp	.prologP
@endusing

@using .excl_cliprect
.excl_cliprect:
	mov rax,[ExcludeClipRect]
	jmp	.prologP
@endusing

@using .get_syscol
.get_syscol:
	mov rax,[GetSysColor]
	jmp	.prolog0
@endusing

@using .get_stockobj
.get_stockobj:
	mov rax,[GetStockObject]
	jmp	.prolog0
@endusing

@using .get_syscolbr
.get_syscolbr:
	mov rax,[GetSysColorBrush]
	jmp	.prolog0
@endusing

@using .sysparinfo
.sysparinfo:
	mov rax,[SystemParametersInfoW]
	jmp	.prolog0
@endusing

@using .get_sysmet
.get_sysmet:
	mov rax,[GetSystemMetrics]
	jmp	.prolog0
@endusing

@using .invrect
.invrect:
	mov rax,[InvalidateRect]
	jmp	.prolog0
@endusing
	
@using .scr2cli
.scr2cli:
	;--- in RCX hwnd
	;--- in RDX point
	mov rax,[ScreenToClient]
	jmp	.prolog0
@endusing

@using .cli2scr
.cli2scr:
	;--- in RCX hwnd
	;--- in RDX point
	mov rax,[ClientToScreen]
	jmp	.prolog0
@endusing

@using .get_clirect
.get_clirect:
	;--- in RCX hwnd
	;--- in RDX pRect
	mov rax,[GetClientRect]
	jmp	.prolog0
@endusing

@using .get_winrect
.get_winrect:
	;--- in RCX hwnd
	;--- in RDX pRect
	mov rax,[GetWindowRect]
	jmp	.prolog0
@endusing

@using .get_winplacem
.get_winplacem:
	;--- in RCX hwnd
	;--- in RDX struct
	mov rax,[GetWindowPlacement]
	jmp	.prolog0
@endusing

@using .get_curspos
	;--- in RCX LPPOINT
.get_curspos:
	mov rax,[GetCursorPos]
	jmp	.prolog0
@endusing

@using .set_curspos
.set_curspos:
	mov rax,[SetCursorPos]
	jmp	.prolog0
@endusing

@using .map_wpt
	;--- RCX/RDX/R8/R9
.map_wpt:
	mov rax,[MapWindowPoints]
	jmp	.prolog0
@endusing

@using .end_paint
.end_paint:
	mov rax,[EndPaint]
	jmp	.prolog0
@endusing

@using .fillrect
.fillrect:
	mov rax,[FillRect]
	jmp	.prolog0
@endusing

@using .set_bkmode
.set_bkmode:
	mov rax,[SetBkMode]
	jmp	.prolog0
@endusing

@using .set_bkcol
.set_bkcol:
	mov rax,[SetBkColor]
	jmp	.prolog0
@endusing

@using .set_txtcol
.set_txtcol:
	mov rax,[SetTextColor]
	jmp	.prolog0
@endusing

   ;ü------------------------------------------ö
   ;|   window managing                        |
   ;#------------------------------------------ä

@using .beg_defwpos
.beg_defwpos:
	mov rax,[BeginDeferWindowPos]
	jmp	.prolog0
@endusing


@using .chwinfptx
.chwinfptx:
	mov rax,[ChildWindowFromPointEx]
	jmp	.prolog0
@endusing

@using .en_win
.en_win:
	mov rax,[EnableWindow]
	jmp	.prolog0
@endusing

@using .end_defwpos
.end_defwpos:
	mov rax,[EndDeferWindowPos]
	jmp	.prolog0
@endusing

@using .enum_cwin
.enum_cwin:
	mov rax,[EnumChildWindows]
	jmp	.prolog0
@endusing

@using .set_lwattr
.set_lwattr:
	mov rax,[SetLayeredWindowAttributes]
	jmp	.prolog0
@endusing

@using .set_focus
.set_focus:
	mov rax,[SetFocus]
	jmp	.prolog0
@endusing


@using .redraw_win
.redraw_win:
	mov rax,[RedrawWindow]
	jmp	.prolog0
@endusing

@using .regcls
.regcls:
	mov rax,[RegisterClassExW]
	jmp	.prolog0
@endusing

@using .unregcls
.unregcls:
	mov rax,[UnregisterClassW]
	jmp	.prolog0
@endusing

@using .set_wpos
	;--- in RCX hWnd
	;--- in RDX hWndInsertAfter
	;--- in R8 X
	;--- in R9 Y
	;--- in r10 cx
	;--- in R11 cy
	;--- in RAX uFlags
.set_wpos:
	push rbp
	mov rbp,rsp
	and rsp,-16
	push 0
	push rax
	push r11
	push r10
	mov rax,[SetWindowPos]
	jmp	.epilog0
@endusing


@using .cwinex
.cwinex:
	push rbp
	mov rbp,rsp
	and rsp,-16
	push qword[rbp+104]
	push qword[rbp+96]
	push qword[rbp+88]
	push qword[rbp+80]
	push qword[rbp+72]
	push qword[rbp+64]
	push qword[rbp+56]
	push qword[rbp+48]
	sub rsp,20h
	mov r9,[rbp+40]
	mov r8,[rbp+32]
	mov rdx,[rbp+24]
	mov rcx,[rbp+16]
	call [CreateWindowExW]
	mov edx,12*8+8
	jmp	.epilog2
@endusing

@using .is_win
.is_win:
	mov rax,[IsWindow]
	jmp	.prolog0
@endusing

@using .set_capt
.set_capt:
	mov rax,[SetCapture]
	jmp	.prolog0
@endusing

@using .rel_capt
.rel_capt:
	mov rax,[ReleaseCapture]
	jmp	.prolog0
@endusing

@using .set_parent
.set_parent:
	;--- in RDX new parent
	;--- in RCX our hwnd
	mov rax,[SetParent]
	jmp	.prolog0
@endusing

@using .destroy
.destroy:
	mov rax,[DestroyWindow]
	jmp	.prolog0
@endusing

@using .show
.show:
	mov rax,[ShowWindow]
	jmp	.prolog0
@endusing

@using .update
.update:
	mov rax,[UpdateWindow]
	jmp	.prolog0
@endusing

@using .animate
	;--- in RCX hwnd
	;--- in RDX timer
	;--- in R8 flags
.animate:
	mov rax,[AnimateWindow]
	jmp	.prolog0
@endusing

   ;ü------------------------------------------ö
   ;|   USER                                   |
   ;#------------------------------------------ä
@using .destr_icon
.destr_icon:
	mov rax,[DestroyIcon]
	jmp	.prolog0
@endusing

@using .ddetect
.ddetect:
	mov rax,[DragDetect]
	jmp	.prolog0
@endusing
	

@using .drawtext
.drawtext:
	xor r11,r11
	mov rax,[DrawTextW]
	jmp	.prologP
@endusing

@using .movewin
.movewin:
	mov rax,[MoveWindow]
	jmp	.prologP
@endusing

@using .get_win
.get_win:
	mov rax,[GetWindow]
	jmp	.prolog0
@endusing

@using .drawstt
.drawstt:
	mov rax,[DrawStatusTextW]
	jmp	.prolog0
@endusing
	
@using .get_curs
.get_curs:
	mov rax,[GetCursor]
	jmp	.prolog0
@endusing

@using .loadcurs
.loadcurs:
	mov rax,[LoadCursorW]
	jmp	.prolog0
@endusing

@using .get_dlgbu
.get_dlgbu:
	mov rax,[GetDialogBaseUnits]
	jmp	.prolog0
@endusing

@using .sms
.sms:
	mov rax,[SendMessageW]
	jmp	.prolog0
@endusing

@using .pms
.pms:
	mov rax,[PostMessageW]
	jmp	.prolog0
@endusing

@using .snms
.snms:
	mov rax,[SendNotifyMessageW]
	jmp	.prolog0
@endusing


   ;ü------------------------------------------ö
   ;|   RESOURCES                              |
   ;#------------------------------------------ä

@using .icex
	;--- in RCX flags
.icex:
	push rbp
	mov rbp,rsp
	and rsp,-16
	sub rsp,\
		sizea16.INITCOMMONCONTROLSEX
	mov rdx,rsp
	mov rax,\
		[InitCommonControlsEx]
	mov [rsp+INITCOMMONCONTROLSEX.dwICC],ecx
	mov [rsp+INITCOMMONCONTROLSEX.dwSize],\
		sizeof.INITCOMMONCONTROLSEX
	mov rcx,rdx
	jmp .epilog0
@endusing

@using .loadacc
.loadacc:
	mov rax,[LoadAcceleratorsW]
	jmp	.prolog0
@endusing

@using .create_acct
.create_acct:
	mov rax,[CreateAcceleratorTableW]
	jmp	.prolog0
@endusing

@using .destroy_acct
.destroy_acct:
	mov rax,[DestroyAcceleratorTable]
	jmp	.prolog0
@endusing

@using .loadicon
.loadicon:
	mov rax,[LoadIconW]
	jmp	.prolog0
@endusing

@using .loadmenu
.loadmenu:
	mov rax,[LoadMenuW]
	jmp	.prolog0
@endusing

@using .loadcurs
.loadcursor:
	mov rax,[LoadCursorW]
	jmp	.prolog0
@endusing

@using .set_curs
.set_curs:
	mov rax,[SetCursor]
	jmp	.prolog0
@endusing

@using .enddlg
.enddlg:
	mov rax,[EndDialog]
	jmp	.prolog0
@endusing

@using .get_dlgitem
.get_dlgitem:
	;--- in RCX hDialog
	;--- in RDX item id
	mov rax,[GetDlgItem]
	jmp	.prolog0
@endusing

@using .cdlgp
.cdlgp:
	;--- in RCX hInstance
	;--- in RDX lpTemplate
	;--- in R8 hWndParent
	;--- in R9 lpDialogFunc
	;--- in R10 param
	mov rax,[CreateDialogParamW]
	jmp	.prologP
@endusing

@using .dlgbp
.dlgbp:
	;--- in RCX hInstance
	;--- in RDX lpTemplate
	;--- in R8 hWndParent
	;--- in R9 lpDialogFunc
	;--- in R10 param
	mov rax,[DialogBoxParamW]
	jmp	.prologP
@endusing


@using .loadimg
.loadimg:
	mov rax,[LoadImageW]
	jmp	.prologP
@endusing

@using .loadbmp
.loadbmp:
	mov rax,[LoadBitmapW]
	jmp	.prolog0
@endusing


@using .loadres
.loadres:
	mov rax,[LoadResource]
	jmp	.prolog0
@endusing

@using .loadstr
.loadstr:
	mov rax,[LoadStringW]
	jmp	.prolog0
@endusing

@using .findresx
.findresx:
	mov rax,[FindResourceExW]
	jmp	.prolog0
@endusing

@using .findres
.findres:
	mov rax,[FindResourceW]
	jmp	.prolog0
@endusing

	;#---------------------------------------------------ö
	;|                 KERNEL & RT                       |
	;ö---------------------------------------------------ü

@using .f_close,.ff_file,.fn_file
.f_close:
	mov rax,[FindClose]
	jmp	.prolog0

.fn_file:
	mov rax,[FindNextFileW]
	jmp	.prolog0

.ff_file:
	mov rax,[FindFirstFileW]
	jmp	.prolog0
@endusing

@using .cmdline
.cmdline:
	mov rax,[GetCommandLineW]
	jmp	.prolog0
@endusing

@using .cmdargs
.cmdargs:
	mov rax,[CommandLineToArgvW]
	jmp	.prolog0
@endusing

@using .query_pf
.query_pf:
	mov rax,[QueryPerformanceFrequency]
	jmp	.prolog0
@endusing

@using .query_pc
.query_pc:
	mov rax,[QueryPerformanceCounter]
	jmp	.prolog0
@endusing

@using .wait_sobj
.wait_sobj:
	mov rax,[WaitForSingleObject]
	jmp	.prolog0
@endusing

@using .sleep
.sleep:
	mov rax,[Sleep]
	jmp	.prolog0
@endusing
	

	;#---------------------------------------------------ö
	;|                SHELL 
	;ö---------------------------------------------------ü
@using .sfinfo
.sfinfo:
	;--- in RCX pszPath
	;--- in RDX dwFileAttributes
	;--- in R8 SHFILEINFO FAR *psfi, 	
	;--- in R10 UINT uFlags	
	xor r11,r11
	mov r9,\
		sizeof.SHFILEINFOW
	mov rax,[SHGetFileInfoW]
	jmp .prologP
@endusing


@using .shexec
.shexec:
	push rbp
	mov rbp,rsp
	and rsp,-16

	sub rsp,\
		sizeof.SHELLEXECUTEINFOW+10h

	xor eax,eax
	mov [rsp],rcx
	mov [rsp+8],rdi

	mov rcx,\
		sizeof.SHELLEXECUTEINFOW / 8
	lea rdi,[rsp+10h]
	rep stosq

	pop rcx
	pop rdi

  ;--- in RCX hwnd handle to parent window
	;--- in RDX lpOperation   pointer to string that specifies operation to perform
	;--- in R8  lpFile	      pointer to filename or folder name string
	;--- in R9  lpParameters  pointer to string that specifies executable-file parameters 
	;--- in R10 lpDirectory 	pointer to string that specifies default directory
	;--- in R11 nShowCmd 	    whether file is shown when opened
	mov [rsp+\
		SHELLEXECUTEINFOW.cbSize],\
		sizeof.SHELLEXECUTEINFOW

	mov [rsp+\
		SHELLEXECUTEINFOW.fMask],\
		SEE_MASK_DOENVSUBST or \
		SEE_MASK_FLAG_NO_UI
	
	mov [rsp+\
		SHELLEXECUTEINFOW.hwnd],rcx

	mov [rsp+\
		SHELLEXECUTEINFOW.lpVerb],rdx
	
	mov [rsp+\
		SHELLEXECUTEINFOW.lpFile],r8

	mov [rsp+\
		SHELLEXECUTEINFOW.lpParameters],r9

	mov [rsp+\
		SHELLEXECUTEINFOW.lpDirectory],r10

	mov [rsp+\
		SHELLEXECUTEINFOW.nShow],r11d

	mov rax,[ShellExecuteExW]
	mov rcx,rsp

	jmp .epilog0
@endusing


@using .shget_kfpath
.shget_kfpath:
	mov rax,[SHGetKnownFolderPath]
	jmp	.prolog0
@endusing


	;#---------------------------------------------------ö
	;|                   .messages                       |
	;ö---------------------------------------------------ü

@using .msg_ok
.msg_ok:
	mov r9,\
		MB_OK or MB_ICONINFORMATION
	jmp	.msg_exec
@endusing

@using .msg_yn
.msg_yn:
	mov r9,\
		MB_YESNO \
		or MB_ICONQUESTION
	jmp	.msg_exec
@endusing

@using .msg_ync
.msg_ync:
	mov r9,\
		MB_YESNOCANCEL \
		or MB_ICONQUESTION
	jmp	.msg_exec
@endusing

@using .msg_err
.msg_err:
	mov r9,\
		MB_ICONERROR\
		or MB_DEFBUTTON1
	jmp	.msg_exec
@endusing

@using .msg_exec
.msg_exec:
	mov r10,(SUBLANG_DEFAULT shl 10 ) \
		or LANG_NEUTRAL
	mov rax,[MessageBoxExW]
	jmp	.prologP
@endusing


	;#---------------------------------------------------ö
	;|           KEYS                                    |
	;ö---------------------------------------------------ü

@using .map_vk
.map_vk:
	mov rax,[MapVirtualKeyW]
	jmp	.prolog0
@endusing

@using .get_keynt
.get_keynt:
	mov rax,[GetKeyNameTextW]
	jmp	.prolog0
@endusing


	;#---------------------------------------------------ö
	;|           COM,OLE,SHELL                           |
	;ö---------------------------------------------------ü

@using .co_init
.co_init:
	xor ecx,ecx
	mov rax,[CoInitialize]
	jmp	.prolog0
@endusing	

@using .co_initx
.co_initx:
	mov rax,[CoInitializeEx]
	jmp	.prolog0
@endusing	

@using .co_createi
.co_createi:
  ;--- __in  REFCLSID rclsid,
  ;--- __in  LPUNKNOWN pUnkOuter,
  ;--- __in  DWORD dwClsContext,
  ;--- __in  REFIID riid,
  ;--- __out LPVOID *ppv
	mov rax,[CoCreateInstance]
	jmp	.prologP
@endusing

@using .co_taskma
.co_taskma:
	mov rax,[CoTaskMemAlloc]
	jmp	.prolog0
@endusing

@using .co_taskmf
.co_taskmf:
	mov rax,[CoTaskMemFree]
	jmp	.prolog0
@endusing

@using .co_uninit
.co_uninit:
	mov rax,[CoUninitialize]
	jmp	.prolog0
@endusing


	;#---------------------------------------------------ö
	;|           ADVAPI                                  |
	;ö---------------------------------------------------ü

@using .get_usrname
  ;--- in RCX LPTSTR lpBuffer,
  ;--- in RDX LPDWORD lpnSize
.get_usrname:
	mov rax,[GetUserNameW]
	jmp	.prolog0
@endusing

	;#---------------------------------------------------ö
	;|           LANG LOCALE                             |
	;ö---------------------------------------------------ü

@using .is_locname
.is_locname:
	mov rax,[IsValidLocaleName]
	jmp	.prolog0
@endusing
	
@using .get_sysdeflocname
.get_sysdeflocname:
	mov rax,[GetSystemDefaultLocaleName]
	jmp	.prolog0
@endusing
	
@using .get_locinfox
	;---  in RCX LPCWSTR lpLocaleName
	;---  in RDX LCTYPE LCType
	;---  in R8 LPWSTR lpLCData
	;---  in R9 int cchData
.get_locinfox:
	mov rax,\
		[GetLocaleInfoEx]
	jmp	.prolog0
@endusing


@using .lcid2name
.lcid2name:
	;--- LCID Locale,
	;--- LPWSTR lpName,
	;--- int cchName,
	;--- DWORD dwFlags
	mov rax,\
		[LCIDToLocaleName]
	jmp	.prolog0
@endusing
	
@using .name2lcid
.name2lcid:
	;--- DWORD dwFlags
	;--- LPWSTR lpName,
	mov rax,\
		[LocaleNameToLCID]
	jmp	.prolog0
@endusing

