.model tiny
.486
smart
.code

org 0100h

start:
mov ah,2
int 47h
mov ah,6
int 47h
mov ah,6
int 47h
mov ah,13
mov si,offset msg
int 47h
replay:
mov ah,6
int 47h   
mov ah,6
int 47h
mov ah,13
mov si,offset prompt
int 47h
mov di,offset buffer
waitchar:
mov ax,0
int 16h
mov dl,al
mov [di],al
cmp al,0Dh
je entere
inc di
mov ah,7
int 47h
jmp waitchar
entere:
mov ah,6
int 47h
mov ah,6
int 47h  
mov byte ptr [di],0
mov si,offset buffer
call uppercasestr0
mov bx,offset commands
tre:
mov di,[bx]
add bx,4
cmp di,0
je error
push cs
pop es   
call cmpstr0
jne tre
mov bx,[bx-2]
call bx
jmp replay
error:
push cs
pop es   
mov dl,'.'
call searchcharstr0
je noaddext
mov di,offset buffer
mov si,offset extcom
call concatstr0
noaddext:
mov si,offset buffer
push cs
mov ax,offset arrive
push ax
mov di,offset vga
mov ah,40
int 47h
mov ax,6000h
mov es,ax
push ax
mov di,0100h
push di
mov ah,4
int 48h
jc reallyerror
     push es
     push es
     push es
     pop ds
     pop fs
     pop gs
     push 7202h
     popf 
db 0CBh
arrive:
push cs
push cs
push cs
push cs
pop ds
pop es
pop fs
pop gs
mov si,offset vga
mov ah,41
int 47h
jmp replay
reallyerror:
pop ax
pop ax
pop ax
pop ax
mov ah,13
mov si,offset Error_Syntax
int 47h
jmp replay

;met en majuscule la string ds:si
uppercasestr0: 
push si ax
uppercaser:
mov al,ds:[si]
inc si
cmp al,0
je enduppercase
cmp al,'a'
jb uppercaser
cmp al,'z'
ja uppercaser
sub byte ptr [si-1],'a'-'A'
jmp uppercaser
enduppercase:
clc
pop ax si
ret

;Cherche dl dans la str ds:si -> di
SearchCharStr0:
push ax cx si di es
mov di,si
push ds
pop es
mov cx,0FFh
mov al,0
cld
repne scasb
neg cx
dec cx
xor ch,ch
mov di,si
mov al,dl
repne scasb
pop es di si cx ax
ret

;concatŠne la chaine str ds:si avec es:di
concatstr0:
push ax cx dx si di
push es di
mov di,si
push ds
pop es
mov al,0  
mov cx,255
cld      
repne scasb
neg cx
dec cx
xor ch,ch
mov dx,cx
pop di es
mov cx,0FFh
repne scasb
dec di
mov cx,dx
rep movsb
pop di si dx cx ax
ret    

;compare la chaine es:di avec ds:si
cmpstr0:
push cx dx si di 
push di
mov al,0
mov cx,255
cld
repne scasb
neg cx
mov dx,cx
pop di
push es di
mov di,si
push ds
pop es
mov cx,255
repne scasb
neg cx
cmp dx,cx
pop di es
jne notequal
dec cx
xor ch,ch
rep cmpsb
notequal:
pop di si dx cx
ret

Code_Exit:
pop ax
db 0CBh

Code_Version:
mov ah,13
mov si,offset Version_Text
int 47h
ret

Version_Text db 'Cos 2000 version 1.1.1B by Nico',0
extcom db '.EXE',0

commands dw Str_Exit   ,Code_Exit
         dw Str_Version,Code_Version
         dw 0


Str_Exit     db 'EXIT',0
Str_Version  db 'VERSION',0

Error_Syntax db 'The command doesn''t exit !',0
prompt db 'COS>',0
msg db 'Cos command interpretor V1.0',0
buffer db 255 dup (0)

vga db 0
end start
