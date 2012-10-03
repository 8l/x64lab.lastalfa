  
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



struct SPLASH_STRUCT
	hThread	dq 0
	hLib		dq 0
	hSplash	dq 0
	hOp 		dq 0
	hProgr 	dq 0
	union
		pFile		dq 0	;--- in
		hEMF		dq 0	;--- out
	ends
	hSurf		dq 0
					dq 0
ends


struct LAYS
	union
		hwnd	dq 0	;--- child
		hMain	dq 0	;--- main
	ends
	union
		hControl	dq 0	;--- child
		pLast			dq 0	;--- main
	ends
	union
		pNext		dq 0 	;--- child
		pChild	dq 0	;--- main
	ends
	union
		pShare	dq 0	;--- child
		paramB	dq 0	;--- child by creation,sharing prev
	ends

	type		db 0	;--- child
	align		db 0	;--- child
	flags		db 0	;--- child ACTIVE/FSPLIT

	union
		id			db 0	;--- child
		ord			db 0	;--- main
	ends
						dw 0
						dw 0
	hInst			dq 0
						dq 0

	union
		pLaym			dq 0	;--- child -> main layer
		paramA		dq 0	;--- main MDICLIENT WIN
	ends

	wrc		RECT
	hrc		RECT	;--- control rc child
	drc		RECT	;--- dest rect main
	crc		RECT	;--- client rc
	grc		RECT	;--- grip rc
ends

	CHILD_STYLE	equ \
		WS_OVERLAPPED or \
		WS_VISIBLE or \
		WS_CHILD or \
		WS_CLIPCHILDREN or \
		WS_CLIPSIBLINGS
	

	;--- in DL flags ------------
	ALIGN_LEFT		equ 0000'0001b
	ALIGN_TOP			equ 0000'0010b
	ALIGN_RIGHT		equ 0000'0100b
	ALIGN_BOTTOM	equ 0000'1000b
	ALIGN_CLIENT	equ 0001'0000b

	HAS_CONTROL		equ 0010'0000b
	SHARE_PANEL		equ 0100'0000b
	SHARE_FIRST		equ 1000'0000b

	;--- flags 
	FLAYC_SPLIT		equ 1
	FLAYC_MOVER		equ 2
	FLAYC_ACTIVE	equ 4

	FLAYM_MDI			equ 1

	CX_GRIP	equ 5
	CY_GRIP	equ 5

	CX_MIN	equ 40
	CY_MIN	equ 40

	VGRIP	equ \
		ALIGN_LEFT \
		or ALIGN_RIGHT

	HGRIP equ \
		ALIGN_TOP \
		or ALIGN_BOTTOM


;display_decimal sizeof.SPLITINFO


AW_ACTIVATE = 0x00020000			;Activates the window. Do not use this value with AW_HIDE.
AW_BLEND = 0x00080000 				;Uses a fade effect. This flag can be used only if hwnd is a top-level window.
AW_CENTER = 0x00000010				;Makes the window appear to collapse inward if AW_HIDE is used or expand outward if the AW_HIDE is not used. The various direction flags have no effect.
AW_HIDE = 0x00010000					;Hides the window. By default, the window is shown.
AW_HOR_POSITIVE = 0x00000001	;Animates the window from left to right. This flag can be used with roll or slide animation. It is ignored when used with AW_CENTER or AW_BLEND.
AW_HOR_NEGATIVE = 0x00000002	;Animates the window from right to left. This flag can be used with roll or slide animation. It is ignored when used with AW_CENTER or AW_BLEND.
AW_SLIDE = 0x00040000					;Uses slide animation. By default, roll animation is used. This flag is ignored when used with AW_CENTER.
AW_VER_POSITIVE = 0x00000004 	;Animates the window from top to bottom. This flag can be used with roll or slide animation. It is ignored when used with AW_CENTER or AW_BLEND.
AW_VER_NEGATIVE  = 0x00000008 ;Animates the window from bottom to top. This flag can be used with roll or slide animation. It is ignored when used with AW_CENTER or AW_BLEND. 


define INTERNET_CONNECTION_CONFIGURED 0x40 ; Local system has a valid connection to the Internet, but it might or might not be currently connected.
define INTERNET_CONNECTION_LAN 0x02        ; Local system uses a local area network to connect to the Internet.
define INTERNET_CONNECTION_MODEM 0x01      ; Local system uses a modem to connect to the Internet.
define INTERNET_CONNECTION_MODEM_BUSY 0x08 ; No longer used.
define INTERNET_CONNECTION_OFFLINE 0x20    ; Local system is in offline mode.
define INTERNET_CONNECTION_PROXY 0x04      ; Local system uses a proxy server to connect to the Internet.
define INTERNET_RAS_INSTALLED 0x10         ; Local system has RAS installed.

define FLAG_ICC_FORCE_CONNECTION  0x00000001
define INTERNET_FLAG_ASYNC  			0x10000000
define WININET_API_FLAG_SYNC      0x00000004
define INTERNET_FLAG_RELOAD       0x80000000 
define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000
define INTERNET_FLAG_NO_COOKIES        0x00080000
define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100

define INTERNET_OPEN_TYPE_PRECONFIG	                   0
define INTERNET_OPEN_TYPE_DIRECT                       1
define INTERNET_OPEN_TYPE_PROXY                        3
define INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4

define INTERNET_FLAG_KEEP_CONNECTION   0x00400000
define INTERNET_FLAG_NO_AUTO_REDIRECT  0x00200000
define INTERNET_SERVICE_URL    0
define INTERNET_SERVICE_FTP    1
define INTERNET_SERVICE_GOPHER 2
define INTERNET_SERVICE_HTTP   3

define INTERNET_INVALID_PORT_NUMBER    0
define INTERNET_DEFAULT_FTP_PORT       21
define INTERNET_DEFAULT_GOPHER_PORT    70
define INTERNET_DEFAULT_HTTP_PORT      80
define INTERNET_DEFAULT_HTTPS_PORT     443
define INTERNET_DEFAULT_SOCKS_PORT     1080

define HTTP_QUERY_CONTENT_LENGTH     5
define HTTP_QUERY_CONTENT_LOCATION  51
define HTTP_QUERY_CONTENT_MD5       52
define HTTP_QUERY_RAW_HEADERS       21
define HTTP_QUERY_RAW_HEADERS_CRLF  22
define HTTP_QUERY_COOKIE            44
define HTTP_QUERY_SET_COOKIE        43
define HTTP_QUERY_CUSTOM         65535
define HTTP_QUERY_LAST_MODIFIED     11

define HTTP_QUERY_FLAG_NUMBER    0x20000000 ;   Returns the data as a 32-bit number for headers whose value is a number, such as the status code.
define HTTP_QUERY_FLAG_REQUEST_HEADERS  0x80000000 ;  Queries request headers only.
define HTTP_QUERY_FLAG_SYSTEMTIME  0x40000000

define INTERNET_RFC1123_FORMAT       0
define INTERNET_RFC1123_BUFSIZE     30

define INTERNET_STATUS_RESOLVING_NAME          10
define INTERNET_STATUS_NAME_RESOLVED           11
define INTERNET_STATUS_CONNECTING_TO_SERVER    20
define INTERNET_STATUS_CONNECTED_TO_SERVER     21
define INTERNET_STATUS_SENDING_REQUEST         30
define INTERNET_STATUS_REQUEST_SENT            31
define INTERNET_STATUS_RECEIVING_RESPONSE      40
define INTERNET_STATUS_RESPONSE_RECEIVED       41
define INTERNET_STATUS_CTL_RESPONSE_RECEIVED   42
define INTERNET_STATUS_PREFETCH                43
define INTERNET_STATUS_CLOSING_CONNECTION      50
define INTERNET_STATUS_CONNECTION_CLOSED       51
define INTERNET_STATUS_HANDLE_CREATED          60
define INTERNET_STATUS_HANDLE_CLOSING          70
define INTERNET_STATUS_DETECTING_PROXY         80
define INTERNET_STATUS_REQUEST_COMPLETE        100
define INTERNET_STATUS_REDIRECT                110
define INTERNET_STATUS_INTERMEDIATE_RESPONSE   120
define INTERNET_STATUS_USER_INPUT_REQUIRED     140
define INTERNET_STATUS_STATE_CHANGE            200        

define INTERNET_STATE_CONNECTED                0x00000001  
define INTERNET_STATE_DISCONNECTED             0x00000002  
define INTERNET_STATE_DISCONNECTED_BY_USER     0x00000010  
define INTERNET_STATE_IDLE                     0x00000100  
define INTERNET_STATE_BUSY                     0x00000200              
define INTERNET_INVALID_STATUS_CALLBACK        -1

	struct NETINFO
		hNet	dq 0    ;--- NOTE shared offset!!!!
		state db 0
					db 0
					db 0
					db 0
		type 	dd 0
		flags	dd 0
					dd 0
		pAgent dq 0
	ends

	struct NETFILEINFO
		hUrl		dq 0			;--- NOTE shared offset!!!!
		fStop		db 0			;--- continue operation in a thread
		fRedir	db 0
		chunk		dw 0			;--- read/write chunk
		queries		dd 0
		flags			dd 0
		tstamp		dd 0
		rbytes		dq 0		;--- received bytes
		tbytes		dq 0
		fsize			dq 0		;--- file size
		hThread		dq 0
		pGui			dq 0		;--- pointer to GUI stuff
		param			dq 0		;--- eventual param
		pUrl			dq 0		;--- evantual redirection
		pProto		dq 0
		pHost			dq 0
		pIpath		dq 0
		pIfile		dq 0
		pIargs		dq 0
		pLpath		dq 0
		pLfile		dq 0
		cbnotify	dq 0
		qbuf			dq 0
		pMem			dq 0    ;--- file stored in mem
		qidx			dq 0
		qlen			dq 0
	ends


NFI_USELMEM	 equ 1
;--- user cback ---------
NFI_LFILE_OK equ 1
NFI_CLEN_OK	 equ 2
NFI_RBYTES	 equ 3

