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
include "..\include\fat.h"

memorystart equ 0052h             ;premier bloc de la mémoire

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
        call    [cs:setvideomode],2
        jc      error
        call    [cs:clearscreen]
        call    [cs:print],offset msg_memory
        call    [cs:print],offset msg_ok2
        call    [cs:print],offset msg_memory_init
        call    [cs:print],offset msg_ok2
        call    [cs:print],offset msg_memory_section
        call    [cs:print],offset msg_ok2
        call    [cs:print],offset msg_memory_jumps
        call    [cs:print],offset msg_ok2
        call    [cs:print],offset msg_video_init
        call    [cs:print],offset msg_ok2
        call    [cs:print],offset msg_handler
        ;call    installirqhandler
        call    [cs:print],offset msg_ok2
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
        call    [cs:print],offset msg_flat
        call    enablea20
        call    flatmode
        xor     ax,ax
        mov     fs,ax
        mov     esi,0100000h
        mov     [dword ptr fs:esi],"OKIN"
        call    [cs:print],offset msg_ok2
        call    [cs:print],offset msg_disk_init
        call    [cs:initdrive]
        jc      error2
        call    [cs:print],offset msg_ok2
        call    [cs:execfile],offset shell
        
error2:
        call    [cs:print],offset msg_error2
        call    bioswaitkey
        jmp     far 0FFFFh:0000h

error:
        call    biosprint,offset msg_error
        call    bioswaitkey
        jmp     far 0FFFFh:0000h
        
shell find <"COMMANDE.CE",0,0,0,1,>
thepci pciinf <>
thecpu cpu <>
temp db 256 dup (0)
return             db 0dh,0ah,0
msg_memory         db "Initialisation de la memoire",0
msg_memory_init    db "  -Creation du bloc primordial",0
msg_memory_section db "  -Developpement des sections",0
msg_memory_jumps   db "Redirection du systeme",0
msg_video_init     db "Initialisation du pilote VIDEO",0
msg_handler        db "Initialisation du gestionnaire d'interruption",0
msg_cpu_detect     db "Dectection du processeur",0
msg_cpu_detect_inf db "  -Fondeur  : %0\l  -Modele   : %0\l  -Revision : %u\l  -Version  : %u\l  -Famille  : %u\l  -Technologies: %0\l",0
msg_pci            db "Detection des systemes PCI",0
msg_pci_info       db "  -Version  : %yB.%yB\l  -Numero bus max: %u\l",0
msg_pci_enum       db "  -Enumeration des peripheriques PCI:\l"
                   db "   |Vendeur|Modele|Bus |Dev.|Func|Classe.Sous-classe\l",0
msg_pci_card       db "   | %hW  | %hW |%w|%w|%w|%0P.%0P\l",0
msg_vmware         db "\c04 VMWare a ete detecte !!!\c07\l",0
msg_flat           db "Initialisation du Flat Real Mode\l",0
msg_disk_init      db "Initialisation du pilote DISQUE\l",0


msg_error          db " [Erreur]",0dh,0ah,"<Pressez une touche pour redemarrer le systeme>",0
msg_ok             db " [  Ok  ]",0dh,0ah,0
msg_error2         db "\h70 [\c04Erreur\c07]\g00,49<Pressez une touche pour redemarrer le systeme>",0
msg_ok2            db "\h70 [\c02  Ok  \c07]\l",0
msg_echec2         db "\h70 [\c0CPasser\c07]\l",0


exporting
declare biosprinth
declare biosprint
declare mbinit
declare mbcreate
declare mbfree
declare mbclean
declare mbresident
declare mbnonresident
declare mbchown
declare mballoc
declare mbfind
declare mbfindsb
declare mbget
declare mbloadfuncs
declare mbsearchfunc
declare bioswaitkey
declare mbloadsection
declare enableirq
declare enableirq
declare readimr
declare readirr
declare readisr
declare seteoi
declare enablea20
declare disablea20
declare flatmode
declare installirqhandler
declare irqhandler
declare isenableirq
declare isrequestirq
declare isinserviceirq
declare savecontext
declare restorecontextg
ende


importing
use VIDEO,setvideomode
use VIDEO,clearscreen
use VIDEO.LIB,print
use DETECT.LIB,cpuinfo
use DETECT.LIB,setinfo
use DETECT.LIB,pciinfo
use DETECT.LIB,getcardinfo
use DETECT.LIB,getpcisubclass
use DETECT.LIB,getpciclass
use DETECT.LIB,detectvmware
use DISQUE,initdrive
use DISQUE,projfile
use DISQUE,execfile
endi
        
include "mcb.asm"
include "8259a.asm"

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
dw offset mb4-offset mb3
db "DETECT.LIB",0

dw offset mb4
dw offset mb5-offset mb4
db "DISQUE",0

dd 0

mb1:
includebin "video.sys"
mb2:
includebin "..\lib\video.lib"
mb3:
includebin "..\lib\detect.lib"
mb4:
includebin "disque.sys"
mb5:


        

