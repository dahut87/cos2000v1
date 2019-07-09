include "..\include\mem.h"
include "..\include\divers.h"

org 0h

start:
header exe 1

waitkey:
    mov     ax,0
    int     16h
    retf

exporting
declare waitkey
ende
