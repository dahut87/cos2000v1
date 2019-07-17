use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

header exe 1,0,imports,0,realstart

realstart:  
    invoke    mouseon
    jc      errormouse
    invoke    print, message
    ret

errormouse:
    invoke    print, errormessage
    ret

message db 'Activation de la souris\l',0
errormessage db 'impossible d''activer la souris\l',0

importing
use VIDEO.LIB,print
use MOUSE.SYS,mouseon
endi
