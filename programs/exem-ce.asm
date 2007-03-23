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
header exe <"CE",1,0,0,,offset imports,,offset realstart>

realstart:
    call    [print],offset message
    call    [waitkey]
    retf

message db 'Appel de la librairie \c02video\c07 et de la librairie \c02EXEM-LIB.LIB\c07 !',0

importing
use VIDEO.LIB,print
use EXEM-LIB.LIB,waitkey
endi
