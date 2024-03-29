.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
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
lines:
     xor edx,edx
     mov dx,di
     push edx
     mov edx,edi
     shr edx,4*4
     shl edx,4*3
     push edx
     push offset spaces
     call [print]
     mov dx,di
     mov al,infos+1
     mov esi,edi
doaline:
     mov edx,edi
     shr edx,4*4
     shl edx,4*3
     mov fs,dx      
     push dword ptr fs:[di]
     push 8
     call [showhex]
     push ' '
     call [showchar]
     inc edi
     dec al
     jnz doaline
     mov edi,esi
     push offset spaces2
     call [print]
     mov al,infos+1
doaline2:
     mov edx,edi
     shr edx,4*4
     shl edx,4*3
     mov fs,dx     
     push word ptr fs:[di]
     call [showchar]
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
     mov bh,0
     mov bl,infos
     mov ah,25
     int 47h
     push offset menu
     call [print]
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
     mov dword ptr [pope],'TIDE'
     mov bh,0
     mov bl,infos
     mov ah,25
     int 47h
     push offset menu
     call [print]
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
     mov bh,0
     mov bl,infos
     mov ah,25
     int 47h
     push offset msg
     call [print]
     mov ax,0
     int 16h
     mov bh,0
     mov bl,infos
     mov ah,25
     int 47h
     push offset menu
     call [print]
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
     retf

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

msg  db '\c74Erreur : zone non modifiable (ROM) pressez une touche pour continuer                ',0
menu db '\c70haut/bas [F1/2] Offset [F3/4] Segment [F5/6] Mode F7, Quitter F8 MODE  '
pope  db 'VUE     ',0         
spaces db  '\c02%hW:%hW \c04|  \c07',0
spaces2 db  '\c04 | \c07',0

showbuffer db 35 dup (0FFh)
oldmode db 0
infos db 40 dup (0)

imports:
         db "VIDEO.LIB::print",0
print    dd 0
         db "VIDEO.LIB::showhex",0
showhex  dd 0
         db "VIDEO.LIB::showchar",0
showchar dd 0
         dw 0

end start








