.model tiny
.386c
.code
org 0100h
             
                
start:
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
xor si,si

mov ah,28h
int 47h
mov ax,0008h
int 47h
mov ah,2
int 47h
mov cx,300
mov bx,30
mov ah,37
int 47h
mov ah,15h
mov cl,11
int 47h
push cs
pop ds
mov ah,13
mov si,offset poper
int 47h
mov ax,0
int 16h
mov ah,29h
int 47h
db 0CBH      

problem:
push cs
pop ds
mov ah,13
mov si,offset error
int 47h
mov ax,0
int 16h
db 0CBh

problem2:
push cs
pop ds
mov ah,13
mov si,offset error2
int 47h
mov ax,0
int 16h
db 0CBh

problem3:
push cs
pop ds
mov ah,13
mov si,offset error3
int 47h
mov ax,0
int 16h
db 0CBh

poper db 'COS2000 en mode graphique',0
logo db 'cos.rip',0
ok1 db 'Chargement de l''image OK',0
ok2 db 'Decompression de l''image OK',0
error3 db 'Une erreur est apparue lors de l''allocation de mémoire',0
error db 'Une erreur est apparue lors du chargement de l''image',0
error2 db 'Une erreur est apparue lors de la decompression de l''image',0
end start
