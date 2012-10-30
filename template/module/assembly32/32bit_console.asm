  
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
	
	;--- 32bit_console Template
	
	format  PE console
	entry start
	include "win32a.inc"

	section ".data" data readable writeable
		_action db "Please, type a character here: ",0
		_pause db 'pause',0
		_format db 13,10,"Char is:%d,<%c>",13,10,0
		_message db 'Hello world',13,10,0

	section ".code" code readable executable
	start:
		cinvoke printf,_message
		cinvoke printf,_action
		cinvoke _getch
		cinvoke printf,_format,eax,eax
		cinvoke system,_pause
		ret

	section '.idata' import data readable

	 library MSVCRT, "MSVCRT"

	 import  MSVCRT,\
		printf, "printf",\
		_getch,"_getch",\
		system,"system"
 
 

