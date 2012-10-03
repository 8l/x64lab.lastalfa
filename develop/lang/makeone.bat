@IF "%LANG%"=="" set LANG=en-US
IF not "%1"=="" set LANG=%1

 @echo -----------------------------------
 @echo Assembling %LANG% language
 @echo -----------------------------------
 @del %x64devdir%\lang\%LANG%\lang.dll
 @fasm %x64devdir%\lang\main.asm %x64devdir%\lang\%LANG%\lang.dll
@set LANG=