.model tiny
.386c
.code
org 0100h
             
                
start:
    mov ax,0002
    int 47H   
    mov ah,26
    int 47H
replay:
    mov ah,2
    int 47h
mov ah,21
mov cl,7
int 47h
    xor di,di
    xor cx,cx
        mov ah,20
        mov bx,1D00h
        mov si,offset Msg
        int 47h
        mov ah,20
        mov bx,0231h
        mov si,offset msgapp
        int 47h
VerifAll:
        mov ah,1
        int 16h
        cmp al,32
        je enend
        mov ax,cx
        mov si,100
        mul si
        mov si,2880
        div si
        xor edx,edx
        mov dx,ax
        mov ah,15
        mov bx,0A14h
        int 47h
        mov ah,13
        mov si,offset po
        int 47h
        mov ah,15         
        mov dx,cx
        mov bx,0A10h
        int  47h
        mov ah,13
        mov si,offset Msg2
        int 47h
        mov ah,8         
        mov edx,0
        mov dx,di
        int  47h
        mov ah,13
        mov si,offset Msg3
        int 47h 
    call gauge
    call verifysector
    jc errors
    je noprob
    inc di
    noprob:
    inc cx
    cmp cx,2880
    jnz verifall
 enend:
 cmp di,0
 je noatall
mov bx,0E09h
mov ah,20
mov si,offset error2
int 47h
 jmp someof
 noatall:
mov bx,0E09h
mov ah,20
mov si,offset noerror
int 47h
 someof:
  mov ah,0
  int 16h
    mov ah,27
    int 47h
    db 0CBH
 errors:
mov ah,21
mov cl,4
int 47h
mov bx,0D09h
mov ah,20
mov si,offset errore
int 47h
mov ah,0
int 16h
jmp replay



errore db 'Error IO with floppy drive, insert a disk and Press a key',0
noerror db 'No defectuous Cluster, Press a key to Quit',0
error2 db 'This disk is bad, Press a key to Quit',0
po db ' %',0
msgapp db '<Press Space to quit>',0
msg db '- Disk Surface Test -',0
msg2 db ' cluster tested.           ',0
msg3 db ' defectuous cluster.',0
;->Increment CX
gauge:
push ax bx cx dx si ds
push cs
pop ds
mov ax,cx
mul sizes
div max
mov dx,ax
mov bl,oldvalue
xor bh,bh
mov byte ptr [offset gaugetxt+bx],'л'
cmp bx,0
jnz nono2
mov ah,21
mov cl,8
int 47h
mov bx,xy
mov ah,20
mov si,offset gaugetxt
int 47h
mov ah,21
mov cl,7
int 47h
nono2:
mov bx,dx
xor bh,bh
mov byte ptr [offset gaugetxt+bx],0
mov oldvalue,bl
mov bx,xy
mov ah,20
mov si,offset gaugetxt
int 47h
pop ds si dx cx bx ax
ret
oldvalue db 0
max dw 2880
sizes dw 50
xy dw 0A12h
gaugetxt db 'ллллллллллллллллллллллллллллллллллллллллллллллллллллллллл',0

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
TryAgain:
  mov AL, 1
  mov DL, 0
  mov AH, 2
  int 13h
  jnc Done
  dec SI
  jnz TryAgain
Done:
  pop si dx cx ax
ret  

WriteSector:
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

Buffer equ $
Buffer2 equ $+512


End Start
