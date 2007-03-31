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
    call    [mouseon]
    jc      errormouse
    call    [print],offset message
    retf

errormouse:
    call    [print],offset errormessage
    retf

message db 'Activation de la souris\l',0
errormessage db 'impossible d''activer la souris\l',0

importing
use VIDEO.LIB,print
use MOUSE.SYS,mouseon
endi
