include "..\include\mem.h"
include "..\include\divers.h"
include "..\include\graphic.h"

org 0h

start:
header exe 1

realstart:
mov     ax,0305h
mov     bx,0008h
int     16h
invoke    savestate
invoke    setvideomode,2
xor     ebp,ebp
xor     ax,ax
mov     fs,ax
invoke    disablescroll
adres:
invoke    saveparamto,infos
invoke    readsector,[sect], buffer
jnc adres2
errtr:
    invoke setxy,0,word [lastline]
     invoke print, errordisk
     xor ax,ax
     int 16h
adres2:
invoke    saveparamto, infos
mov     al,[infos.lines]
dec     al
mov     [lastline],al
mov     al,[infos.columns]
sub     al,16
mov     bl,al
shr     al,2
mov     [sizex],al
and     bl,11b
mov     [sizex2],bl
mov     al,[infos.modenum]
cmp     al,[oldmode]
je      noinit
invoke    clearscreen
mov     [oldmode],al
noinit:
invoke    setxy,0,0
mov     edi,ebp
mov     bh,[lastline]
lines:
xor     edx,edx
mov     dx,di
push    edx
mov     edx,edi
mov dx,[sect]
push    edx
push    spaces
invoke    print
mov     dx,di
mov     al,[sizex]
mov     esi,edi
doaline:
push dword [di+buffer]
push    8
invoke    showhex
invoke    showchar,' '
inc     edi
dec     al
jnz     doaline
mov     edi,esi
push    spaces2
invoke    print
mov     al,[sizex]
doaline2:
push word [di+buffer]
invoke    showchar
inc     edi
dec     al
jnz     doaline2
dec     bh
je      outes
cmp     [sizex2],0
je      lines
invoke    addline
jmp     lines
outes:
invoke    setxy,0,word [lastline]   
invoke    print,menu
     waitkey:
     mov ax,0
     int 16h
     cmp ax,3B00h
     jne suit
     cmp bp,8*16
     jae waitkey
     add bp,16  
     jmp adres2
     suit:
     cmp ax,3C00h
     jne suit2
     cmp bp,0
     je waitkey
     sub bp,16
     jmp adres2
     suit2:
     cmp ax,3D00h
     jne suit3
     cmp [sect],2880
     ja waitkey
     inc [sect]
     jmp adres
     suit3:
     cmp ax,3E00h
     jne suit4
     cmp [sect],0
     je waitkey
     dec [sect]
     jmp adres   
     suit4:
     cmp ax,3F00h
     jne suit5
     jmp adres2
     suit5:
     cmp ax,4000h
     jne suit6
invoke    writesector,[sect],buffer
     jnc waitkey
     jmp errtr
     suit6:
cmp     ax,4100h
jne     suit7
mov     dword [pope],'TIDE'
invoke    setxy,0,word [lastline]
invoke    print,menu
mov     ax,0B800h
mov     es,ax
mov     [xxyy2],3
mov     [xxyy],3
invoke    calc1
invoke    calc2
waitst:
mov     ax,0
int     16h
cmp     ah,41h
jne     tre
mov     dword [pope],' EUV'
push    cs
pop     es
invoke    writesector,[sect],buffer
     jnc waitkey
     jmp errtr
tre:
cmp     al,0
jne     write
cmp     ah,48h
jne     tre1
cmp     [yy],0
je      waitst
dec     [yy]
jmp     cursor
tre1:
cmp     ah,50h
jne     tre2
mov     al,[lastline]
dec     al
xor     ah,ah
cmp     [yy],ax
je      waitst
inc     [yy]
jmp     cursor
tre2:
cmp     ah,4Dh
jne     tre4
cmp     [xx],15
je      waitst
inc     [xx]
jmp     cursor
tre4:
cmp     ah,4Bh
jne     waitst
cmp     [xx],0
je      waitst
dec     [xx]
jmp     cursor
write:
invoke    asciihex2dec
cmp     cl,15
ja      waitst
invoke    calc1
invoke    calc2
mov     edi,[es:bx-1]
mov     dx,[es:si-1]
mov     byte [es:bx],0112
mov     [es:bx-1],al
writs:
     mov ax,0
     int 16h
     mov ch,cl
     call asciihex2dec
     cmp cl,15
     ja writs
     shl ch,4
     add ch,cl
     mov [es:bx+1],al
     mov [es:si-1],ch
     mov ax,bx
     call calc3
     mov [bx],ch
     inc [xx] 
     cmp [xx],16
     jne pasde
     inc [yy]
     mov [xx],0h
     pasde:
     call calc1
     call calc2
     jmp waitst
cursor:
call    calc1
call    calc2
jmp     waitst
suit7:
cmp     ax,4200h
jne     adres
invoke    restorestate
retf
calc1:
push    ax dx si
mov     ax,[xx]
mov     dx,[xx]
shl     ax,2
shl     dx,1
add     ax,dx
add     ax,27
mov     bx,[yy]
mov     dx,[yy]
shl     bx,5
shl     dx,7
add     bx,dx
add     bx,ax
mov     byte [es:bx],112
mov     byte [es:bx+2],112
mov     si,[xxyy]
mov     byte [es:si],07
mov     byte [es:si+2],07
mov     [xxyy],bx
pop     si dx ax
ret
calc2:
push    ax bx dx
mov     si,[yy]
mov     dx,[yy]
shl     si,5
shl     dx,7
add     si,dx
mov     dx,[xx]
shl     dx,1
add     si,dx
add     si,129
mov     byte [es:si],112
mov     bx,[xxyy2]
mov     byte [es:bx],07
mov     [xxyy2],si
pop     dx bx ax
ret
calc3:
     push dx
     xor bx,bx
     mov bx,[xx]
     mov dx,[yy]
     shl dx,4
     add bx,dx
     add bx,bp
     add bx,buffer
     pop dx 
     ret

asciihex2dec:
cmp     al,'a'
jb      nomin
cmp     al,'f'
ja      nomin
sub     al,'a'-'A'
jmp     ismaj
nomin:
cmp     al,'A'
jb      nomaj
cmp     al,'F'
ja      nomaj
ismaj:
mov     cl,al
sub     cl,'A'-10
jmp     endt
nomaj:
mov     cl,al
sub     cl,'0'
endt:
ret

xx dw 0
yy dw 0
xxyy dw 3
xxyy2 dw 3

lastline db 0
sizex db 0
sizex2 db 0
buffer db 2048 dup (0)

dep db ':',0
errordisk db '\c74Une erreur est apparue sur le lecteur, appuyez sur une touche                  ',0
menu      db '\c70Haut&Bas [F1/2] Secteur [F3/4] Charger/Sauver [F5/6] Mode [F7] Quit. [F8] '
pope  db 'VUE     ',0
spaces db  '\c02%hW:%hW \c04|  \c07',0
spaces2 db  '\c04 | \c07',0

showbuffer db 35 dup (0FFh)
oldmode db 0
sect dw 0
infos vgainf 

importing
use DISQUE,readsector
use DISQUE,writesector
use VIDEO,setvideomode
use VIDEO,savestate
use VIDEO,restorestate
use VIDEO,setxy
use VIDEO,addline
use VIDEO,saveparamto
use VIDEO,disablescroll
use VIDEO,clearscreen
use VIDEO.LIB,print
use VIDEO.LIB,showhex
use VIDEO.LIB,showchar
endi

