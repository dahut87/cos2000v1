.model tiny
.386c
.code
org 0h
             
                
start:
    mov ah,28h
    int 47H
    mov ax,0002
    int 47H   
replay:
    mov ah,2
    int 47h
mov ah,21
mov cl,7
int 47h
    xor di,di
    xor cx,cx
        mov ah,20
        mov bx,1D00h
        mov si,offset Msg
        int 47h
        mov ah,20
        mov bx,0231h
        mov si,offset msgapp
        int 47h
        mov bp,1000h
VerifAll:
        mov ah,1
        int 16h
        jz nokey
        cmp al,' '
        je enend
nokey:
        mov ax,cx
        inc ax
        mov si,100
        mul si
        mov si,2880
        div si
        xor edx,edx
        mov dx,ax
        mov ah,15
        mov bx,0A14h
        int 47h
        mov ah,13
        mov si,offset po
        int 47h
        mov ah,15
        mov dx,cx
        inc dx
        mov bx,0A10h
        int  47h
        mov ah,13
        mov si,offset Msg2
        int 47h
        mov ah,8         
        mov edx,0
        mov dx,di
        int  47h
        mov ah,13
        mov si,offset Msg3
        int 47h 
    call gauge
    mov ah,2
    int 48h
    jc errors
    je noprob
    inc di
    noprob:
    inc cx
    cmp cx,2880
    jnz verifall
 enend:
 cmp di,0
 je noatall
mov bx,0E09h
mov ah,20
mov si,offset error2
int 47h
 jmp someof
 noatall:
mov bx,0E09h
mov ah,20
mov si,offset noerror
int 47h
 someof:
  mov ah,0
  int 16h
  mov ah,29h
    int 47H
    db 0CBH
 errors:
mov ah,21
mov cl,4
int 47h
mov bx,0D09h
mov ah,20
mov si,offset errore
int 47h
mov ah,0
int 16h
  mov ah,29h
    int 47H
db 0CBH



errore db 'Erreur avec le lecteur de disquette !',0
noerror db 'Pas de secteurs defectueux, appuyez sur une touche pour continuer',0
error2 db 'Le disque est defectueux, appuyez sur une touche pour quitter',0
po db ' %',0
msgapp db '<Pressez espace pour quitter>',0
msg db '- Test de surface du disque -',0
msg2 db ' cluster testes.           ',0
msg3 db ' cluster defectueux.       ',0
;->Increment CX
gauge:
push ax bx cx dx si ds
push cs
pop ds
mov ax,cx
mul sizes
div max
mov dx,ax
mov bl,oldvalue
xor bh,bh
mov byte ptr [offset gaugetxt+bx],'л'
cmp bx,0
jnz nono2
mov ah,21
mov cl,8
int 47h
mov bx,xy
mov ah,20
mov si,offset gaugetxt
int 47h
mov ah,21
mov cl,7
int 47h
nono2:
mov bx,dx
xor bh,bh
mov byte ptr [offset gaugetxt+bx],0
mov oldvalue,bl
mov bx,xy
mov ah,20
mov si,offset gaugetxt
int 47h
pop ds si dx cx bx ax
ret
oldvalue db 0
max dw 2880
sizes dw 50
xy dw 0A12h
gaugetxt db 'ллллллллллллллллллллллллллллллллллллллллллллллллллллллллл',0
End Start
