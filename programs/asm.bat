@echo off

echo Assembling file %1... 
..\util\tasm %1.asm /m5/x/t
if errorlevel 1 goto end
if "%1"=="boot" goto boot
echo Linking file %1...
..\util\tlink %1.obj /x/t
if errorlevel 1 goto end
echo Copying file %1...  
if "%1"=="video" goto video
if "%1"=="lpt" goto system
if "%1"=="keyboard" goto system
if "%1"=="mouse" goto system 
if "%1"=="pic8259a" goto system 
if "%1"=="timer" goto system
if "%1"=="drive" goto system 
if "%1"=="joystick" goto system 
if "%1"=="system" goto system
if "%1"=="setup" goto setup 
copy %1.com ..\data\%1.exe>nul
goto end   

:boot
echo Linking file %1...
..\util\tlink %1.obj /x
if errorlevel 1 goto end
echo Copying file %1...
..\util\exe2boot %1.exe
copy %1.bin ..\data\%1.bin>nul 
goto end

:video
type thin8x8.fnt>>%1.com
:system
copy %1.com ..\data\%1.sys>nul
goto end
:setup
copy %1.com ..\%1.com>nul
goto end

:end
if not exist *.bin goto exes
del *.bin
:exes
if not exist *.exe goto coms
del *.exe
:coms
if not exist *.com goto objs
del *.com
:objs  
if not exist *.obj goto nobjs
del *.obj
:nobjs
