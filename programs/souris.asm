include "..\include\mem.h"
include "..\include\divers.h"

org 0h

start:
header exe 1

realstart:  
    invoke    mouseon
    jc      errormouse
    invoke    print, message
    retf

errormouse:
    invoke    print, errormessage
    retf

message db 'Activation de la souris\l',0
errormessage db 'impossible d''activer la souris\l',0

importing
use VIDEO.LIB,print
use MOUSE.SYS,mouseon
endi
