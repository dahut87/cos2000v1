.model small
.486
smart
.code
org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,offset exports,>

realstart:
push offset message
call [affiche]
call [waitkey]
retf

message db 'Appel de la librairie video !',0


imports:
        db "VIDEO.LIB::print",0
affiche dd 0
        db "EXEM-LIB.LIB::waitkey",0
waitkey dd 0
        dw 0
exports:

end start
