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
         dw compressrle
         dw decompressrle

;cx entr‚e -> fatway chemin
getfatway:
push bx cx 
mov bx,offset fatway
fatagain:
mov cs:[bx],cx
add bx,2 
cmp cx,0FFF0h
jae finishload
call getfat
jnc fatagain
finishload:  
pop cx bx
ret

;Charge le fichier de chemin cx -> taille dx
loadfatway:
push ax bx cx di 
call getfatway
jc endload
mov di,offset fatway
xor dx,dx
loadagain:
mov cx,cs:[di]
cmp cx,0FFF0h
jae endload
add di,2
mov al,1
call readsector
jc endload
add bx,cs:sizec
add dx,cs:sizec
jmp loadagain
endload:
pop di cx bx ax
ret        


;<-cx nøsecteur  ->cx code FAT
getfat:
push es ax bx dx
push cs
pop ds
push cs
pop es
mov ax,cx
xor dx,dx
div sizec
mov cx,ax
add cx,reserv
mov bx,offset buffer
call readsector
jc errorgetfat
shl dx,1
add bx,dx
mov cx,[bx]
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

;Charge le fichier Ds:si en es:di taille-> cx
loadfile:
push bx 
call searchfile
jc errorloadfile
mov bx,di
call loadfatway
jc errorloadfile
mov cx,dx
errorloadfile:
pop bx
ret   

;Recherche le fichier et retourne sont path et en cx sont debut
Searchfile:
push ax bx dx si di ds es
push cs
pop es
xor dx,dx
mov di,offset temp
call asciiztofit
push cs
pop ds
mov cx,13
check:
mov al,1
mov bx,offset buffer  
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
cld
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
cld
jmp goodboot
errorboot:
stc
goodboot:
pop es ds di si dx bx ax
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

;Carry si al = caractŠre systŠme
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
clc
pop di 
ret
nogood:
stc
jmp endanal

;Transforme les x caractŠres de la mem en ds:si en maj
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

;decompress ds:si en es:di taille bp d‚compress‚ cx compress‚
DecompressRle:
push cx dx si di
mov dx,cx
mov bp,di
decompression:
mov eax,[si]
cmp al,'/'
jne nocomp
cmp si,07FFFh-6
jae thenen
mov ecx,eax
ror ecx,16
cmp cl,'*'
jne nocomp
cmp byte ptr [si+4],'/'
jne nocomp
mov al,ch
mov cl,ah
xor ah,ah
xor ch,ch
rep stosb
add si,5
sub dx,5
jnz decompression
jmp thenen
nocomp:
mov es:[di],al
inc si
inc di
dec dx
jnz decompression
thenen:
mov ax,dx
sub bp,di
neg bp
pop di si dx cx
ret

;compress ds:si en es:di taille cx d‚compress‚ BP compress‚
CompressRle:
push ax bx cx dx si di ds es
mov bp,di
xchg si,di
push es
push ds
pop es
pop ds
mov dx,cx
;mov bp,cx
againcomp:
mov bx,di
mov al,es:[di]
mov cx,dx
cmp ch,0
je poo
mov cl,0ffh
;mov cx,bp
;sub cx,di
;mov ah,cl
poo:
mov ah,cl
inc di
xor ch,ch
repe scasb
sub cl,ah
neg cl
cmp cl,6
jbe nocomp2
mov dword ptr [si],' * /'
mov byte ptr [si+4],'/'
mov [si+1],cl
mov [si+3],al
add si,5
dec di
xor ch,ch
sub dx,cx
jnz againcomp
jmp fini
nocomp2:
mov [si],al
inc si
inc bx
mov di,bx
dec dx
jnz againcomp
fini:
sub bp,si
neg bp
pop es ds di si dx cx bx ax
ret

nbfit equ 255
namesize equ 12
extsize equ 5
exeptchar db '/\<>:|.',01,0,0
temp db 12+5+1+90 dup (0) 
DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2
sizec dw 512
reserv dw 1
buffer equ $
buffer2 equ $+512 
fatway equ $+512

end start
