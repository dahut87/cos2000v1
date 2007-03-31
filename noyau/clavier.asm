.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h

start:

jmp tsr
offsets dd 0
db 'KEYBOARD'
tsr:
 pushf
 db  2eh,0ffh,1eh
 dw  offsets
        cli
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
        pop     ax
        pop     ax
        pop     ax
        push    gs
        push    gs
        push    gs
        pop     ds
        pop     es
        pop     fs
        push    gs
        push    size exe
        sti
        mov     cs:[isstate],0
        retf
        
com db 'COMMANDE.CE',0

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
pushad
pushf
push ds
mov cs:[eaxr],eax
mov cs:[ebxr],ebx
mov cs:[ecxr],ecx
mov cs:[edxr],edx
mov cs:[esir],esi
mov cs:[edir],edi
mov cs:[espr],esp
mov cs:[ebpr],ebp
mov cs:[csr],cs
mov cs:[dsr],ds
mov cs:[esr],es
mov cs:[fsr],fs
mov cs:[gsr],gs
mov cs:[ssr],ss
push cs
pop ds
mov si,offset sep
call Showstr
mov si,offset reg
mov di,offset regdata
mov bx,7
showregs:
cmp byte ptr cs:[si+6],":"
jne endshowregs
call Showstr
cmp byte ptr cs:[si+4]," "
je segsss
mov edx,cs:[di]
mov cx,32
call Showhex
add di,4
jmp showmax
segsss:
mov dx,cs:[di]
mov cx,16
call Showhex
add di,2
showmax:
add si,9
mov bp,dx
push si
mov si,offset beginds
call showstr
mov si,bp
mov cx,8
mov al,0
letshow:
mov dl,ds:[si]
inc si
call showhex
inc al
cmp al,10
jb letshow
mov si,offset ende
call showstr
mov si,offset begines
call showstr
mov si,bp
mov cx,8
mov al,0
letshow2:
mov dl,es:[si]
inc si
call showhex
inc al
cmp al,10
jb letshow2
mov si,offset ende
call showstr
pop si
jmp showregs
endshowregs:
mov si,offset sep
call Showstr
xor ax,ax
int 16h
pop ds
popf
popad
jmp endof
begines db ' es[',0
beginds db ' ds[',0
ende db '] ',0


;==============================Affiche le nombre nb hexa en EDX de taille CX et couleur BL==============
ShowHex:
        push    ax bx cx edx si di
        mov     di,cx
        sub     cx,32
        neg     cx
        shl     edx,cl
        shr     di,2
        mov 	ah,09h
        and 	bx,1111b
Hexaize:
        rol     edx,4
        mov     si,dx
	and	si,1111b
	mov	al,[si+offset tab]
	push    cx
	mov     cx,1
        cmp     al,32
        jb       control2
        mov         ah,09h
        int       10h
control2:
        mov    ah,0Eh
        int    10h
        pop     cx
        dec     di
        jnz     Hexaize
        pop     di si edx cx bx ax
        ret
Tab db '0123456789ABCDEF'

;==============================Affiche une chaine DS:SI de couleur BL==============
showstr:
        push ax bx cx si
        mov cx,1
again:
        lodsb
        or al,al
        jz fin
        and bx,0111b
        cmp al,32
        jb  control
        mov ah,09h
        int 10h
control:
        mov ah,0Eh
        int 10h
        jmp again
        fin:
        pop si cx bx ax
        ret


;================================================
;Routine de débogage
;================================================
regdata:
eaxr dd 0
ebxr dd 0
ecxr dd 0
edxr dd 0
esir dd 0
edir dd 0
espr dd 0
ebpr dd 0
csr dw 0
dsr dw 0
esr dw 0
fsr dw 0
gsr dw 0
ssr dw 0

reg db 0Dh,0Ah,"eax : ",0
    db 0Dh,0Ah,"ebx : ",0
    db 0Dh,0Ah,"ecx : ",0
    db 0Dh,0Ah,"edx : ",0
    db 0Dh,0Ah,"esi : ",0
    db 0Dh,0Ah,"edi : ",0
    db 0Dh,0Ah,"esp : ",0
    db 0Dh,0Ah,"ebp : ",0
    db 0Dh,0Ah,"cs  : ",0
    db 0Dh,0Ah,"ds  : ",0
    db 0Dh,0Ah,"es  : ",0
    db 0Dh,0Ah,"fs  : ",0
    db 0Dh,0Ah,"gs  : ",0
    db 0Dh,0Ah,"ss  : ",0

sep db 0Ah,0Dh,'********************',0Ah,0Dh,0

end start
