  
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


define RAWMOD bk64
define MODULE "bk64"
define VERBOSE TRUE
define WORKDIR "%x64devdir%\plugin"
define SHAREDDIR "%x64devdir%\shared"
define RELOCATION TRUE
define ATTACH_CODE bk64.attach
define DETACH_CODE bk64.detach

INC_RC	equ
INC_SDATA equ

INC_EQU		equ	\
	WORKDIR#'\'#MODULE#'\equates.inc',\
	"%x64devdir%\version.inc",\
	SHAREDDIR#'\art.equ',\
	"%x64devdir%\macro\com_macro.inc"

INC_DATA	equ \
	SHAREDDIR#'\art.inc',\
	WORKDIR#'\'#MODULE#'\data.inc',\
	WORKDIR#'\'#MODULE#'\layer.inc',\
	SHAREDDIR#'\shobjidl.inc',\
	WORKDIR#'\'#MODULE#'\dialog.inc'
		
INC_CODE	equ \
	WORKDIR#'\'#MODULE#'\code.asm'

INC_RES		equ
	;WORKDIR#'\'#MODULE#'\splash.res'

APIIMPORT	equ
	;gdiplus,"gdiplus"

INC_IMP	equ \
	SHAREDDIR#'\importw.inc'
	;WORKDIR#'\'#MODULE#'\import.inc'

INC_INC equ 
	;WORKDIR#'\'#MODULE#'\gdip.inc'
	;WORKDIR#'\'#MODULE#'\rsrc.inc'

INC_ASM equ \
	WORKDIR#'\'#MODULE#'\inet.asm',\
	WORKDIR#'\'#MODULE#'\layer.asm',\
	WORKDIR#'\'#MODULE#'\dialog.asm'

	;WORKDIR#'\'#MODULE#'\log.asm',\
	;WORKDIR#'\'#MODULE#'\gdip.asm',\
	;WORKDIR#'\'#MODULE#'\splash.asm'

INC_FIX	equ TRUE

APIEXPORT equ

APIBRIDGE equ \
	inet.check,\
	inet.state,\
	inet.open,\
	inet.close,\
	inet.iourl,\
	inet.setopt,\
	inet.cback,\
	inet.fread,\
	inet.lsave,\
  inet.closeurl,\
  inet.query,\
	lay64.init,\
	lay64.panel,\
	lay64.release,\
	lay64.resize,\
	dlg.open,\
	bk64.listfiles

;	gdip.startup,\
;	gdip.shutdown,\
;	gdip.file2bmp,\
;	gdip.hdc2graph,\
;	gdip.delgraph,\
;	gdip.drawimgri,\
;	splash.init,\
;	splash.close,\

;	split.create,\
;	split.destroy,\
;	split.getpos,\
;	split.redraw,\
;	split.release,\
;	split.split,\
;	split.capture,\
;	split.map,\
;	log.open,\

include '%x64devdir%\shared\common.asm'
