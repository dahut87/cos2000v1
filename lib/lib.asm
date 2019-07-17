use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

header exe 1,exports,0,0,0

waitkey:
    mov     ax,0
    int     16h
    ret

exporting
declare waitkey
ende
