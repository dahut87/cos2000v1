.model tiny
.486
smart
.code
org 0100h  


start:
mov ah,26
int 47h
mov ax,0001
int 47h
mov ah,2
int 47h

mov si,offset text1      ;titre
mov ah,13
int 47h
mov ah,6
int 47h
int 47h

mov ah,21
mov cl,3
int 47h
mov ah,13
mov si,offset text2
int 47h
mov ah,6
int 47h
mov edx,2612182686
mov ah,8
int 47h
mov ah,6
int 47h
mov edx,7576534
mov ah,8
int 47h
mov ah,6
int 47h

mov ah,21
mov cl,4
int 47h
mov si,offset text3
mov ah,13
int 47h
mov ah,6
int 47h
mov edx,-6876253
mov cx,32
mov ah,9
int 47h
mov ah,6
int 47h
mov edx,-311212323
mov cx,32
mov ah,9
int 47h
mov ah,6
int 47h

mov ah,21
mov cl,5
int 47h  
mov ah,13
mov si,offset text4
int 47h
mov ah,6
int 47h
mov edx,0892325457
mov cx,16
mov ah,10
int 47h
mov ah,6
int 47h
mov edx,0236514
mov ah,10
mov cx,32
int 47h
mov ah,6
int 47h

mov ah,21
mov cl,6
int 47h
mov ah,13
mov si,offset text5
int 47h
mov ah,6
int 47h     
mov edx,3762182686
mov ah,11
mov cx,32
int 47h
mov ah,6
int 47h
mov edx,2182686
mov ah,11
mov cx,16
int 47h
mov ah,6
int 47h

mov ah,21
mov cl,7
int 47h
mov ah,13
mov si,offset text6
int 47h
mov ah,6
int 47h
mov dl,'h'
mov ah,7
int 47h
mov ah,6
int 47h
mov dl,'@'
mov ah,7
int 47h
mov ah,6
int 47h

mov ah,21
mov cl,8
int 47h
mov ah,13
mov si,offset text7
int 47h
mov ah,6
int 47h
mov si,offset textt
mov ah,13
int 47h
mov ah,6
int 47h
mov si,offset texttt
mov ah,13
int 47h 

mov ax,0
int 16h

mov ah,2
int 47h
mov ah,30
int 47h
mov ah,2
int 47h

mov ah,21
mov cl,5
int 47h  
mov cx,200
go1:
mov ah,30
int 47h
mov ah,33
int 47
mov ah,20
xor bh,bh
inc bl
mov si,offset text8 
int 47h   
call put
mov ah,30
int 47h
mov ah,33
int 47h
dec cx
jnz go1

mov ah,21
mov cl,7
int 47h
mov cx,200
go2:
mov si,offset text9
mov ah,30
int 47h
mov ah,33
int 47h
mov ah,6
int 47h
mov ah,13
int 47h
call put
mov ah,30
int 47h
mov ah,33
int 47h
dec cx
jnz go2

mov ah,21
mov cl,9
int 47h
mov cx,200
go3:
mov si,offset text10
mov ah,30
int 47h
mov ah,33
int 47h
xor bh,bh
inc bl
mov ah,20
int 47h
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
mov bx,040Dh
mov si,offset texte1
mov ah,20
int 47h
mov si,offset texte2
inc bl
mov ah,20
int 47h
mov ah,30
int 47h
mov ah,2
int 47h
mov ah,30
int 47h

mov cl,12
mov ah,21
int 47h
mov bp,255
xor edx,edx
go4:
mov ah,30
int 47h
mov ah,33
int 47h
inc edx
mov ah,11
mov cx,16
int 47h
mov ah,6
int 47h
mov ah,30
int 47h
mov ah,33
int 47h
dec bp
jnz go4
mov ah,27
int 47h
xor bx,bx
mov si,offset texte3
mov ah,20
int 47h
mov ax,0
int 16h
db 0CBh

put:
call random
mov di,dx
and di,4096-2
mov si,offset text11
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
		  
texttt db 'Texte',0
textt db 'Divers',0
text1 db ' D‚monstration de l''utilisation de la bibliothŠque VIDEO',0
text2 db 'Nombre entier :',0
text3 db 'Nombre sign‚ :',0
text4 db 'Nombre h‚xad‚cimal :',0
text5 db 'Nombre binaire :',0
text6 db 'CaractŠres :',0
text7 db 'Texte :',0
text8 db 'Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling',0
text9 db 'Vertical Vertical Vertical Vertical Vertical Vertical Vertical Vertical',0
text10 db 'Rapide Rapide Rapide Rapide Rapide Rapide Rapide Rapide',0
text11 db 'Echange rapide de pages Vid‚o',0
texte1 db 'Routine d''affichage Ultra Rapide Agissant sur le Mat‚riel',0
texte2 db 'Possibilit‚ de r‚aliser des effets de superposition',0
texte3 db 'Sauvegarde et restauration de l''ecran',0

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



end start
