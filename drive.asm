.model tiny
.486
smart
.code

org 0100h

start:
jmp tsr
db 'DRIVE'
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
tables   dw readsector
         dw writesector
         dw verifysector2  
         dw loadfatway
         dw loadfile

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

;Charge le fichier de chemin cx
loadfatway:
push ax bx cx di
call getfatway
jc endload
mov di,offset fatway
loadagain:
mov cx,cs:[di]
cmp cx,0FFF0h
jae endload
add di,2
xor al,al
call readsector
jc endload
add bx,cs:sizec
jmp loadagain
endload:
pop di cx bx ax
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

ReadSector:
push ax cx dx si
  cmp al,1
  je pr
  cmp cx,cs:lastread
  je done
  pr:
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

Lastread dw 0FFFFh

Inverse:
mov si,512/4
invert:
shl si,2
not dword ptr [bx+si-4]
shr si,2
dec si
jnz invert
ret

VerifySector:
push bx cx si di ds es
push cs
pop es
push cs
pop ds
mov bx,offset buffer
call ReadSector        
jc errorverify
call inverse
call WriteSector
jc errorverify
mov bx,offset buffer2
call ReadSector        
call inverse
jc errorverify
mov bx,offset buffer
call inverse
call WriteSector
jc errorverify
mov cx,512/4
mov si,offset buffer
mov di,offset buffer2
cld
rep cmpsd
errorverify:
pop es ds di si cx bx
ret

VerifySector2:
call verifysector
jne nook
or byte ptr [bp+6],10b
nook:
ret

;Charge le fichier Ds:si en es:di
loadfile:
push bx cx
call searchfile
mov bx,di
call loadfatway
pop cx bx
ret

;Recherche le fichier et retourne sont path et en cx sont debut
Searchfile:
push bx dx si di ds es
push cs
pop es
mov di,offset temp
call asciiztofit
mov bx,offset buffer
push cs
pop ds
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
cmp al,[di]
je nogood
inc di
cmp byte ptr [di],0
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


temp db 12+5+1 dup (0)

DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2

fatway equ $

buffer equ $+3000
buffer2 equ $+512 
end start
