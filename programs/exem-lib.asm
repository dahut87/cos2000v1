.model tiny
.486
smart
.code
org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,offset exports,>


getvar2:
mov ax,0
int 16h
retf


imports:

exports:
         db "waitkey",0
         dw getvar2
         dw 0
end start
