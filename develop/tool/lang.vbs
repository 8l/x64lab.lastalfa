
	const rd   = 1
	const ww   = 2
 
	dim std_in, std_out
	set std_in = WScript.StdIn
	set std_out = WScript.StdOut

	dim fso,file
	srv_dir	= "http://x64lab.googlecode.com/hg/develop/lang"
	loc_dir = "lang\"
	lang_list = "lang.txt"
	app = "x64labd.exe"
	
	set wshshell = WScript.CreateObject("WScript.Shell")
	set fso = CreateObject("Scripting.FileSystemObject")
	If fso.Fileexists(loc_dir & lang_list) then fso.DeleteFile loc_dir & lang_list

	'--- first download lang.txt list of available languages
	std_out.writeblanklines(1)
	std_out.writeline " Download [" & lang_list & "] list of languages..."
	std_out.writeblanklines(1)
	download srv_dir & "/" & lang_list,loc_dir & lang_list

	If not fso.Fileexists(loc_dir & lang_list) then 
		std_out.writeline " Cannot update from server. File does not exist locally"
		std_out.writeblanklines(1)
		std_out.writeline " Restarting x64lab..."
		WScript.Sleep 1000
		wshshell.run app
		WScript.Sleep 1000
		set wshshell = nothing
		set fso = Nothing
		set file = Nothing
		WScript.Quit (1)
	end if
	
	set file = fso.OpenTextFile(loc_dir & lang_list,rd)
	content = file.readall
	arr_content = split (content,VbCrLf)
	file.Close

	max = ubound(arr_content)
	std_out.writeblanklines(1)
	std_out.writeline " Available languages "
	std_out.writeline " Select index to choose your language. Accept it pressing <enter>."
	std_out.writeline " Press simply <enter> will quit"
	std_out.writeblanklines(1)
	std_out.Write content

	strIdx = std_in.ReadLine
	std_out.writeblanklines(1)
	idx = max
	if (IsNumeric(strIdx)) then
		idx = int (strIdx)
	end if

	if ((idx >= 0) and (idx < max)) then
		std_out.writeblanklines(1)
		std_out.WriteLine " Choosing " & arr_content(idx)
		arr_line = split (arr_content(idx)," ")
		strLang = arr_line(1)		'en-US
		std_out.WriteLine " Folder " & strLang
		idx = -1
	end if

	if idx <> -1 then
		std_out.writeline " No valid selected index. Quit..."
		std_out.writeline " Restarting x64lab..."
		WScript.Sleep 1000
		wshshell.run app
		WScript.Sleep 1000
		set wshshell = nothing
		set fso = Nothing
		set file = Nothing
		WScript.Quit (1)
	end if
	
	If not fso.FolderExists(loc_dir & strLang) then 
		std_out.writeline " Create local folder for language plugin [" & loc_dir & strLang & "]"
		fso.CreateFolder(loc_dir & strLang)
		std_out.writeblanklines(1)
	end if

	download "http://x64lab.googlecode.com/hg/lang/" & strLang & "/lang.dll", loc_dir & strLang & "\lang.dll"
	set fso = Nothing
	set file = Nothing
	std_out.writeline " Ok. Restarting x64lab..."
	WScript.Sleep 1000
	wshshell.run app
	WScript.Sleep 1000
	set wshshell = nothing

	'--- 	credits to
	'--- http://vbscriptautomation.net/73/download-files-using-vbscript/
function download(sFileURL, sLocation)
	'create xmlhttp object
	Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
	'get the remote file
	objXMLHTTP.open "GET", sFileURL, false
	'send the request
	objXMLHTTP.send()
	'wait until the data has downloaded successfully
	do until ((objXMLHTTP.Status = 200) or (objXMLHTTP.Status = 404))
		wscript.sleep(1000) 
	loop
	'if the data has downloaded sucessfully

	If objXMLHTTP.Status = 200 Then
    		'create binary stream object
		Set objADOStream = CreateObject("ADODB.Stream")
		objADOStream.Open
        'adTypeBinary
		objADOStream.Type = 1
		objADOStream.Write objXMLHTTP.ResponseBody
        'Set the stream position to the start
		objADOStream.Position = 0    
        'create file system object to allow the script to check for an existing file
    Set objFSO = Createobject("Scripting.FileSystemObject")
 
    'check if the file exists, if it exists then delete it
		If objFSO.Fileexists(sLocation) Then objFSO.DeleteFile sLocation
    'destroy file system object
		Set objFSO = Nothing
 
    'save the ado stream to a file
		objADOStream.SaveToFile sLocation
    'close the ado stream
		objADOStream.Close
		'destroy the ado stream object
		Set objADOStream = Nothing
	'end object downloaded successfully
	end if
	'destroy xml http object
	Set objXMLHTTP = Nothing
end function


