.model tiny
.486
smart
.code

org 0100h

start:
mov si,offset video
mov bx,400h
mov ax,47h
call installhandler
jc erroron
mov si,offset timer
mov bx,900h
mov ax,8h
call replacehandler
jc erroron
mov si,offset pic
mov bx,950h
mov ax,50h
call installhandler
jc erroron
mov si,offset drive
mov bx,1020h
mov ax,48h
call installhandler
jc erroron
mov si,offset keyboard
mov bx,1400h
mov ax,9h
call replacehandler
jc erroron
mov ax,40h
mov es,ax
mov dx,es:[8]
cmp dx,0
je nolpt1
mov al,0FFh
add dx,2
out dx,al
mov si,offset lpt
mov bx,1500h
mov ax,0Fh
call installhandler
jc erroron
mov es,bx
sub al,8
xor ah,ah
int 50h
mov byte ptr es:[105h],'1'
nolpt1:
push es
mov ax,40h
mov es,ax
mov dx,es:[10]
pop es
cmp dx,0
je nolpt2
mov al,0FFh
add dx,2
out dx,al
mov si,offset lpt
mov bx,1700h
mov ax,0Dh
call installhandler
jc erroron
sub al,8
xor ah,ah
int 50h
mov es,bx
mov byte ptr es:[105h],'2'
nolpt2:
mov si,offset mouse
mov bx,1900h
mov ax,74h
call installhandler   
jc erroron
mov ax,0012
int 50h         
mov ah,2
int 74h
;mov si,offset joystick
;mov bx,2700h
;mov ax,08h
;call replacehandler   
mov si,offset hours
mov bx,2900h
mov ax,08h
call replacehandler   

start2:
push cs
push cs
pop ds
pop es
mov ah,21
mov cl,7
int 47h
mov ax,0002
int 47h   
mov ah,2
int 47h
mov ah,25
mov bx,0
int 47h
mov ah,13
mov si,offset msg1
int 47h
mov ah,6
int 47h
int 47h
mov ah,13
mov si,offset prompt
int 47h
mov ah,6
int 47h
xor di,di
mov ax,0001h
mov bx,offset buffer
mov cx,13  
int 48h       
xor bp,bp
showall:
cmp byte ptr [bx+di],0
je endof2
mov al,[bx+di+12]
mov byte ptr [bx+di+12],0
mov si,bx
add si,di
mov ah,13
int 47h
mov si,offset spaces
int 47h
mov [bx+di+12],al
mov byte ptr [bx+di+12+5],0
mov si,bx
add si,di
add si,12
int 47h
mov ah,6
int 47h
add di,32
inc bp
jmp showall
endof2:
mov ah,21
mov cl,112
int 47h
mov ah,13
mov si,offset menu
int 47h  
mov xx,1
mov xxold,2
call Select
endof:
mov ax,0
int 16h
     cmp ah,50h
     jne tre1
     cmp xx,bp
     je endof
     inc xx
     call select
     jmp endof
tre1:
     cmp ah,48h
     jne tre2
     cmp xx,1
     je endof
     dec xx
     call select
     jmp endof
tre2:
     cmp al,0Dh
     jne tre3 
     mov di,xx
     dec di
     shl di,5
     mov dx,[di+bx+26]
     cmp [di+bx+12],00657865h ;EXE
     jne tre3
     mov ah,6
     int 47h
     int 47h
     mov ah,21
     mov cl,7
     int 47h
     mov ah,13
     mov si,offset msg2
     int 47h
     mov cx,dx
     call executefatway
tre3:
     cmp ah,59
     jne tre4
     mov lastread,0FFFFh
     jmp start2
tre4:
     cmp ah,67
     jne endof
     mov ax,0001
     int 47h
     mov ah,2
     int 47h
     mov ah,21
     mov cl,4
     int 47h
     mov ah,13
     mov si,offset msg3
     int 47h
     mov ax,0
     int 16h
     mov ax,40h
     mov ds,ax
     mov bx,1234h
     mov ds:[072h],bx
     push 0FFFFh  
     push 0000h
     db 0CBh

executefatway:
     push cs
     mov bx,offset start2
     push bx     
     mov bx,03000h
     mov es,bx
     push bx
     mov bx,0100h
     push bx
     call loadfatway
     push es
     push es
     push es
     pop ds
     pop fs
     pop gs
     push 7202h
     popf
     db 0CBh

;selectionne la ligne xx
Select:
push ax di
mov di,xxold
mov al,7
add di,2
mov ah,32
int 47h
mov ax,xx
mov xxold,ax
mov di,xx
mov ah,32
mov al,112
add di,2
int 47h
pop di ax
ret      

xx dw 1
xxold dw 0
menu db 'F1 Read disk F2 Read file F9 Quit F11 Change video F12 Debug                   ',0
msg1 db '  Cos 2000 menu loader release 1.0',0
msg2 db 'The program is loading',0
msg3 db ' Cos will restart your computer, eject the floppy disk and press a key',0                                                      
prompt db '>',0
spaces db '   ',0
dot db '.',0
               
;cx entrÇe -> fatway chemin
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
mov si,offset dot
mov ah,13
xor dx,dx
loadagain:
mov cx,cs:[di]
cmp cx,0FFF0h
jae endload
add di,2
call readsector
jc endload
add bx,cs:sizec
add dx,cs:sizec
jmp loadagain
endload:
pop di cx bx ax
ret        


sizec dw 512
reserv dw 1

;<-cx n¯secteur  ->cx code FAT
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

Lastread dw 0FFFFh

;remplace le handler pointer par ds:si en bx:100h interruption ax
replacehandler:
push ax bx cx si di ds es
mov es,bx
mov di,0100h
call loadfile
jc reph
mov bx,ax
call getint
mov es:[102h],si
mov es:[104h],ds
call setint
reph:
pop es ds di si cx bx ax
ret
      
;install le handler pointer par ds:si en bx:100h interruption ax
installhandler:
push bx cx di es
mov es,bx
mov di,100h
call loadfile
jc insh
mov bx,ax
call setint
insh:
pop es di cx bx
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
                              
;met es:di le handle de l'int bx
setint:
push ax bx ds
cli
shl bx,2
xor ax,ax
mov ds,ax
mov ds:[bx],di
mov ds:[bx+2],es
pop ds bx ax
sti
ret

;met ds:si le handle de l'int bx
getint:
push ax bx es
shl bx,2
xor ax,ax
mov es,ax
mov si,es:[bx]
mov ds,es:[bx+2]
pop es bx ax
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
clc
pop di 
ret
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

erroron:
push cs
pop ds
xor edx,edx
mov dx,ax
mov ax,0001h
int 47h
mov ah,6
int 47h
mov ah,6
int 47h
mov ah,13
mov si,offset errormsg
int 47h
mov ah,10
mov cx,16
int 47h
mov ah,6
int 47h
mov ah,6
int 47h
mov ah,13
mov si,offset errormsg2 
int 47h
mov ax,0
int 16h
push 0FFFFh
push 0
db 0CBh

errormsg db 'Error with drivers loading on interrupt n¯',0
errormsg2 db 'Press a key to restart...',0
namesize equ 12
extsize equ 5       
nbfit equ 255
hours db 'hours.sys',0
joystick db 'joystick.sys',0
mouse db 'mouse.sys',0
pic db 'pic8259a.sys',0
drive db 'drive.sys',0
timer db 'timer.sys',0
lpt db 'lpt.sys',0
video db 'video.sys',0
keyboard db 'keyboard.sys',0
temp db 12+5+1 dup (0)
exeptchar db '/\<>:|.',01,0,0
DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2

fatway equ $

buffer equ $+3000

end start
