  
  ;#-------------------------------------------------ß
  ;|          dock64  MPL 2.0 License                |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

startdata:
	define MAINCLASS "Dock64"
	timestamp dd %t
	uzThmWinClass 	du "WINDOW",0
	uzThmRebarClass du "REBAR",0
	uzShadowClass		du "x64Shad",0
	uzPanelClass		du "x64Pane",0
	uzStatic				du "STATIC",0
	uzClass	du MAINCLASS,0
	copyright	du "Copyright (c) Marc Rainer Kranz 2009-2011",0

	match =TRUE,DEBUG {
		uzTitle du MAINCLASS," (DEBUG) ",0 }
	match =FALSE,DEBUG {
		uzTitle du MAINCLASS," v. "
		match v,VERSION \{
      szVersion du \`v,0 \}
	}

	align 8
	atom_panel	dw 0
	atom_shadow	dw 0
	cx_edge			db 0
	cy_edge			db 0
	cx_fxframe	db 0
	cy_fxframe	db 0
	cy_caption	db 0
	cy_border		db 0
	cx_border		db 0
	cx_smicon		db 0
	cy_smicon		db 0
	cx_smbsize	db 0
	cy_smbsize	db 0
	cx_wmin			db 0
	cy_wmin			db 0
	align 8

	hVCurs	dq 0
	hHCurs	dq 0
	hDCurs	dq 0

	hThmWin				dq 0
	hInstance			dq 0
	hBrPanel			dq 0
	hBrActCapt		dq 0
	hColActText		dq 0
	hBrInactCapt	dq 0
	hColInactText	dq 0


