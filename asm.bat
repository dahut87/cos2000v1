@echo off
del system.bin
tasm boot.asm /t/x/m4
tasm mem.asm /t/x/m4
tasm choise.asm /t/x/m4
tasm vg2.asm /t/x/m4
tasm sect.asm /t/x/m4
tlink boot.obj /x
del boot.obj
exe2boot.com
del boot.exe
cosinit.com
