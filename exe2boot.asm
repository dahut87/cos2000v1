.model tiny
.486
smart
.code

org 0100h


start:
jmp transform
NameBoot db 'Boot.exe',0
nameboot2 db 'Boot.bin',0
buffer db 510 dup (0)
       dw 0AA55h
message db 0ah,0dh,'Transformation of boot.com to boot.bin...',0ah,0dh,'By Horde Nicolas',0ah,0dh,'Copyright 2000',0ah,0dh,'$'
ok db 0ah,0dh,'The transformation was done succefully !',0ah,0dh,'$'
errormsg db 0ah,0dh,'Some errors has been detected !',0ah,0dh,'$'
transform:
mov ah,09
mov dx,offset message
int 21h
mov ax,3D00h
mov dx,offset nameboot
int 21h
jc error
mov bx,ax
mov ax,4202h
xor cx,cx
xor dx,dx
int 21h
jc error
cmp dx,0
jne error
mov ax,4200h
xor cx,cx
mov dx,7E00h
int 21h
jc error
mov ah,3fh
mov cx,512
mov dx,offset buffer
int 21h
jc error
mov ah,3eh
int 21h
jc error
mov ah,3ch
xor cx,cx
mov dx,offset nameboot2
int 21h
jc error
mov ah,40h
mov cx,512
mov dx,offset buffer
int 21h
jc error
mov ah,09
mov dx,offset ok
int 21h
ret
error:
mov ah,09
mov dx,offset errormsg
int 21h
ret

end start
