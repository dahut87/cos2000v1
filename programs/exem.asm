use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

header exe 1,0,imports,0,realstart

realstart:
    invoke    print,message
    invoke    waitkey
    retf

message db 'Appel de la librairie \c02video\c07 et de la librairie \c02EXEM-LIB.LIB\c07 !',0

importing
use VIDEO.LIB,print
use LIB.LIB,waitkey
endi
