  
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



inet:
	virtual at rbx
		.nfi NETFILEINFO
	end virtual

.prolog0:
	push rbp
	mov rbp,rsp
	and rsp,-16

.epilog0:
	sub rsp,20h
	call rax
	mov rsp,rbp
	pop rbp
	ret 0

.check:
	xor r8,r8
	mov rdx,0;FLAG_ICC_FORCE_CONNECTION
	mov rax,[InternetCheckConnectionW]
	jmp	.prolog0

.state:
	;--- in RCX NETINFO
	push rcx
	push 0
	mov rcx,rsp
	xor rdx,rdx
	mov rax,[InternetGetConnectedState]
	call .prolog0
	pop rdx
	pop rcx
	mov [rcx+NETINFO.state],dl
	ret 0

.open:
	;--- in RCX NETINFO
	push rbp
	push rbx
	mov rbp,rsp
	and rsp,-16
	mov rbx,rdx

	movzx rax,byte[rcx+NETINFO.state]
	test al,INTERNET_CONNECTION_OFFLINE
	jnz	.openA
;	test al,INTERNET_RAS_INSTALLED
;	jz	.openB

	mov rax,[rcx+NETINFO.hNet]
	test rax,rax
	jnz	.openC
	mov rax,[rcx+NETINFO.pAgent]
	mov rbx,rcx
	mov r8d,[rcx+NETINFO.flags]
	mov edx,[rcx+NETINFO.type]
	push 0
	push r8
	xor r9,r9
	xor r8,r8
	mov rcx,rax
	sub rsp,20h
	call [InternetOpenW]
	mov [rbx+NETINFO.hNet],rax
	jmp	.openC

.openB:
	;--- RAS installed
	jmp	.openA

.openA:
	;--- system is offline
	xor rax,rax

.openC:
	mov rsp,rbp
	pop rbx
	pop rbp
	ret 0

.closeurl:
	;--- in RCX NETFILEINFO
	mov r8,rcx
	xor rax,rax
	test rcx,rcx
	jnz	.closeurlB
	ret 0

.closeurlB:
	cmp rax,[r8+NETFILEINFO.qbuf]
	jz	.close
	push rcx
	mov [r8+NETFILEINFO.qidx],rax
	mov [r8+NETFILEINFO.qlen],rax
	mov rcx,[r8+NETFILEINFO.qbuf]
	call art.a16free
	pop rcx

.close:
	;--- in RCX NETINFO
	xor r8,r8
	mov rdx,rcx
	mov rax,[InternetCloseHandle]
	mov rcx,[rdx+NETINFO.hNet]
	test rcx,rcx
	mov [rdx+NETINFO.hNet],r8
	jnz	.prolog0
	xor rax,rax
	ret 0

.cback:
	;--- in RCX hNet
	;--- in RDX cback / 0
	mov rax,[InternetSetStatusCallbackW]
	jmp .prolog0

.iourl:
	push rbp
	push rbx
	push rdi
	
	mov rbp,rsp
	and rsp,-16
	;--- in RCX hInternet
	;--- in RDX NETFILEINFO
	;--- in R8 flags
	mov rbx,rdx

	sub rsp,URL_BUFLEN	;--- TODO: antispoof
	mov rdi,rsp
	mov [.nfi.hUrl],rcx

	xor rax,rax
	mov r9,[.nfi.pIargs]
	push rax
	test r9,r9
	jz	@f
	push r9
@@:
	mov r9,[.nfi.pIfile]
	test r9,r9
	jz	@f
	push r9
	push uzIslash
@@:
	mov r9,[.nfi.pIpath]
	test r9,r9
	jz	@f
	push r9
	push uzIslash
@@:
	push [.nfi.pHost]
	push [.nfi.pProto]
	push rdi
	push rax
	call art.catstrw

	;  InternetOpenUrl(
	;  __in  HINTERNET hInternet,
	;  __in  LPCTSTR lpszUrl,
	;  __in  LPCTSTR lpszHeaders,
	;  __in  DWORD dwHeadersLength,
	;  __in  DWORD dwFlags,
	;  __in  DWORD_PTR dwContext
	;lea rax,[.nfi.param]
	mov rcx,[.nfi.hUrl]
	mov eax,[.nfi.flags]

	xor r9,r9
	xor r8,r8

	push rbx
	push rax
	mov rdx,rdi
	sub rsp,20h
	call [InternetOpenUrlW]
	mov [.nfi.hUrl],rax

	mov rsp,rbp
	pop rdi
	pop rbx
	pop rbp
	ret 0

.setopt:
	;--- in RCX hInternet
	;--- in RDX option
	;--- in R8 buffer
	;--- in r9 buflen
	;BOOL InternetSetOption(
	;  __in  HINTERNET hInternet,
	;  __in  DWORD dwOption,
	;  __in  LPVOID lpBuffer,
	;  __in  DWORD dwBufferLength
	mov rax,[InternetSetOptionW]
	jmp	.prolog0

.fread:
	;--- in RCX NETFILEINFO
	;--- in RDX buffer
	;--- in R8 bytes to read
	;--- RET RDX bytes read
	;--- RET RCX NETFILEINFO
	;BOOL InternetReadFile(
	;  __in   HINTERNET hFile,
	;  __out  LPVOID lpBuffer,
	;  __in   DWORD dwNumberOfBytesToRead,
	;  __out  LPDWORD lpdwNumberOfBytesRead
	push rcx
	push 0
	mov rax,[InternetReadFile]
	mov r9,rsp
	mov rcx,[rcx+NETFILEINFO.hUrl]
	call .prolog0
	pop rdx
	pop rcx
	ret 0

;.lmem:
;	;--- in RCX
;	xor r8,r8
;	mov rdx,HTTP_QUERY_CONTENT_LENGTH or \
;		HTTP_QUERY_FLAG_NUMBER
;	mov rcx,nfi
;	call [inet.query]
;	test rax,rax
;	jle	@f
;	mov rcx,[nfi.qbuf]
;	mov rax,[rcx]
;@@:


.lsave:
	push rbp
	push rbx
	push rdi
	push rsi
	push r12
	push r13
	push r14
	push r15
;@break
	mov rbp,rsp
	xor rax,rax
	and rsp,-16
	mov rbx,rcx
	;--- in RCX NETFILEINFO
	xor r13,r13
	mov [.nfi.tbytes],rax
	mov [.nfi.rbytes],rax
	xor r15,r15
	cmp [.nfi.pMem],rax
	jz	.lsaveA1

.lmem:
	xor r8,r8
	mov rdx,HTTP_QUERY_CONTENT_LENGTH or \
		HTTP_QUERY_FLAG_NUMBER
	mov rcx,rbx
	call .query
	test rax,rax
	jle	.lsave_exit
	dec r13
	mov rax,[.nfi.qbuf]
	mov rdx,[rax]
	mov [.nfi.fsize],rdx
	call art.valloc
	mov [.nfi.pMem],rax
	jz	.lsave_exit
	mov r15,rax

	;--- notify user -------------
	mov rsi,[.nfi.cbnotify]
	test rsi,rsi
	jz .lmemA
	mov r8,NFI_CLEN_OK
	mov rdx,[.nfi.fsize]
	mov rcx,rbx
	call rsi
	test rax,rax
	jnz	.err_lsave
	jmp .lmemA
	
.lsaveA1:
	mov rdx,[.nfi.pLpath]
	mov rdi,[.nfi.pLfile]
	test rdx,rdx
	jz	.lsaveA

	mov rax,rdi
	sub rsp,FILE_BUFLEN
	mov rdi,rsp

	push 0
	push rax
	push uzSlash
	push rdx
	push rdi
	push 0
	call art.catstrw

.lsaveA:
	dec r13			;--- -1 = err create file
	xor r12,r12
	mov rcx,rdi
	call art.fcreate_rw
	test rax,rax
	jle	.lsave_exit
	mov r12,rax

.lmemA:
	movzx rcx,[.nfi.chunk]
	test rcx,rcx
	jnz	.lsaveB
	inc cl

.lsaveB:
	@nearest 4096,rcx
	dec r13			;--- -2 = err alloc mem
	mov [.nfi.chunk],cx
	call art.a16malloc
	test rax,rax
	jz	.err_lsave
	mov r14,rax
	mov rsi,[.nfi.cbnotify]
	test rsi,rsi
	jz .lsaveC

	mov r8,NFI_LFILE_OK
	mov rdx,rdi
	mov rcx,rbx
	call rsi
	test rax,rax
	jnz	.err_lsaveA
	
.lsaveC:
	movzx r8,[.nfi.chunk]
	mov rdx,r14
	mov rcx,rbx
	call .fread
	test rax,rax
	jnz	.lsaveC1
	dec r13					;--- -3 err inet
	jmp .err_lsaveB

.lsaveC1:
	mov [.nfi.rbytes],rdx
	test rdx,rdx
	jz	.lsaveC3
	test rsi,rsi
	jz	.lsaveC2

	mov r8,NFI_RBYTES
	mov rcx,rbx
	call rsi
	test rax,rax
	jnz	.err_lsaveB

.lsaveC2:
	test r15,r15
	jz	.lsaveC4
;@break
	push rdi
	push rsi
	mov rsi,r14
	mov rdi,r15
	add rdi,[.nfi.tbytes]
	mov rcx,[.nfi.rbytes]
	add [.nfi.tbytes],rcx
	;--- TODO: xmm fast copy
	rep movsb
	pop rsi
	pop rdi
	jmp	.lsaveC

.lsaveC4:
	mov r8,[.nfi.rbytes]
	add [.nfi.tbytes],r8
	mov rdx,r14
	mov rcx,r12
	call art.fwrite
	test rax,rax
	jle .err_lsaveB
	jmp	.lsaveC

.lsaveC3:
	xor r13,r13
	inc r13
	
.err_lsaveB:
	mov rcx,rbx
	call .closeurl
	
.err_lsaveA:
	mov rcx,r14
	call art.a16free
	
.err_lsave:
	test r15,r15
	jz	.err_lsaveC
	test r13,r13
	cmovg r13,r15
	jg .lsave_exit
	mov rcx,r15
	call art.vfree
	xor r13,r13
	jmp	.lsave_exit

.err_lsaveC:
	mov rdx,[.nfi.tbytes]
	mov rcx,r12
	call art.fpoint
	mov rcx,r12
	call art.fclose
	
.lsave_exit:
	xchg rax,r13
	mov rsp,rbp
	pop r15
	pop r14
	pop r13
	pop r12
	pop rsi
	pop rdi
	pop rbx
	pop rbp
	ret 0
	

.query:
	;--- in RCX NETFILEINFO
	;--- in RDX dwInfoLevel
	;--- in R8 index on same headers
	push rbp
	push rbx
	push r12
;@break
	xor rax,rax
	mov rbp,rsp
	xor r12,r12
	mov rbx,rcx
	and rsp,-16   

	mov [.nfi.qlen],MAX_UTF16_HEAD_CPTS
	mov [.nfi.qidx],r8
	push rdx
	cmp rax,[.nfi.qbuf]
	jnz	.queryA
	dec r12				;--- err memalloc
	mov rcx,HEAD_BUFLEN
	call art.a16malloc
	pop rdx
	test rax,rax
	jz	.err_query
	mov [.nfi.qbuf],rax

.queryA:
	;BOOL HttpQueryInfo(
	;  __in     HINTERNET hRequest,
	;  __in     DWORD dwInfoLevel,
	;  __inout  LPVOID lpvBuffer,
	;  __inout  LPDWORD lpdwBufferLength,
	;  __inout  LPDWORD lpdwIndex
	lea rax,[.nfi.qidx]
	push 0			;--- align stack
	dec r12
	push rax
	lea r9,[.nfi.qlen]
	mov r8,[.nfi.qbuf]
	mov rcx,[.nfi.hUrl]
	sub rsp,20h
	call [HttpQueryInfoW]
	mov r12,rax

.err_query:
	xchg rax,r12
	mov rsp,rbp
	pop r12
	pop rbx
	pop rbp
	ret 0
	
;.startB:
;	add esp,-124
;	xor ecx,ecx
;	mov edx,esp
;	push ecx
;	push szCrLf
;	push eax
;	push szSpace
;	push szInetSession
;	push sz2Greater
;	push edx
;	push ecx
;	call shared.catstr
;	mov eax,esp
;	push eax
;	push [hOutput]
;	call general.output_set
;	sub esp,-124
;.startA:
;	ret 0


;;	push szHelpConsole
;;	push [hOutput]
;;	call general.output_set

;	;--- fileden ---------------------
;;	mov [nfi.fRedir],TRUE
;;	mov [nfi.pHost],szHost1
;;	mov [nfi.pUrl],szUrl1
;;	mov [nfi.fQueries],QUERY_LENGTH

;;;	;---- sourceforge 
;;	mov [nfi.fQueries],QUERY_LENGTH or QUERY_LAST_MODIFIED
;;	mov [nfi.fRedir],FALSE
;;	mov [nfi.pHost],szHost
;;	mov [nfi.pUrl],szUrl0

;	;--- intel ---------------------
;;	mov [nfi.fRedir],TRUE
;;	mov [nfi.pHost],szHost2
;;	mov [nfi.pUrl],szUrl2
;;	mov [nfi.fQueries],QUERY_LENGTH or QUERY_LAST_MODIFIED

;;	;--- intel ftp -------------------
;;	mov [nfi.fRedir],TRUE
;;	mov [nfi.pHost],szHost3
;;	mov [nfi.pUrl],szUrl3
;;	mov [nfi.fQueries],QUERY_LENGTH or \
;;			QUERY_LAST_MODIFIED or \
;;			QUERY_DISPOSITION

;;	mov [nfi.pPath],szTmpdir
;;	mov	[nfi.fLab],DLOAD_FASMLAB_BIN or DLOAD_FASMLAB_SRC


;.tDownload:
;	;IN EAX = nfi
;	push ebx
;	push edi
;	push esi
;	mov ebx,[esp+16]
;	call inet.start
;;@break

;	push ebx
;	call inet.download
;	call inet.close
;	mov [ebx+NETFILEINFO.hThread],0
;	pop esi
;	pop edi
;	pop ebx
;	ret 4

;proc .download\
;	_nfi
;	local .sbuffer1024[1024]:BYTE
;	local .dbuffer1024[1024]:BYTE
;	local .istime:SYSTEMTIME
;	local	.ftime:FILETIME
;	local .pIndex:DWORD
;	local .pSize:DWORD
;	local .rBytes:DWORD
;	local .pName:DWORD
;	local .namelen:DWORD
;	local .is_sourceforge:DWORD

;	push ebx
;	push edi
;	push esi
;	mov ebx,[_nfi]

;;@break
;	;--- cat main url -------------------
;	xor ecx,ecx
;	lea edi,[.dbuffer1024]
;	mov [.pName],ecx
;	mov [.namelen],ecx
;	mov [ebx+NETFILEINFO.fsize],ecx
;	mov [ebx+NETFILEINFO.tstamp],ecx
;	mov [.is_sourceforge],ecx
;	lea esi,[.sbuffer1024]

;	push ecx
;	push [ebx+NETFILEINFO.pUrl]
;	push szIslash
;	push [ebx+NETFILEINFO.pHost]
;	push szProtoSep
;	push [ebx+NETFILEINFO.pProto]
;	push edi
;	push ecx
;	call shared.catstr

;	xor eax,eax
;	movzx ecx,[ebx+NETFILEINFO.fRedir]
;	test cl,TRUE
;	jnz	.tdlA

;	;--- open sourceforge url no redirect -----------
;	mov eax,INTERNET_FLAG_NO_AUTO_REDIRECT
;	mov edx,edi
;	call .iourl

;	test eax,eax
;	jz	.err_tdlA
;	mov [ebx+NETFILEINFO.hUrl],eax
;	cmp [ebx+NETFILEINFO.bContinue],FALSE
;	jz	.err_tdlB

;	xor eax,eax
;	lea esi,[.sbuffer1024]

;	mov eax,HTTP_QUERY_RAW_HEADERS_CRLF
;	call .qinfo
;	push esi
;	push [hOutput]
;	call general.output_set

;	xor eax,eax
;	;--- so works the server on sourceforge !!! -----
;	mov dword[esi],"loca"
;	mov dword[esi+4],"tion"
;	mov dword[esi+8],eax

;	mov eax,HTTP_QUERY_CUSTOM
;	call .qinfo

;	test eax,eax
;	jz	.err_tdlC

;	;--- copy the custom "location" in edi
;	mov eax,[.pSize]
;	test eax,eax
;	jz	.err_tdlD
;	push esi
;	lea edi,[.dbuffer1024]
;	mov ecx,eax
;	push edi
;	rep movsb
;	xor eax,eax
;	stosb
;	pop edi
;	pop esi

;	;--- close this base url -------------
;.tdlN:
;	push [ebx+NETFILEINFO.hUrl]
;	InternetCloseHandle
;	xor eax,eax
;	mov [ebx+NETFILEINFO.hUrl],eax
;	mov [ebx+NETFILEINFO.readbytes],eax
;	cmp [ebx+NETFILEINFO.bContinue],FALSE
;	jz	.err_tdlB

;	;--- open the redirected url ---------
;.tdlA:
;	mov edx,edi
;	call .iourl
;	test eax,eax
;	jz	.err_tdlA
;	mov [ebx+NETFILEINFO.hUrl],eax
;	cmp [ebx+NETFILEINFO.bContinue],FALSE
;	jz	.err_tdlB

;	movzx eax,[ebx+NETFILEINFO.fQueries]
;	and al,QUERY_LENGTH
;	test al,al
;	jz	.tdlB

;	;--- query len ---------
;	mov eax,HTTP_QUERY_CONTENT_LENGTH
;	call .qinfo
;	test eax,eax
;	jz	.err_tdlE

;	;--- convert number and store it -----------
;	push esi
;	call shared.a2dd
;	pop esi
;	jc	.err_tdlE
;	mov [ebx+NETFILEINFO.fsize],eax


;.tdlB:
;	;--- query timestamp only for fasmlab ------
;	movzx eax,[ebx+NETFILEINFO.fLab]
;	test eax,eax
;	jz	.tdlC

;	movzx eax,[ebx+NETFILEINFO.fQueries]
;	and al,QUERY_LAST_MODIFIED
;	test al,al
;	jz	.tdlC

;	;--- query last-modified ---------
;	mov eax,HTTP_QUERY_LAST_MODIFIED
;	call .qinfo
;	test eax,eax
;	jz	.err_tdlF

;	cmp [ebx+NETFILEINFO.bContinue],FALSE
;	jz	.err_tdlB

;	lea eax,[.istime]
;	push 0
;	push eax
;	push esi
;	InternetTimeToSystemTime

;	lea eax,[.istime]
;	lea edx,[.ftime]

;	push edx
;	push eax
;	SystemTimeToFileTime
;	
;	lea eax,[.ftime]
;	call shared.ft2stamp
;	cmp eax,[timestamp]
;	jbe	.err_tdlG			;<-----------------------


;.tdlC:				;update available
;	cmp [ebx+NETFILEINFO.bContinue],FALSE
;	jz	.err_tdlB

;	mov eax,HTTP_QUERY_RAW_HEADERS_CRLF
;	call .qinfo

;	push esi
;	push [hOutput]
;	call general.output_set

;	;--- ask to download ------------------------
;	;--- ord download silent --------------------

;	;--- extact the filename --------------------
;	;--- using in ESI .sbuffer1024
;	;1) --- copy local path in esi

;	xor ecx,ecx
;	xor eax,eax

;	;--- if server is SOURCEFORGE
;	cmp dword[edi+7],"sour"
;	setz cl
;	cmp dword[edi+11],"cefo"
;	setz ch
;	cmp dword[edi+15],"rge."
;	setz al
;	cmp dword[edi+19],"net/"
;	setz ah
;	and eax,ecx
;	and al,ah
;	jz	.tldI

;	;--- if last received URL has /download
;	push edi
;	call shared.get_fname
;	xor edx,edx
;	cmp dword[eax],"down"
;	setz dl
;	cmp dword[eax+4],"load"
;	setz dh
;	and dl,dh
;	jz	.tldI
;	
;	;--- if user reqired URL has /latest
;	push [ebx+NETFILEINFO.pUrl]
;	call shared.get_fname
;	test eax,eax
;	jz	.err_tdlH
;	xor edx,edx
;	cmp dword[eax],"late"
;	setz dl
;	cmp word[eax+4],"st"
;	setz dh
;	and dl,dh
;	jz	.tldI
;	
;	;--- then we are on sourceforge for a project
;	;--- with this proto:
;	;--- http://sourceforge.net/projects/x32lab/files/x32lab_bin_0307.7z/download",0
;	mov [.is_sourceforge],1
;	push edi
;	call shared.get_fname
;	test eax,eax
;	jz	.err_tdlH
;	
;	push dword[eax-1]
;	push eax
;	mov dword[eax-1],0
;	push edi
;	call shared.get_fname

;	xor ecx,ecx
;	mov edx,[ebx+NETFILEINFO.pPath]

;	push ecx
;	push eax
;	test edx,edx
;	jz	@f
;	push szSlash
;	push [ebx+NETFILEINFO.pPath]
;@@:
;	push esi
;	push ecx
;	call shared.catstr

;	pop eax
;	pop dword[eax-1]	;restore last URL (in edi)
;	jmp	.tdlL

;.tldI:
;	;--- this is not sourceforge -------------
;	push edi
;	call shared.get_fname
;	test eax,eax
;	jz	.err_tdlH
;	mov [.pName],eax
;	mov [.namelen],ecx

;	push esi
;	push edi
;	
;	push eax
;	push ecx
;	
;	mov esi,[ebx+NETFILEINFO.pPath]
;	lea edi,[.sbuffer1024]
;	call shared.copyz
;	test eax,eax
;	jz	.tldG
;	dec eax
;	add edi,eax
;	mov al,"\"
;	stosb

;.tldG:
;	pop ecx
;	pop esi

;.tldH:
;	lodsb
;	test al,al
;	jz	.tdlD
;	cmp al,"/"
;	jz	.tdlE
;	cmp al,"\"
;	jz	.tdlE
;	cmp al,"?"
;	jz	.tdlE
;	cmp al,"*"
;	jz	.tdlE
;	jmp	.tldF

;.tdlE:
;	mov al,"_"

;.tldF:
;	stosb
;	dec ecx
;	jnz .tldH
;	
;.tdlD:
;	xor eax,eax
;	stosb
;	pop edi
;	pop esi

;.tdlL:	
;	cmp [ebx+NETFILEINFO.bContinue],FALSE
;	jz	.err_tdlB
;	mov eax,esi
;	call .isavefile
;	test eax,eax
;	jz	.err_tdlL		
;	cmp [ebx+NETFILEINFO.bContinue],FALSE
;	jz	.err_tdlB

;	;--- try setup for sources ------------
;	movzx eax,[ebx+NETFILEINFO.fLab]
;	and al,DLOAD_FASMLAB_SRC
;	jz	.tdlM
;	
;	;--- ask or download sources ------------
;	;--- close binary url -------------------
;	;--- ONLY for x32lab -------------------

;	;--- disallow sources download when not on sourceforge
;	cmp [.is_sourceforge],1
;	jnz	.tdlM

;	push edi
;	call shared.get_fname
;	test eax,eax
;	jz	.err_tdlH
;	;--- .../files/x32lab_bin_0307.7z/download",0
;	;----------------------|
;	mov dword[eax-12],"src_"
;	mov [ebx+NETFILEINFO.fLab],0
;	jmp .tdlN

;.tdlM:
;	mov eax,TRUE
;	jmp	.exit_tdl


;.err_tdlB:	;err user aborted
;	mov eax,szBreakDload
;	jmp	.err_tdlM

;.err_tdlG:	;no update
;	mov eax,szUptodate
;	jmp	.err_tdlM

;.err_tdlM:
;	lea esi,[.sbuffer1024]
;	xor ecx,ecx
;	push ecx
;	push szCrLf
;	push szSpace
;	push eax
;	push sz2Greater
;	push esi
;	push ecx
;	call shared.catstr

;	push esi
;	push [hOutput]
;	call general.output_set
;	
;.err_tdlL:	;error reading file
;.err_tdlI:	;error creating local file
;.err_tdlH:	;error filename
;.err_tdlF:	;last-modified header error
;.err_tdlE:	;content-lenght header error
;.err_tdlD:	;location header is zero
;.err_tdlC:	;custom header location not found
;.err_tdlA:	;err opening url
;	xor eax,eax

;.exit_tdl:
;	push eax
;	push eax
;	push [ebx+NETFILEINFO.hUrl]
;	InternetCloseHandle
;	pop eax
;	pop [ebx+NETFILEINFO.hUrl]
;	mov [ebx+NETFILEINFO.bContinue],al
;	
;	pop esi
;	pop edi
;	pop ebx
;	ret


;.isavefile:
;	;IN EAX = path+filename
;	;IN EBX = netfileinfo
;	;buffer is 4 kb
;	push ebx
;	push edi
;	push esi

;	push eax
;	push esi
;	sub esp,512

;	mov esi,esp
;	xor ecx,ecx
;	push ecx
;	push szCrLf
;	push szSpace
;	push eax
;	push szSpace
;	push szAskSaveFile
;	push sz2Greater
;	push esi
;	push ecx
;	call shared.catstr

;	push esi
;	push [hOutput]
;	call general.output_set

;	add esp,512
;	pop esi
;	pop eax

;	sub esp,1000h
;	mov edi,ebx
;	mov esi,esp

;	call shared.open_AfileRW
;	or eax,eax	
;	jle	.err_isf
;	mov ebx,eax

;.isfB:
;	lea edx,[.rBytes]
;	push edx
;	push 1000h
;	push esi
;	push [edi+NETFILEINFO.hUrl]
;	InternetReadFile
;	test eax,eax
;	jz	.isfC

;	;BOOL InternetReadFile(
;	;  __in   HINTERNET hFile,
;	;  __out  LPVOID lpBuffer,
;	;  __in   DWORD dwNumberOfBytesToRead,
;	;  __out  LPDWORD lpdwNumberOfBytesRead
;	;);

;.isfD:
;	mov ecx,[.rBytes]
;	add [edi+NETFILEINFO.readbytes],ecx
;	test ecx,ecx
;	jz	.isfC
;	
;	mov edx,esi
;	call shared.fwrite

;	cmp [edi+NETFILEINFO.bContinue],FALSE
;	jz	.err_isfB
;	jmp	.isfB

;.isfC:
;	xor eax,eax
;	mov edx,[edi+NETFILEINFO.fsize]
;	cmp edx,[edi+NETFILEINFO.readbytes]
;	jnz	.err_isfA
;	inc eax
;	jmp	.isfA

;.err_isfC:
;	; error creating file
;	xor eax,eax
;	jmp	.err_isf

;.err_isfB:
;	;user stop request

;.err_isfA:
;	;error reading file
;	xor eax,eax

;.isfA:
;	push eax
;	push [edi+NETFILEINFO.readbytes]
;	call shared.fpoint
;	mov eax,ebx
;	call shared.fclose
;	pop eax

;.err_isf:
;	add esp,1000h
;	pop esi
;	pop edi
;	pop ebx
;	ret 0


;.qinfo:
;	;IN EAX = flags
;	;IN EBX = pnfi

;	;HttpQueryInfo(
;	;  __in     HINTERNET hRequest,
;	;  __in     DWORD dwInfoLevel,
;	;  __inout  LPVOID lpvBuffer,
;	;  __inout  LPDWORD lpdwBufferLength,
;	;  __inout  LPDWORD lpdwIndex
;	xor ecx,ecx
;	mov [.pIndex],ecx
;	mov [.pSize],1020

;	lea ecx,[.pIndex]
;	lea edx,[.sbuffer1024]
;	push ecx
;	lea ecx,[.pSize]
;	push ecx
;	push edx
;	push eax
;	push [ebx+NETFILEINFO.hUrl]
;	HttpQueryInfo	
;	ret 0
;endp
