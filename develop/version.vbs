
	'-------------------------------------------------------
	' execute at prompt as "cscript version.vbs //nologo"
	' it create a file in the current directoy "version.txt"
	' set optionally start number in this way
	' "cscript version.vbs //nologo 1.4.5"
	' it echoes back the incremented version 1.4.6
	'-------------------------------------------------------
	
	version = "0.0.1"
	strfile = "version.txt"

	Const ForReading   = 1
  Const ForWriting   = 2

	Const MAI = 0
	Const MIN = 1
	Const BUILD = 2

	set objFSO = CreateObject( "Scripting.FileSystemObject" )

  If objFSO.FileExists(strfile) Then
		set objFile = objFSO.OpenTextFile( strfile, ForReading, False )
		arrline = Split(objFile.ReadLine,".")
		objFile.Close
		
		arrline(BUILD) = arrline(BUILD) + 1
			
		if arrline(BUILD) > 255 then
		  arrline(BUILD) = 0
		  arrline(MIN) = arrline(MIN) + 1
		end if
		if arrline(MIN)  > 255 then
		  arrline(MIN) = 0
		  arrline(MAI) = arrline(MAI) + 1
		end if

		version = Join(arrline,".")
		set objFile = objFSO.OpenTextFile( strfile, ForWriting, False )
		
	else
		set objFile = objFSO.CreateTextFile(strfile, False, False )
	end if

	if WScript.Arguments.Count > 0 then 
			version = WScript.Arguments(0)
	end if
	
		WScript.Echo version
		objFile.WriteLine version
		objFile.Close

