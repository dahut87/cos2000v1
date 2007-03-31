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
    call    [cs:mballoc],65535
    jc      problem3
    push    ax
    pop     es
    call    [cs:projfile],offset logo
    jc      problem
    mov     ecx,eax
    call    [cs:mbfind],offset logo
    jc      problem
    call    [cs:decompressrle],ax,0,es,0,cx
    jc      problem2
    push    es
    pop     ds
    call    [cs:savestate]
    call    [cs:setvideomode],word 8
    call    [cs:clearscreen]
    call    [cs:loadbmppalet],word 0
    call    [cs:showbmp],word 0,word 20,word 150
    jc      problem4
    push    cs
    pop     ds
    call    [cs:print],offset poper
endofit:
    xor     ax,ax
    int     16h
    call    [cs:restorestate]
    retf

problem:
    push    cs
    pop     ds
    call    [cs:print],offset error
    jmp     endofit

problem2:
    push    cs
    pop     ds
    call    [cs:print],offset error2
    jmp     endofit

problem3:
    push    cs
    pop     ds
    call    [cs:print],offset error3
    jmp     endofit

problem4:
    push    cs
    pop     ds 
    call    [cs:print],offset error4
    jmp     endofit

poper db '\c0BC\c0CO\c0DS\c0E2\c0E0\c0E0\c0F0 en mode graphique',0
logo db 'COS.RIP',0
ok1 db 'Chargement de l''image OK',0
ok2 db 'Decompression de l''image OK',0
error3 db '\c04Une erreur est apparue lors de l''allocation de mémoire',0
error db '\c04Une erreur est apparue lors du chargement de l''image',0
error2 db '\c04Une erreur est apparue lors de la decompression de l''image',0
error4 db '\c0FUne erreur est apparue lors de l''affichage de l''image',0


importing
use VIDEO,restorestate
use VIDEO,savestate
use VIDEO,setvideomode
use VIDEO,clearscreen
use DISQUE,decompressrle
use DISQUE,projfile
use SYSTEME,mbfind
use SYSTEME,mballoc
use VIDEO.LIB,print
use BMP.LIB,showbmp
use BMP.LIB,loadbmppalet
endi
