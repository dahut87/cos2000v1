model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\divers.h"

org 100h
xor eax,eax

call biosprint,offset test1
call biosprint,offset retr


call biosprint,offset test2
call biosprint,offset retr

;call whatisitem0,offset test2,0,','
;call biosprinth,eax


call checksyntax0,offset test1,offset test2,','
jc  suite
call biosprint,offset test3
suite:


ret
test1 db "c'est un test,2Ah,1d,10111b,test.bin",0
test2 db "?,FFh,65536d,101b,&",0
test3 db "egale                                                      "
retr db 0xA,0xD,0

;Affiche le nombre hexa dans %0[dword]
PROC biosprinth FAR
        ARG     @num:dword
        USES    ax,bx,cx,edx,si,di
        mov     edx,[@num]
        mov 	ah,09h
        mov     di,8
@@hexaize:
        rol     edx,4
        mov     si,dx
	and	si,1111b
	mov	al,[cs:si+offset @@tab]
	mov     cx,1
        cmp     al,32
        jb      @@control
        mov     bx,7
        mov     ah,09h
        int     10h
@@control:
        mov     ah,0Eh
        int     10h
        dec     di
        jnz     @@hexaize
        ret
@@tab db '0123456789ABCDEF'
endp biosprinth


;Affiche le texte ASCIIZ pointé par %0
PROC biosprint FAR
        ARG    @pointer:word
        USES   ax,bx,cx,si
        mov    si,[@pointer]
        mov    cx,1
        mov    bx,7
@@again:
        lodsb
        or     al,al
        jz     @@fin
        cmp    al,32
        jb     @@control
        mov    ah,09h
        int    10h
@@control:
        mov    ah,0Eh
        int    10h
        jmp    @@again
@@fin:
        ret
endp biosprint
