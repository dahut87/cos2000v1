boots segment
.386
org 000h
assume cs:boots,ds:boots

start:
jmp boot


bootdb  db     'COS2000A'               ;ID Formatage
        dw      512                      ;octet/secteur
        db      1                        ;secteur/cluster
        dw      1                        ;secteur reserv‚
        db      2                        ;nb de FAT
        dw      224                      ;nb secteur rep racine
        dw      2880                     ;nb secteur du volume
        db      0F0h                     ;ID support
        dw      9                        ;secteur/FAT
        dw      18                       ;secteur/piste       
        dw      2                        ;nb de tˆte
        dw      0                        ;distance 1er sect et sect masse
        db      0,0,0,0,0,0,0,0,29h     ;?
        db      01,02,03,04      ;no de serie
        db      'COS2000    '            ;nom de volume
        db      'FAT16   '               ;FAT
specialboot:
        db      0                        ;Secteur Systeme
errorloading  db 'The disk inserted in the floppy drive is not a system disk !!',0dh,0
okloading db 'COS is loading',0dh,0


errorboot:
        mov si,offset errorloading
        call showstr
        mov ah,0
        int 16h
        int 19h
boot:
        cli
        mov ax,07C0h
        mov ds,ax
        mov ax,09000h
        mov ss,ax
        mov sp,0FFFFh
        mov ax,1000h
        mov es,ax
        sti
        xor ax,ax
        xor dx,dx
        int 13h
        jc errorboot
        mov si,offset okloading
        call showstr
        mov cx,13
        mov bx,100h
        call readsector
        jc errorboot
        mov cx,es:[bx+26]
        call readsector
        jc errorboot
        add bx,512
        inc cx
        call readsector
        jc errorboot
        db 2eh,0ffh,1eh
        dw offsets
        Offsets  dw 100h
                 dw 1000h
        ret


DiskSectorsPerTrack dw 18   
DiskTracksPerHead dw 80
DiskHeads dw 2

;===================================Afficher un int EDX a l'‚cran================
ShowInt:
        push    eax edx esi di es
        mov     di,xy
        mov     ax,0B800h
        mov     es,ax
        mov     eax,edx
        mov     esi,10
decint2:
        xor     edx,edx
        div     esi
        add     dl,'0'
        mov     dh,colors
        mov     es:[di],dx
        sub     di,2
        cmp     ax,0
        jne     decint2
        sub     di,2
        mov     xy,di
        pop     es di esi edx eax 
ret

xy dw 20
colors db 4

ReadSector:
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
  xor dX, DX
  div DiskHeads
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
  pop si dx cx 
ret  

showcrlf:
  push ax bx
  mov ax, 0E0Dh
  xor bx, bx
  int 10h
  mov al, 0Ah
  int 10h
  pop bx ax
ret

showstr:
        push ax bx si
again:
        lodsb
        or al,al
        jz fin
        cmp al,0Dh
        jne noret
        call showcrlf
        jmp again
noret:
        mov ah,0Eh
        mov bx,07h
        int 10h
        jmp again
        fin:
        pop si bx ax
        ret  


end start

