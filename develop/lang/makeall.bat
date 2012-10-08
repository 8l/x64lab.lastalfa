@echo off
@cscript %x64devdir%\lang\makelist.vbs //nologo
copy %x64devdir%\lang\lang.txt %x64devdir%\..\lang /Y

set LANG=en-US
  call %x64devdir%\lang\makeone.bat
  IF ERRORLEVEL 1 GOTO :err_exit
  xcopy %x64devdir%\lang\en-US\lang.dll %x64devdir%\..\lang\en-US\ /Y

set LANG=pl-PL
	call %x64devdir%\lang\makeone.bat
  IF ERRORLEVEL 1 GOTO :err_exit
  xcopy %x64devdir%\lang\pl-PL\lang.dll %x64devdir%\..\lang\pl-PL\ /Y

:err_exit
set LANG=
