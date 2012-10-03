  
  ;#-------------------------------------------------ß
  ;|          dock64  MPL 2.0 License                |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

	F_SHADOW	equ 1 	;--- showing shadow
	F_MOVE		equ 2		;--- dragging on/off
	F_RESIZE	equ 4		;--- dragged from the caption bar
	F_SPLIT		equ 8		;--- using splitter side
	F_MINIM		equ 10h	;--- minimized win

	PART_GRIP	equ 0010'0000b
	PART_CBUT	equ 0100'0000b

struct MDL
	hwnd		dq 0 ;--- LOCKED
	hInst		dq 0 ;--- LOCKED
	shadrc	RECT ;--- LOCKED
	;------------------------------------------------
	exclude	db 0 ;--- LOCKED or exclusion as EXC_LEFT
	type		db 0 ;--- LOCKED	
	union
		cside		db 0 ;--- docking on choosen side
		sside		db 0 ;--- splitting on choosen side
	ends
	flags		db 0
	nslots	dw 0	
	cx_grip	db CX_SPLITTER
	cy_grip	db CY_SPLITTER
	seed		dd 0
					dd 0
	;------------------------------------------------
	src			RECT	;--- final client rect/0
	wrc			RECT	;--- window rect
	crc			RECT	;--- orig. clirect / src, when src logs panel

	floats		dq 0
	panels		dq 0
	target		dq 0
	pLastAct	dq 0

	phit	POINT
	hShadow		dq 0
	tmp_ssize	dd 0	;--- total tmp size of side
	union
		tmpTop	dd 0	;--- top y
		tmpLeft	dd 0	;--- 
	ends
	tmpOff		dd 0	;--- offset to panel
	tmpRest		dd 0	;--- rest from ratio/division
ends

;display_hex 16, sizeof.MDL
;display 13,10

struct PNL
	union
		hwnd	dq 0	;--- LOCKED
		tmp		dq 0	;--- LOCKED
	ends
		share	dq 0	;--- LOCKED
		wrc		RECT	;--- LOCKED
	;----------------------------------------------
	exclude	db 0 	;--- LOCKED	
	type		db 0	;--- LOCKED float panel or child
	cxy			dw 0
	tot_ssize	dd 0	;--- total size of complete side on SHA/SFI
	active		db 0	
	alignment	db 0	;--- side which the panel resides on
	ttype			db 0	;--- transition type
						db 0
	id				dd 0
	;----------------------------------------------
		crc	RECT
		frc	RECT
	;-------------------
		prev	dq 0
		next	dq 0
	;-------------------
	idord	dw 0
	ratio	db 0
				db 0
	style	dd 0
	hControl	dq 0
	;<------------------
	mdl	 	 dq 0
				 dq 0
	caprc	 RECT
	ctrc	 RECT
ends

	;--- using .get_order
	struct DOCKITEM
		id			dd 0
		flags		dd 0
		union
			pack_rc	dq 0	;--- packed rect for PNL
			info		dq 0	;--- run-time info from bin file,popcount etc. for safety
		ends
		;-----------
		rt_hPanel	dq 0		;--- runtime stored internally on static data
							dq 0
		;-----------
				dq 0
				dq 0
				dq 0
				dq 0
	ends


;display_hex 16, sizeof.PNL

	;--- internal --------------------
	CX_SPOT	= 20
	CY_SPOT = 20
	CX_SPLITTER = 3
	CY_SPLITTER = 3

	IS_FLO	equ 0000'0001b
	SHA_FI	equ 0000'0010b
	SHA_PA	equ 0000'0100b
	HAS_CO	equ 0000'1000b
	IS_HID	equ 0001'0000b		
	dummy0	equ 0010'0000b
	dummy1	equ 0100'0000b
	DOCKER	equ 1000'0000b


	;--- use this alignment/exclusion/type -----
	ALIGN_LEFT		equ 0000'0001b
	ALIGN_TOP			equ 0000'0010b
	ALIGN_RIGHT		equ 0000'0100b
	ALIGN_BOTTOM	equ 0000'1000b
	ALIGN_CLIENT	equ 0001'0000b

	ALIGN_ALL			equ \
		ALIGN_LEFT or \
		ALIGN_RIGHT or \
		ALIGN_TOP or \
		ALIGN_BOTTOM or \
		ALIGN_CLIENT

	EXCLUDE_LEFT		equ ALIGN_LEFT shl 8
	EXCLUDE_TOP			equ ALIGN_TOP shl 8
	EXCLUDE_RIGHT		equ ALIGN_RIGHT shl 8
	EXCLUDE_BOTTOM	equ ALIGN_BOTTOM shl 8
	EXCLUDE_CLIENT	equ ALIGN_CLIENT shl 8

	EXCLUDE_ALL	equ \
		EXCLUDE_LEFT or \
		EXCLUDE_TOP	or \	
		EXCLUDE_RIGHT	or \
		EXCLUDE_BOTTOM or \
		EXCLUDE_CLIENT

	FLOAT_PANEL		equ IS_FLO shl 16
	HAS_CONTROL		equ HAS_CO shl 16
	SHARE_PANEL		equ SHA_PA shl 16
	SHARE_FIRST		equ SHA_FI shl 16
	IS_HIDDEN			equ IS_HID shl 16
	
	FLAGS_ALL	equ \
		FLOAT_PANEL or \	
		SHARE_PANEL or \	
		SHARE_FIRST or \
		IS_HIDDEN	

		;HAS_CONTROL or \	


	;--- internal --------------------
	EXC_LEFT		equ ALIGN_LEFT
	EXC_TOP			equ ALIGN_TOP
	EXC_RIGHT		equ ALIGN_RIGHT
	EXC_BOTTOM	equ ALIGN_BOTTOM
	EXC_CLIENT	equ ALIGN_CLIENT

	EXC_ALL	equ \
		EXC_LEFT or \
		EXC_TOP or \
		EXC_RIGHT or \
		EXC_BOTTOM or \
		EXC_CLIENT


	;--- internal --------------------
	PSIDE	equ ALIGN_LEFT \
			or ALIGN_TOP

	FSIDE	equ ALIGN_RIGHT \
			or ALIGN_BOTTOM

	ALIGN_V	equ ALIGN_LEFT \
			or ALIGN_RIGHT

	ALIGN_H	equ ALIGN_TOP \
			or ALIGN_BOTTOM

	FLOAT_STYLE	equ \
		WS_VISIBLE or \
		WS_POPUP or \
		WS_DLGFRAME or \
		WS_THICKFRAME or \
		WS_CAPTION or \
		WS_SYSMENU

	CHILD_STYLE	equ \
		WS_VISIBLE or \
		WS_CHILD ;or WS_CLIPCHILDREN or WS_CLIPSIBLINGS ;or WS_OVERLAPPED;or WS_CLIPSIBLINGS ;or WS_DLGFRAME ;or WS_CAPTION ;\
			; or WS_THICKFRAME; WS_BORDER or 

	;----- themes -------------

	define WP_CAPTION          1
	define WP_CLOSEBUTTON      18
	define WP_SMALLCLOSEBUTTON 19
	define WP_HELPBUTTON       23


; WINDOW CAPTION / SMALLCAPTION state */
	define CS_ACTIVE   1
	define CS_INACTIVE 2
	define CS_DISABLED 3


;/* WINDOW CLOSEBUTTON / SMALLCLOSEBUTTON / MDICLOSEBUTTON state */
	define CBS_NORMAL   1
	define CBS_HOT      2
	define CBS_PUSHED   3
	define CBS_DISABLED 4

;/* WINDOW HELPBUTTON / MDIHELPBUTTON state */
	define HBS_NORMAL   1
	define HBS_HOT      2
	define HBS_PUSHED   3
	define HBS_DISABLED 4


;/* REBAR parts */
	define RP_GRIPPER     1
	define RP_GRIPPERVERT 2
	define RP_BAND        3
	define RP_CHEVRON     4
	define RP_CHEVRONVERT 5

;/* REBAR CHEVRON states */
	define CHEVS_NORMAL  1
	define CHEVS_HOT     2
	define CHEVS_PRESSED 3
