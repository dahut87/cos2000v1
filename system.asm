.model tiny
.486
smart
.code

org 0100h



start:
mov si,offset video
call searchfile
mov bx,8400h
mov es,bx
mov bx,100h
call loadfatway
mov di,bx
mov bx,47h
call setint
mov bx,9
call getint
mov cs:int9seg,ds
mov cs:int9off,si
push cs
pop es
mov di,offset int9
call setint
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
mov bx,offset buffer
mov cx,13
call readsector
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
msg1 db 'Cos 2000 menu loader release 1.0',0
msg2 db 'The program is loading',0
msg3 db 'Cos will restart your computer, eject the floppy disk and press a key',0                                                      
prompt db '>',0
spaces db '   ',0
dot db '.',0


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
WriteSector:


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
cli
shl bx,2
xor ax,ax
mov es,ax
mov si,es:[bx]
mov ds,es:[bx+2]
pop es bx ax
sti
ret

int9off dw 0 
int9seg dw 0

int9:
        pushf
        db  2eh,0ffh,1eh
        dw  int9off
        cli
        pusha
        in al,60h
        cmp cs:isstate,1
        jne nostate
        cmp al,57
        jne nof12
        mov cs:isstate,0
        jmp noF12
        nostate:
        cmp al,87
        jne NoF11
        push es
        push cs
        pop es
        mov di,offset infos
        mov ah,34
        int 47h
        mov al,cs:infos+7
        inc al
        and ax,111b
        int 47h
        pop es

        nof11:
        cmp al,88
        jne NoF12 
        mov ah,26
        int 47h
        call showstate
        mov cs:isstate,1
        sti
        waitt:
        cmp cs:isstate,0
        jne waitt
        mov ah,27
        int 47h 
        noF12:
        popa
        sti
        iret
        isstate db 0
        infos db 10 dup (0)

 showstate:
     push ds es       
     push ss
     push gs
     push fs
     push es
     push ds
     push cs  
     pushad
     pushfd

     push cs
     push cs
     pop es
     pop ds
     mov ah,2
     int 47h
     mov ah,21
     mov cl,4
     int 47h
     mov ah,13
     mov si,offset reg
     int 47h
     mov ah,6
     int 47h
     mov ah,21
     mov cl,7
     int 47h
     mov ah,13
     mov si,offset fla
     int 47h
     pop edx
     mov cx,32
     mov ah,11
     int 47h
     mov ah,5
     int 47h
     mov ah,10
     int 47h
     mov si,offset regs
     mov bx,8+6
     mov ah,21
     mov cl,6
     int 47h
showallREG:
     mov ah,6
     int 47h
     cmp bx,7
     jb nodr
     pop edx
     jmp popo
     nodr:
     mov ah,21
     mov cl,1
     int 47h
     xor edx,edx
     pop dx
     popo:
     mov ah,13
     int 47h
     mov ah,10
     mov cx,32
     int 47h
     mov ah,5
     int 47h
     push si
     mov si,offset gr
     mov ah,13
     int 47h
     mov ah,8
     int 47h
     mov si,offset dr
     mov ah,13
     int 47h
     pop si
     add si,5
     dec bx
     jnz showallreg
     mov ah,34
     mov di,offset infos
     int 47h
     mov ah,25
     mov bl,cs:infos
     xor bh,bh
     dec bl
     int 47h
     mov si,offset app
     mov ah,13
     int 47h
     mov ah,32
     mov bl,cs:infos
     xor bh,bh
     mov di,ax
     dec di
     mov cl,116
     int 47h
     pop es ds
     ret

reg db 'State of registers',0
fla db 'Flags:',0 
regs db 'EDI:',0
     db 'ESI:',0
     db 'EBP:',0
     db 'ESP:',0
     db 'EBX:',0
     db 'EDX:',0
     db 'ECX:',0
     db 'EAX:',0
     db ' CS:',0
     db ' DS:',0
     db ' ES:',0
     db ' FS:',0
     db ' GS:',0
     db ' SS:',0
gr db '(',0
dr db ')',0
app db 'Press space to quit...',0

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

namesize equ 12
extsize equ 5


nbfit equ 255
video db 'video.sys',0
temp db 12+5+1 dup (0)

DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2

fatway equ $

buffer equ $+3000
end start
