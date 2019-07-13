use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

start:
header exe 1

realstart:
    mov     eax,cr0
    or      al,1
    mov     cr0,eax
    retf


