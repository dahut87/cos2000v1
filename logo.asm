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
mov ah,6
int 48h
push es
pop ds
mov ax,0006h
int 47h
mov ah,38
int 47h
mov ah,35
int 47h
mov ah,37
int 47h   
xor cx,cx
xor bx,bx
mov ah,36
int 47h
mov ax,0
int 16h
mov ah,39
int 47h    
mov ax,0004
int 47h                      
db 0CBH                                          
logo db 'cos.rip',0
end start
