.model tiny
.486
smart
.code

org 0100h

include ..\include\fat.h

start:
mov ah,2
int 47h
mov ah,25
mov bx,0
int 47h
mov ah,21
mov cl,70h
int 47h
mov ah,13
mov si,offset msg1
int 47h
mov ah,21
mov cl,7
int 47h 
mov ah,13
mov si,offset prompt
int 47h
mov ah,13
mov si,offset infos
int 47h
mov ah,13
mov si,offset prompt
int 47h
mov ah,3
int 48h
xor bp,bp
mov di,offset bufferentry
mov si,di
mov ah,7
int 48h
jc nofiles
go:
test 	[si+Entries.FileAttr],00010000b
je	notdirectory
mov ah,21
mov cl,4
int 47h
jmp notall
notdirectory:
cmp [si+Entries.FilExt],'E'
jne notexe
cmp [si+Entries.FilExt+1],'X'
jne notexe
cmp [si+Entries.FilExt+2],'E'
jne notexe
mov ah,21
mov cl,5
int 47h
jmp notall
notexe:
cmp [si+Entries.FilExt],'S'
jne notsys
cmp [si+Entries.FilExt+1],'Y'
jne notsys
cmp [si+Entries.FilExt+2],'S'
jne notsys
mov ah,21
mov cl,0Ah
int 47h
jmp notall
notsys:
mov ah,21
mov cl,7h
int 47h
notall:
mov ah,46
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,44
mov dx,[si+Entries.FileDateCrea]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,45
mov dx,[si+Entries.FileTimeCrea]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,44
mov dx,[si+Entries.FileDate]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,45
mov dx,[si+Entries.FileTime]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,48
mov edx,[si+Entries.FileSize]
int 47h
mov ah,05
int 47h
int 47h
int 47h
mov ah,47
mov dl,[si+Entries.FileAttr]
int 47h
mov ah,6
int 47h
inc bp
mov ah,8
int 48h
jnc go
nofiles:
mov ah,21
mov cl,70h
int 47h
mov ah,13
mov si,offset menu
int 47h
mov xx,1
mov xxold,2
call Select
endof:
mov ax,0
int 16h
     cmp ah,50h
     jne tre1
     cmp xx,bp
     je endof
     inc xx
     call select
     jmp endof
tre1:
     cmp ah,48h
     jne tre2
     cmp xx,1
     je endof
     dec xx
     call select
     jmp endof
tre2:
     cmp al,0Dh
     jne tre3 
tre3:
     cmp ah,59
     jne tre4
     jmp start
tre4:
     cmp ah,67
     jne endof
      db      0CBh

;selectionne la ligne xx
Select:
push ax di
mov di,xxold
mov al,7
add di,3
mov ah,32
int 47h
mov ax,xx
mov xxold,ax
mov di,xx
mov ah,32
mov al,112
add di,3
int 47h
pop di ax
ret      

xx dw 1
xxold dw 0
menu db '[F1] Lire disque [F9] Quitter                                                   ',0
msg1 db '                       Gestionnaire de fichier Version 1.0                      ',0
msg2 db 'Programme en cours de chargement',0   
prompt db '--------------------------------------------------------------------------------',0
infos  db 'Nom      Ext.  Date creation           Date modification      Taille   Attributs',0   

bufferentry equ $

end start
