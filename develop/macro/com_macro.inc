  
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



	struc GUID def {
	;--- example:
	;--- iFileOpenDialog GUID DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7
  match d1-d2-d3-d4-d5, def  \{
	 .Data1 dd 0x\#d1
	 .Data2 dw 0x\#d2
	 .Data3 dw 0x\#d3
	 .Data4 db \
			0x\#d4 shr 8,\
			0x\#d4 and 0FFh
	 .Data5 db \
			0x\#d5 shr 40,\
			0x\#d5 shr 32 and 0FFh,\
			0x\#d5 shr 24 and 0FFh,\
			0x\#d5 shr 16 and 0FFh,\
			0x\#d5 shr 8 and 0FFh,\
			0x\#d5 and 0FFh
   \}
 } 


	;--- set com pointer at address
	;--- @comptr .pUnk,rsp+8,iUnknown
	macro @comptr [name,atarg,arginter]{
		forward
		local ..tmp
		virtual at atarg
		..tmp arginter
		name equ ..tmp
		end virtual
	}	

	;--- set static com pointer 
	;--- @comsta pUnk,iUnknown
	macro @comsta argcall,arginter {
		align 8
		virtual at $
			argcall arginter
		end virtual
		dq 0
	}

	;--- call com method 
	;--- .pUnk->QueryInterface
	macro @comcall argmeth{
		match p->meth,argmeth\{
			mov rcx,[p]
			mov rax,[rcx]
			sub rsp,20h
			call [rax+p\#.\#meth-p]
			add rsp,20h
		\} 
	}
