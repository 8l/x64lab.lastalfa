	set WshShell = WScript.CreateObject("WScript.Shell")
	labenv = WshShell.ExpandEnvironmentStrings("%x64devdir%")

	strfile = labenv & "\version.txt"
	listfile = labenv & "\lang\lang.txt"
	version = "0.0.1"

	const rr  = 1
  const ww  = 2
	wscript.echo " Write list of languages in [lang.txt]"
	set objFSO = CreateObject( "Scripting.FileSystemObject" )

  If objFSO.FileExists(strfile) then
		set objFile = objFSO.OpenTextFile(strfile,rr, false )
		version = objFile.ReadLine
		objFile.Close
	end if

	set objFile = objFSO.CreateTextFile(listfile,true,false)
	objFile.WriteLine "0) en-US " & version
	objFile.Write     "1) pl-PL " & version
	objFile.Close

	set objFSO = nothing
	set WshShell = nothing