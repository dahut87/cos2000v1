.model tiny
.486
smart
.code

org 0100h

start:
go:
call calc
jmp go
ret

calc:
pusha
mov ah,2Ch
int 21h
mov bh,dh
xor ebp,ebp
wait2:
xor bl,bl
waits:
mov dx,3dah
in al,dx
and al,1000b
jz wait2
cmp bl,1
je waits
inc ebp
inc bl
cmp ebp,300
jne waits
mov ah,2Ch
int 21h
sub dh,bh
mov bl,dh
xor bh,bh
mov ax,bp
shr ebp,16
mov dx,bp
div bx
xor edx,edx
mov dx,ax
call showint
popa
ret

;===================================Afficher un int EDX a l'‚cran en ah,al================
ShowInt:
        push    eax bx cx edx esi di es ds
        mov     di,0
        mov     cx,0B800h
        mov     es,cx
        xor     cx,cx
        mov     eax,edx
        mov     esi,10
        mov     bx,offset showbuffer+27
decint3:
        xor     edx,edx
        div     esi
        add     dl,'0'
        mov     dh,cs:colors
        sub     bx,2
        add     cx,2
        mov     cs:[bx],dx
        cmp     ax,0
        jne     decint3
        mov     si,bx
        push    cs
        pop     ds
        cld
        rep     movsb
        pop     ds es di esi edx cx bx eax 
ret       
showbuffer db 35 dup (0FFh)

colors equ 1


;40*25 16 couleurs
mode0        DB 67H,00H,  03H,08H,03H,00H,02H
             DB 2DH,27H,28H,90H,2BH,0A0H,0BFH,01FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,8EH,8FH,14H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,01H,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,08H,00H
             db 40,25

;80*25 16 couleurs
mode1        DB 67H,00H,  03H,00H,03H,00H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,1FH,96H,0B9H,0A3h,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,6H,7H,8H,9H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 0CH,00H,0FH,08H,00H
             db 80,25

;80*50 16 couleurs
mode2        DB 67H, 00H, 03H,00H,03H,00H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9CH,8EH,8FH,28H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             db 80,50

;100*50 16 couleurs
mode3        DB 067H , 00H, 03H,01H,03H,00H,02H
             DB 70H, 63H , 64H ,85H,68H,84H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9Ch, 08EH ,8FH, 32H ,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             db 100,50


;100*60 16 couleurs
mode22        DB 067H , 00H, 03H,01H,03H,00H,02H
             DB 70H, 63H , 64H ,85H,68H,84H,0FFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,0E7H,8EH,0DFH,32H,1FH,0DFH,0E5H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             db 100,60


Sequencer equ 03C4h
misc equ 03C2h
misc2 equ 03CCh
CCRT equ 03D4h
Attribs equ 03C0h
graphic equ 03CEh
statut equ 3DAh

;====Met les cl registres cons‚cutif … ds:si du port dx
Setregs:
push ax  
xor ax,ax
initreg:
mov ah,[si]
out dx,ax
inc al
inc si
cmp al,cl
jb initreg    
pop ax  
ret

;met une serie de registres Cl a partir du port dx 
Setlowregs:
push ax bx 
xor bx,bx
cmp cl,0
je only
initreg2:
mov al,bl
out dx,al
only:
mov al,[si]
out dx,al
inc bl
inc si
cmp bl,cl
jb initreg2    
pop bx ax 
ret    

Setvideomode:
push ax cx dx si
xor ah,ah
mov si,ax
shl si,6
add si,offset mode0 
xor cx,cx
mov dx,misc
call setlowregs
mov dx,statut
call setlowregs
mov dx,sequencer
mov cl,5
call setregs
mov ax,0E11h
mov dx,ccrt
out dx,ax      
mov cl,25
call setregs
mov dx,graphic
mov cl,9
call setregs
mov dx,attribs
mov cl,20
call setlowregs
mov al,20h
out dx,al   
pop dx cx ax si
ret

;====Met les cl registres cons‚cutif … en es:DI du port dx TOUT REGISTRES
getregs:
push ax bx dx
xor bx,bx
cmp cl,0
je only2
initreg4:
mov al,bl
out dx,al
cmp dx,3C1h
je only2
inc dx
only2:
in al,dx
mov es:[di],al
dec dx
inc bl
inc di
cmp bl,cl
jb initreg4    
pop dx bx ax 
ret  

;====Met le mode video present dans Es:di
getvideomode:
push ax cx dx di
xor cx,cx
mov dx,misc2
call getregs
mov dx,statut
call getregs
mov dx,sequencer
mov cl,5
call getregs
mov dx,ccrt
mov cl,25
call getregs
mov dx,graphic
mov cl,9
call getregs
mov dx,attribs
mov cl,20
call getregs
mov al,20h
out dx,al  
pop di dx cx ax
ret

;mode s‚curis‚ al
Safemode:
push cx si di ds es
call setvideomode
mov di,offset buffer
push cs
pop es
push cs
pop ds
call getvideomode
mov byte ptr es:[di+1],0
mov si,offset mode1
mov di,offset buffer
mov cx,62
rep cmpsb
jne errormode
clc
endsafe:
pop ds es di si cx 
ret
errormode:
stc
jmp endsafe



buffer db 0

end start
