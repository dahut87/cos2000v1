.model tiny
.486
smart
.code

org 0100h

start:
mov ax,6
int 47h
mov ax,0a000h
mov es,ax
mov ds,ax
xor di,di
mov cx,0ffffh/4
mov eax,0
rep stosd
mov ax,0c40h
boucle:
mov ah,4
int 74h
mov byte ptr es:[di],0FFh
mov si,0
mov di,0
mov cx,0ffffh
reboucle:
mov al,[si]
inc si
cmp al,0
je suite
dec al
suite:
mov es:[di],al
inc di
dec cx
jnz reboucle
cmp dl,2
jne boucle
db 0CBh

end start
