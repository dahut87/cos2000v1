.model tiny
.486
smart
.code
org 0100h
start:
jmp tsr
drv db 'MOUSE',0
Tsr:
cli
cmp ax,1234h
jne nomore
mov ax,4321h
jmp itsok
nomore:
push bx ax
mov ah,4
mov bh,0
int 50h
mov bl,al
pop ax
cmp byte ptr cs:isact,1
je  nottest
mov cs:isact,1
and bl,10000b
cmp bl,16
jae react
mov bl,ah
xor bh,bh
shl bx,1
mov bx,cs:[bx].tables
mov cs:current,bx
pop bx
call cs:current
itsok:
jnc noerror
push bp
mov bp,sp
or byte ptr [bp+6],1b
pop bp
mov ax,cs
shl eax,16
mov ax,cs:current
jmp endofint
noerror:
push bp
mov bp,sp
and byte ptr [bp+6],0FEh
pop bp
endofint:
mov cs:isact,0
sti
iret
nottest:
pop bx
jmp endofint
current dw 0
tables   dw cmdmouse
         dw cmdmouse2
         dw detectmouse
         dw getmouse
         dw getmousescreen
         dw configmouse

isact db 0

;Envoie une commande AL … la souris via controleur clavier
cmdmouse:
        push ax
videbuff1:
        in al, 64h                            
        and al, 10b                             
        jne videbuff1                   
        mov al, 00d4h                     
        out 64h, al
videbuff2:
        in al, 64h
        and al, 10b                            
        jne  videbuff2              
        pop ax
        out 60h, al                            
        in al, 60h                            
        ret

;Envoie une commande2 AL … la souris via controleur clavier carry=nomouse
cmdmouse2:
        push ax
videbuff21:
        in al, 64h                            
        and al, 10b                             
        jne videbuff21                   
        mov al, 0060h                     
        out 64h, al
videbuff22:
        in al, 64h
        and al, 10b                            
        jne  videbuff22               
        pop ax
        out 60h, al                            
        in al, 60h                            
        ret

Detectmouse:
        push ax cx
        mov al, 0a8h                            ;AUX enable
        out 64h, al
        mov al, 0f3h                            ;Set sample
        call cmdmouse
        mov al, 100                             ;Set sample
        call cmdmouse  
        mov al, 0e8h                            ;Set resolution
        call cmdmouse  
        mov al, 01                              ;Set resolution
        call cmdmouse  
        mov al, 0e7h                            ;Set scale 2:1
        call cmdmouse  
        mov al, 0f4h                            ;Enable device
        call cmdmouse  
        mov al, 47h                             ;Interruption ON
        call cmdmouse2  
        mov cx, 1024                 
testmouse:
        in al, 60h                              ;Lecture du port de donn‚es
        cmp al, 250                             ;Test si il y a une souris
        je okmouse
        dec cx
        jnz testmouse
        stc
        jmp endoftest
okmouse:
        clc
endoftest:
        pop cx ax
        ret

;envoie en bx,cx les coordonn‚es et en dl les boutons
getmouse:
mov bx,cs:rx
mov cx,cs:ry
mov dl,cs:button
sub dl,8
and dl,0Fh
clc
ret

;envoie en di les coordonn‚es ecran et en dl les boutons
getmousescreen:
mov di,cs:xy
mov dl,cs:button
sub dl,8
and dl,0Fh
clc
ret


;configure la rapidit‚ dans cl et dans ah,al sphŠre x et y
Configmouse:
mov cs:speed,cl
mov cs:spherex,ah
mov cs:spherey,al
ret

Button  db 0
rx      dw 0
ry      dw 0
VX      db 0
VY      db 0
X       dw 7FFFh
Y       dw 7FFFh
speed   db 6
spherex db 0
spherey db 0
count   db 0
error   db 0
xy      dw 0
old     db 0
;Gestionnaire de souris PS/2
react:
        push ax bx cx dx di ds es
        push cs
        pop ds
        in al, 60h 
        cmp error, 1
        je gest1
        cmp count, 1
        je gest1
        cmp count, 2
        je gest2
        cmp count, 3
        je gest3

gest1:
        mov count, 2
        mov Button, al
        and al, 00001000b
        cmp al, 8
        je gest1end
        mov error, 1
        jmp gest1end2
gest1end:
        mov error, 0
gest1end2:
        mov count, 2
        jmp endgest
gest2:
        mov count, 3
        mov VX, al
        jmp endgest
gest3:
        mov count, 1
        mov VY, al
        jmp endgest
endgest:
        cmp error,1
        je errormouse
        push cs
        pop es
        mov di,offset infos
        mov ah,34
        int 47h              
        mov cl,speed
        movsx bx,VY
        shl bx,cl
        cmp spherey,0
        jne nolimity
        xor ah,ah
        mov al,[di]
       cmp byte ptr [di+7],4
        jbe text4
       shl ax,3
text4:
        dec ax
        cmp bx,0
        jg decy
        cmp ry,ax
        jae noaddy
        jmp nolimity
decy:
        cmp ry,0
        je noaddy
nolimity:
        sub y,bx
noaddy:
        movsx bx,VX
        shl bx,cl
        cmp spherex,0
        jne nolimitx
         xor ah,ah
        mov al,[di+1]
        cmp byte ptr [di+7],4
        jbe text5
       shl ax,3
text5: 
        dec ax
        cmp bx,0
        jl decx
        cmp rx,ax
        jae noaddx
        jmp nolimitx
decx:
        cmp rx,0
        je noaddx
nolimitx:
        add x,bx
noaddx:
        mov ax,x
        mov bx,0FFFFh
        xor ch,ch
        mov cl,[di+1]
       cmp byte ptr [di+7],4
        jbe text1
       shl cx,3
text1:
        mul cx
        div bx
        mov rx,ax
        mov ax,y
        xor ch,ch
        mov cl,[di]
       cmp byte ptr [di+7],4
        jbe text2
       shl cx,3
text2:
        mul cx
        div bx
        mov ry,ax
        xor ch,ch
        mov cl,[di+1]
        cmp byte ptr [di+7],4
        jbe text3
       shl cx,3
text3:   
        mul cx
        add ax,rx
       cmp byte ptr [di+7],4
        mov di,ax
        jbe textpoint
       mov ax,0A000h
        mov es,ax
        jmp graphpoint
textpoint:
        mov ax,0B800h
        mov es,ax
        shl di,1
        inc di
graphpoint: 
        mov bx,xy
        cmp byte ptr es:[bx],070h 	
        jne waschanged
        mov al,old
        mov byte ptr es:[bx],al 
waschanged:
        mov xy,di
        mov al,es:[di]
        mov old,al
        mov byte ptr es:[di],070h 
        mov al, 20h
        out 0a0h, al                         
        out 20h, al             
errormouse:
        pop es ds di dx cx bx ax
        mov cs:isact,0
        pop bx
        iret
 infos db 40 dup (0)

end start
