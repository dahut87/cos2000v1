.model tiny
.486
smart
.code
org 0100h
start:
jmp tsr
drv db 'JOYSTICK',0
Tsr:
cli
cmp ax,1234h
jne nomore
mov ax,4321h
jmp itsok
nomore:
push bx
cmp byte ptr cs:isact,1
je  nottest
mov cs:isact,1
jmp react
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
tables   dw 0;detectjoystick
         ;dw getjoystick
         ;dw getjoystickscreen
         ;dw configjoystick
isact db 0

;envoie en bx,cx les coordonn‚es et en dl les boutons
getjoystick:
push ax cx
mov bx,cs:rx
mov cx,cs:ry
mov al,cs:button
not al                   
mov  cl,4
shr al,cl   
mov dl,al
pop cx ax
ret

;envoie en di les coordonn‚es ecran et en dl les boutons
getjoystickscreen:
push ax cx
mov di,cs:xy
mov al,cs:button
not al                   
mov  cl,4
shr al,cl   
mov dl,al
pop cx ax
ret
db 'button'
Button  db 0
db 'rx'
rx      dw 0
db 'ry'
ry      dw 0
db 'vx'
VX      db 0
db 'vy'
VY      db 0
db 'x'
X       dw 7FFFh
db 'y'
Y       dw 7FFFh
speed   db 6
spherex db 0
spherey db 0
db 'count'
count   db 0
db 'error'
error   db 0
xy      dw 0
old     db 0

calibrate db 0
db 'ticks'
ticks dw 0
db 'state'
state db 0
db 'connard'
connard db 1
connard2 db 1
;Gestionnaire de joystick
react:
        push ax bx cx dx si di bp ds es
       push cs
       pop ds
       mov     dx,201h    
       cmp error, 1
        je gest1        
       cmp count,1
       je gest1
       cmp count,2
       je gest2
gest1:
       mov error,0
       mov count,2
       call getticks
        mov ticks,ax
        out dx,al
        in al,dx
        and al,00000011b
        mov state,al
        jmp endgest
gest2:
not connard
       call getticks
       sub ax,ticks      
        cmp ax,1FF0h
        jb nofinish
        mov error,1
        jmp endgest
nofinish:
       mov bx,ax
        in al,dx
        and 	al,00000011b
        cmp state,al
        je endgest
        xchg state,al
        xor al,state
        mov cl,4
        or      bx,bx                
        js      noadj
        shr     bx,cl                  
noadj:
        test al,1
        je isy
        mov VX,bl
        jmp wasx
isy:
        test al,2
        je endgest
       mov VY,bl 
wasx:
mov connard2,0fh
        mov count,1 
endgest:
        in      al,dx               
        not     al                   
        mov     cl,4
        shr     al,cl                  
        mov button,al
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
        pop es ds bp di si dx cx bx ax
        mov cs:isact,0
        pop bx
        iret
 infos db 40 dup (0)


getticks:
mov     al,0                 
out     43h,al
jmp    wait1
wait1:                 
in      al,40h               
mov     ah,al
jmp     wait2
wait2:
in      al,40h               
xchg    ah,al                  
ret

end start
