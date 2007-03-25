model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\fat.h"
include "..\include\divers.h"
include "..\include\graphic.h"

org 0h

start:
header exe <"CE",1,0,0,,offset imports,,offset realstart>

realstart:  
    call    [saveparamto],offset infos
    call    [print],offset msg1
    call    [initdrive]
    xor     bp,bp
    call    [findfirstfile],offset bufferentry 
    jc      nofiles
go:
        push    [word bufferentry.result.fileattr]
        push    [bufferentry.result.filesize]
        push    [bufferentry.result.filetime]
        push    [bufferentry.result.filedate]
        push    [bufferentry.result.filetimecrea]
        push    [bufferentry.result.filedatecrea]
        mov     bx,offset bufferentry.result.filename
        push    bx
        push    offset line
    call    [print]
 
    call    [findnextfile],offset bufferentry 
    jc      nofiles
    inc     bp
    jmp     go
nofiles:
    call    [print],offset menu
    mov     [xx],1
    call    changelineattr,[xx],112
endof:
    mov     ax,0
    int     16h
    cmp     ah,50h
    jne     tre1
    cmp     [xx],bp
    ja      endof
    call    changelineattr,[xx],7
    inc     [xx]
    call    changelineattr,[xx],112
    jmp     endof
tre1:
    cmp     ah,48h
    jne     tre2
    cmp     [xx],1
    je      endof
    call    changelineattr,[xx],7
    dec     [xx]
    call    changelineattr,[xx],112
    jmp     endof
tre2:
    cmp     al,0Dh
    jne     tre3 
tre3:
    cmp     ah,59
    jne     tre4
    jmp     realstart
tre4:
    cmp     ah,67
    jne     endof
    retf

;couleur al pour ligne %0 en %1
PROC changelineattr near
USES ax,bx,di,es
ARG  @line:word,@attr:word
mov ax,0B800h
mov es,ax
mov ax,[@line]
add ax,3
mul [cs:infos.columns]
mov di,ax
shl di,1
mov al,[cs:infos.columns]
inc di
mov bx,[@attr]
@@popep:
mov [es:di],bl
add di,2
dec al
jnz @@popep
ret   
endp changelineattr

xx dw 1
xxold dw 0
menu db '\c70 [F1] Lire disque [F9] Quitter                                                  \c07',0
msg1 db '\e\g00,00\c70                       Gestionnaire de fichier Version 1.5                      '
     db '\g00,01\c07--------------------------------------------------------------------------------'
     db '\g00,02Nom      Ext.  Date creation           Date modification      Taille   Attributs'
     db '\g00,03-------------------------------------------------------------------------------\l',0
line db '\c07%n   %d   %t   %d   %t   %z   %a\l',0
bufferentry find <>
infos vgainf <>

importing
use VIDEO.LIB,print
use VIDEO,saveparamto
use DISQUE,initdrive
use DISQUE,findfirstfile
use DISQUE,findnextfile
endi

