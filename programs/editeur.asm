.model tiny
.386c
.code
org 0100h
             
                
start:
     mov ax,0305h
     mov bx,0008h
     int 16h
     mov ah,28h
     int 47h
     mov ax,0002
     int 47H   
     mov ah,2
     int 47h
     xor ebp,ebp
     xor ax,ax
     mov fs,ax
     mov ah,43
     int 47h
Adres:
     mov di,offset infos
     mov ah,34
     int 47h
     dec byte ptr [di]
     mov al,[di+1]
     sub al,16
     mov bl,al
     shr al,2
     mov [di+1],al
     and bl,11b
     mov [di+2],bl
     mov al,[di+7]
     cmp al,oldmode
     je noinit
     mov ah,2
     int 47h
     mov oldmode,al
     noinit:
     mov bx,0
     mov ah,25
     int 47h
     mov bh,infos
     mov edi,ebp
     mov ah,21
     mov cl,7
     int 47h
lines:
     mov edx,edi
     shr edx,4*4
     shl edx,4*3
     mov cx,16
     mov ah,10
     int 47h
     mov si,offset dep
     mov ah,13
     int 47h
     mov dx,di
     mov ah,10
     int 47h
     mov ah,13
     mov si,offset spaces
     int 47h
     mov ah,5
     int 47h
     mov al,infos+1
     mov cl,7
     mov ah,21
     int 47h
     mov esi,edi
doaline:
     mov edx,edi
     shr edx,4*4
     shl edx,4*3
     mov fs,dx      
     mov dl,fs:[di]
     mov ah,10
     mov cl,8
     int 47h
     mov ah,5
     int 47h
     inc edi
     dec al
     jnz doaline
     mov edi,esi
     mov si,offset spaces
     mov ah,13
     int 47h
     mov al,infos+1
     mov ah,21
     mov cl,7
     int 47h
doaline2:
     mov edx,edi
     shr edx,4*4
     shl edx,4*3
     mov fs,dx     
     mov dl,fs:[di]
     mov ah,7
     int 47h
     inc edi
     dec al
     jnz doaline2
     dec bh
     je outes
     cmp byte ptr infos+2,0
     je  lines
     mov ah,6
     int 47h
     jmp lines
outes:     
     mov ah,21
     mov cl,112
     int 47h
     mov bh,0
     mov bl,infos
     mov si,offset menu
     mov ah,14h
     int 47h
     waitkey:
     mov ax,0
     int 16h
     cmp ax,3B00h
     jne suit
     inc ebp
     jmp adres
     suit:
     cmp ax,3C00h
     jne suit2
     dec ebp
     jmp adres
     suit2:
     cmp ax,3D00h
     jne suit3
     add ebp,24*16
     jmp adres
     suit3:
     cmp ax,3E00h
     jne suit4
     sub ebp,24*16
     jmp adres   
     suit4:
     cmp ax,3F00h
     jne suit5
     add ebp,010000h
     jmp adres
     suit5:
     cmp ax,4000h
     jne suit6
     sub ebp,010000h
     jmp adres
     suit6:
     cmp ax,4100h
     jne suit7
     mov ah,21
     mov cl,116
     int 47h
     mov dword ptr [pope],'TIDE'
     mov bl,infos
     xor bh,bh
     mov si,offset menu
     mov ah,14h
     int 47h
     mov ah,21
     mov cl,7
     int 47h
     mov ax,0B800h
     mov es,ax   
     mov xxyy2,3
     mov xxyy,3
     call calc1
     call calc2  
waitst:
     mov ax,0
     int 16h  
     cmp ah,41h
     jne tre
     mov dword ptr [pope],' EUV'
     push cs
     pop es
     jmp adres
tre:
     cmp al,0
     jne write      
     cmp ah,48h
     jne tre1
     cmp yy,0
     je waitst
     dec yy
     jmp cursor
tre1:
     cmp ah,50h
     jne tre2
     mov al,infos
     dec al
     xor ah,ah
     cmp yy,ax
     je waitst
     inc yy
     jmp cursor
tre2:
     cmp ah,4Dh
     jne tre4
     cmp xx,15
     je waitst
     inc xx
     jmp cursor
tre4:       
     cmp ah,4Bh
     jne waitst
     cmp xx,0
     je waitst
     dec xx
     jmp cursor
write:
     call AsciiHex2dec
     cmp cl,15
     ja waitst
     call calc1
     call calc2
     mov edi,es:[bx-1]
     mov dx,es:[si-1] 
     mov byte ptr es:[bx],0112
     mov es:[bx-1],al
writs:
     mov ax,0
     int 16H
     mov ch,cl
     call AsciiHex2dec
     cmp cl,15
     ja writs
     shl ch,4
     add ch,cl
     mov es:[bx+1],al
     mov es:[si-1],ch
     mov ax,bx
     call calc3
     mov gs:[bx],ch
     pusha
     popa
     mov cl,gs:[bx]
     cmp ch,cl
     je no
     push si ax
     mov ah,25
     mov bl,infos
     xor bh,bh
     int 47h
     mov ah,21
     mov cl,117
     int 47h
     mov si,offset msg
     mov ah,13
     int 47h
     mov ax,0
     int 16h
     mov bl,infos
     xor bh,bh
     mov ah,25
     int 47h
     mov ah,21
     mov cl,116
     int 47h
     mov ah,13
     mov si,offset menu
     int 47h
     pop bx si
     mov es:[bx-1],edi
     mov es:[si-1],dx
     no:

     inc xx 
     cmp xx,16
     jne pasde
     inc yy
     mov xx,0h
     pasde:
     call calc1
     call calc2
     jmp waitst

cursor:
     call calc1
     call calc2
     jmp waitst
     suit7:
     cmp ax,4200h
     jne adres
     mov ah,29h
     int 47h
     db 0CBH     ; +++++++
     ret

calc1:
     push ax dx si
     mov ax,xx
     mov dx,xx
     shl ax,2
     shl dx,1
     add ax,dx
     add ax,27
     mov bx,YY
     mov dx,yy
     shl bx,5
     shl dx,7
     add bx,dx
     add bx,ax
     mov byte ptr es:[bx],112
     mov byte ptr es:[bx+2],112
     mov si,xxyy
     mov byte ptr es:[si],07
     mov byte ptr es:[si+2],07
     mov xxyy,bx 
     pop si dx ax
     ret

calc2:
     push ax bx dx 
     mov si,YY
     mov dx,yy
     shl si,5
     shl dx,7
     add si,dx
     mov dx,xx
     shl dx,1
     add si,dx
     add si,129
     mov byte ptr es:[si],112
     mov bx,xxyy2
     mov byte ptr es:[bx],07
     mov xxyy2,si 
     pop dx bx ax
     ret

calc3:
     push dx
     xor ebx,ebx
     mov bx,xx
     mov dx,yy
     shl dx,4
     add bx,dx
     add ebx,ebp
     mov edx,ebx
     shr edx,4*4
     shl edx,4*3
     mov gs,dx 
     pop dx 
     ret

     asciihex2dec:
     cmp al,'a'
     jb nomin
     cmp al,'f'
     ja nomin
     sub al,'a'-'A'
     jmp ismaj
     nomin:
     cmp al,'A'
     jb nomaj
     cmp al,'F'
     ja nomaj
     ismaj:
     mov cl,al
     sub cl,'A'-10
     jmp endt
     nomaj:
     mov cl,al
     sub cl,'0'
     endt:
     ret   

dep db ':',0
sect dw 0
xx dw 0
yy dw 0
xxyy dw 3
xxyy2 dw 3

msg  db 'Erreur : zone non modifiable (ROM) pressez une touche pour continuer                ',0
menu db 'haut/bas [F1/2] Offset [F3/4] Segment [F5/6] Mode F7, Quitter F8 MODE  '
pope  db 'VUE     ',0         
spaces db  ' ³ ',0

showbuffer db 35 dup (0FFh)
oldmode db 0
infos db 40 dup (0)
end start








