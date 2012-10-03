echo off
 copy config\config_ok.utf8 config\config.utf8 /Y
 copy develop\config\config_ok.utf8 develop\config\config.utf8 /Y

 copy config\devtool_ok.utf8 config\devtool.utf8 /Y
 copy develop\config\devtool_ok.utf8 develop\config\devtool.utf8 /Y


 REM * repack files as bin or src, using tool\7za.exe
 REM * output in packed\x64lab.bin.0.0.21.7z
 REM * args as <NULL>,<bin>,<src>
	set /p vers=<version.txt
  
  if not exist tool\7za.exe (
    echo - 7za.exe in the tool directory doesnt exist
    goto end
    )
   if not exist packed (
     echo - packed folder doesnt exist
     choice  /c yn /t 3 /d n /m "- Create packed\ folder "
     IF ERRORLEVEL 2 goto end
     md packed
     echo - packed directory created
   )

  IF "%1"=="" goto out_bin
  IF "%1"=="src" goto out_src

:out_bin
  if exist packed\x64lab.bin.%vers%.7z del packed\x64lab.bin.%vers%.7z
  tool\7za.exe a packed\x64lab.bin.%vers%.7z @list_bin.txt
  IF "%1"=="bin" goto end

:out_src
  if exist packed\x64lab.src.%vers%.7z del packed\x64lab.src.%vers%.7z
  tool\7za.exe a packed\x64lab.src.%vers%.7z @list_src.txt

:end
 set vers=
 echo - Done !
