@echo off
set LANG=en-US
call  %x64devdir%\lang\makeone.bat
  IF ERRORLEVEL 1 GOTO :err_exit

set LANG=pl-PL
call %x64devdir%\lang\makeone.bat
  IF ERRORLEVEL 1 GOTO :err_exit

set LANG=it-IT
call %x64devdir%\lang\makeone.bat
  IF ERRORLEVEL 1 GOTO :err_exit

:err_exit
set LANG=
