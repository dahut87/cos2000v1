.model tiny
.486
smart
.code

org 0100h


start:
jmp CopyCOS

DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2  
NameBoot db 'Boot.bin',0
Namesystem db 'System.bin',0
Message db 0Ah,0Dh,'Installation of the COS (Celyn Operating System) !!',0Ah,0Dh,'Written By Horde Nicolas',0Ah,0Dh,'Copyright 2000',0Ah,0Dh
        db 0Ah,0Dh,'Create boot sector$'
systfile db  0Ah,0Dh,'Creating file allocation table 16 bits$'
systfile2 db  0Ah,0Dh,'Creating file information table 32 bytes$'
systfile3 db  0Ah,0Dh,'Creating operating system files$'
Errormsg db 0Ah,0Dh,0Ah,0Dh,'An error has stopped the copying process !',0Ah,0Dh,'$'
Ok db 0Ah,0Dh,0Ah,0Dh,'The boot sector and the system files had been succefully copied.',0Ah,0Dh, 'To try COS reboot with this system disk',0Ah,0Dh,0Ah,0Dh,'$'

entrie  db 'System file',0
        db 'sys',0,0
        dw 1234h
        dw 1234h
        dw 1234h
        dw 1234h
        db 0h
        dw 32
        dw 512
        dw 0h
        dw 0


CopyCOS:
mov ah,09
mov dx,offset message
int 21h
jc error
mov ax,3D00h
mov dx,offset nameboot
int 21h
jc error
mov bx,ax
mov ax,4202h
xor cx,cx
xor dx,dx
int 21h
jc error
cmp dx,0
jne error
cmp ax,512
jne error
mov ax,4200h
xor cx,cx
xor dx,dx
int 21h
jc error
mov ah,3fh
mov cx,512
mov dx,offset buffer
int 21h
jc error
mov ah,3eh
int 21h
jc error
mov cx,0
mov bx,dx
call writesector
jne error
mov ah,09
mov dx,offset systfile
int 21h
jc error

mov cx,512/4
mov di,bx
mov eax,0
rep stosd
mov cx,13
fatanymore:
call writesector
jne error
dec cx
cmp cx,1
ja fatanymore
mov di,bx
mov ax,0FFF0h
mov cx,13
rep stosw
mov ax,0FFFFh
stosw
mov word ptr [bx+32*2],33
mov word ptr [bx+33*2],0FFFFh
mov cx,1
call writesector
jne error

mov ah,09
mov dx,offset systfile2
int 21h
jc error
mov cx,13
mov bx,offset entrie
call writesector
jne error

mov ah,09
mov dx,offset systfile3
int 21h
jc error

mov ax,3D00h
mov dx,offset namesystem
int 21h
jc error
mov bx,ax
mov ax,4202h
xor cx,cx
xor dx,dx
int 21h
jc error
cmp dx,0
jne error
sub ax,1  ;+512
cmp ax,0
jl error
shr ax,9
inc ax
mov bp,ax
mov ax,4200h
xor cx,cx
xor dx,dx
int 21h
jc error
mov ah,3fh
mov cx,0FFFFh
mov dx,offset buffer
int 21h
jc error
mov bx,dx
mov cx,32
syst:
call writesector
jne error
add bx,512
inc cx
dec bp
jnz syst







mov ah,09
mov dx,offset ok
int 21h
jc error
ret
error:
mov ah,09
mov dx,offset errormsg
int 21h
ret







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
  mov cl, AH
  mov ah,9
  mov dx,offset sign
  int 21h
  cmp cl,0
  pop si dx cx
ret

sign db '.$'
buffer db 512 dup (0)

end start
