  
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



; Win64 programming headers (WideChar)

include 'macro/struct.inc'
include 'macro/import64.inc'
include 'macro/export.inc'
include 'macro/resource.inc'

struc TCHAR [val] { common match any, val \{ . du val \}
			   match , val \{ . du ? \} }

include 'equates/kernel64.inc'
include 'equates/user64.inc'
include 'equates/gdi32.inc'
include 'equates/comctl64.inc'
include 'equates/comdlg64.inc'
include 'equates/shell64.inc'

