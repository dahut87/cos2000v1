.model tiny
.386c
.code
org 0100h
             
                
start:
     mov ax,0305h
     mov bx,0008h
     int 16h      
;mov ax,1100h
;mov bx,1000h    ;2000H
;mov cx,0100h     ;80h
;xor dx,dx
;mov bp,offset copy2
;int 10h
     call savescreen
     xor bp,bp 
Adres:
     push cs
     pop es
     mov cx,sect
     mov bx,offset buffer
     call readsector
     jnc noerror
     errtr:
     mov ax,24
     call setxy
     mov colors,116
     mov si,offset errordisk
     call showstring0
     mov ax,0
     int 16h
     noerror:
 adres2:
     mov bx,offset buffer     
     call clear
     mov ax,0
     call setxy
     mov ah,24
     mov di,bp
     mov colors,7
lines:
     mov dx,sect
     mov cx,16
     call showhexrow
     mov si,offset dep
     call showstring0
     mov dx,di
     call showhexrow
     mov si,offset spaces
     call showstring0
     mov al,16
     mov cx,8
     mov colors,7
     mov si,di
doaline:
     mov dl,[di+bx]
     call showhexrow
     call space
     inc di
     dec al
     jnz doaline
     mov di,si
     mov si,offset spaces
     call showstring0
     mov al,16
     mov colors,7
doaline2:
     mov dl,[di+bx]
     call showchar
     inc di
     dec al
     jnz doaline2
     call line
     dec ah
     jnz lines
     mov colors,112
     mov si,offset menu
     call showstring0
     mov bx,bp
     waitkey:
     mov ax,0
     int 16h
     cmp ax,3B00h
     jne suit
     cmp bx,8*16
     jae waitkey
     add bp,16  
     jmp adres2
     suit:
     cmp ax,3C00h
     jne suit2
     cmp bp,0
     je waitkey
     sub bp,16
     jmp adres2
     suit2:
     cmp ax,3D00h
     jne suit3
     cmp sect,2880
     ja waitkey
     inc sect
     jmp adres
     suit3:
     cmp ax,3E00h
     jne suit4
     cmp sect,0
     je waitkey
     dec sect
     jmp adres   
     suit4:
     cmp ax,3F00h
     jne suit5
     jmp adres2
     suit5:
     cmp ax,4000h
     jne suit6
     mov cx,sect
     mov bx,offset buffer
     call writesector
     jnc waitkey
     jmp errtr
     suit6:
     cmp ax,4100h
     jne suit7
     mov dword ptr [pope],'TIDE'
     mov ax,24
     call setxy
     mov colors,116
     mov si,offset menu
     call showstring0
     mov colors,7
     mov ax,0B800h
     mov es,ax   
     mov xxyy2,3
     mov xxyy,3
     call calc1
     call calc2  
waitst:
     mov ax,0
     int 16h  
     cmp ah,41h
     jne tre
     mov dword ptr [pope],' EUV'
     push cs
     pop es
     mov cx,sect
     mov bx,offset buffer
     call writesector
     jnc adres
     jmp errtr
tre:
     cmp al,0
     jne write      
     cmp ah,48h
     jne tre1
     cmp yy,0
     je waitst
     dec yy
     jmp cursor
tre1:
     cmp ah,50h
     jne tre2
     cmp yy,23
     je waitst
     inc yy
     jmp cursor
tre2:
     cmp ah,4Dh
     jne tre4
     cmp xx,15
     je waitst
     inc xx
     jmp cursor
tre4:       
     cmp ah,4Bh
     jne waitst
     cmp xx,0
     je waitst
     dec xx
     jmp cursor
write:
     call AsciiHex2dec
     cmp cl,15
     ja waitst
     call calc1
     call calc2      
     mov byte ptr es:[bx],0112
     mov es:[bx-1],al
writs:
     mov ax,0
     int 16H
     mov ch,cl
     call AsciiHex2dec
     cmp cl,15
     ja writs
     shl ch,4
     add ch,cl
     mov es:[bx+1],al
     mov es:[si-1],ch
     mov ax,bx
     call calc3
     mov [bx],ch
     inc xx 
     cmp xx,16
     jne pasde
     inc yy
     mov xx,0h
     pasde:
     call calc1
     call calc2
     jmp waitst

cursor:
     call calc1
     call calc2
     jmp waitst
     suit7:
     cmp ax,4200h
     jne waitkey
     call restorescreen
     ret

calc1:
     push ax dx si
     mov ax,xx
     mov dx,xx
     shl ax,2
     shl dx,1
     add ax,dx
     add ax,25
     mov bx,YY
     mov dx,yy
     shl bx,5
     shl dx,7
     add bx,dx
     add bx,ax
     mov byte ptr es:[bx],112
     mov byte ptr es:[bx+2],112
     mov si,xxyy
     mov byte ptr es:[si],07
     mov byte ptr es:[si+2],07
     mov xxyy,bx 
     pop si dx ax
     ret

calc2:
     push ax bx dx 
     mov si,YY
     mov dx,yy
     shl si,5
     shl dx,7
     add si,dx
     mov dx,xx
     shl dx,1
     add si,dx
     add si,127
     mov byte ptr es:[si],112
     mov bx,xxyy2
     mov byte ptr es:[bx],07
     mov xxyy2,si 
     pop dx bx ax
     ret

calc3:
     push dx
     xor bx,bx
     mov bx,xx
     mov dx,yy
     shl dx,4
     add bx,dx
     add bx,bp
     add bx,offset buffer
     pop dx 
     ret

     asciihex2dec:
     cmp al,'a'
     jb nomin
     cmp al,'f'
     ja nomin
     sub al,'a'-'A'
     jmp ismaj
     nomin:
     cmp al,'A'
     jb nomaj
     cmp al,'F'
     ja nomaj
     ismaj:
     mov cl,al
     sub cl,'A'-10
     jmp endt
     nomaj:
     mov cl,al
     sub cl,'0'
     endt:   
     ret

dep db ':',0
sect dw 0
xx dw 0
yy dw 0
xxyy dw 3
xxyy2 dw 3
errordisk db 'Une erreur est survenu sur le lecteur A:, appuyer sur une touche        ',0
menu db 'Haut F1, Bas F2, Secteurs F3&F4, Load/Save F4&F5, Edit F7, Quitter F8  MODE '
pope  db 'VUE  ',0         
spaces db  ' ³ ',0
xy dw 0
colors db 7
x db 1
y Db 1

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

DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2
                 
copy2 equ $
buffer equ $+4000


end start








