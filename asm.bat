@echo off
del system.bin
ren id.com system.bin
tasm boot.asm /t/x/m4
tlink boot.obj /x
del boot.obj
exe2boot.com
del boot.exe
cosinit.com
