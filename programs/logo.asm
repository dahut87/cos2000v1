.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
mov ah,7
mov cx,65535
int 49h
jc problem3
push gs
pop es
mov ah,7
mov cx,65535
int 49h
jc problem3
mov si,offset logo
mov ah,4
xor di,di
int 48h
jc problem


push es
pop ds
push gs
pop es
xor si,si
xor di,di
mov ah,6
int 48h
jc problem2

push es
pop ds

mov ah,28h
int 47h
mov ax,0008h
int 47h
mov ah,2
int 47h
push 0
call cs:[loadbmppalet]
push 150
push 20
push 0
call cs:[showbmp]
jc problem4
push cs
pop ds
push offset poper
call [print]
endofit:
xor ax,ax
int 16h
mov ah,29h
int 47h
retf

problem:
push cs
pop ds
push offset error
call [print]
jmp endofit

problem2:
push cs
pop ds
push offset error2
call [print]
jmp endofit

problem3:
push cs
pop ds
push offset error3
call [print]
jmp endofit

problem4:
push cs
pop ds
push offset error4
call [print]
jmp endofit

poper db '\c0BC\c0CO\c0DS\c0E2\c0E0\c0E0\c0F0 en mode graphique',0
logo db 'cos.rip',0
ok1 db 'Chargement de l''image OK',0
ok2 db 'Decompression de l''image OK',0
error3 db '\c04Une erreur est apparue lors de l''allocation de mémoire',0
error db '\c04Une erreur est apparue lors du chargement de l''image',0
error2 db '\c04Une erreur est apparue lors de la decompression de l''image',0
error4 db '\c0FUne erreur est apparue lors de l''affichage de l''image',0


imports:
        db "VIDEO.LIB::print",0
print   dd 0
        db "BMP.LIB::showbmp",0
showbmp dd 0
        db "BMP.LIB::loadbmppalet",0
loadbmppalet   dd 0
        dw 0
end start
