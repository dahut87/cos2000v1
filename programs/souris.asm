.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
mov ah,2
int 74h
push offset message
call [print]
retf

message db 'Activation de la souris',0

imports:
        db "VIDEO.LIB::print",0
print   dd 0
        dw 0

end start
