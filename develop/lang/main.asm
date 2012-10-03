  
  ;#-------------------------------------------------ß
  ;|          lang MPL 2.0 License                   |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä
  
  ;---------------------------------------------------
  ;--- compile it with fasm using the following guideline
  ; 1) set path to fasm, ex: path=%path%;E:\fasm
  ; 2) set variable name,ex: x64devdir=E:\x64lab\develop
  ; 3) set lang name,    ex: LANG=en-US
  ; 4) assemble it,      ex: fasm main.asm %LANG%\lang.dll
  ;---------------------------------------------------

define RAWMOD lang
define MODULE "lang"
define VERBOSE FALSE
define WORKDIR "%x64devdir%\lang"
define SHAREDDIR "%x64devdir%\shared"
define RELOCATION TRUE
define ATTACH_CODE lang.attach
define DETACH_CODE lang.detach

INC_RC		equ
INC_SDATA equ

INC_EQU equ \
	"%x64devdir%\version.inc",\
	WORKDIR#"\lang.inc",\			;--- our base definitions
	SHAREDDIR#'\art.equ',\		;--- extra definition
	"%x64devdir%\ide\x64lab.equ"	;--- ids from here

	;---  local lang.inc
	INC_DATA	equ\
		WORKDIR#"\%LANG%\data.inc"

	;--- 	our base code
	INC_CODE	equ \
		WORKDIR#"\code.asm"

INC_RES		equ 
APIIMPORT	equ 
INC_IMP		equ 
INC_STR		equ


INC_INC equ \
	SHAREDDIR#'\unicode.inc'
INC_ASM equ \
	SHAREDDIR#'\unicode.asm'
INC_FIX equ TRUE

APIEXPORT equ

APIBRIDGE equ \
	lang.get_uz,\
	lang.info_uz
	
include '%x64devdir%\shared\common.asm'
