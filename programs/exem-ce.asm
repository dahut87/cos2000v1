.model small
.486
smart
.code
org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,offset exports,>

realstart:
call [affiche]
call [waitkey]
call [bye]
retf


imports:
        db "EXEM-LIB.LIB::affiche",0
affiche  dd 0
        db "EXEM-LIB.LIB::waitkey",0
waitkey  dd 0
        db "EXEM-LIB.LIB::bye",0
bye  dd 0
        dw 0
exports:

end start
