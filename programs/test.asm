.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
mov ah,28h
int 47h

push word ptr 0FFFFh
push dword ptr 652201
push dword ptr 1545454545
push word ptr 1523
push word ptr 2041
push offset zero
push offset fixe
push word ptr 5
push word ptr 'i'
push word ptr 'a'
push dword ptr 5041
push dword ptr 125645
push dword ptr 5041
push dword ptr 125645
push dword ptr 5041
push dword ptr 125645
push offset message
call [print]
mov ax,0
int 16h

mov ah,2
int 47h
mov ah,30
int 47h
mov ah,2
int 47h

mov cx,200
go1:
mov ah,30
int 47h
mov ah,33
int 47
push offset textdemo1
call [print]
call put
mov ah,30
int 47h
mov ah,33
int 47h
dec cx
jnz go1

mov cx,200
go2:
mov ah,30
int 47h
mov ah,33
int 47h
push offset textdemo2
call [print]
call put
mov ah,30
int 47h
mov ah,33
int 47h
dec cx
jnz go2

mov cx,200
go3:
mov ah,30
int 47h
mov ah,33
int 47h
push offset textdemo3
call [print]
call put
mov ah,30
int 47h
mov ah,33
int 47h
dec cx
jnz go3

mov ah,30
int 47h
mov ah,2
int 47h
push offset texte2
call [print]
mov ah,30
int 47h
mov ah,2
int 47h
mov ah,30
int 47h

mov bp,255
xor edx,edx
go4:
mov ah,30
int 47h
mov ah,33
int 47h
inc edx
push edx
push offset texte3
call [print]
mov ah,30
int 47h
mov ah,33
int 47h
dec bp
jnz go4
push offset texte4
call [print]
mov ax,0
int 16h
mov ah,29h
int 47h
retf

put:
call random
mov di,dx
and di,4096-2
mov si,offset fond
call showstring2
ret

Random:      
push ax
MOV AX,cs:[RandSeed]
MOV DX,8405h
MUL DX
INC AX
MOV cs:[RandSeed],AX
pop ax
ret
		  
randseed        dw 1234h   

Randomize:        
push ax	cx dx
mov ah,0
int 1ah
mov cs:randseed,dx
pop dx cx ax
ret
		  
zero db 'Chaine a z‚ro terminal',0
fixe db 20,'Chaine a taille fixe'
message db "\m01\e\c07\h01D‚monstration de la librairie VIDEO.LIB\l\l"
        db "\c01Nombres entiers ou sign‚s (%%u/%%i):\l%u\l%iD\l"
        db "\c02Nombre hexad‚cimaux (%%h):\l%hD\l%hW\l"
        db "\c03Nombres Binaires (%%b):\l%bD\l%bB\l"
        db "\c04Caracteres simples ou multiples (%%c/%%cM):\l%c\l%cM\l"
        db "\c05Chaines a z‚ro terminal ou fixes (%%0/%%s):\l%s\l%0\l"
        db "\c06Dates et heures (%%t/%%d):\l%t\l%d\l"
        db "\c07Nombre a echelle automatique (%%z):\l%z\l%z\l"
        db "\c08Attributs de fichiers (%%a):\l%a",0

fond       db 16,'Ceci est un fond'
textdemo1  db '\c05Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling\l',0
textdemo2  db '\c07Vertical Vertical Vertical Vertical Vertical Vertical Vertical Vertical\l',0
textdemo3  db '\c09Rapide Rapide Rapide Rapide Rapide Rapide Rapide Rapide\l',0
texte1     db 'Echange rapide de pages Vid‚o',0
texte2     db '\g04,13Routine d''affichage Ultra Rapide Agissant sur le Mat‚riel'
           db '\g04,14Possibilit‚ de r‚aliser des effets de superposition',0
texte3     db '\c04%bD\l',0
texte4     db '\g01,00Sauvegarde et restauration de l''ecran (%%s/%%r)',0

showstring2:
        push    es bx cx si di
        add     di,4000
        mov     bx,0B800h
        mov     es,bx
        mov     bl,[si]
        mov     ch,3
strinaize4:
        inc     si
        mov     cl,[si]
        mov     es:[di],cx
        add     di,2
        dec     bl
        jnz     strinaize4
        pop     di si cx bx es
        ret

imports:
        db "VIDEO.LIB::print",0
print   dd 0
        dw 0

end start
