.model tiny
.486
smart
.code
org 0100h
start:
;call setemettor
call getfirstlpt
call initlpt 
call receivecommand
ret                



gogo db 'Salut'
gotoz db 23 dup (0)

;Re‡ois une commande et l'execute
Receivecommand:
push ax bx cx di es
push cs
pop es
mov di,offset command
call receivelptblock
mov bl,al
xor bh,bh
shl bx,1
add bx,offset cmd
call [bx]
pop es di cx ax
ret
command db 25 dup (0)
cmd dw nothings
    dw sendram

nothings:
ret

Sendram:
push ax cx si ds
mov ax,es:[di]
mov si,ax
mov ax,es:[di+2]
mov ds,ax
mov cx,es:[di+2]
call sendlptblock
pop ds si cx ax
ret


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
tokenstart equ 0
tokennext equ 1
tokenstop equ 2  
tokenbad equ 3
tokenresend equ 4


Initlpt:
push ax ecx
call StartTimer
cmp emettor,0
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
mov cs:Timeout,ax
ret

timeout dw tensec

getTimeout:
mov ax,cs:Timeout
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
mov times,ecx
pop ds ecx ax
ret
times dd 0

;->Ecx time elapsed
EndTimer:
push ax ds
mov ax,Bios
mov ds,ax
mov ecx,ds:[timer]
sub ecx,times
mov ecx,0
pop ds ax
ret

;->
GetLptOut:
push dx
mov dx,lpt
in al,dx
pop dx
ret

GetLptIn:
push dx
mov dx,lpt
inc dx
in al,dx
shr al,3
pop dx
ret

GetLptInOut:
push dx
mov dx,lpt
add dx,2
in al,dx
and al,11111b
pop dx
ret

SetLptOut:
push dx
mov dx,lpt
out dx,al
pop dx
ret

SetLptIn:
push dx
mov dx,lpt
inc dx
out dx,al
pop dx
ret

SetLptInOut:
push dx
mov dx,lpt
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
push ax bx dx si bp
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
pop bp si dx bx ax
ret





























end start;
