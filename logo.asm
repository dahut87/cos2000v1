.model tiny
.386c
.code
org 0100h
             
                
start:
mov si,offset logo
mov ah,4
xor di,di
mov bx,6000h
mov es,bx
int 48h
push es
pop ds
mov bx,5000h
mov es,bx
xor si,si
xor di,di
xor bx,bx
call DecompressRle
push es
pop ds
call loadbmp
xor ax,ax
xor bx,bx
call showbmp
mov ax,0
int 16h
db 0CBH

loadbmp:
push ax bx cx dx bp ds
mov ax,6
int 47h      
mov ax,ds:[18]
mov si,ax
shr ax,2
and si,11b
cmp si,0
je is4x
add ax,1
is4x:
mov cs:sizeh,ax
mov ax,ds:[22]
mov cs:sizev,ax
mov di,0FFFFh-1024
mov si,54
mov cl, 0ffh
paletteload:
lodsb
shr al, 2
mov [di+2], al
lodsb
shr al, 2
mov [di+1], al
lodsb
shr al, 2
mov [di+0], al
inc si
add di, 3
dec cl
jnz paletteload
mov si,0FFFFh-1024
mov dx, 3c8h
cld
mov cl, 0ffh
xor bx, bx
palettemake:
mov al, bl
out dx, al
inc dx
lodsb
out dx, al
lodsb
out dx, al
lodsb
out dx, al
dec dx
inc bl
dec cl
jnz palettemake
pop ds bp dx cx bx ax  
ret
sizeh dw 0
sizev dw 0

showbmp:
push ax bx cx dx si di ds es
mov cx,cs:sizeh
mov dx,cs:sizev
add bx,dx
mov di,ax
mov ax,bx
shl ax,6
shl bx,8
add di,bx
add di,ax
mov bx,di
mov ax,0A000H
mov es,ax
mov si,1024+54
mov ax,cx
bouclebmp:
cmp di,64000
jae nopp
cld
rep movsd
no:
mov cx,ax
sub bx,320
mov di,bx
dec dx
jnz bouclebmp
fin:
pop es ds di si dx cx bx ax 
ret
nopp:
shl cx,2
add si,cx
jmp no
                    
DecompressRle:
push cx dx si di
mov dx,cx
mov bp,di
decompression:
mov eax,[si]
cmp al,'/'
jne nocomp
cmp si,07FFFh-6
jae thenen
mov ecx,eax
ror ecx,16
cmp cl,'*'
jne nocomp
cmp byte ptr [si+4],'/'
jne nocomp
mov al,ch
mov cl,ah
xor ah,ah
xor ch,ch
rep stosb
add si,5
sub dx,5
jnz decompression
jmp thenen
nocomp:
mov es:[di],al
inc si
inc di
dec dx
jnz decompression
thenen:
mov ax,dx
sub bp,di
neg bp
pop di si dx cx
ret

logo db 'cos.rip',0
end start
