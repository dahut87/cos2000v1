model tiny,stdcall
p586
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"

org 0h

header exe <"CE",1,0,0,offset exports,,,>

exporting
declare random
declare randomize
ende

randseed        dw 1234h 

PROC random FAR
    USES    dx
    mov     ax,[cs:randseed]
    mov     dx,8405h
    mul     dx
    inc     ax
    mov     [cs:randseed],ax
    mov     ax,dx
    ret
endp random

PROC randomize FAR
    USES    ax,cx,dx
    mov     ah,0
    int     1ah
    mov     [cs:randseed],dx
    ret
endp randomize
