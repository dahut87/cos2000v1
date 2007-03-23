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
header exe <"CE",1,0,0,,,,offset realstart>

realstart:
    mov     eax,cr0
    or      al,1
    mov     cr0,eax
    retf


