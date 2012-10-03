  
  ;#-------------------------------------------------ß
  ;|          top64  MPL 2.0 License                 |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

define RAWMOD top64
define MODULE "top64"
define VERBOSE TRUE
define WORKDIR "%x64devdir%\plugin"
define SHAREDDIR "%x64devdir%\shared"
define RELOCATION TRUE
define ATTACH_CODE
define DETACH_CODE

INC_RC		equ
INC_SDATA equ
INC_DATA	equ
INC_CODE	equ WORKDIR#'\'#MODULE#'\code.asm'
INC_RES		equ 
APIIMPORT			equ 

INC_IMP		equ SHAREDDIR#'\importw.inc'
INC_FIX	equ TRUE

INC_EQU equ  \
	WORKDIR#'\'#MODULE#'\equates.inc',\
	SHAREDDIR#'\art.equ',\
	"%x64devdir%\version.inc"

INC_INC equ SHAREDDIR#'\unicode.inc'
INC_ASM equ SHAREDDIR#'\unicode.asm'

APIEXPORT equ

APIBRIDGE equ \
	top64.parse,\
	top64.free,\
	top64.locate

;	top64.getnum,\
;	top64.locate,\
;	top64.getstr,\
;	top64.next,\
;	top64.rawnext,\


include '%x64devdir%\shared\common.asm'
