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
    call    [savestate]
    call    [print],offset msg
    mov     bp,1000h
    xor     di,di
    xor     cx,cx
    xor     edx,edx
verifall:
    mov     ah,1
    int     16h
    jz      nokey
    cmp     al,' '
    je      enend
nokey:
    mov     dx,di
    push    edx
    mov     dx,cx
    inc     dx
    push    edx
    mov     ax,cx
    inc     ax
    mov     si,100
    mul     si
    mov     si,2880
    div     si
    mov     dx,ax
    push    edx 
    call    [print],offset msg2
    call    gauge
    call    [verifysector],cx
    jc      errors
    je      noprob
    inc     di
noprob:
    inc     cx
    cmp     cx,2880
    jnz     verifall
enend:
    cmp     di,0
    je      noatall
    call    [print],offset error2
    jmp     someof
noatall:
    call    [print],offset noerror
someof:
    mov     ah,0
    int     16h
    call    [restorestate]
    retf
errors:
    call    [print],offset error
    mov     ah,0
    int     16h
    call    [restorestate]
    retf

error db '\g10,10Erreur avec le lecteur de disquette !',0
error2 db '\g10,10Le disque est defectueux, appuyez sur une touche pour quitter',0
noerror db '\g10,10Pas de secteurs defectueux, appuyez sur une touche pour continuer',0
msg db '\m02\e\c07\g29,00- Test de surface du disque -\g02,49<Pressez espace pour quitter>',0
msg2 db '\g10,20%u %%\g10,16%u cluster testes.    \h34%u cluster defectueux.    ',0

gauge:
    push    ax dx
    mov     ax,cx
    mul     [sizeof]
    div     [max]
    xor     edx,edx
    mov     dx,[sizeof]
    sub     dx,ax
    push    dx
    push    'Û'
    mov     dx,ax
    push    dx
    push    'Û'
    push    offset gauges
    call    [print]
    pop     dx ax
    retn

max      dw 2879
sizeof   dw 50

gauges db '\g10,18\c05%cM\c07%cM',0

importing
use VIDEO.LIB,print
use VIDEO,savestate
use VIDEO,restorestate
use DISQUE,verifysector
endi
