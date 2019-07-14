use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

header exe 1,0,imports,0,realstart

realstart: 
    invoke    mballoc,65535
    jc      problem3
    push    ax
    pop     es
    invoke    projfile,logo
    jc      problem
    mov     ecx,eax
    invoke    mbfind,logo
    jc      problem
    invoke    decompressrle,ax,0,es,0,cx
    jc      problem2
    push    es
    pop     ds
    invoke    savestate
    invoke    setvideomode,word 8
    invoke    clearscreen
    invoke    loadbmppalet,word 0
    invoke    showbmp,word 0,word 20,word 150
    jc      problem4
    push    cs
    pop     ds
    invoke    print,poper
endofit:
    xor     ax,ax
    int     16h
    invoke    restorestate
    retf

problem:
    push    cs
    pop     ds
    invoke    print, error
    jmp     endofit

problem2:
    push    cs
    pop     ds
    invoke    print, error2
    jmp     endofit

problem3:
    push    cs
    pop     ds
    invoke    print, error3
    jmp     endofit

problem4:
    push    cs
    pop     ds 
    invoke    print, error4
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
