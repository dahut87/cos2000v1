.model tiny
.486
smart
.code
org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,offset exports,>

getvar:
push ds
push cs
pop ds
mov si,offset mes
mov ah,13
int 47h
pop ds
retf
mes db 'c un test qui illustre les appels de fonctions externes !!!',0

getvar2:
mov ax,0
int 16h
retf

mettar:
push ds
push cs
pop ds
mov si,offset mes2
mov ah,13
int 47h
pop ds
retf
mes2 db 'Cela fonctionne.',0

imports:

exports:
         db "affiche",0
         dw mettar
         db "waitkey",0
         dw getvar2
         db "bye",0
         dw getvar
         dw 0
end start
