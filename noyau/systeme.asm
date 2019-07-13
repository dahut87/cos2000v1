use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"
include "..\include\cpu.h"
include "..\include\pci.h"
include "..\include\fat.h"

memorystart equ 0052h             ;premier bloc de la mémoire

org 0h

mb0:
header exe 1

start:
        push    cs
        push    cs
        push    cs
        push    cs
        pop     ds
        pop     es
        pop     fs
        pop     gs
        stdcall   biosprint,makereturn
        stdcall    biosprint,msg_memory
        stdcall    biosprint,makereturn
        stdcall    biosprint,msg_memory_init
        stdcall    mbinit
        jc      error
        stdcall    biosprint,msg_ok
        stdcall    biosprint,msg_memory_section
        mov     ax,cs
        stdcall    mbloadsection,ax
        jc      error
        stdcall    biosprint,msg_ok
        stdcall    biosprint,msg_memory_jumps
        jmp     dword [cs:pointer]
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
        stdcall    biosprint,msg_ok
        stdcall    biosprint,msg_video_init
        invoke     setvideomode,2
        jc      error
        invoke     clearscreen
        invoke     print,msg_memory
        invoke     print,msg_ok2
        invoke     print,msg_memory_init
        invoke     print,msg_ok2
        invoke     print,msg_memory_section
        invoke     print,msg_ok2
        invoke     print,msg_memory_jumps
        invoke     print,msg_ok2
        invoke     print,msg_video_init
        invoke     print,msg_ok2
        invoke     print,msg_handler
        ;invoke    installirqhandler
        invoke     print,msg_ok2
        invoke     print,msg_cpu_detect
        invoke     cpuinfo,thecpu
        invoke     setinfo,thecpu,temporary
        invoke     print,msg_ok2
        push    temporary
        xor     eax,eax
        mov     al,[thecpu.family]
        push    eax
        mov     al,[thecpu.models]
        push    eax
        mov     al,[thecpu.stepping]
        push    eax
        push    thecpu.names
        push    thecpu.vendor
        invoke     print,msg_cpu_detect_inf
        invoke     print,msg_pci
        invoke     pciinfo,thepci
        jc      nopci
        invoke     print,msg_ok2
        xor     eax,eax
        mov     al,[thepci.maxbus]
        push    eax
        mov     al,[thepci.version_minor]
        push    eax
        mov     al,[thepci.version_major]
        push    eax
        invoke     print,msg_pci_info
        invoke     print,msg_pci_enum
        xor     ebx,ebx
        xor     ecx,ecx
        xor     si,si
searchpci:
        invoke  getcardinfo,bx,cx,si,temporary
        jc      stopthis
	virtual at temporary
	.pcidata pcidata
	end virtual
        mov     al,[.pcidata.subclass]
        push    ax
        mov     al,[.pcidata.class]
        push    ax
        invoke     getpcisubclass
        push    dx
        push    ax
        mov     al,[.pcidata.class]
        xor     ah,ah
        push    ax
        invoke     getpciclass 
        push    dx
        push    ax
        push    4
        push    esi
        push    4
        push    ecx
        push    4
        push    ebx
        mov     ax,[.pcidata.device]
        push    eax
        mov     ax,[.pcidata.vendor]
        push    eax
        invoke     print,msg_pci_card
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
        invoke     print,msg_echec2
next:
        ;invoke     detectvmware
        ;jne     novirtual
        ;invoke     print,msg_vmware
novirtual:
        ;invoke    print,msg_flat
        ;invoke    enablea20
        ;invoke    flatmode
        ;xor     ax,ax
        ;mov     fs,ax
        ;mov     esi,0100000h
        ;mov     [dword ptr fs:esi],"OKIN"
        invoke    print,msg_ok2
        invoke    print,msg_disk_init
        invoke    initdrive
        jc      error2
        invoke    print,msg_ok2
        invoke    print,msg_launchcommand
        invoke    execfile,shell
        jc      error2
error2:
        invoke     print,msg_error2
        stdcall    bioswaitkey
        jmp     far 0FFFFh:0000h

error:
        stdcall    biosprint,msg_error
        stdcall    bioswaitkey
        jmp     far 0FFFFh:0000h
        
shell find "COMMANDE.CE\0"
thepci pciinf
thecpu cpu
temporary db 256 dup (0)
makereturn             db 0dh,0ah,0
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
                   db "   | Vendeur | Modele |Bus |Dev.|Func|Classe.Sous-classe\l",0
msg_pci_card       db "   | 0x%hW  | 0x%hW |%w|%w|%w|%0P.%0P\l",0
msg_vmware         db "\c04 VMWare a ete detecte !!!\c07\l",0
msg_flat           db "Initialisation du Flat Real Mode\l",0
msg_disk_init      db "Initialisation du pilote DISQUE\l",0
msg_launchcommand  db "Execution du SHELL\l",0

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

allsection:
dw mb0
dw mb1-mb0
db "SYSTEME",0

dw mb1
dw mb2-mb1
db "VIDEO",0

dw mb2
dw mb3-mb2
db "VIDEO.LIB",0

dw mb3
dw mb4-mb3
db "DETECT.LIB",0

dw mb4
dw mb5-mb4
db "DISQUE",0

dd 0

mb1:
file "video.sys"
mb2:
file "..\lib\video.lib"
mb3:
file "..\lib\detect.lib"
mb4:
file "disque.sys"
mb5:


        

