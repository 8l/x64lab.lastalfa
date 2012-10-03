echo off
 cscript version.vbs //nologo
 set /p vers=<version.txt
 echo. > version.inc
 echo define VERSION %vers% >> version.inc
 echo. >> version.inc

 @del x64labd.exe
 @del x64lab.exe

 call lang\makeall.bat
   IF ERRORLEVEL 1 GOTO err_exit

 call plugin\makeall.bat
   IF ERRORLEVEL 1 GOTO err_exit

 echo.
 fasm x64labd.asm
   IF ERRORLEVEL 1 GOTO err_exit
 echo.
 fasm x64lab.asm
   IF ERRORLEVEL 1 GOTO err_exit
 echo.
 echo --------- All Ok ----------

:err_exit
 set vers=

