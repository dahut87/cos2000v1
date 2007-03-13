model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\divers.h"
include "..\include\cpu.h"
include "..\include\pci.h"

org 0h

mb0:
header exe <"CE",1,0,0,offset exports,offset imports,offset section,offset start>

start:
        push    cs
        push    cs
        push    cs
        push    cs
        pop     ds
        pop     es
        pop     fs
        pop     gs
        call    biosprint,offset return
        call    biosprint,offset msg_memory
        call    biosprint,offset return
        call    biosprint,offset msg_memory_init
        call    mbinit
        jc      error
        call    biosprint,offset msg_ok
        call    biosprint,offset msg_memory_section
        mov     ax,cs
        dec     ax
        dec     ax
        call    mbloadsection,ax
        jc      error
        call    biosprint,offset msg_ok
        call    biosprint,offset msg_memory_jumps
        jmp     [dword ptr cs:pointer]
pointer:
        dw suite
        dw memorystart
suite:
        push    cs
        push    cs
        push    cs
        push    cs
        pop     ds
        pop     es
        pop     fs
        pop     gs
        call    biosprint,offset msg_ok
        call    biosprint,offset msg_video_init
        call    [setvideomode],2
        jc      error
        call    [clearscreen]
        call    [print],offset msg_memory
        call    [print],offset msg_ok2
        call    [print],offset msg_memory_init
        call    [print],offset msg_ok2
        call    [print],offset msg_memory_section
        call    [print],offset msg_ok2
        call    [print],offset msg_memory_jumps
        call    [print],offset msg_ok2
        call    [print],offset msg_video_init
        call    [print],offset msg_ok2
        call    [print],offset msg_cpu_detect
        call    [cpuinfo],offset thecpu
        call    [setinfo],offset thecpu,offset temp
        call    [print],offset msg_ok2
        push    offset temp
        xor     eax,eax
        mov     al,[thecpu.family]
        push    eax
        mov     al,[thecpu.models]
        push    eax
        mov     al,[thecpu.stepping]
        push    eax
        push    offset thecpu.names
        push    offset thecpu.vendor
        call    [print],offset msg_cpu_detect_inf
        call    [print],offset msg_pci
        call    [pciinfo],offset thepci
        jc      nopci
        call    [print],offset msg_ok2
        xor     eax,eax
        mov     al,[thepci.maxbus]
        push    eax
        mov     al,[thepci.version_minor]
        push    eax
        mov     al,[thepci.version_major]
        push    eax
        call    [print],offset msg_pci_info
        call    [print],offset msg_pci_enum
        xor     ebx,ebx
        xor     ecx,ecx
        xor     esi,esi
searchpci:
        call    [getcardinfo],bx,cx,si,offset temp
        jc      stopthis
        mov     al,[(pcidata offset temp).subclass]
        push    ax
        mov     al,[(pcidata offset temp).class]
        push    ax
        call    [getpcisubclass]
        push    dx
        push    ax
        mov     al,[(pcidata offset temp).class]
        xor     ah,ah
        push    ax
        call    [getpciclass]
        push    dx
        push    ax
        push    4
        push    esi
        push    4
        push    ecx
        push    4
        push    ebx
        mov     ax,[(pcidata offset temp).device]
        push    eax
        mov     ax,[(pcidata offset temp).vendor]
        push    eax
        call    [print],offset msg_pci_card
        inc     si
        cmp     si,7
        jbe     searchpci
stopthis:
        xor     si,si
        inc     cx
        cmp     cx,31
        jbe     searchpci
        xor     cx,cx
        inc     bx
        cmp     bx,16
        jbe     searchpci
        jmp     next
nopci:
        call    [print],offset msg_echec2
next:
        call    [print],offset msg_fini
;        call    [detectvmware]
;        jne     novirtual
;        call    [print],offset msg_vmware
;novirtual:

error2:
        call    [print],offset msg_error2
        call    bioswaitkey
        jmp     far 0FFFFh:0000h

error:
        call    biosprint,offset msg_error
        call    bioswaitkey
        jmp     far 0FFFFh:0000h
        

thepci pciinf <>
thecpu cpu <>
temp db 256 dup (0)
return             db 0dh,0ah,0
msg_memory         db "Initialisation de la memoire",0
msg_memory_init    db "  -Creation du bloc primordial",0
msg_memory_section db "  -Developpement des sections",0
msg_memory_jumps   db "  -Redirection du systeme",0
msg_video_init     db "Initialisation du pilote VIDEO",0
msg_cpu_detect     db "Dectection du processeur",0
msg_cpu_detect_inf db "  -Fondeur  : %0\l  -Modele   : %0\l  -Revision : %u\l  -Version  : %u\l  -Famille  : %u\l  -Technologies: %0\l",0
msg_pci            db "Detection des systemes PCI",0
msg_pci_info       db "  -Version  : %yB.%yB\l  -Nombre de bus : %u\l",0
msg_pci_enum       db "  -Enumeration des peripheriques PCI:\l"
                   db "   |Vendeur|Modele|Bus |Dev.|Func|Classe.Sous-classe\l",0
msg_pci_card       db "   | %hW  | %hW |%w|%w|%w|%0P.%0P\l",0
;msg_vmware         db "\c04 VMWare a été detecté !!!\c07",0
msg_fini           db "\c04Demarrage terminee : c pas encore fini :(:(:( mais c pour l'inspiration !",0

msg_error          db " [Erreur]",0dh,0ah,"<Pressez une touche pour redemarrer le systeme>",0
msg_ok             db " [  Ok  ]",0dh,0ah,0
msg_error2         db "\h70 [\c04Erreur\c07]\g00,49<Pressez une touche pour redemarrer le systeme>",0
msg_ok2            db "\h70 [\c02  Ok  \c07]\l",0
msg_echec2         db "\h70 [\c0CPasser\c07]\l",0
        
imports:
             db "VIDEO::setvideomode",0
setvideomode dd 0
             db "VIDEO::clearscreen",0
clearscreen  dd 0
             db "VIDEO.LIB::print",0
print        dd 0
             db "DETECT.LIB::cpuinfo",0
cpuinfo      dd 0
             db "DETECT.LIB::setinfo",0
setinfo      dd 0
             db "DETECT.LIB::pciinfo",0
pciinfo      dd 0
             db "DETECT.LIB::getcardinfo",0
getcardinfo  dd 0
             db "DETECT.LIB::getpcisubclass",0
getpcisubclass  dd 0
             db "DETECT.LIB::getpciclass",0
getpciclass  dd 0
             ;db "DETECT.LIB::detectvmware",0
;detectvmware  dd 0
             dw 0
        
exports:
include "mcb.asm"
mb1:
includebin "video.sys"
mb2:
includebin "..\lib\video.lib"
mb3:
includebin "..\lib\detect.lib"
mb4:

section:
dw offset mb0
dw offset mb1-offset mb0
db "SYSTEME",0

dw offset mb1
dw offset mb2-offset mb1
db "VIDEO",0

dw offset mb2
dw offset mb3-offset mb2
db "VIDEO.LIB",0

dw offset mb3
dw offset mb4-offset mb
db "DETECT.LIB",0

dd 0
        

