.model tiny
.486
smart
.code

org 0100h

include ..\include\mem.h
include ..\include\divers.h

start:
mov si,offset msg
mov ah,13
int 47h
mov ah,6
int 47h
mov ah,0
int 49h

xor cx,cx
listmcb:
mov ah,06h
int 47h
mov ah,4
int 49h
jc fino
inc cx
push gs
pop ds
mov si,MB.Names
mov ah,0Dh
int 47h
mov ah,05h
int 47h
xor edx,edx
mov dx,ds:[MB.Sizes]
shl edx,4
mov ah,08
int 47h
mov ah,05h
int 47h
push cs
pop ds
cmp ds:[MB.Sizes],true
jne notresident
mov si,offset resident
mov ah,0Dh
int 47h
mov ah,05h
int 47h
jmp listmcb
notresident:
mov si,offset nonresident
mov ah,0Dh
int 47h
fino:
push cs
pop ds
mov si,offset findesprog
mov ah,0Dh
int 47h
mov ax,0
int 16h
db 0CBh
findesprog db '********* FIN ***********',0
resident db 'Resident',0
nonresident db 'Volatile',0
msg db 'Memory manager V1.0',0

end start
