  
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



struc db [data]	{
	common
	. db data
	.size = $ - .
}

struc du [data]	{
	common
	. du data
	.size = $ - .
	.cpts = ($ - . )/2
}

;--- align into struc at 0/reg
macro @salign val,fill {
	times ((($-$$+val-1) and (-val))- ($-$$) ) db fill
}

	macro @sizea16 argstruc {
		sizea16.#argstruc = \
		(sizeof.#argstruc + 15) and (-16)
	}


macro @reg2rect argrect,argreg {
	pxor xmm1,xmm1
	movq xmm0,argreg
	punpcklwd xmm0,xmm1
	movdqu dqword[argrect],xmm0
}

macro @rect2reg argreg,argrect {
	;--- all SSE2
	movdqu xmm0,dqword[argrect]
	pcmpeqw xmm1,xmm1
	psrld xmm1,17
	pand xmm0,xmm1
	packssdw xmm0,xmm0
	movq argreg,xmm0
	;---	movdqu xmm0,dqword[argrect]
	;---	packusdw xmm0,xmm0
	;---	movq argreg,xmm0
}



macro @frame arg{
		;---
	;--- RET RAX pointer to stack
	;--- RET RCX size
	local ..tmp1,..tmp2
	mov rax,arg
	and rsp,-16
	@nearest 16,rax
	mov r8,1000h

	mov rcx,rax
	mov r9,rax
	xor edx,edx
	and eax,0FFFh
	shr ecx,12
	jz	..tmp2
@@:
	sub rsp,r8
	mov [rsp],rdx
	dec ecx
	jnz	@b

..tmp2:
	test eax,eax
	jz	..tmp1
	sub rsp,rax
	mov [rsp],rdx

..tmp1:
	mov rcx,r9
	mov rax,rsp
	}


macro @wpro argptf,arguses {
	count@wpro = 28h
	count@regs equ 0
	in@wpro equ

	irps items,arguses\{
		match any,in@wpro\\{
			in@wpro equ in@wpro,items argptf+20h+count@regs
		\\}
		match ,in@wpro \\{
			in@wpro equ items argptf+20h+count@regs
		\\}
		count@wpro = count@wpro+8
		count@regs equ count@regs+8
	\}

	count@wpro = count@wpro or 8
	;display_hex 8,count@wpro
	mov rax,argptf
	sub rsp,count@wpro
	mov argptf,rsp

	.s_ptf	equ argptf+count@wpro-8
	.hwnd 	equ argptf+count@wpro+8
	.msg		equ argptf+count@wpro+10h
	.wparam equ argptf+count@wpro+18h
	.lparam equ argptf+count@wpro+20h

	mov [.s_ptf],rax
	mov [.hwnd],rcx
	mov [.msg],rdx
	mov [.wparam],r8
	mov [.lparam],r9
	
;	mov [rbp+count@wpro-8],rax
;	mov [rbp+count@wpro+8],rcx
;	mov [rbp+count@wpro+10h],rdx
;	mov [rbp+count@wpro+18h],r8
;	mov [rbp+count@wpro+20h],r9

	match items,in@wpro\{
		irp i,items\\{
		match n r,i\\\{
			mov [r],n
		\\\}
		\\}
	\}

	macro @@wepi \{
		match items,in@wpro\\{
			irp i,items\\\{
			match n r,i\\\\{
				mov n,[r]
			\\\\}
			\\\}
		\\}
	lea rsp,[.s_ptf]
	pop rbp
	ret 0
	\}
}

macro @wepi{
	@@wepi
	purge @@wepi
	restore count@wpro
	restore count@regs
	restore .s_ptf
	restore .hwnd
	restore .msg
	restore .wparam
	restore .lparam
}


include "unsupported.inc"

macro @p64 argname,[argparas] {
	list@uses equ
	list@nhomes equ
	list@rhomes equ
	list@paras equ
	list@locals equ

	reg@locals	equ
	count@uses equ 0
	count@homes equ 0
	count@paras equ 0

	size@stack equ 0
	size@paras equ 0	
	size@locals equ 0
	offs@home	equ 8

	has@uses		equ 0
	has@homes		equ 0
	has@locals	equ 0

	name@proc equ argname

	match =0 name list,has@uses argname \{
		has@uses	equ 1
		name@proc equ \name	
	\}

	common
	label name@proc
	;push rbp

	define status 0
	match =0 =1 name list =* argl,status has@uses argname \{
		reg@locals equ argl
		;push argl
		list@uses equ argl
		size@stack equ size@stack + 8
		irps args,list \\{
			;display \\`args
			;\\reverse push args
			list@uses equ list@uses args
			size@stack equ size@stack + 8
		\\}
		define status 1
	\}

	match =0 =1 name list,status has@uses argname \{
		irps args,list \\{
			list@uses equ list@uses args
			;\\reverse push args
			size@stack equ size@stack + 8
		\\}
		define status 1
	\}

	forward
	match argparam,argparas\{
		define status 0
		match =0 n r,status argparam\\{
			has@homes equ 1
			list@nhomes equ list@nhomes n
			list@rhomes equ list@rhomes r
;			push r
			n	equ rbp-offs@home
			offs@home equ offs@home - 8
			count@homes equ count@homes + 1
			;display \\`n	
			define status 1
		\\}
		match =0,status\\{
			;display \\`argparam
			has@paras equ 1
			size@paras equ size@paras + 8
			list@paras equ list@paras argparam
			argparam equ rbp + 8 + size@stack + size@paras
			count@paras equ count@paras + 1
			define status 1
		\\}
	\}
		common
		push rbp
		
		match =1 list@uses,has@uses list@uses \{
			irps reg,list@uses \\{
				\\forward push reg 
				\\}
			\}
		mov rbp,rsp
		match =1 list@rhomes,has@homes list@rhomes \{
			irps reg,list@rhomes \\{
				\\forward push reg 
				\\}
			\}
		and rsp,-16
	
		macro @locals [arglocals]\{
			\common
			match =0,status reg@locals \\{
				display ";---",13,10
				display ";- WARNING! proc "," has no register",13,10
				display ";- for local variables on stack!",13,10
				display ";- example.: @uses rbx rdi *r10",13,10
				display ";-",13,10
				err
			\\}
			\forward
			match n s,arglocals \\{
			define status 0
				match =0 =grows,status n \\\{
					define status 1
					size@locals equ size@locals + s
				\\\}

				match =0 [slen],status s\\\{
					size@locals equ (size@locals + slen + 15 ) and - 16
					;display_decimal size@locals
					;display 13,10
					n	equ reg@locals - (size@locals)
					define status 1
				\\\}

				match =0,status \\\{
					has@locals equ 1
					define fstruct 0
					list@locals equ list@locals n
						match =0 =dqword,fstruct s\\\\{
							;display \\\\`n
							size@locals equ size@locals + 16
							define fstruct 1
						\\\\}
						match =0 =qword,fstruct s\\\\{
							;display \\\\`n
							size@locals equ size@locals + 8
							define fstruct 1
						\\\\}
						match =0 =dword,fstruct s \\\\{
							;display \\\\`n
							size@locals equ size@locals + 4
							define fstruct 1
						\\\\}

						match =0,fstruct \\\\{
							;display \\\\`n
;				display "- before struct -> "
;				display_decimal size@locals
;				display 13,10

;				display "- aligned 4 -> "
;;				size@locals equ size@locals + 3
;;				size@locals equ size@locals and -4
;				display_decimal size@locals
;				display 13,10

;				display "- original structsize -> "
;				display_decimal sizeof.\\\\#s
;				display 13,10

;				display "- aligned 8 structsize -> "
;				ali equ (sizeof.\\\\#s + 7) and -8
				size@locals equ (size@locals + sizeof.\\\\#s + 7) and -8
;				display_decimal ali
;				display 13,10
;							size@locals equ size@locals + sizeof.\\\\#s
;							size@locals equ size@locals + 7
;							size@locals equ size@locals and -8
							define fstruct 1
						\\\\}
					
					n	equ reg@locals - (size@locals)
					define status 1
				\\\}
			\\}
			\common
				mov reg@locals,rsp
				size@locals equ (size@locals + 15 ) and - 16
				sub rsp,size@locals
;				display "- final size of stack -> "
;				display_decimal size@locals
;				display 13,10	
				;and rsp,-16
		\}

	macro @e64 \{
		mov rsp,rbp
		match =1 items,has@locals list@locals \\{
			irps n,items \\\{
				restore \\\n
				;display \\\`n
			\\\}
		\\}

		match =1 items,has@homes list@nhomes \\{
			irps n,items \\\{
				restore \\\n
				;display \\\`n
			\\\}
		\\}

		match =1 items,has@paras list@paras \\{
			irps n,items \\\{
				restore \\\n
				;display \\\`n
			\\\}
		\\}

		match list@uses,list@uses \\{
			irps reg,list@uses \\\{
				\\\reverse pop reg 
				\\\}
			\\}
		pop rbp
		ret size@paras
		restore has@paras
		restore list@uses
		restore list@nhomes
		restore list@rhomes
		restore list@paras
		restore list@locals
		restore reg@locals
		restore count@uses
		restore count@homes
		restore count@paras

		restore size@stack
		restore size@paras
		restore size@locals
		restore offs@home

		restore has@uses
		restore has@homes
		restore has@locals
	\}
}


;--- usage
;--- @nearest 16,eax
;--- IN/OUT REG aligned quantity to arg
macro @nearest arg,reg {
	add reg,arg-1
	and reg,-(arg)	
}


;--- aligned complement
;--- argto is a 1-bit-position quantity
;--- e.d. 4/8/16/32...
macro @acompl argto,arg {
	neg arg
	add arg,argto
	and arg,argto-1	
}

macro @align val,fill { 
	define status 0
	match =0 =TRUE,status RELOCATION \{
		times(((rva $+val-1)and not (val-1)) - rva $) db fill
		define status 1
	\}
	match =0,status	\{
		times((($+val-1)and not (val-1)) -$) db fill
		define status 1
	\}
} 

macro @break {
	align 2
	db 0cch
	db 90h
}

macro append aList, item {
	match any,aList	\{
		aList equ aList,item
		\}
	match ,aList\{ 
		aList equ item
		\}
}

macro add_to_list argList,[value] {
 match any, argList \{	
 		argList equ argList,value
  \}
 match , argList \{	
  argList equ value
  \}
}
; 
macro display_list value {
	match items,value \{ 
		display_item items 
	\}
}

;macro @log_str strname {
;	local ..tmpstring,size@true
;	virtual at logdata + incr@du 
;		..tmpstring	du `strname,0
;		size@true = $ - ..tmpstring
;	end virtual
;	define status 0
;	
;	match =0 strname,status list@du
;	\{
;		add_to_list list@ok, uz_log_#strname du \`strname 0
;		uz_log_#strname = ..tmpstring
;		incr@du = incr@du + size@true
;		define status 1
;	\}
;	match =0,status
;	\{
;		add_to_list list@du,strname
;		define status 1
;	\}
;}

;macro @log_str strname {
;	local ..tmpstring,size@true
;	virtual at logdata + incr@du 
;		..tmpstring	du strname,0
;		size@true = $ - ..tmpstring
;	end virtual
;	define status 0
;	
;	match =0 strname,status list@du
;	\{
;		add_to_list list@ok, uz_log_#strname du strname 0
;		uz_log_#strname = ..tmpstring
;		incr@du = incr@du + size@true
;		define status 1
;	\}
;	match =0,status
;	\{
;		add_to_list list@du,strname
;		define status 1
;	\}
;}

;macro @log_explode_item [anitem] {
;	;sz_dbg_#anitem db `anitem,0
;	match a b c d,anitem	\{
;		du \`c ,0
;	\}
;}

;macro @log_explode {
; match items,list@ok	\{
;	@log_explode_item items
;	\}
;}

;macro @log_foot	 {
;;	@align 4,0
;	if incr@du > 0
;		@log_explode
;	end if
;}


;;------------------------------ on debug ----------------
;macro @onDebug argvar,argdebug,argrelease {
;	define status 0
;	match =0 =TRUE,status DEBUG	\{
;		argvar argdebug
;		define status 1
;		\}
;	match =0 =FALSE,status DEBUG \{
;		argvar argrelease
;		define status 1
;	\}
;}

;;------------------------------trace -------------------
;macro @log_trace argmod,argproc,argvar,argvalue,addrstring {
; match =TRUE,DEBUG	\{
;	local ..tmpvalue,..tmplabel,..noexec
;	define status 0
;	match =0 argreg argcond argval,status argvalue \\{
;			..tmpvalue equ argreg
;			cmp argreg,argval
;			\\j\\#argcond	 ..tmplabel
;			jmp ..noexec
;			define status 1
;	\\}
; match =0,status	\\{
;		..tmpvalue equ argvalue 
;			define status 1
;	\\}
; \}
;	@dbg_sz argmod
;	@dbg_sz argproc
;	@dbg_sz argvar

; match =TRUE,DEBUG	\{
;	..tmplabel:
;		if ~addrstring eq
;			push addrstring
;		else
;			push dbgd.szNull
;		end if
;		push dword ..tmplabel
;		push dword ..tmpvalue;argvalue
;		push sz_dbg_#argvar
;		push sz_dbg_#argproc
;		push sz_dbg_#argmod
;		call debug.format
;		call debug.outreg
;..noexec:
;	\}
;}

;macro @dbg_call argfunc,[args] {
;	reverse
;	match =TRUE,DEBUG	\{
;	if ~args eq
;			pushd args
;		end if
;	\}	
;	common
;	match =TRUE,DEBUG	\{
;		call debug#argfunc
;	\}
;}


;macro @dbg_sz strname {
;	match =TRUE,DEBUG	\{
;	@dbg_dostring strname	
;	\}
;}

;macro @dbg_dostring strname {
;	local ..tmpstring,size@true
;	virtual at foot@db + incr@db 
;		..tmpstring	db `strname,0
;		size@true = $ - ..tmpstring
;	end virtual
;	define status 0
;	
;	match =0 strname,status list@db
;	\{
;		add_to_list list@ok,sz_dbg_#strname db `strname 0
;		sz_dbg_#strname = ..tmpstring
;		incr@db = incr@db + size@true
;		define status 1
;	\}
;	match =0,status
;	\{
;		add_to_list list@db,strname
;		define status 1
;	\}
;}

;macro @dbg_explode_item [anitem] {
;	;sz_dbg_#anitem db `anitem,0
;	match a b c d,anitem	\{
;		db \`c ,0
;	\}
;}

;macro @dbg_explode {
; match items,list@ok	\{
;	@dbg_explode_item items
;	\}
;}

;macro @dbg_foot	 {
;;	@align 4,0
;	align 4
;	label foot@db
;	if incr@db > 0
;		@dbg_explode
;	end if
;}


;macro @mVIRTUALIZE reg,argName,localName,aStruct
; {
;	mov reg,argName
;	virtual at reg
;		localName aStruct	
;	end virtual
;}


macro @m2m arg1,arg2 {
	push arg2
	pop arg1
 }

macro @loword reg,arg
 {
	if arg eqtype eax
		mov reg,arg
		and reg,0FFFFh
	else
		match [name],arg
		\{
		movzx reg,word [name]
		\}
	end if
 }

macro @hiword reg,arg {
	if arg eqtype eax
		mov reg,arg
		shr reg,16
	else
		match [name],arg 	\{
		movzx reg,word [name+2]
	\}
	end if
}

	;#---------------------------------------------------ö
	;|               @xsdbm hash	(my method)            |
	;ö---------------------------------------------------ü

macro @xsdbm argname,argresult,argprime {
	common 
	local	result,char,prime,..tmp
	argresult equ 0
	if argprime eq
		prime = 6121
	else
		prime = argprime
	end if
	virtual at 0
		..tmp:
		db `argname
		result = prime
		argname#.#size = $-..tmp

		repeat $
			load char byte from % - 1
			result = (char and 0x000000FF) + \
				(result shl 6) + \
				(result shl 17) - \
				result
		end repeat
	end virtual
argresult equ (result and 0xffffffff)
}


macro @szhash [argstr]{
	result equ 0
	@xsdbm argstr,result
	HASH_#argstr equ result
	.sz_#argstr db \`argstr,0
	common
	@align 2,0
}



macro @make_version argmod,packver,argver {
	@align 8,0CCh
		@xsdbm argmod,result
		result equ (result shl 32) or %t
		;--- get_version
		;--- RET RAX hashname(HI) OR tstamp (LO)
		;--- RET RCX packvers(HI) OR version
		;--- RET RDX POPCOUNT(HI) OR CRC
		;--- RET R8,R9 0 not used
	get_version:
		mov rax,result	;48B8+HASHNAME or TSTAMP
		mov rcx,(packver shl 32) or	argver	;48B9+SETVERS or VERSION
		db 49h,0B8H		;R8
		dq 0					;--- not used
		db 49h,0B9H		;R9
		dq 0					;--- not used
		db 48h,0BAH		;RDX	;--- POPCOUNT + HASHVALUE
		dq 0
		ret 0
		nop
	;	display "---@ "
	;	display_hex 64,result
	;	display "h " ;9,"RAX -> HASHNAME(HI) TSTAMP(LO)",13,10
	;	display_hex 64,(packver shl 32) or	argver
	;	display "h ";9,"RCX -> PACKVERSION (HI) VERSION(LO)",13,10
	;	display `argmod,13,10
	;	display "---  HNAME   TSTAMP       PACKV  VERS",13,10
	}



macro @top_pack argreg,argname,arglevel {
	local ..tmp
	@xsdbm argname,..tmp
	..tmp equ (..tmp shl 8 or argname#.#size)
	..tmp equ (..tmp shl 8 or arglevel )
	..tmp equ (..tmp shl 8 or F_HAS_SSYM_BLANKS)
	..tmp equ (..tmp shl 8 or T_IS_LABEL)
	mov argreg,..tmp
}
	;#---------------------------------------------------ö
	;|               @make_hash			                     |
	;ö---------------------------------------------------ü

;macro @make_hash argname,argresult  {
;	common 
;	local	result,char,prime,tmp
;	argresult equ 0
;	prime = 01000193h
;	virtual at 0
;		tmp:
;		db `argname
;		result = 811C9DC5h	;basis
;		gsize = $-tmp
;		repeat $
;			load char byte from % - 1
;			result = prime * ((result xor (char and 0x000000FF)) and 0xffffffFF)
;		end repeat
;	end virtual
;argresult equ (result and 0xffffffff)
;}

;;----------------- MACRo for shared.asm -----------------
	macro @using [name] {
		composit equ (used name)
	forward
		composit equ composit |(used name)
	common
		if composit
		align 2
	}

	macro @endusing {
		align 2
	end if
	}


macro @accels [argflag,argkey,argcmd,argdescr]
{
 common
	count = 0
	label .num_accels
		dd 0
 forward
	db argflag
	db 0
	dw argkey
	dw argcmd
	count = count + 1
common
	store dword count at .num_accels
 forward
	du argdescr
}



macro @e_rva [funcname] {
	common
	match =TRUE,VERBOSE \{
		;display 13,10,";--------- hashing API in [",MODULE,"] ------------>",13,10
		display 13,10,"; Copy this block in your data section "
		display 13,10,"@i_rva ",MODULE
	\}
	align 4
	forward
		@xsdbm funcname,result
		dd result
	match =TRUE,VERBOSE \{
		display ",\",13,10,32,`funcname
	\}
		dd RVA funcname
	common
	match =TRUE,VERBOSE \{
		display 13,10,13,10
		;display ";--------- end hashing API function ------------>",13,10
	\}
}


macro @i_rva modname,[name] {
	common
	align 4
	modname#_bridge:
		hMod_#modname	 dq 0
		modname#.#size dw  modname#_table - uzLib_#modname
		uzLib_#modname du `modname,0;#".dll",0
	@align 4,0CCh
	modname#_table:
	forward
		if used name
			;display `name
			@xsdbm name,result
 			dd result			;--- hash
			name dq 0  		;--- future proc address
		end if
	common
		dd 0
}


macro @topitem name,[argname,arglev,initval] {
	common
		align 4
	forward
		define status 0
	match =0 n,status name \{
		@xsdbm name#.#argname,result
		name#.#argname#.hash 		= result
		name#.#argname#.level		= arglev
		name#.#argname#.info	dd 0
		name#.#argname#.param	initval
	align 2
		define status 1
		\}
	match =0,status\{
		@xsdbm argname,result
		argname#.hash 		= result
		argname#.level 		= arglev
		argname#.info		dd 0
		argname#.param	initval
	align 2
		define status 1
		\}
	common
	match n,name \{	
		utf8_#name	db `name,0
	\}
	forward
	define status 0
	match =0 n,status name \{
		utf8_#name#.#argname	db `argname,0
		define status 1
	\}
	match =0,status\{
		utf8_#argname	db `argname,0	
		define status 1
	\}
}


;;--- set constant in reg if reg=0 (FALSE) or reg#0 (TRUE)
;;--- thanks to 
;;--- <LocoDelAssembly> for improvement
;;--- <baldr> for assistance and suggestions

;macro @set reg,const,fbool {
;	xchg reg,ecx
;	push const
;	match =TRUE,fbool \{
;		neg ecx
;		pop reg
;		sbb ecx,ecx
;		and reg,ecx
;		neg ecx
;	\}
;	match =FALSE,fbool \{
;		cmp ecx,1
;		pop reg
;		sbb ecx,ecx
;		and reg,ecx
;		inc ecx
;	\}
;}

;macro minor reg,arg1,arg2
; {
;	local ..p1
;	if ~reg eq arg1
;		mov reg,arg1
;	end if
;	cmp reg,arg2
;	jl	@f
;;	jle	@f
;	mov reg,arg2
;	clc
;	jmp ..p1	
;@@:
;	if ~reg eq arg1
;		mov reg,arg1
;	end if
;	stc
;..p1:
; }

;macro major reg,arg1,arg2
; {
;	local ..p1
;	if ~reg eq arg1
;		mov reg,arg1
;	end if
;	cmp reg,arg2
;	jnl	@f
;;	jnle	@f
;	mov reg,arg2
;	clc
;	jmp ..p1	
;@@:
;	if ~reg eq arg1
;		mov reg,arg1
;	end if
;	stc
;..p1:
; }

;;----------------------
;macro @vesp argname,argstruct
;{
;	sub esp,sizeof.#argstruct
;	local ..tmp1
;	if ~argname#_defined eq \`argstruct
;		virtual at esp
;			if defined argname
;				label ..tmp1	
;				argname equ ..tmp1
;			else
;				argname argstruct
;			end if
;		end virtual
;		argname#_defined equ argstruct
;	end if
;}


;------------ names/quoted-------
;match items,APIEXPORT {
;	irp i,items	\{
;		define status 0
;		match =0 \`i,status i \\{	
;			;display \\`i
;			display "a"
;		define status 1
;			\\}
;		match =0 \i,status i \\{	
;			;display \\`i
;			display "b"
;		define status 1
;			\\}
;		\}
;	}

;----------------------------------
;macro include_it aPath,flags,[value] 
;{ 
;	EXTFLAGS equ flags
;	DEFCCONV equ invoke
;	include aPath#`value#'.inc'
;}

;macro @idata path,[libnames]
; {
;	common
;		liblist equ
;		inclib	equ
;		incext	equ

;	section '.idata' import data readable writeable
;	forward
;	define status 0				
;	match =0 modimp aName,status libnames
;	\{
;	define fmod 0				
;	
;	;define \use_\#aName TRUE
;	append liblist,aName 		
;	append liblist,\`aName\#'.dll'
;		
;	match =0 =manual,fmod modimp
;	\\{	define fmod 1	
;			define status 1 \\}
;		
;	match =0 =apicon,fmod modimp
;	\\{	append inclib,\\`aName	
;			define fmod 1
;			define status 1	\\}

;	match =0 =extend,fmod modimp
;	\\{	append incext,\\`aName	
;			define fmod 1
;			define status 1	\\}
;		
;	match =0,fmod
;		\\{	display ":ERR: need <extend/apicon/manual> for <", \`libnames,">",13,10		\\}	
;	\}
;	match =0,status
;	\{	display ":ERR: invalid @idata declare",13,10	\}

;common
;	match items, liblist	\{	library items	\}
;	match items, inclib	\{	include_it path,apicon,items	\}
;	match items, incext	\{	include_it path,extend,items	\}
;}

;;-------------------------------------------------------

;;macro explodeitem aReg,anId,[value]
;;{ 
;;	match theId:acase:cond:sign,value
;;	\{
;;	if (theId eq anId)
;;;	;/comment	
;;;		display \`theId
;;;		display " ",\`cond,9
;;;		
;;;		if acase eqtype eax
;;;			display " reg  =",\`acase
;;;			else
;;;			match =minus,sign
;;;			\\{
;;;			display " dec. -"
;;;			\\}
;;;			match =plus,sign
;;;			\\{
;;;			display " dec. +"
;;;			\\}
;;;			display_decimal acase
;;;		end if	
;;;		display 9,\`sign
;;;		display 9,\`acase
;;;		display 13,10
;;;	;comment/
;;	
;;		\theId\#acase\#cond\#sign\#@cmp:
;;		define status 0
;;		match =minus,sign
;;		\\{
;;			cmp aReg,-acase
;;			define status 1
;;		\\}
;;		match =0,status
;;		\\{
;;			cmp aReg,acase
;;			define status 1
;;		\\}
;;		j\#cond	\theId\#acase\#cond\#sign
;;	end if
;;	\}
;;}
;;macro explodelist aReg,anId,aList
;;{
;;;	;/comment
;;;	display "----------------------------------------",13,10
;;;	display "Display values for optimization purpouse",13,10		
;;;	display "----------------------------------------",13,10
;;;	;comment/
;;	match items,aList 
;;	\{ 
;;		explodeitem aReg,anId,items
;;	\}
;;}

;;;---- Updated [Sonntag] - 07.Juni.2009 - 15:47:05 
;;;----
;;macro select reg,param
;;{
;;	local ..id@sel,reg@sel,list@sel,flags
;;	reg@sel equ reg
;;	flags equ 0
;;	prev@instr equ `select

;;	define status 0
;;	match =0 =word argval,status param \{
;;		; ---- > select ax,word[val1]
;;		; ---- > select ax,word bx
;;		if reg in <ax,bx,bp,cx,dx,di,si,sp>
;;			mov reg,word argval
;;			else
;;			; ---- > select eax,word[val1]
;;			; ---- > select eax,word bx
;;			movzx reg,word argval
;;		end if
;;		define status 1
;;	\}

;;	match =0 =loword argval,status param \{
;;		; ---- > select ax,loword[val1]
;;		; ---- > select ax,loword bx
;;		if reg in <ax,bx,bp,cx,dx,di,si,sp>
;;			mov reg,word argval
;;			else
;;			; ---- > select eax,loword[val1]
;;			; ---- > select eax,loword ebx		;not useful
;;			movzx reg,word argval
;;		end if
;;		define status 1
;;	\}

;;	match =0 =hiword [argval],status param \{
;;		; ---- > select ax,hiword[val1]
;;		if reg in <ax,bx,bp,cx,dx,di,si,sp>
;;			mov reg,word [argval+2]
;;			else
;;			; ---- > select eax,hiword[val1]
;;			movzx reg,word [argval+2]
;;		end if
;;		define status 1
;;	\}

;;	match =0,status \{
;;		mov reg,param
;;	\}

;;..id@sel#common:
;;	
;;macro case [namecase]
;;\{
;;	if prev@instr eq `select
;;		jmp ..id@sel#start
;;	end if
;;	cond@case equ e
;;	sign@case equ plus
;;	name@case equ
;;	expr@case equ
;;	define status 0
;;	
;;	match =0 thecase == theexpr,status namecase
;;	\\{
;;		thecase = theexpr
;;		expr@case equ thecase
;;		define status 1
;;	\\}

;;	match =0 thecase,status namecase
;;	\\{
;;		expr@case equ thecase
;;		define status 1
;;	\\}
;;	
;;	
;;	define status 0
;;	match =0 cond =- n,status expr@case	;namecase
;;	\\{
;;		cond@case equ cond
;;		sign@case equ minus
;;		name@case equ n
;;		define status 1
;;	\\}
;;	match =0 cond =+ n,status expr@case	;namecase

;;	\\{
;;		cond@case equ cond
;;		sign@case equ plus
;;		name@case equ n
;;		define status 1
;;	\\}
;;	match =0 =- n,status expr@case	;namecase

;;	\\{
;;		sign@case equ minus
;;		name@case equ n
;;		define status 1
;;	\\}
;;	match =0 =+ n,status expr@case	;namecase

;;	\\{
;;		sign@case equ plus
;;		name@case equ n
;;		define status 1
;;	\\}

;;	match =0 cond n,status expr@case	;namecase

;;	\\{
;;		cond@case equ cond
;;		name@case equ n
;;		define status 1
;;	\\}
;;	
;;	match =0 n,status expr@case 	;namecase
;;	\\{
;;		name@case equ n
;;		define status 1
;;	\\}
;;	
;;	match n c s,name@case cond@case sign@case 
;;	\\{
;;		..id@sel\\#n\\#c\\#s:
;;	add_to_list list@sel,..id@sel#:#name@case#:#cond@case#:#sign@case
;;	\\}
;;	prev@instr equ `case
;;\}



;;macro continue how
;;\{
;;	define status 0
;;	match =0 =default,status how
;;	\\{
;;		jmp ..id@sel\\#\\default
;;		define status 1
;;	\\}
;;	match =0 =exit,status how
;;	\\{
;;		jmp ..id@sel\\#\\exit
;;		define status 1
;;	\\}
;;	match =0 =common,status how
;;	\\{
;;		jmp ..id@sel\\#\\common
;;		define status 1
;;	\\}

;;	match =0 lab@cont,status how
;;	\\{
;;	if (~defined ..id@sel\\#\\lab@cont\\#\\@cmp) 
;;		display "WARNING: ",\\`lab@cont
;;		display " not defined in current level",13,10
;;	else
;;		jmp ..id@sel\\#\\lab@cont\\#\\@cmp
;;	end if
;;	\\}
;;\}

;;macro default
;; \{
;;	match =0,flags
;;	\\{
;;	..id@sel#start:
;; 		explodelist reg@sel,..id@sel,list@sel
;; 	..id@sel#default:
;;	restore prev@instr
;; 	restore ..id@sel
;;	restore reg@sel
;; 	flags equ 1
;; 	\\}
;; \}
;;macro exitselect
;;\{
;;	..id@sel#exit:
;;\}
;;}
;;macro endselect
;; {
;;  default
;;  purge case,continue,default
;;  exitselect
;;  purge exitselect
;; }

	macro @do_eol {
		mov ax,0A0Dh
		stosw
	}

	macro @do_indent{
		mov al,09h
		rep stosb
	}
