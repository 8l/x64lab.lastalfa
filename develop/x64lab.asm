  
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

   
	define RAWMOD x64lab
	define VERBOSE FALSE      
	define DEBUG FALSE  
	define UNICODE TRUE
	define TITLE "x64lab"

	define MAINCLASS X64LAB
	include "version.inc"

	define COPYRIGHT "Copyright (c) Marc Rainer Kranz 2009-2012"
	define NOTE "All rights reserved"
	define REMOTE "sites.google.com/site/x64lab"

	include 'macro/struct.inc'
	include 'macro/import64.inc'
	include 'macro/export.inc'
	include 'macro/resource.inc'

	struc TCHAR [val] { 
		common 
		match any, val \{ 
			. du val \}
   match , val \{ 
			. du ? \}
	}

	macro @sizea16 argstruc {
		sizea16.#argstruc = \
		(sizeof.#argstruc + 15) and (-16)
	}

	include 'equates/kernel64.inc'
	include 'equates/user64.inc'
	include 'equates/gdi64.inc'
	include "equates\comctl64.inc"
	include 'equates/comdlg64.inc'
	include 'equates/shell64.inc'
	include 'equates/nls.inc'

	include "ide\main.asm"  
