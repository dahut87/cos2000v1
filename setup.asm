.model tiny
.486
smart
.code

org 0100h

ent equ 32h

start:
jmp CopyCOS

DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2  

Message db 0Dh,0Ah,'COS 2000b installation program (Celyn Operating System) !!',0Dh,0Ah,'Written By Nico',0Ah,0Dh,'Site online HTTP://WWW.MULTIMANIA.COM/COS2000',0Dh,0AH,'Copyright 2000',0Dh,0AH,'Please insert a floppy disk and press a key...',0Dh,0AH,'Be careful! All the disk is going to be deleted',0Dh,0AH,'$'
Message2 db 0Dh,0AH,'Create boot sector$'
systfile db  0Dh,0AH,'Creating file allocation table 16 bits$'
systfile2 db  0Dh,0AH,'Creating file information table 32 bytes$'
systfile3 db  0Dh,0AH,'Creating operating system files',0Dh,0Ah,'$'
systfile4 db 0D,0Ah,'Creating system tools',0Dh,0Ah,'$'
Errormsg db 0Dh,0AH,0Dh,0AH,'Installing error, please contact me at COS2000@MULTIMANIA.COM !',0Dh,0AH,'$'
Ok db 0Dh,0AH,0Dh,0AH,'The boot sector and the system files had been succefully copied.',0Dh,0AH, 'To try COS reboot with this system disk',0Dh,0AH,'$'
files db '*.*',0
tools db '*.exe',0
allboot db 0dh,0ah
boot db 'boot.bin',0,'    $'
retu db 0Dh,0AH,'$'
dat db 'data',0
dat2 db '..',0
dta db 43 dup (0)

copycos:
        mov     ah,4ah
        mov     bx,1000h
        int     21h
        jc      error
        mov     ah,48h
        mov     bx,65536/16
        int     21h
        jc      error
        mov     fs,ax 
mov ah,3Bh
mov dx,offset dat
int 21h
mov ah,9
mov dx,offset message
int 21h
jc error
mov ax,0
int 16h
mov ah,9
mov dx,offset systfile
int 21h
jc error
mov cx,12
mov bx,offset fat
erase:
call writesector
jc error
dec cx
jnz erase
mov ah,9
mov dx,offset message2
int 21h
jc error
mov dx,Offset allboot
int 21h
jc error
mov dx,offset boot
call addfile
mov ax,0F0FFh
mov cx,14
mov di,offset fat
cld
rep stosw
mov bx,offset fat
mov cx,1
call writesector
jc error
mov ah,9
mov dx,offset systfile2
int 21h
jc error
mov eax,0
mov cx,512/4
mov di,offset fat
cld
rep stosd
mov bx,offset fat
mov cx,13
call writesector
jc error   
mov ah,1Ah
mov dx,offset dta
int 21h
jc error     
mov ah,4eh
xor cx,cx
mov dx,offset files
int 21h
mov ah,9
mov dx,offset systfile3
int 21h
jc error
allfile:
mov di,offset dta+43
mov byte ptr [di],'$'
mov ah,9
mov si,offset dta+30
mov cl,13
call uppercasemem
mov dx,si
int 21h
jc error
call addfile
jc error
call makefit
jc error
mov ah,9
mov dx,offset retu
int 21h
jc error
mov di,offset dta+30
mov al,0
mov cl,13
cld
rep stosb
mov ah,4fh
int 21h
jnc allfile
mov ah,9
mov dx,Offset ok
int 21h
mov ah,3Bh
mov dx,offset dat2
int 21h       
ret

error:
mov ah,3Bh
mov dx,offset dat2
int 21h  
mov ah,9
mov dx,offset errormsg
int 21h
ret

addfile:
push ax bx dx si di bp ds es
mov cx,1
mov bx,offset fat
call readsector
jc error2
mov ax,3D00h
int 21h
jc error2
mov bx,ax
mov ax,4202h
xor cx,cx
xor dx,dx
int 21h
jc error2
cmp dx,0
jne error2
cmp ax,0
je error2
sub ax,1
shr ax,9
inc ax
mov bp,ax
mov ax,4200h
xor cx,cx
xor dx,dx
int 21h
jc error2
push fs
pop ds
push fs
pop es
mov ah,3fh
mov cx,0FFFFh
xor dx,dx
int 21h
push cs
pop ds 
jc error2
mov si,-2
mov di,0
xor bx,bx
fats:
add si,2
cmp si,512
jz error2
cmp WORD PTR [si+offset fat],0h
jne fats 
mov ax,si
shr ax,1 
cmp di,0
jne nonew
mov entrie,ax
jmp new
nonew:
mov [offset fat+di],ax
new:
mov di,si
mov cx,ax
call writesector
jc error2
add bx,512
dec bp 
jnz fats
mov word ptr [offset fat+di],0FFFFh
mov bx,offset fat
mov cx,1
push cs
pop es
call writesector
mov cx,entrie
end1:
pop es ds bp di si dx bx ax
ret
entrie dw 0
error2:
stc
jmp end1


makefit:
push bx cx si di bp
mov ax,cx
mov bx,offset fat
mov cx,13
call readsector
jc error3
xor si,si
findfit:
cmp byte ptr [si+bx],0
je finishfit
add si,32
cmp si,512
jb findfit
jmp error3
finishfit:
mov di,si
add di,bx
mov si,dx
call asciiztofit
jc error3
mov [di+26],ax
mov cx,13
call writesector
jc error3
end3:
pop bp di si cx bx
ret
error3:
stc
jmp end3

WriteSector:
push cx dx si
  mov AX, CX
  xor DX, DX
  div DiskSectorsPerTrack
  mov CL, DL                    ;{ Set the sector                            }
  and CL, 63                    ;{ Top two bits are bits 8&9 of the cylinder }
  xor DX, DX
  div DiskTracksPerHead
  mov CH, DL                    ;{ Set the track bits 0-7                    }
  mov AL, DH
  ror AL, 1
  ror AL, 1
  and AL, 11000000b
  or CL, AL                     ;{ Set bits 8&9 of track                     }
  xor DX, DX
  div DiskHeads
  mov DH, DL                    ;{ Set the head                              }
  inc CL
  mov SI, 4
TryAgain:
  mov AL, 1
  mov DL, 0
  mov AH, 3
  int 13h
  jnc Done
  dec SI
  jnz TryAgain
Done:
  jc enddd
  mov cl, AH
  mov ah,9
  mov dx,offset sign
  int 21h
  cmp cl,0
  enddd:
  pop si dx cx
ret

ReadSector:
push ax cx dx si
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
TryAgain2:
  mov AL, 1
  mov DL, 0
  mov AH, 2
  int 13h
  jnc Done2
  dec SI
  jnz TryAgain2
Done2:
  pop si dx cx ax
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

sign db '.$'
fat DB 512 dup (0)
buffer db 0

end start
