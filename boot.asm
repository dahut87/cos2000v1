boots segment
.386
org 7C00h
;org 100h
assume cs:boots,ds:boots

start:
jmp boot


bootdb  db     'COS2000A'               ;ID Formatage
sizec   dw      512                      ;octet/secteur
        db      1                        ;secteur/cluster
reserv  dw      1                        ;secteur reserv‚
nbfat   db      1                        ;nb de FAT
nbfit   dw      25                       ;nb secteur rep racine
allclu  dw      2880                     ;nb secteur du volume
        db      0F0h                     ;ID support
fatsize dw      12                        ;secteur/FAT
nbtrack dw      18                       ;secteur/piste       
head    dw      2                        ;nb de tˆte
hidden  dd      0                        ;nombre de secteur cach‚s
        dd      0                        ;si nbsecteur = 0 nbsect                                       ; the number of sectors
bootdrv db      0                        ;Lecteur de d‚marrage
        db      0                        ;NA
bootsig db      29h                      ;boot signature 29h
        dd      01020304h                ;no de serie
pope    db      'COS2000    '            ;nom de volume
        db      'FAT16   '               ;FAT
specialboot:

errorloading  db 'It''s not a COS disk!',0dh,0ah,0
okloading db 'COS search system',0Dh,0ah,0
syst db 'Ok',0dh,0ah,0
dot db '.',0
carry db 0dh,0ah,0
Sys db 'system',0,0,0,0,0,0
sys2 db 'sys',0

errorboot:
        mov si,offset errorloading
        call showstr
        mov ah,0
        int 16h
        int 19h
boot:
        mov Bootdrv,dl
        cli        
        mov ax,09000h
        mov ss,ax
        mov sp,0FFFFh
	sti
        p:
        push cs
        pop ds
        xor ax,ax
        int 13h
        jc errorboot
        mov si,offset okloading
        call showstr
        mov cx,nbtrack       
        les si,ds:[1Eh*4]
        mov byte ptr es:[si+4], cl
        mov byte ptr es:[si+9], 0Fh
        xor ax,ax
        mov al,NbFat
        mov bx,FatSize
        mul bx
        mov cx,ax
        add cx,word ptr [offset Hidden]
        adc cx,word ptr [offset Hidden+2]
        add cx,Reserv     
        mov word ptr [offset BootSig],cx
        xor dx,dx
        mov ax,allclu
        div nbtrack
        xor dx,dx
        div head
        mov word ptr [offset pope],ax
        push cs
        pop es
        mov bx,offset buffer
        mov si,bx
        xor dx,dx 
CheckRoot:
call readsector
jc errorboot
xor di,di
findnext:
cmp byte ptr [bx+di],0
je errorboot
push si di cx
mov si,di
add si,bx
call showstr
mov ax,si
mov si,offset dot
call showstr
mov si,ax
add si,12
call showstr
mov si,offset carry
call showstr
mov si,ax
mov di,offset sys
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
jmp Checkroot
oksystem:
mov si,offset syst
call showstr
mov cx,[di+BX+26]
mov bx,1000h
mov es,bx
push bx
mov bx,0100h
push bx
mov si,offset dot
fatagain:
cmp cx,0FFF0h
jae finishload
call readsector
jc errorboot
call showstr
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


         
;<-cx nøsecteur  ->cx code FAT
getfat:
push es bx
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
pop bx es
ret

ReadSector:
push ax cx dx si
  mov AX, CX
  xor DX, DX
  div nbtrack
  mov CL, DL                    ;{ Set the sector                            }
  and CL, 63                    ;{ Top two bits are bits 8&9 of the cylinder }
  xor DX, DX
  div word ptr pope
  mov CH, DL                    ;{ Set the track bits 0-7                    }
  mov AL, DH
  ror AL, 1
  ror AL, 1
  and AL, 11000000b
  or CL, AL                     ;{ Set bits 8&9 of track                     }
  xor dX, DX
  div head
  mov DH, DL                    ;{ Set the head                              }
  inc CL
  mov SI, 4
TryAgain:
  mov AX,0201h
  mov DL, bootdrv
  int 13h
  jnc Done
  dec SI
  jnz TryAgain
Done:
  pop si dx cx ax
ret  

showstr:
        push ax bx si
again:
        lodsb
        or al,al
        jz fin
        mov ah,0Eh
        mov bx,07h
        int 10h
        jmp again
        fin:
        pop si bx ax
        ret


Buffer equ $
boots ends
end start

