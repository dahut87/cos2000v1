.model tiny
.486
smart
.code

org 0100h

start:

Tsr:
cli
cmp ax,1234h
jne nomore
mov ax,4321h
jmp itsok
nomore:
push bx
mov bl,ah
xor bh,bh
shl bx,1
mov bx,cs:[bx].tables
mov cs:current,bx
pop bx
call cs:current
itsok:
jnc noerror
push bp
mov bp,sp
or byte ptr [bp+6],1b
pop bp
mov ax,cs
shl eax,16
mov ax,cs:current
jmp endofint
noerror:
push bp
mov bp,sp
and byte ptr [bp+6],0FEh
pop bp
endofint:
sti
iret
current dw 0
tables   dw setvideomode
         dw getvideomode
         dw cleartext
         dw changefont
         dw loadfont
         dw space
         dw line
         dw showchar
         dw showint
         dw showsigned
         dw showhex
         dw showbin
         dw showstring
         dw showstring0
         dw showcharat
         dw showintat
         dw showsignedat
         dw showhexat
         dw showbinat
         dw showstringat
         dw showstring0at
         dw setcolor
         dw getcolor
         dw scrolldown
         dw getxy
         dw setxy2
         dw savescreen
         dw restorescreen
         dw page2to1
         dw page1to2
         dw xchgPages
         dw savepage1
         dw changelineattr
         dw waitretrace
         dw getinfos

;Change la police a CL
changefont:
push ax cx dx
mov ah,cl
and cl,11b
and ah,0100b
shl ah,2
add ah,cl
mov dx,3C4h
mov al,3
out dx,ax
pop dx cx ax
ret        

;met la police BL … ds:si taille dans CL
loadfont:
push ax bx cx dx si di es
xor di,di
mov dx,3C4h
cli  
doseq:   
mov ax,cs:[di+offset reg1]
out dx,ax
inc di
inc di
cmp di,6
jbe doseq
mov dx,3CEh
doseq2:   
mov ax,cs:[di+offset reg1]
out dx,ax
inc di
inc di
cmp di,6+6
jbe doseq2
sti
mov ax,0A000h
mov es,ax
mov dx,255
mov al,0
xor bh,bh
cmp bl,4
jb isless
sub bl,4
shl bl,1
inc bl
jmp okmake
isless:
shl bl,1
okmake:
mov di,bx
shl di,13
mov bh,cl
mov bl,cl
sub bl,32
neg bl
xor cx,cx
cld
popz:
mov cl,bh
rep movsb
mov cl,bl
rep stosb
dec dx
jnz popz 
xor di,di
mov dx,3C4h
doseqs:   
mov ax,cs:[di+offset reg2]
out dx,ax
inc di
inc di
cmp di,6
jbe doseqs
mov dx,3CEh
doseqs2:   
mov ax,cs:[di+offset reg2]
out dx,ax
inc di
inc di
cmp di,6+6
jbe doseqs2
pop es di si dx cx bx ax
ret    
reg2 dw 0100h, 0302h, 0304h, 0300h 
     dw 0004h, 1005h, 0E06h 
reg1 dw 0100h, 0402h, 0704h, 0300h
     dw 0204h, 0005h, 0406h                   

;40*25 16 couleurs
mode0        DB 67H,00H,  03H,08H,03H,00H,02H
             DB 2DH,27H,28H,90H,2BH,0A0H,0BFH,01FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,8EH,8FH,14H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,08H,00H
             db 40,25

;80*25 16 couleurs
mode1        DB 67H,00H,  03H,00H,03H,00H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,1FH,96H,0B9H,0A3h,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,08H,00H
             db 80,25

;80*50 16 couleurs
mode2        DB 67H, 00H, 03H,00H,03H,01H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9CH,8EH,8FH,28H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             db 80,50

;100*50 16 couleurs
mode3        DB 067H,00H,03H,01H,03H,01H,02H
             DB 70H,63H,64H,85H,68H,84H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9Ch,08EH,8FH,32H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             db 100,50


;100*60 16 couleurs
mode4b        DB 067H,00H,03H,01H,03H,01H,02H
             DB 70H,63H,64H,85H,68H,84H,0FFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,0E7H,8EH,0DFH,32H,1FH,0DFH,0E5H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             db 100,60


;320*200 16 couleurs
mode4      DB 63H,00H,  03H,09H,0FH,00H,06H
             DB 2DH,27H,28H,90H,2BH,080H,0BFH,01FH,00H,0C0H,00H,00H,00H,00H,00H,00H
             DB 9CH,8EH,8FH,14H,00H,96H,0B9H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,00H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             db 40,25

;320*200 256 couleurs
mode5        DB 63H, 00H,  03H,01H,0FH,00H,0EH
             DB 5FH,4FH,50H,82H,54H,80H,0BFH,1FH,00H,41H,00H,00H,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,40H,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             db 00,00

;640*400 16 couleurs
mode6        DB 63H, 00H,  03H,01H,0FH,00H,0EH
             DB 5FH,4FH,50H,82H,54H,80H,0BFH,1FH,00H,41H,00H,00H,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,40H,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H 
             db 00,00

;640*400 256 couleurs
mode7        DB 63H, 00H,  03H,01H,0FH,00H,0EH
             DB 2DH,27H,27H,91H,2AH,9FH,0BFH,1FH,00H,0C0H,00H,00H,00H,00H,00H,00H
             DB 9CH,0EH,8FH,50H,00H,8FH,0C0H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H 
             db 00,00




;
;=============CLEAR=========
;Efface l'ecran texte
;-> 
;<- 
;=============================
cleartext:
push es eax cx di
xor di,di
mov ax,0b800h
mov es,ax
mov eax,07200720h
mov cx,cs:pagesize
shr cx,2
cld
rep stosd
mov cs:xy,0
mov cs:x,0
mov cs:y,0
pop di cx eax es
ret

;=============CLEAR=========
;Efface l'ecran texte
;-> 
;<- 
;=============================
clearpixel:
push es eax cx di
xor di,di
mov ax,0A000h
mov es,ax
mov eax,0h
mov cx,cs:pagesize
shr cx,2
cld
rep stosd
pop di cx eax es
ret             

Sequencer equ 03C4h
misc equ 03C2h
CCRT equ 03D4h
Attribs equ 03C0h
graphic equ 03CEh
statut equ 3DAh

initmode:
push bx cx si ds
;xor bx,bx
;mov ds,bx
;lds si,ds:[43h*4]
push cs
pop ds
mov si,offset font
mov cl,8
mov bl,1
call loadfont
pop ds si cx bx
ret

;Renvoie le mode video dans al
getvideomode:
mov al,cs:mode
ret

;====Met le mode video a al
setvideomode:
push ax dx di
cmp cs:mode,0FFh
jne noinit
call initmode
mov cs:pagesize,4000
call cleartext
noinit:
mov cs:mode,al
xor ah,ah
mov di,ax
shl di,6
add di,offset mode0 
mov dx,misc
mov al,cs:[di]
out dx,al
inc di              
mov dx,statut
mov al,cs:[di]
out dx,al 
inc di              
mov dx,sequencer
xor ax,ax
initsequencer:
mov ah,cs:[di]
out dx,ax
inc al
inc di
cmp al,5
jb initsequencer    
mov ax,0E11h
mov dx,ccrt
out dx,ax           
xor ax,ax
initcrt:
mov ah,cs:[di]
out dx,ax
inc al
inc di
cmp al,25
jb initcrt          
mov dx,graphic
xor ax,ax
initgraphic:
mov ah,cs:[di]
out dx,ax
inc al
inc di
cmp al,9
jb initgraphic            
mov dx,statut
in al,dx                          
mov dx,attribs
xor ax,ax
initattribs:
mov ah,cs:[di]
push ax
in ax,dx
pop ax
out dx,al
xchg ah,al
out dx,al
xchg ah,al
inc al
inc di
cmp al,21
jb initattribs
mov al,cs:[di]
mov cs:columns,al
mov ah,cs:[di+1]
mov cs:lines,ah
mul ah
shl ax,1
mov cs:pagesize,ax
mov al,20h
out dx,al
pop di dx ax
ret

;==========SPACE===========
;met un espace apr‚s le curseur
;-> 
;<- 
;=============================
space:
push bx es
add cs:xy,2
mov bx,0B800h
mov es,bx
mov bx,cs:xy
mov byte ptr es:[bx],' '
pop es bx
ret

;==========SHOWCHAR===========
;met un caractŠre apr‚s le curseur
;-> dl
;<- 
;=============================
showchar:
push dx bx es
mov bx,0B800h
mov es,bx
mov bx,cs:xy
mov dh,cs:colors
mov es:[bx],dx
add cs:xy,2
pop es bx dx
ret

;==========SHOWCHARAT===========
;met un caractŠre apr‚s le curseur coord ah,al
;-> dl ah al
;<- 
;=============================
showcharat:
push es di
call setxy
call showchar
pop di es
ret

;==========LINE=========
;remet le curseur a la ligne
;-> 
;<- 
;=============================
line:
push bx cx di es
mov bh,cs:x
mov bl,cs:y
xor bh,bh
mov cl,cs:lines
dec cl
cmp bl,cl
jne scro
dec bl
mov cl,1
call scrolldown
scro:
inc bl
call setxy
pop es di cx bx
ret

;==========SETCOLOR=========
;Change les attributs du texte a CL
;-> CL
;<- 
;=============================
setcolor:
mov cs:colors,CL
ret

;==========GETCOLOR=========
;R‚cupŠre les attributs du texte dans CL
;-> 
;<- CL
;=============================
getcolor:
mov cl,cs:colors
ret

updatecursor:
push ax dx di
mov dx,3D4h
mov al,0Eh
mov di,offset xy
mov ah,cs:[di]
out dx,ax
mov ah,cs:[di+1]
inc al
out dx,ax
pop di dx ax
ret

;==========SCROLLDOWN=========
;defile de cx lines vers le bas
;-> CX
;<- 
;=============================
scrolldown:
push ax cx dx si di ds es
mov si,0B800h
mov es,si
mov ds,si
mov ax,cx
mul cs:columns
shl ax,1
mov si,ax
mov cx,cs:pagesize
sub cx,si
xor di,di
cld
rep movsb
pop es ds di si dx cx ax
ret

;==========GETXY=========
;Change les coordonnées du curseur a X:AL,Y:AH
;-> AX
;<- 
;=============================
getxy:
mov bh,cs:x
mov bl,cs:y
ret

;==========SETXY=========
;Change les coordonnées du curseur a X:AH,Y:AL
;-> AX
;<- es di
;=============================
setxy:
push ax bx dx
mov cs:x,bh
mov cs:y,bl
mov al,bl
mov bl,bh
xor bh,bh
mov di,bx
mul cs:columns
add di,ax
shl di,1
mov cs:xy,di
mov ax,0B800h
mov es,ax
pop dx bx ax
ret

setxy2:
push es di
call setxy
pop di es
ret


;===================================sauve l'ecran rapidement================
SaveScreen:
        push    cx si di ds es
        mov     cx,0B800H
        mov     ds,cx
        push    cs
        pop     es
        mov     cx,cs:pagesize
        shr     cx,2
        xor     si,si
        mov     di,offset Copy2
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===================================sauve l'ecran rapidement================
Savepage1:
        push    cx si di ds es
        mov     cx,0B800H
        mov     ds,cx
        push    cs
        pop     es
        mov     cx,cs:pagesize
        shr     cx,2
        xor     si,si
        mov     di,offset Copy
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===================================sauve l'ecran rapidement================
RestoreScreen:
        push    cx si di ds es
        mov     cx,0B800H
        mov     es,cx
        push    cs
        pop     ds
        mov     cx,cs:pagesize
        shr     cx,2
        mov     si,offset Copy2
        xor     di,di
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===============================Page2to1============================
Page2to1:
        push    cx si di ds es
        mov     cx,0B800H
        mov     es,cx
        mov     ds,cx
        mov     cx,cs:pagesize
        shr     cx,2
        mov     si,4000
        xor     di,di
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===============================Page1to2============================
Page1to2:
        push    cx si di ds es
        mov     cx,0B800H
        mov     es,cx
        mov     ds,cx
        mov     cx,cs:pagesize
        shr     cx,2
        mov     di,4000
        xor     si,si
        cld
        rep     movsd
        pop     ds es di si cx 
        ret
 
;===============================xchgPages============================
xchgPages:
        push    cx si di ds es
        call    savepage1
        call    page2to1
        mov     cx,0B800H
        mov     es,cx
        push    cs
        pop     ds
        mov     cx,cs:pagesize
        shr     cx,2
        mov     si,offset Copy
        mov     di,4000
        rep     movsd
        pop     es ds di si cx 
        ret

;===================================Afficher un int EDX a l'‚cran en ah,al================
ShowInt:
        push    eax bx cx edx esi di es ds
        mov     di,cs:xy
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
        mov     cs:xy,di
        pop     ds es di esi edx cx bx eax 
ret       
showbuffer db 35 dup (0FFh)

;===================================Afficher un int EDX a l'‚cran en ah,al================
ShowIntat:
push es di
        call    setxy
        call    showint
pop di es
ret

waitretrace:
push ax dx
mov dx,3DAh
waitr:
in al,dx
test al,8
jz waitr
pop dx ax
ret

nbexactbit:
push edx
xor cx,cx
viewnb:
inc cx
shr edx,1
cmp edx,0
jnz viewnb
pop edx
ret

bittobyte:
push dx
adap:
mov dx,cx
and dx,3
jz adapfin
add cx,1
jmp adap
adapfin:
pop dx
ret

Nbbit:
cmp edx,0FFh
jb ok1
cmp edx,0FFFFh
jb ok2
mov cx,32
ret
ok1:
mov cx,8
ret
ok2:
mov cx,16
ret   

showhexat:
push es di
        call    setxy
        call    showhex
pop di es
ret      

showbinat:
push cx es di
call setxy
call showbin
pop di es cx
ret

;==============================Affiche le nombre nb binaire en EDX==============
Showbin:
        push    es ax bx cx di
        mov     di,cs:xy
        mov     bx,0B800h
        mov     es,bx
        mov     ax,cx
        sub     cx,32
        neg     cx
        shl     edx,cl
        mov     ch,cs:colors
binaize:
        rol     edx,1
        mov     cl,'0'
        adc     cl,0  
        mov     es:[di],cx
        add     di,2
        dec     al
        jnz     binaize
        mov     cs:xy,di
        pop     di cx bx ax es
        ret

;==============================Affiche le nombre nb hexa en EDX==============
ShowHex:
        push    es ax bx cx di
        mov     di,cs:xy
        mov     bx,0B800h
        mov     es,bx
        mov     ax,cx
        sub     cx,32
        neg     cx
        shl     edx,cl
        mov     ch,cs:colors
        shr     ax,2
Hexaize:
        rol     edx,4
        mov     bx,dx
        and     bx,0fh
        mov     cl,cs:[bx+offset Tab]
        mov     es:[di],cx
        add     di,2
        dec     al
        jnz     Hexaize
        mov     cs:xy,di
        pop     di cx bx ax es
        ret
Tab db '0123456789ABCDEF'

;===================================Afficher un int EDX a l'‚cran en ah,al================
Showsigned:
push ax ebx edx es
xor ebx,ebx
mov bl,cl
bt edx,ebx
jnc pos
neg edx 
mov ah,cs:colors
mov al,'-'
mov bx,0B800h
mov es,bx
mov bx,cs:xy
mov word ptr es:[bx],ax
add cs:xy,2
pos:
call showint 
pop es edx ebx ax
ret

showsignedat:
push es di
call setxy
call showsigned
pop di es 
ret

;================Affiche la chaine de caractŠre contenue dans ds:si
showstring:
        push    es bx cx si di
        mov     di,cs:xy
        mov     bx,0B800h
        mov     es,bx
        mov     bl,[si]
        mov     ch,cs:colors
strinaize:
        inc     si
        mov     cl,[si]
        mov     es:[di],cx
        add     di,2
        dec     bl
        jnz     strinaize
        mov     cs:xy,di
        pop     di si cx bx es
        ret

;================Affiche la chaine 0 de caractŠre contenue dans ds:si
showstring0:
        push    es cx si di
        mov     di,cs:xy
        mov     cx,0B800h
        mov     es,cx
        mov     ch,cs:colors
strinaize0:
        mov     cl,[si]
        cmp     cl,0
        je      no0
        mov     es:[di],cx
        add     di,2
        inc     si
        jmp     strinaize0
        no0:
        mov     cs:xy,di
        pop     di si cx es
        ret


showstringat:
push es di
call setxy
call showstring
pop di es
ret

showstring0at:
push es di
call setxy
call showstring0
pop di es
ret

;couleur al pour ligne di
changelineattr:
push ax bx di es
mov bx,ax
mov ax,0B800h
mov es,ax
mov ax,di
mul cs:columns
mov di,ax
shl di,1
mov al,cs:columns
inc di
popep:
mov es:[di],bl
add di,2
dec al
jnz popep
pop es di bx ax
ret       

;Retourne en es:di un bloc de donn‚es
Getinfos:
push cx si di ds
push cs
pop ds
mov cx,10
mov si,offset lines
cld
rep movsb
pop ds di si cx
ret

lines db 0
columns db 0
x db 0
y db 0
xy dw 0
colors db 7
mode db 0FFh
pagesize dw 0
font equ $
copy equ $+4000
copy2 equ $+8000

endofme equ $ +12000

end start
