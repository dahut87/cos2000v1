.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h
include ..\include\divers.h

start:
mov si,offset msg
mov ah,13
int 47h
mov ah,6
int 47h
mov si,offset menu
mov ah,13
int 47h
mov ah,6
int 47h
xor cx,cx
listmcb:
mov ah,4
int 49h
jc fino
inc cx
mov ah,18h
int 47h
push gs
pop ds
mov bh,0
mov si,MB.Names
mov ah,14h
int 47h
mov bh,15
xor edx,edx
mov dx,ds:[MB.Sizes]
shl edx,4
mov ah,0Fh
int 47h
mov bh,24
cmp ds:[MB.IsResident],true
push cs
pop ds
jne notresident
mov si,offset resident
mov ah,14h
int 47h
jmp suitelistmcb
notresident:
mov si,offset nonresident
mov ah,14h
int 47h
suitelistmcb:
mov bh,30
cmp gs:[MB.Reference],0
je next
cmp gs:[MB.Reference],1000h
jb next
mov ax,gs:[MB.Reference]
dec ax
dec ax
mov ds,ax
mov si,MB.Names
mov ah,14h
int 47h
next:
mov bh,46
xor edx,edx
mov dx,gs
inc dx
inc dx
push cx
mov cx,16
mov ah,11h
int 47h
pop cx
mov ah,6h
int 47h
jmp listmcb
fino:
db 0CBh
resident db 'oui',0
nonresident db 'non',0
msg db 'Memory manager V1.5',0
menu db 'Nom          | Taille | Res | Parent        | Mem',0

end start
