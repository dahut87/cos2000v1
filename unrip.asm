net segment

org 0100h
assume cs:net,ds:net

start:
jmp deb
taille dw 0
signe2 db 64 dup (0)
p1 db '@'
p2 db '@'
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
mov si,offset data
mov cx,3
rep movsb
mov cx,taille
mov di,offset data
add di,taille
mov dx,1
boucle:
lodsb
cmp al,p1
je pas
suite:
stosb
loop boucle
jmp fin
pas:
mov al,p2
cmp [si+2],al
jne suite
lodsb
mov bx,cx
mov cl,al
xor ch,ch
lodsb
rep stosb
mov cx,bx
sub cx,3
inc si
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