.model tiny
.486
smart
.code

org 0h

start:

jmp tsr
offsets dd 0
db 'KEYBOARD'
tsr:
 pushf
 db  2eh,0ffh,1eh
 dw  offsets
        cli
        add dword ptr cs:popes,1
        cmp cs:isstate,1
        je endofforce
        mov cs:isstate,1
        mov cs:eaxr,eax
        in al,60h
        cmp al,68
        je F10
        cmp al,87
        je F11
        cmp al,88
        je F12
endof:
        mov cs:isstate,0
        mov eax,cs:eaxr
endofforce:
        sti
        iret
        isstate db 0
        infos db 40 dup (0)
        feax dd 0

F10:
        push    cs
        pop     ds
        mov     si,offset com
        mov     ah,5
        int     49h
        mov     cs:isstate,0
        push    gs
        push    0100h
        db      0CBh
        
com db 'COMMANDE.EXE',0

F11:
     push ax di es
     push cs
     pop es
     mov di,offset infos
     mov ah,34
     int 47h
     mov al,cs:[di+7]
     inc al
     cmp al,9
     jbe notabove
     mov al,0
notabove:
     mov ah,0
     int 47h
     pop es di ax
     jmp endof


f12:

showreg:
pushf
pushad
mov  bp,sp
mov ax,ss:[bp+28h]
mov cs:[csr],ax
mov ax,ss:[bp+26h]
mov cs:[ipr],ax
mov ax,ss:[bp+2Ah]
mov cs:[flr],ax
mov cs:[ebxr],ebx
mov cs:[ecxr],ecx
mov cs:[edxr],edx
mov cs:[esir],esi
mov cs:[edir],edi
mov cs:[espr],esp
mov cs:[ebpr],ebp
mov cs:[dsr],ds
mov cs:[esr],es
mov cs:[fsr],fs
mov cs:[gsr],gs
mov cs:[ssr],ss
push ds
pop fs
push cs
pop ds
mov ah,28h
int 47h
mov ax,0002
int 47H
mov ah,2
int 47h
mov si,offset etat
mov ah,13
int 47h
mov ah,6
int 47h
mov ah,6
int 47h
mov si,offset reg
mov di,offset regdata
mov bx,7
showregs:
cmp byte ptr cs:[si+4],":"
jne endshowregs
mov ah,13
int 47h
cmp byte ptr cs:[si+3],"g"
je segsss
cmp byte ptr cs:[si+2]," "
je segsss
mov edx,cs:[di]
mov cx,32
mov ah,0Ah
int 47h
add di,4
jmp showmax
segsss:
xor edx,edx
mov dx,cs:[di]
mov cx,16
mov ah,0Ah
int 47h
push si
mov ah,13
mov si,offset blank
int 47h
pop si
add di,2
showmax:
add si,7
mov ebp,edx
push si
mov si,offset beginds
mov ah,13
int 47h
pop si
mov cx,8
mov al,0
mov bx,bp
letshow:
mov dl,fs:[bx]
inc bx
mov ah,0Ah
int 47h
inc al
cmp al,10
jb letshow
push si
mov si,offset ende
mov ah,13
int 47h
mov si,offset begines
mov ah,13
int 47h
pop si
mov bx,bp
mov cx,8
mov al,0
letshow2:
mov dl,es:[bx]
inc bx
mov ah,0Ah
int 47h
inc al
cmp al,10
jb letshow2
push si
mov si,offset ende
mov ah,13
int 47h
mov si,offset beginint
mov ah,13
int 47h
pop si
mov edx,ebp
mov ah,8
int 47h
push si
mov si,offset endint
mov ah,13
int 47h
pop si
mov ah,6
int 47h
jmp showregs
endshowregs:
mov ah,6
int 47h
mov si,offset pile
mov ah,13
int 47h
mov ah,6
int 47h
mov bp,sp
mov di,0ffffh
sub di,bp
xor si,si
showstack:
mov dl,'+'
mov ah,07h
int 47h
mov ah,0Ah
mov cx,8
mov dx,si
int 47h
mov dl,':'
mov ah,07h
int 47h
mov dx,ss:[bp+si]
mov ah,0Ah
mov cx,16
int 47h
mov ah,06
int 47h
inc si
inc si
cmp si,di
jb showstack

mov ah,0ah
mov edx,cs:popes
mov cx,32
int 47h






xor ax,ax
int 16h
mov ah,29h
int 47h
popad
popf
jmp endof

popes dd 0

regdata:
eaxr dd 0
ebxr dd 0
ecxr dd 0
edxr dd 0
esir dd 0
edir dd 0
espr dd 0
ebpr dd 0
ipr  dw 0
csr dw 0
dsr dw 0
esr dw 0
fsr dw 0
gsr dw 0
ssr dw 0
flr dw 0

etat db ' Etat des registres processeurs',0

reg db "eax : ",0
    db "ebx : ",0
    db "ecx : ",0
    db "edx : ",0
    db "esi : ",0
    db "edi : ",0
    db "esp : ",0
    db "ebp : ",0
    db "ip  : ",0
    db "cs  : ",0
    db "ds  : ",0
    db "es  : ",0
    db "fs  : ",0
    db "gs  : ",0
    db "ss  : ",0
    db "flag: ",0
    
pile db 'Stack :',0

blank db '    ',0
beginint db ' (',0
endint db ') ',0
begines db ' es[',0
beginds db ' ds[',0
ende db '] ',0
end start
