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
    call    [cs:randomize]
    push    0FFFFh
    pushd    652201
    pushd    1545454545
    push    1523
    push    2041
    push    offset zero
    push    offset fixe
    push    5
    push    'i'
    push    'a'
    pushd    5041
    pushd    125645
    pushd    5041
    pushd    125645
    pushd    5041
    pushd    125645
    push    offset message
    call    [print]
    xor     ax,ax
    int     16h
    call    [clearscreen]
    call    [xchgpages]
    call    [clearscreen]
    mov     cx,200
go1:
    call    [xchgpages]
    call    [waitretrace]
    call    [print],offset textdemo1
    call    put
    call    [xchgpages]
    call    [waitretrace]
    dec     cx
    jnz     go1
    mov     cx,200
go2:
    call    [xchgpages]
    call    [waitretrace]
    call    [print],offset textdemo2
    call    put
    call    [xchgpages]
    call    [waitretrace]
    dec     cx
    jnz     go2
    mov     cx,200
go3:
    call    [xchgpages]
    call    [waitretrace]  
    call    [print],offset textdemo3
    call    put
    call    [xchgpages]
    call    [waitretrace]
    dec     cx
    jnz     go3
    call    [clearscreen] 
    call    [xchgpages]
    call    [clearscreen] 
    call    [print],offset texte2
    mov     bp,255
    xor     edx,edx
go4:
    call    [xchgpages]
    call    [waitretrace]
    inc     edx
    push    edx
    push    offset texte3
    call    [print]
    call    [xchgpages]
    call    [waitretrace]
    dec     bp
    jnz     go4
    push    offset texte4
    call    [print]
    mov     ax,0
    int     16h
    call    [restorestate]
    retf
put:
    call    [cs:random]
    mov     di,ax
    and     di,4096-2
    mov     si,offset fond
    call    showstring2
    ret

		  
zero db 'Chaine a z‚ro terminal',0
fixe db 20,'Chaine a taille fixe'
message db "\s\m01\e\c07\h01D‚monstration de la librairie VIDEO.LIB\l\l"
        db "\c01Nombres entiers ou sign‚s (%%u/%%i):\l%u\l%iD\l"
        db "\c02Nombre hexad‚cimaux (%%h):\l%hD\l%hW\l"
        db "\c03Nombres Binaires (%%b):\l%bD\l%bB\l"
        db "\c04Caracteres simples ou multiples (%%c/%%cM):\l%c\l%cM\l"
        db "\c05Chaines a z‚ro terminal ou fixes (%%0/%%s):\l%s\l%0\l"
        db "\c06Dates et heures (%%t/%%d):\l%t\l%d\l"
        db "\c07Nombre a echelle automatique (%%z):\l%z\l%z\l"
        db "\c08Attributs de fichiers (%%a):\l%a",0

fond       db 16,'Ceci est un fond'
textdemo1  db '\c05Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling Scrolling\l',0
textdemo2  db '\c07Vertical Vertical Vertical Vertical Vertical Vertical Vertical Vertical\l',0
textdemo3  db '\c09Rapide Rapide Rapide Rapide Rapide Rapide Rapide Rapide\l',0
texte1     db 'Echange rapide de pages Vid‚o',0
texte2     db '\g04,13Routine d''affichage Ultra Rapide Agissant sur le Mat‚riel'
           db '\g04,14Possibilit‚ de r‚aliser des effets de superposition',0
texte3     db '\c04%bD\l',0
texte4     db '\g01,00Sauvegarde et restauration de l''ecran (\\s/\\r)',0

showstring2:
    push    es bx cx si di
    add     di,4000
    mov     bx,0B800h
    mov     es,bx
    mov     bl,[si]
    mov     ch,3
strinaize4:
    inc     si
    mov     cl,[si]
    mov     [es:di],cx
    add     di,2
    dec     bl
    jnz     strinaize4
    pop     di si cx bx es
    ret


importing
use MATH.LIB,randomize
use MATH.LIB,random
use VIDEO.LIB,print
use VIDEO,xchgpages
use VIDEO,setvideomode
use VIDEO,clearscreen
use VIDEO,savestate
use VIDEO,restorestate
use VIDEO,waitretrace
endi
