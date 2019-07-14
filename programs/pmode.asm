use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

header exe 1,0,0,0,realstart

realstart:
    mov     eax,cr0
    or      al,1
    mov     cr0,eax
    retf


