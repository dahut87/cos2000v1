.model tiny
.386c
.code
org 0100h
             
                
start:
mov si,offset logo
call searchfile
mov bx,7000h
mov es,bx
mov bx,0h
call loadfatway
push es
pop ds
call loadbmp
xor ax,ax
xor bx,bx
call showbmp
mov ax,0
int 16h
ret
db 0CBH

loadbmp:
push ax bx cx dx bp ds
mov ax,4
int 47h      
mov ax,ds:[18]
mov si,ax
shr ax,2
and si,11b
cmp si,0
je is4x
add ax,1
is4x:
mov cs:sizeh,ax
mov ax,ds:[22]
mov cs:sizev,ax
mov di,0FFFFh-1024
mov si,54
mov cl, 0ffh
paletteload:
lodsb
shr al, 2
mov [di+2], al
lodsb
shr al, 2
mov [di+1], al
lodsb
shr al, 2
mov [di+0], al
inc si
add di, 3
dec cl
jnz paletteload
mov si,0FFFFh-1024
mov dx, 3c8h
cld
mov cl, 0ffh
xor bx, bx
palettemake:
mov al, bl
out dx, al
inc dx
lodsb
out dx, al
lodsb
out dx, al
lodsb
out dx, al
dec dx
inc bl
dec cl
jnz palettemake
pop ds bp dx cx bx ax  
ret
sizeh dw 0
sizev dw 0

showbmp:
push ax bx cx dx si di ds es
mov cx,cs:sizeh
mov dx,cs:sizev
add bx,dx
mov di,ax
mov ax,bx
shl ax,6
shl bx,8
add di,bx
add di,ax
mov bx,di
mov ax,0A000H
mov es,ax
mov si,1024+54
mov ax,cx
bouclebmp:
cmp di,64000
jae nopp
cld
rep movsd
no:
mov cx,ax
sub bx,320
mov di,bx
dec dx
jnz bouclebmp
fin:
pop es ds di si dx cx bx ax 
ret
nopp:
shl cx,2
add si,cx
jmp no

Searchfile:
push bx dx si di ds es
mov di,offset temp
mov bx,offset buffer
call asciiztofit
mov cx,13
check:
call readsector
jc errorboot
xor di,di
findnext:
cmp byte ptr [bx+di],0
je errorboot
push si di cx
mov si,di
add si,bx
mov di,offset temp
mov cx,12+4
rep cmpsb
pop cx di si
je oksystem
add di,32
inc dx
cmp dx,nbfit
ja errorboot
cmp di,sizec
jb findnext
inc cx
jmp Check
oksystem:
mov cx,[di+BX+26]
errorboot:
pop es ds di si dx bx
ret

;->name ds:si ->es:di
AsciiZtoFit:
push ax bx cx dx si di ds es
xor bx,bx
mov dx,di
noextens:
mov al,[si+bx]
cmp al,'.'
je extens
call Issystchar
jc errortranslate
mov es:[di],al
inc di
inc bx
cmp bx,namesize ;(.)
jne noextens
erro:
stc
jmp errortranslate
extens:  
add si,bx
inc si
sub bx,namesize
neg bx
mov al,0
mov cx,bx
cld
rep stosb
xor bx,bx         
wasextens:
mov al,[si+bx]
cmp al,0
je endextens
call Issystchar
jc errortranslate
mov es:[di],al
inc di
inc bx
cmp bx,extsize
jne wasextens
jmp erro
endextens:        
sub bx,extsize
neg bx
mov al,0
mov cx,bx
cld
rep stosb
mov si,dx
mov di,dx
push es
pop ds
mov cx,extsize+namesize
call uppercaseMEM  
clc
endtranslate:
pop es ds di si dx cx bx ax
ret
errortranslate:
stc
jmp endtranslate

;Carry si al = caractäre systäme
isSystchar:
push di
mov di,offset exeptchar
isexcept:
cmp al,cs:[di]
je nogood
inc di
cmp byte ptr cs:[di],0
jne isexcept
endanal:
pop di
ret
exeptchar db '/\<>:|.',01,0,0
nogood:
stc
jmp endanal

;Transforme les x caractäres de la mem en ds:si en maj
uppercaseMEM: 
push si di cx ax
mov di,si
uppercaser:
mov al,ds:[si]
inc si
cmp al,'A'
jb nonmaj
cmp al,'Z'
ja nonmaj
add al,'a'-'A'
nonmaj:
mov es:[di],al
inc di
dec cx
jnz uppercaser
enduppercase:
clc
pop ax cx di si
ret

nbfit equ 255


namesize equ 12
extsize equ 5

;cx entrÇe -> fatway chemin
getfatway:
push bx cx es
mov bx,offset fatway
fatagain:
mov cs:[bx],cx
add bx,2 
cmp cx,0FFF0h
jae finishload
call getfat
jnc fatagain
finishload:  
pop es cx bx
ret

lastread dw 0FFFFh

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


dot db '.',0

loadfatway:
push bx cx di
call getfatway
jc endload
mov di,offset fatway
mov si,offset dot
mov ah,13
loadagain:
mov cx,cs:[di]
cmp cx,0FFF0h
jae endload
add di,2
call readsector
jc endload
int 47h
add bx,cs:sizec
jmp loadagain
endload:
pop di cx bx
ret        

sizec dw 512
reserv dw 1

;<-cx n¯secteur  ->cx code FAT
getfat:
push es ax bx dx
mov ax,cx
xor dx,dx
div cs:sizec
mov cx,ax
add cx,cs:reserv
mov bx,offset buffer
push cs
pop es
call readsector
jc errorgetfat
shl dx,1
add bx,dx
mov cx,cs:[bx]
errorgetfat:
pop dx bx ax es
ret

logo db 'cos.bmp',0
temp db 12+5+1 dup (0)

DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2

fatway equ $

buffer equ $+1000 
end start
