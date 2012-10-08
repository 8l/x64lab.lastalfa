  
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

section '.data' data readable writeable
	curDir	dq sizeof.DIR
	dirHash	dq 400h*8
	envHash	dq 80h*8
	extHash dq 100h*8
	
	pConf		dq sizeof.CONFIG
	pCons 	dq sizeof.CONS
	pMp			dq sizeof.MPURP
	pIo			dq sizeof.IODLG * 5
	pHu			dq sizeof.HU
	pEdit		dq sizeof.EDIT
	pKdlg		dq sizeof.KEYDLG
	pTime		dq sizeof.SYSTIME
	pKeya		dq (MI_OTHER-MNU_X64LAB) * sizeof.KEYA
	NUM_ITEMS = ($-curDir)/8

	pOmni		dq 0
	hSciDll	dq 0
	hDocker	dq 0

	pTopDevT	dq 0
	 .dsize		dd 0
	 .items		dd 0

	pExtClass	dq 0

	hTree			dq 0
	hRootWsp	dq 0
	hDocs			dq 0
	pLabfWsp	dq 0

	hInst				dq 0
	hAccel			dq 0
	hMain				dq 0
	hMnuMain		dq 0
	hlaSysList	dq 0
	hsmSysList	dq 0
	hMnuFont		dq 0
	pTopStr	dq 0
	pTopExt	dq 0
	hBmpIml	dq 0

	appDir		dq 0
	backDir		dq 0
	confDir		dq 0
	;logDir		dq 0
	;mountDir	dq 0
	helpDir		dq 0
	plugDir		dq 0
	projDir		dq 0
	templDir	dq 0
	tmpDir		dq 0
	toolDir		dq 0
  DEF_DIRS	= ($-appDir)/8

	match n,\`MAINCLASS {	uzClass	du n,0 }
	match =TRUE,DEBUG {
		uzTitle du TITLE," (DEBUG) "
	}
	match =FALSE,DEBUG {
		uzTitle du TITLE," v. "
	}
	match v,VERSION {
    uzVers du `v,0 }

		szCharExt 	db "_999999",0

		rexpSOL1	db "^.*\S" 	;--- comment line SOL
		rexpSOL2a	db "^\(\s*"	;--- follow needle for SOL+patt
		rexpSOL2b	db "\)\(.*\)"
		rexpTAG2	db "\2",0
		szDefLang	db "en-US",0
		szParam		db "param",0

		align 2
		tmMnuSize	SIZE 6,28
		uzExtName		du "ext",0
		uzBackName	du "backup",0
		uzAccelName du "accel",0
		uzConfName	du "config",0
		uzLogName   du "log",0
		uzHelpName	du "help",0
		uzMountName	du "mount",0
		uzPlugName	du "plugin",0
		uzLangName	du "lang",0
		uzProjName	du "project",0
		uzTemplName du "template",0
		uzTmpName	  du "tmp",0
		uzToolName 	du "tool",0
		uzDevTName	du "devtool",0
		uzMenuName	du "menu",0
		uzExplore		du "explore",0
		uzDocking		du "docking",0
		uzDefLang		du "en-US",0
		

		uzDefault  du "default"		;<--- follows
		uzLabExt   du "."
		uzAppName  du TITLE,0
		uzUtf8Ext  du ".utf8",0
		uzBinExt   du ".bin",0
		uzCfgExt   du ".cfg",0
		uzPngExt   du ".png",0
		uzEmfExt   du ".emf",0
		uzExeExt   du ".exe",0
		uzSciExt   du ".sci",0
		uzBmpExt	 du ".bmp",0
		uzVbsExt	 du ".vbs",0
		uzCmd 		 du "cmd " ;--- 16 bytes
		uzCscript	 du "cscript",0
		uzNoLogo	 du "//nologo",0
		uzR				 du "r /e" ;--- "explore" "r /e"  ',"path"'

		uzTreeClass	du "SysTreeView32",0
		uzLViewClass	du "SysListView32",0
		uzCbexClass	du "ComboBoxEx32",0
		uzStbClass	du "msctls_statusbar32",0
		uzSciDll		du "Scilexer64.dll",0
		uzSciClass	du "Scintilla",0
		uzCourierN	db "Courier New",0
		
		;--- menu -----------------------------------------
		macro @mnp argname,argicon,argtysta,argflags,[args]{
			common
			align 8
				label t#argname
				label h#argname qword
				dw argname
				dw argicon
				dw argtysta
				dw argflags
			forward
			if ~args eq
				dw args
			end if
			common	
				dw 0
			}

		OWN equ MFT_OWNERDRAW
		DIF	equ MIIM_DATA or MIIM_ID or MIIM_FTYPE
		ISS equ MIIM_ID or MIIM_SUBMENU or MIIM_STRING
		RJU equ MFT_RIGHTJUSTIFY

		@mnp MP_WSPACE,	0,0,ISS,\
			MI_WS_LOAD,		9,OWN,DIF,\
			-1,\
			MI_WS_NEW,		0,OWN,DIF,\
			-1,\
			MI_WS_SAVE,		3,OWN,DIF,\
			-1,\
			MI_WS_EXIT,		7,OWN,DIF

		@mnp MP_FILE,		0,0,ISS,\
			MI_FI_OPEN,		4,OWN,DIF,\
			MI_FI_IMP,		6,OWN,DIF,\
			-1,\
			MI_FI_NEWB,		0,OWN,DIF,\
			MI_FI_NEWF,		1,OWN,DIF,\
			-1,\
			MI_FI_SAVE,		2,OWN,DIF,\
			-1,\
			MI_FI_CLOSE,	5,OWN,DIF

		@mnp MP_EDIT,		0,0,ISS,\
			MP_WSPACE,		1,MFS_DISABLED,MIIM_STATE or MIIM_STRING,\
			MI_ED_LNK,		8,OWN,DIF,\
			MI_ED_REMITEM,0,OWN,DIF,\
			-1,\
			UZ_EDIT_PANE,1,MFS_DISABLED,MIIM_STATE or MIIM_STRING,\
			MI_ED_RELSCICLS,	0,OWN,DIF
			;--- MI_ED_REM,7,OWN,DIF

			@mnp MP_SCI,		0,OWN,DIF or MIIM_SUBMENU,\
				MI_SCI_COMML,	0,OWN,DIF,\
				MI_SCI_UNCOMML,	0,OWN,DIF
				;	MI_SCI_COMMB,	0,OWN,DIF,\
				;	MI_SCI_UNCOMMB,	0,OWN,DIF
			
		@mnp MP_CONF,		0,0,ISS,\
			MI_CONF_KEY,	0,OWN,DIF,\
				UZ_MPWIN,		1,MFS_DISABLED,MIIM_STATE or MIIM_STRING
	
		@mnp MP_LANG,	0,OWN,DIF or MIIM_SUBMENU

			@mnp MP_DEVT,		11,OWN,DIF or MIIM_SUBMENU,\
				MI_DEVT_ADD,	10,OWN,DIF,\
				MI_DEVT_REM,	12,OWN,DIF,\
				-1,\
				MI_DEVT_ADDG,	0,OWN,DIF,\
				MI_DEVT_REMG,	0,OWN,DIF,\
				-1,\
				MI_DEVT_MAN,	0,OWN,DIF,\
				MI_DEVT_REL,	0,OWN,DIF

		@mnp MP_UPD,		0,0,ISS,\
			MI_UPD_LANG,	0,OWN,DIF

		@mnp MP_PATH,		0,RJU,ISS or MIIM_FTYPE,\
			MI_PA_BROWSE,	0,OWN,DIF,\
			MI_PA_CONS,		0,OWN,DIF

		;	MI_PA_FIND,		18,OWN,DIF,\
		;	MI_PA_COPY,		18,OWN,DIF,\
		;	MI_PA_SETPROP,18,OWN,DIF
		
		;--- utf8 strings for config/config.utf8 items
		macro @cfg_items [argid,argval]{
		 forward
			;--- because string must be "utf-8" not ascii
			sz_#argid db argval,0
		 }

		@cfg_items\
		 wspace,"wspace",\
		 version,"version",\
		 session,"session",\
	 	 fshow,"fshow",\
		 cons,"cons",\
		 docs,"docs",\
		 prop,"prop",\
		 pos,"pos",\
		 tree,"tree",\
		 bkcol,"bkcol",\
		 language,"language",\
		 owner,"owner",\
		 cdate,"cdate",\
		 ctime,"ctime",\
		 atime,"atime"

		display "--- Size of data "
		display_decimal $-$$
		display 13,10



