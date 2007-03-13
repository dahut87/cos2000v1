.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h
include ..\include\fat.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
push offset msg1
call [print]

mov ah,3
int 48h
xor bp,bp
mov di,offset bufferentry
mov ah,7
int 48h
jc nofiles
go:
push word ptr [di+Entries.FileAttr]
push dword ptr [di+Entries.FileSize]
push word ptr [di+Entries.FileTime]
push word ptr [di+Entries.FileDate]
push word ptr [di+Entries.FileTimeCrea]
push word ptr [di+Entries.FileDateCrea]
push di
push offset line
call [print]
inc bp
mov ah,8
int 48h
jnc go
nofiles:
push offset menu
call [print]
mov xx,1
mov xxold,2
call Select
endof:
mov ax,0
int 16h
     cmp ah,50h
     jne tre1
     cmp xx,bp
     ja endof
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
     jmp realstart
tre4:
     cmp ah,67
     jne endof
     retf

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
menu db '\c70 [F1] Lire disque [F9] Quitter                                                  \c07',0
msg1 db '\e\g00,00\c70                       Gestionnaire de fichier Version 1.5                      '
     db '\g00,01\c07--------------------------------------------------------------------------------'
     db '\g00,02Nom      Ext.  Date creation           Date modification      Taille   Attributs'
     db '\g00,03--------------------------------------------------------------------------------\l',0
line db '\c07%n   %d   %t   %d   %t   %z   %a\l',0
bufferentry db 512 dup (0)


imports:
        db "VIDEO.LIB::print",0
print   dd 0
        dw 0

end start
