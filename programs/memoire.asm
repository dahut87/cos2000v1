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
        call    [cs:print],offset msg
        xor     ebx,ebx
        xor     cx,cx
listmcb:
        call    [cs:mbget],cx
        jc      fino
        dec     ax
        dec     ax
        mov     gs,ax
        inc     cx
        mov     dx,gs
        push    edx          ;Emplacement memoire hex 2
;parent
        cmp     [gs:mb.reference],0
        jne     next
        push    cs
        push    offset none        ;parent lstr0 2x2 
        add     bx,[gs:mb.sizes]
        jmp     suitemn
next:
        mov     dx,[gs:mb.reference]
        dec     dx
        dec     dx
        push    dx                    ;parent lstr0 2x2 
        push    offset (mb).names
suitemn:
        cmp     [gs: mb.isresident],true
        jne     notresident
        push    offset resident        ;resident str0 2 
        jmp     suitelistmcb
notresident:
        push    offset nonresident     ;resident str0 2
suitelistmcb:
        xor     edx,edx
        mov     dx,[gs: mb.sizes]
        shl     edx,4
        push    6                    ;decimal 4 + type 2
        push    edx
        push    gs                   ;nom lstr0 2x2 
        push    offset (mb).names
        push    offset line2         ;ligne
        call    [cs:print]
        jmp     listmcb
fino:
        shl     ebx,4
        push    ebx
        push    offset fin
        call    [cs:print]
        retf
resident db     "oui",0
nonresident db  "non",0
line2   db      "%0P\h15|%w\h25|%0\h30|%0P\h46|%hW\l",0
fin     db      "\l\l\c02%u octets de memoire disponible\l\c07",0
msg     db      "Plan de la memoire\l\lNom            | Taille  |Res |Parent         |Mem\l",0
none    db      ".",0


importing
use VIDEO.LIB,print
use SYSTEME,mbget
endi
