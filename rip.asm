net segment

org 0100h
assume cs:net,ds:net

start:
jmp deb
taille dw 0
signe db 'rip'
signe2 db 64 dup (0)
p1 db '@'
p2 db '@'
min db 4
deb:
mov	BL,DS:[0080h]			
xor 	BH,BH				
or 	BX,BX				
mov 	byte ptr [0081h+BX],00h		
mov 	AX,3D02h			
mov 	DX,0082H			
int 	21h		
mov bx,ax
mov ah,3fh
mov cx,0ffffh
mov dx,offset data
int 21h
mov taille,ax
mov ah,3eh
int 21h
mov si,82h
mov di,offset signe2
mov cx,64
rep movsb
mov di,offset signe2
mov cx,64
mov al,2eh
repne scasb
push di
mov si,di
mov di,offset data
add di,taille
mov cx,3
rep movsb
mov ax,di
pop di
mov cx,3
mov si,offset signe
rep movsb
mov di,ax
mov cx,taille
mov si,offset data
mov dx,1
boucle:
lodsb
cmp al,[si]
jne pas
inc dl
loop boucle
jmp fin
pas:
cmp dl,min
jb suite
cmp dl,1
jne go
suite:
mov bx,cx
mov cx,dx
rep stosb
mov cx,bx
mov dl,1
loop boucle
jmp fin
go:
mov ah,al
mov al,p1
stosb
mov al,dl
stosb
mov al,ah
stosb
mov al,p2
stosb
mov dl,1
loop boucle
fin:
mov ah,3ch
mov cx,0
mov dx,offset signe2
int 21h
mov bx,ax
mov ah,40h
mov cx,di
sub cx,offset data
sub cx,taille
mov dx,offset data
add dx,taille
int 21h
mov ah,3eh
int 21h
mov ah,41h
mov dx,82h
int 21h
ret
data db 0
net ends
end start
 
net