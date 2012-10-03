	SHGFI_ICON = $100
	SHGFI_DISPLAYNAME  = $200
	SHGFI_TYPENAME = $400
	SHGFI_ATTRIBUTES = $800
	SHGFI_ICONLOCATION = $1000
	SHGFI_EXETYPE = $2000
	SHGFI_SYSICONINDEX = $4000
	SHGFI_LINKOVERLAY = $8000
	SHGFI_SELECTED = $10000
	SHGFI_ATTR_SPECIFIED = $20000
	SHGFI_LARGEICON = 0
	SHGFI_SMALLICON = 1
	SHGFI_OPENICON = 2
	SHGFI_SHELLICONSIZE = 4
	SHGFI_PIDL = 8
	SHGFI_USEFILEATTRIBUTES = $10
	SHGFI_ADDOVERLAYS = $20
	SHGFI_OVERLAYINDEX = $40

	struct SHFILEINFOW
		hIcon dq ?
		iIcon dd ?
		dwAttributes dd ?
		szDisplayName du MAX_PATH dup(?)
		szTypeName 		du 80 dup(?)
	ends
	@sizea16 SHFILEINFOW

	SE_ERR_FNF = 2
	SE_ERR_PNF = 3
	SE_ERR_ACCESSDENIED = 5
	SE_ERR_OOM = 8
	SE_ERR_DLLNOTFOUND = 32
	SE_ERR_SHARE = 26
	SE_ERR_ASSOCINCOMPLETE	= 27
	SE_ERR_DDETIMEOUT = 28
	SE_ERR_DDEFAIL = 29
	SE_ERR_DDEBUSY = 30
	SE_ERR_NOASSOC = 31

	SEE_MASK_CLASSNAME = 1
	SEE_MASK_CLASSKEY = 3
	SEE_MASK_IDLIST = 4
	SEE_MASK_INVOKEIDLIST = $c
	SEE_MASK_ICON = $10
	SEE_MASK_HOTKEY = $20
	SEE_MASK_NOCLOSEPROCESS = $40
	SEE_MASK_CONNECTNETDRV = $80
	SEE_MASK_FLAG_DDEWAIT = $100
	SEE_MASK_NOASYNC = 0x00000100
	SEE_MASK_DOENVSUBST = $200
	SEE_MASK_FLAG_NO_UI = $400
	SEE_MASK_UNICODE = $4000
	SEE_MASK_NO_CONSOLE = $8000
	SEE_MASK_ASYNCOK = $100000
	SEE_MASK_HMONITOR = $200000
	SEE_MASK_NOZONECHECKS = $800000
	SEE_MASK_NOQUERYCLASSSTORE = $1000000
	SEE_MASK_WAITFORINPUTIDLE = $2000000
	SEE_MASK_FLAG_LOG_USAGE = $4000000


	struct SHELLEXECUTEINFOW
		cbSize dd ?
		fMask dd ?
		hwnd dq ?
		lpVerb dq ?
		lpFile dq ?
		lpParameters dq ?
		lpDirectory dq ?
		nShow dd ?,?
		hInstApp dq ?
		lpIDList dq ?
		lpClass dq ?
		hkeyClass dq ?
		dwHotKey dd ?,?
		union
			hIcon dq ?
			hMonitor dq ?
		ends
		hProcess dq ?
	ends



;---------------------------------------
; SHELL32.DLL structures and constants

struct NOTIFYICONDATA
  cbSize	   dd ?
		   dd ?
  hWnd		   dq ?
  uID		   dd ?
  uFlags	   dd ?
  uCallbackMessage dd ?
		   dd ?
  hIcon 	   dq ?
  szTip 	   TCHAR 64 dup (?)
ends

struct NOTIFYICONDATAA
  cbSize	   dd ?
		   dd ?
  hWnd		   dq ?
  uID		   dd ?
  uFlags	   dd ?
  uCallbackMessage dd ?
		   dd ?
  hIcon 	   dq ?
  szTip 	   db 64 dup (?)
ends

struct NOTIFYICONDATAW
  cbSize	   dd ?
		   dd ?
  hWnd		   dq ?
  uID		   dd ?
  uFlags	   dd ?
  uCallbackMessage dd ?
		   dd ?
  hIcon 	   dq ?
  szTip 	   du 64 dup (?)
ends

; Taskbar icon messages

NIM_ADD        = 0
NIM_MODIFY     = 1
NIM_DELETE     = 2
NIM_SETFOCUS   = 3
NIM_SETVERSION = 4

; Taskbar icon flags

NIF_MESSAGE    = 01h
NIF_ICON       = 02h
NIF_TIP        = 04h
NIF_STATE      = 08h
NIF_INFO       = 10h
NIF_GUID       = 20h
