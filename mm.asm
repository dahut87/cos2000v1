.model tiny
.486
smart
.code

org 0100h

start:
mov ah,2
int 74h
jc error
mov si,offset dnoerror
jmp noerror
error:
mov si,offset derror
noerror:
mov ah,20
mov bx,1010h
int 47h
mov ax,0
int 16h
xor edx,edx
popr:
mov ah,3
int 74h
mov ah,6
int 47h
mov si,bx
mov di,cx
mov ah,9
mov cx,8
int 47H
mov ah,5
int 47H
mov dx,si
mov ah,9
mov cx,8
int 47H
mov ah,5
int 47h
mov dx,di
mov ah,9
mov cx,8
int 47H 
jmp popr
db 0CBh

dnoerror db 'Souris d‚tect‚e en PS/2',0
derror db 'Souris non d‚tect‚e',0


end start
