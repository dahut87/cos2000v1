model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

start:
header exe <"CE",1,0,0,offset exports,,,>

waitkey:
    mov     ax,0
    int     16h
    retf

exporting

declare waitkey
ende
