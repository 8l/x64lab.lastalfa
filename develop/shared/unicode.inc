  
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


;--- unicode defines

UTF16LE equ 0FEFFh
UTF16BE equ 0FFFEh

HI_SUR_MIN	equ 0D800h
HI_SUR_MAX	equ 0DBFFh
LO_SUR_MIN	equ 0DC00h
LO_SUR_MAX	equ 0DFFFh

SUR_MIN		equ (HI_SUR_MIN shl 16) or LO_SUR_MIN
SUR_MAX		equ (HI_SUR_MAX shl 16) or LO_SUR_MAX

SUR_PLANESHIFT	equ 10
SUR_PLANEMASK		equ 03FFh
SUR_BASE				equ 10000h
MASKUTF8 				equ 0BFh
MARKUTF8 				equ 080h

MAX_BMP 					equ 0000FFFFh
REPLACE_CPT 			equ 0000FFFDh
MAX_UTF_SCALCPT 	equ 0010FFFFh
MAX_UTF32 				equ 7FFFFFFFh

