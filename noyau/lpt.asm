.model tiny
.486
smart
.code
org 0100h
start:
jmp tsr
drv db 'LPT ',0
Tsr:
cli
cmp ax,1234h
jne nomore
mov ax,4321h
jmp itsok
nomore:
push bx ax
mov ah,4
mov bh,1
int 50h
mov bl,al
pop ax
cmp byte ptr cs:isact,1
je nottest
mov cs:isact,1  
cmp bl,80h
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
tables   dw getlptin
         dw getlptout
         dw getlptinout
         dw setlptin
         dw setlptout
         dw setlptinout
         dw getlpt
         dw getfirstlpt
         dw setemettor
         dw setreceptor
         dw settimeout
         dw gettimeout
         dw receivelpt
         dw sendlpt
         dw receivelptblock
         dw sendlptblock
         dw receivecommand
         dw sendcommand

react:
push ds es
mov cs:isact,1 
pushad
push cs
pop ds
push cs
pop es
cmp byte ptr never,1
je oknever   
mov bl,[drv+3]
sub bl,'0'
xor bh,bh
call getlpt
dec bl
shl bl,1
mov al,7
sub al,bl
mov ah,40
mov di,offset video
int 47h
push ax
mov ah,01h
int 50h
mov ah,21
mov cl,4
int 47h
sti
mov al,0111b
call setlptout
call setreceptor
call initlpt
jc errorie
mov cx,0
mov ah,20
mov bx,1012h
mov si,offset initok
int 47h
cmp byte ptr always,1
je yes
mov ah,20
mov bx,1010h
mov si,offset mdd
int 47h
mov ah,13
mov si,offset drv
int 47h
mov ah,6
int 47h
mov ah,20
mov bx,1011h  
mov si,offset msg
int 47h     
waitkey:
mov ax,0
int 16h
cmp al,'n'
je no
cmp al,'N'
je no
cmp al,'Y'
je yes
cmp al,'y'
je yes
cmp al,'e'
je nev
cmp al,'E'
je nev
cmp al,'a'
je alw
cmp al,'A'
je alw
jmp waitkey
yes:
call receivecommand
jc errortimeout
no:
mov al,0111b
call setlptout
cli
mov ah,41
mov si,offset video
int 47h
pop ax
mov ah,00h
int 50h
mov ah,09h
int 50h
oknever:
popad
pop es ds
mov cs:isact,0
pop bx
jmp endofint
errorie:
mov si,offset inits
jmp show
errortimeout:
mov si,offset timeouts
show:
mov ah,20
mov bx,1012h
int 47h
mov ax,0
int 16h
jmp no
nev:
mov byte ptr never,1
jmp no
alw:
mov byte ptr always,1
jmp yes
initok db 'Initialisation is realised !',0
inits db 'Error on initialisation',0
timeouts db 'Connection lost or timeout complete !!',0
mdd db 'Connection demand on ',0
msg db 'Accept connection ? (Y)es (N)o n(E)ver (A)lways',0
isact db 0
always db 0
never db 0

;envois une commande al
sendcommand:
push ax bx cx di 
mov bl,al
xor bh,bh
shl bx,1
add bx,offset cmde
call cs:[bx]
pop di cx bx ax
ret
cmde  dw nothing
      dw getram

;recupŠre la ram en ds:si de cx distant caractŠres en es:di local
getram:
push ax bx cx ds
mov bx,offset command
mov cs:[bx+2],ds
mov cs:[bx],si
mov cs:[bx+4],cx
push cs
pop ds
mov si,bx
mov cx,6
call sendlptblock
jc endofget
call receivelptblock
endofget:
pop ds cx bx ax
ret

;Re‡ois une commande et l'execute
Receivecommand:
push ax bx cx di ds es
push cs
pop es
push cs
pop ds
mov di,offset command
call receivelptblock
jc endofno
mov bl,al
xor bh,bh
shl bx,1
add bx,offset cmd
call cs:[bx]
clc
endofno:
pop es ds di cx bx ax
ret

command db 25 dup (0)
cmd dw nothings
    dw sendram
    dw receiveram
    dw sendreg
    dw receivereg
    dw sendport
    dw receiveport
    dw letexecute
nothings:
ret

letexecute:
push ds es fs gs
pushad
push cs
push offset suite
mov ax,es:[di+2]
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
push ax
mov ax,es:[di]
push ax
DB 0CBh
suite:
popad
pop gs fs es ds
ret

Sendram:
push ax cx si ds
mov si,es:[di]
mov ax,es:[di+2]
mov ds,ax
mov cx,es:[di+4]
call sendlptblock
pop ds si cx ax
ret

receiveram:
sendreg:
receivereg:

sendport:
push ax cx dx si 
mov dx,es:[di]
in ax,dx
mov cx,2
mov si,offset tempblock
mov ds:[si],ax
call sendlptblock
pop si dx cx ax
ret

receiveport:
push ax dx 
mov dx,es:[di]
mov ax,es:[di+2]
out dx,ax
pop dx ax
ret

tempblock db 25 dup (0)

;---------Segment Adress-----------
Bios equ 040h
;---------Offset Adress------------
Lptadr equ 008h
Timer equ 06Ch
;---------Constant-----------------
onesec equ 18
tensec equ 182
Ack equ 00
Nack equ 0FFh
maxtry equ 10   

Initlpt:
push ax ecx
call StartTimer
cmp cs:emettor,0
je receptinit
mov al,10000b
call SetLptOut
waitinit1:
call EndTimer
cmp cx,cs:timeout
ja errorinit
call getlptIn
cmp al,00000b
jnz waitinit1
jmp endinit
receptinit:
call EndTimer
cmp cx,cs:timeout
ja errorinit
call getlptIn
cmp al,00000b
jnz receptinit
mov al,10000b
call SetLptOut
endinit:
clc
pop ecx ax
ret
errorinit:
stc
pop ecx ax   
ret


;-Envoie DL       (dh)    JNE si problŠme  JNC error timeout
Sendlpt:
push ax bx ecx
call StartTimer
mov dh,dl
mov al,dl
and al,0Fh
call SetLptOut
waitSend:
call EndTimer
cmp cx,cs:timeout
ja errorsend
call getlptIn
bt ax,4
jnc waitsend
and al,0Fh
mov bl,al
call StartTimer  ;/////
mov al,dh
shr al,4
or al,10000b
call SetLptOut
waitSend2:
call EndTimer
cmp cx,cs:timeout
ja errorsend
call getlptIn
bt ax,4
jc waitsend2
and al,0Fh
shl al,4
add bl,al
cmp dl,bl
pop ecx bx ax
clc
ret
errorsend:
pop ecx bx ax
stc
ret


;-Re‡ois DL       (dh)   
Receivelpt:
push ax bx ecx 
call StartTimer
waitreceive:
call EndTimer
cmp cx,cs:timeout
ja errorreceive
call getlptIn
bt ax,4
jnc waitreceive
and al,0Fh
mov dl,al
call SetLptOut
call StartTimer  ;/////
waitreceive2:
call EndTimer
cmp cx,cs:timeout
ja errorreceive
call getlptIn
bt ax,4
jc waitreceive2
and al,0Fh
mov dh,al
shl dh,4
add dl,dh
or al,10000b
call SetlptOut
clc
pop ecx bx ax
ret
errorreceive:
stc
pop ecx bx ax 
ret

;-AX
SetTimeout:
mov cs:Timeout,dx
ret

timeout dw tensec

getTimeout:
mov dx,cs:Timeout
ret    

SetEmettor:
mov cs:Emettor,1
ret 
    
Emettor db 0

SetReceptor:
mov cs:Emettor,0
ret  

;->bx  Nøport->Adresse dx 
GetLpt:
push ax bx ds
mov ax,bios
mov ds,ax
dec bx
shl bx,1
mov dx,ds:[Lptadr+bx]
mov cs:lpt,dx
pop ds bx ax
ret
lpt dw 0

;->bx  Nøport->Adresse dx
GetFirstLpt:
push ax ds
mov ax,bios
mov ds,ax
xor bx,bx
findlpt:
mov dx,ds:[Lptadr+bx]
cmp dx,0
jne oklpt
add bx,2
cmp bx,4
jbe findlpt
oklpt:
mov cs:lpt,dx
pop ds ax
ret

;->
StartTimer:
push ax ecx ds
mov ax,Bios
mov ds,ax
mov ecx,ds:[timer]
mov cs:times,ecx
pop ds ecx ax
ret
times dd 0

;->Ecx time elapsed
EndTimer:
push ax ds
mov ax,Bios
mov ds,ax
mov ecx,ds:[timer]
sub ecx,cs:times
pop ds ax
ret

;->
GetLptOut:
push dx
mov dx,cs:lpt
in al,dx
pop dx
ret

GetLptIn:
push dx
mov dx,cs:lpt
inc dx
in al,dx
shr al,3
pop dx
ret

GetLptInOut:
push dx
mov dx,cs:lpt
add dx,2
in al,dx
and al,11111b
pop dx
ret

SetLptOut:
push dx
mov dx,cs:lpt
out dx,al
pop dx
ret

SetLptIn:
push dx
mov dx,cs:lpt
inc dx
out dx,al
pop dx
ret

SetLptInOut:
push dx
mov dx,cs:lpt
add dx,2
out dx,al
pop dx
ret

;R‚alise un checksum 8 bits sur donn‚es DS:SI, nb CX r‚sultat dans dl
Checksum8:
push cx si 
check:
add dl,[si]
inc si
dec cx
jnz check
pop si cx
ret

;DS:SI pointeur sur donn‚es, CX nombres de donn‚es, AL token
SendLptBlock:
push ax bx cx edx si edi bp
mov dx,cx
shl edx,16
mov dh,al
call checksum8
mov edi,edx
xor dh,dh
mov bp,dx
mov ah,maxtry
retry:
mov bl,4
xor al,al
header:
mov dx,di
call sendlpt
setne al
jc outt
rol edi,8
dec bl
jnz header
cmp al,0
jne notgood
mov dl,ACK
jmp allsend
notgood:
mov dl,NACK
allsend:
call sendlpt
setne al
jc outt
cmp al,0
je okheader
dec ah
jnz retry
jmp outt
okheader:
cmp cx,0
je endoftrans
mov di,maxtry
retry2:
mov bx,cx
xor ax,ax
body:
mov dl,[si+bx-1]
add ah,dl
call sendlpt
setne al
jc outt
dec bx
jnz body
cmp al,0
jne notgood2
mov dl,ACK
jmp allisend
notgood2:
mov dl,NACK
allisend:
call sendlpt
setne al
jc outt
cmp al,0
je endoftrans
dec di
jnz retry2
outt:
stc
endoftrans:
mov al,ah
xor ah,ah
cmp bp,ax
pop bp edi si edx cx bx ax
ret

;Receptionne en es:di les donn‚es au nombres de CX token AL   (AH)  (ECX)
receiveLptBlock:
push bx dx si bp
mov ah,maxtry
retrye:
mov bl,4
headere:
call receivelpt
jc outte
mov cl,dl
rol ecx,8
dec bl
jnz headere
call receivelpt
jc outte
cmp dl,ACK
je okheadere
dec ah
jnz retrye
jmp outte
okheadere:
mov al,ch
xor ch,ch
mov bp,cx
rol ecx,16
cmp cx,0
je endoftranse
mov si,maxtry
retrye2:
mov bx,cx
xor ah,ah
bodye:
call receivelpt
jc outte
mov es:[di+bx-1],dl
add ah,dl
dec bx
jnz bodye
call receivelpt
jc outte
cmp dl,ACK
je endoftranse
dec si
jnz retrye2
outte:
stc
endoftranse:
mov bl,ah
xor bh,bh
cmp bp,bx
pop bp si dx bx 
ret
video db 0
end start
