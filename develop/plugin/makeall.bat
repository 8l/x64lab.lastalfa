@echo off
fasm %x64devdir%\plugin\bk64.asm
  IF ERRORLEVEL 1 GOTO :err_exit

fasm %x64devdir%\plugin\dock64.asm
  IF ERRORLEVEL 1 GOTO :err_exit

fasm %x64devdir%\plugin\top64.asm
  IF ERRORLEVEL 1 GOTO :err_exit

:err_exit

