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
noret:
mov ah,6
int 47h    
mov ah,13
mov si,offset prompt
int 47h
mov di,offset buffer
waitchar:
mov ax,0
int 16h
cmp al,0Dh
je entere
cmp di,offset buffer+256
je waitchar
mov [di],al
inc di
mov dl,al  
mov ah,7
int 47h
jmp waitchar
entere:
mov byte ptr [di],0
mov si,offset buffer
cmp si,di
je noret
mov ah,6
int 47h     
call uppercase0
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
call searchchar0
je noaddext
mov di,offset buffer
mov si,offset extcom
call concat0
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

Code_Exit:
pop ax
db 0CBh

Code_Version:
mov ah,13
mov si,offset Version_Text
int 47h
ret

Version_Text db 'Cos 2000 version 1.1.1B by Nico',0

Code_Cls:
mov ah,2
int 47h
ret

Code_Reboot:
push 0FFFFh
push 00000h
db 0CBH

Code_Command:
mov bx,offset commands
showalls:
mov si,[bx]
add bx,4
cmp si,0
je endoff
mov ah,13
int 47h
mov ah,6
int 47h
jmp showalls
endoff:
ret

extcom db '.EXE',0

commands dw Str_Exit   ,Code_Exit   
         dw Str_Version,Code_Version
         dw Str_Cls    ,Code_Cls    
         dw Str_Reboot ,Code_Reboot 
         dw Str_Command,Code_Command
         dw 0


Str_Exit     db 'EXIT',0
Str_Version  db 'VERSION',0
Str_Cls      db 'CLS',0
Str_Reboot   db 'REBOOT',0
Str_Command  db 'COMMAND',0
                         
Error_Syntax db 'Command or executable doesn''t exist !',0
prompt db 'COS>',0
msg db 'Cos command interpretor V1.0',0
buffer db 255 dup (0)

;Recherche un caractäre dl dans la chaåne ds:si
SearchChar0:
        push    ax cx di es
        call    GetLength0
        push    ds
        pop     es
        mov     di,si
        mov     al,dl
        repne   scasb
        pop     es di cx ax
        ret

;Compares 2 chaines de caractäres DS:SI et ES:DI zerof si non equal
cmpstr0:
        push    cx dx si di
        call    GetLength0
        mov     dx,cx
        push    ds si
        push    es
        pop     ds
        mov     si,di
        call    GetLength0       
        pop     si ds
        cmp     cx,dx
        jne     NotEqual
        repe    cmpsb
NotEqual:
        pop     di si dx cx
        ret

;met en majuscule la chaine ds:si
UpperCase0: 
        push    si ax
UpperCase:
        mov     al,ds:[si]
        inc     si
        cmp     al,0
        je      EndUpperCase
        cmp     al,'a'
        jb      UpperCase
        cmp     al,'z'
        ja      UpperCase
        sub     byte ptr [si-1],'a'-'A'
        jmp     UpperCase
EndUpperCase:
        clc
        pop ax si
        ret

;Concatäne le chaine ds:si avec es:di
Concat0:
        push    ax cx dx si di
        call    GetLength0
        mov     dx,cx
        xchg    si,di
        push    ds
        push    es
        pop     ds
        call    GetLength0
        pop     ds
        xchg    si,di
        add     di,cx
        mov     cx,dx
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si dx cx ax
        ret

;renvoie la taille en octets CX de la chaine pointÇe en ds:si
GetLength0:
        push    ax di es
        push    ds
        pop     es
        mov     di,si
        mov     al,0
        mov     cx,0FFFFh
        cld
        repne   scasb
        neg     cx
        dec     cx
        dec     cx
        pop     es di ax
        ret


vga db 0
end start
