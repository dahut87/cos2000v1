use16
align 1

include "..\include\mem.h"

org 0h

header exe 1,exports,0,0,0

exporting
declare random
declare randomize
ende

randseed        dw 1234h 

proc random uses dx
    mov     ax,[cs:randseed]
    mov     dx,8405h
    mul     dx
    inc     ax
    mov     [cs:randseed],ax
    mov     ax,dx
    retf
endp

proc randomize uses ax cx dx
    mov     ah,0
    int     1ah
    mov     [cs:randseed],dx
    retf
endp
