.model tiny
.486
smart
.code

org 0100h

start:  
push cs
push cs
pop ds
pop es
call clear
mov ax,0
call setxy
mov si,offset msg
call showstring0
mov di,0
mov al,112
call changeattrib
call line
call line
mov si,offset mssg
call showstring0
call line
mov si,offset msg2
call showstring0
call line
xor di,di
mov bx,offset buffer
mov cx,13
call readsector
jc fin2
xor bp,bp
showall:
cmp byte ptr [bx+di],0
je endof2
mov al,[bx+di+12]
mov byte ptr [bx+di+12],0
mov si,bx
add si,di
call showstring0
mov si,offset spaces
call showstring0
mov [bx+di+12],al
mov byte ptr [bx+di+12+5],0
mov si,bx
add si,di
add si,12
call showstring0
call line
add di,32
inc bp
jmp showall
endof2:
call Select
endof:
mov ax,0
int 16h
     cmp ah,50h
     jne tre1
     cmp xxx,bp
     je endof
     inc xxx
     call select
     jmp endof
tre1:
     cmp ah,48h
     jne tre2
     cmp xxx,1
     je endof
     dec xxx
     call select
     jmp endof
tre2:
     cmp al,0Dh
     je fin2
     jne tre3 
     mov di,xxx
     dec di
     shl di,5
     mov cx,[di+bx+26]
     call line
     call line
     mov si,offset msgg
     call showstring0
     call executefat
tre3:
     cmp ah,3bh
     jne endof
mov di,0
mov cx,1
mov al,7
call changeattribword
     mov si,offset popup
     mov ax,0200h
     call popupmenu
mov di,0
mov cx,1
mov al,112
call changeattribword  
     jmp endof    
fin2:
ret


popup db 4,'&New'
      db 5,'&Open'
      db 1,'-'
      db 7,'&Delete'
      db 7,'R&ename'
      db 5,'&Copy'
      db 5,'&Link'
      db 1,'-'
      db 8,'&Restart'
      db 10,'&Shut down'
      db 1,'-'
      db 12,'&About me...'
      db 0
      db 070h    ;couleur normale
      db 07Fh    ;couleur speciale
      db 07h     ;couleur select 

executefat:
push cs
mov bx,offset start
push bx
mov bx,6000h
mov es,bx
push bx
mov bx,0100h
push bx
mov si,offset dot
fatagain:
cmp cx,0FFF0h
jae finishload
call readsector
jc fin2
call showstring0
add bx,sizec
call getfat
jnc fatagain
finishload:
push es
push es
push es
pop ds
pop fs
pop gs
push 7202h
popf
db 0CBh

sizec dw 512
reserv dw 1

;<-cx nøsecteur  ->cx code FAT
getfat:
push es ax bx dx
mov ax,cx
xor dx,dx
div sizec
mov cx,ax
add cx,reserv
mov bx,offset buffer
push cs
pop es
call readsector
jc errorgetfat
shl dx,1
add bx,dx
mov cx,[bx]
errorgetfat:
pop dx bx ax es
ret

;selectionne la ligne xx
Select:
push ax di
mov di,xxold
mov al,7
add di,3
call changeattrib
mov ax,xxx
mov xxold,ax
mov di,xxx
mov al,112
add di,3
call changeattrib
pop di ax
ret

;couleur al pour ligne di mot cx
Changeattribword:
push bp bx dx di es
mov dx,0B800h
mov es,dx
mov dx,di
shl dx,5
shl di,7
add di,dx
mov dx,80
xor bp,bp
xor bx,bx
popp:
cmp byte ptr es:[di],' '
je noway
cmp bx,1
je noway2
mov bx,1
inc bp
cmp cx,bp
ja fint
jmp noway2
noway:
xor bx,bx
noway2:
cmp bp,cx
jne noway3
mov es:[di-1],al
noway3:
add di,2
dec dx
jnz popp
fint:
pop es di dx bx bp
ret     


;couleur al pour ligne di
changeattrib:
push dx di es
mov dx,0B800h
mov es,dx
mov dx,di
shl dx,5
shl di,7
add di,dx
mov cx,80
inc di
popep:
mov es:[di],al
add di,2
dec cx
jnz popep
pop es di dx
ret       

colors db 7
xy dw 0
x db 0
y db 0
xxx dw 1
xxold dw 0
msg db '   File  Edition',0
mssg db 'Cos 2000 menu loader release 1.0',0
msg2 db '>',0
spaces db '   ',0
dot db '.',0
msgg db 'Chargement du programme',0

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

;==============================Affiche le nombre nb binaire en EDX==============
ShowbinRow:
        push  es ax bx cx di      
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

;==========SETCOLOR=========
;Change les attributs du texte a CL
;-> CL
;<- 
;=============================
setcolor:
mov cs:colors,CL
ret  

;=============CLEAR=========
;Efface l'ecran texte
;-> 
;<- 
;=============================
clear:
push es eax cx di
xor di,di
mov ax,0b800h
mov es,ax
mov eax,07200720h
mov cx,1000
cld
rep stosd
pop di cx eax es
ret       

;==========SCROLLDOWN=========
;defile de cx lines vers le bas
;-> CX
;<- 
;=============================
scrolldown:
push cx si di ds es
mov si,0B800h
mov es,si
mov ds,si
mov si,cx
shl si,5
shl cx,7
add si,cx
mov cx,4000
sub cx,si
xor di,di
cld
rep movsb
pop es ds di si cx
ret

;==========LINE=========
;remet le curseur a la ligne
;-> 
;<- 
;=============================
line:
push ax cx di es
mov ah,cs:x
mov al,cs:y
xor ah,ah
cmp al,24
jne scro
dec al
mov cl,1
call scrolldown
scro:
inc al
call setxy
pop es di cx ax
ret

;==========SETXY=========
;Change les coordonnées du curseur a X:AL,Y:AH
;-> AX
;<- es di
;=============================
setxy:
push ax bx di 
mov cs:x,ah
mov cs:y,al
mov bl,ah
xor bh,bh
xor ah,ah
mov di,ax
shl di,5
shl ax,7
shl bx,1
add di,ax
add di,bx
mov cs:xy,di
pop di bx ax
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

;==============================Affiche le nombre nb hexa en EDX==============
ShowHexRow:
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
ret                      

;===================================sauve l'ecran rapidement================
SaveScreen:
        push    cx si di ds es
        mov     cx,0B800H
        mov     ds,cx
        push    cs
        pop     es
        mov     cx,(80*25*2)/4
        xor     si,si
        mov     di,offset Copy2
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
        mov     cx,(80*25*2)/4
        mov     si,offset Copy2
        xor     di,di
        cld
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
Lastread dw 0FFFFh

ReadSector:
push ax cx dx si
  cmp cx,cs:lastread
  je done
  mov cs:LastRead,cx
  mov AX, CX     
  xor DX, DX
  div cs:DiskSectorsPerTrack
  mov CL, DL                    ;{ Set the sector                            }
  and CL, 63                    ;{ Top two bits are bits 8&9 of the cylinder }
  xor DX, DX
  div cs:DiskTracksPerHead
  mov CH, DL                    ;{ Set the track bits 0-7                    }
  mov AL, DH
  ror AL, 1
  ror AL, 1
  and AL, 11000000b
  or CL, AL                     ;{ Set bits 8&9 of track                     }
  xor dX, DX
  div cs:DiskHeads
  mov DH, DL                    ;{ Set the head                              }
  inc CL
  mov SI, 4
TryAgain:
  mov AL, 1
  mov DL, 0
  mov AH, 2
  int 13h
  jnc Done
  dec SI
  jnz TryAgain
mov word ptr cs:lastread,0ffffh
Done:
  pop si dx cx ax
ret  

WriteSector:
push ax cx dx si
  cmp cs:Lastread,cx
  jne nodestruct
  mov cs:Lastread,0ffffh
  nodestruct:
  mov AX, CX
  xor DX, DX
  div cs:DiskSectorsPerTrack
  mov CL, DL                    ;{ Set the sector                            }
  and CL, 63                    ;{ Top two bits are bits 8&9 of the cylinder }
  xor DX, DX
  div cs:DiskTracksPerHead
  mov CH, DL                    ;{ Set the track bits 0-7                    }
  mov AL, DH
  ror AL, 1
  ror AL, 1
  and AL, 11000000b
  or CL, AL                     ;{ Set bits 8&9 of track                     }
  xor DX, DX
  div cs:DiskHeads
  mov DH, DL                    ;{ Set the head                              }
  inc CL
  mov SI, 4
TryAgain2:
  mov AL, 1
  mov DL, 0
  mov AH, 3
  int 13h
  jnc Done2
  dec SI
  jnz TryAgain2
Done2:
  pop si dx cx ax
ret

include menu.Asm

DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2

copy2 equ $
buffer equ $

end start
