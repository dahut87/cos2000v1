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


start:
header exe <,1,0,,,offset imports,,offset realstart>

realstart:
        call    [cs:print],offset msg_cpu_detect
        call    [cs:cpuinfo],offset thecpu
        call    [cs:setinfo],offset thecpu,offset temp
        call    [cs:print],offset msg_ok2
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
        call    [cs:print],offset msg_cpu_detect_inf
        call    [cs:print],offset msg_pci
        call    [cs:pciinfo],offset thepci
        jc      nopci
        call    [cs:print],offset msg_ok2
        xor     eax,eax
        mov     al,[thepci.maxbus]
        push    eax
        mov     al,[thepci.version_minor]
        push    eax
        mov     al,[thepci.version_major]
        push    eax
        call    [cs:print],offset msg_pci_info
        call    [cs:print],offset msg_pci_enum
        xor     bx,bx
        xor     cx,cx
        xor     si,si
searchpci:
        call    [cs:getcardinfo],bx,cx,si,offset temp
        jc      stopthis
        mov     al,[(pcidata offset temp).subclass]
        push    ax
        mov     al,[(pcidata offset temp).class]
        push    ax
        call    [cs:getpcisubclass]
        push    dx
        push    ax
        mov     al,[(pcidata offset temp).class]
        xor     ah,ah
        push    ax
        call    [cs:getpciclass]
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
        call    [cs:print],offset msg_pci_card
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
        call    [cs:print],offset msg_echec2
next:
        call    [cs:detectvmware]
        jne     novirtual
        call    [cs:print],offset msg_vmware
novirtual:
        retf 

importing
use VIDEO.LIB,print
use DETECT.LIB,cpuinfo
use DETECT.LIB,setinfo
use DETECT.LIB,pciinfo
use DETECT.LIB,getcardinfo
use DETECT.LIB,getpcisubclass
use DETECT.LIB,getpciclass
use DETECT.LIB,detectvmware
endi

thepci pciinf <>
thecpu cpu <>
temp db 256 dup (0)

msg_ok2            db "\h70 [\c02  Ok  \c07]\l",0
msg_echec2         db "\h70 [\c0CPasser\c07]\l",0
msg_cpu_detect     db "Dectection du processeur",0
msg_cpu_detect_inf db "  -Fondeur  : %0\l  -Modele   : %0\l  -Revision : %u\l  -Version  : %u\l  -Famille  : %u\l  -Technologies: %0\l",0
msg_pci            db "Detection des systemes PCI",0
msg_pci_info       db "  -Version  : %yB.%yB\l  -Numero bus max: %u\l",0
msg_pci_enum       db "  -Enumeration des peripheriques PCI:\l"
                   db "   |Vendeur|Modele|Bus |Dev.|Func|Classe.Sous-classe\l",0
msg_pci_card       db "   | %hW  | %hW |%w|%w|%w|%0P.%0P\l",0
msg_vmware         db "\c04 VMWare a ete detecte !!!\c07\l",0
