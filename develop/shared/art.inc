  
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


	align 2
	@using art.cout2XX, art.cout2XU
		uzFrm2XX	du "%llX %llX",13,10,0
		uzFrm2XU	du "%llX %ls",13,10,0
	@endusing


	;-------------- function .get_pathpart
	@using art.get_partpath
		PATH_NULL				equ 0
		PATH_PATH				equ 1
		PATH_REL 				equ 2
		PATH_SERVNAME 	equ 4
		PATH_LONG		 		equ 8
		PATH_DRIVE  		equ 10h
		PATH_FILE				equ 20h
	@endusing

	;struct BSTORE
	;	pmem		dq 0
	;	pfirst	dq 0
	;	pfreed	dq 0
	;	cpages	dw 0
	;	rpages	dw 0
	;	bsize		dw 0
	;	flags		dw 0
	;ends

	@using art.catstrw
		align 8
		uz2Greater	du ">> ",0
		uzMask			du "*.*",0
		uzUpDir			du "..\",0
		uzSpace			du " ",0
		uzColon			du ":",0
		uzOPar			du "[",0
		uzCPar			du "]",0
		uzFisheye		db 0C9h,25h,0,0
		uzBlackLxPTri	db 0C0h,25h,0,0
		uzTab				du 9,0
		uzNull			du 0,0
		uzSlash			du "\",0
		uzProtoSep	du ":/"
		uzIslash		du "/",0
		uzDot				du ".",0
		uzScore			du "_",0
		uzAsterisk	du "*",0
		uzMinus			du "-",0
		uzPlus			du "+",0
		uzPathSep		du ";",0
		uzSQuote    du "'",0
		uzSmallD		du "d",0
		uzBigM			du "M",0
		uzSmallM		du "m",0
		uzSmallY		du "y",0
		uzSmallS		du "s",0
		uzBigH			du "H",0
		uzComma			du ",",0
		uzNoPath		du 0,0
		uzDQuote		du '"',0
		uzDll				du ".dll",0
		uzHttpProto	du "http://",0
		uzComment 	equ szPathSep
	@endusing

	@using art.time2name
		szTime2Name			db 32 dup (0)
		szFrmTime2Name	db "%.2d%.2d%.2d_%.2d%.2d%.2d_%.4d",0
	@endusing



