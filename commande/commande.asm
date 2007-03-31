model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\fat.h"
include "..\include\mem.h"
include "..\include\divers.h"
include "..\include\pci.h"
include "..\include\cpu.h"

org     0h

start:
header  exe     <,1,0,,,offset imports,,offset realstart>

realstart:
        call    [cs:print],offset msginit
        xor     bp,bp
replay:
        call    [cs:addline]
noret:
        call    [cs:addline]
        mov     di,offset dir
        call    [cs:getdir],di
        call    [cs:print],di
        call    [cs:print],offset prompt
        mov     di,offset buffer
waitchar:
        xor     ax,ax
        int     16h
        call    convertfr
        cmp     ah,59
        jne     norr
        cmp     bp,0
        je      waitchar
        call    [print],[word ptr cs: bp]
        call    [copy],[word ptr cs: bp],di
        call    [getlength],di
        add     di,ax
        jmp     waitchar
norr:
        cmp     al,0dh          ;entrée
        je      entere
        cmp     al,08h          ;backspace
        je      backspace
        cmp     al,27           ;echap
        je      escape
        cmp     al,' '
        jb      waitchar
        cmp     di,offset buffer+256
        je      waitchar
        mov     [di],al
        inc     di
        call    [cs:showchar],ax
        jmp     waitchar
escape:
        cmp     di,offset buffer
        je      waitchar
        call    [cs:getxy]
        mov     dx,offset buffer
        mov     cx,di
        sub     cx,dx
        js      waitchar
        je      waitchar
        sub     ah,cl
        mov     cl,ah
        xor     ah,ah
        xor     ch,ch
        call    [cs:setxy],cx,ax
        mov     di,offset buffer
        mov     [byte ptr di],0
        jmp     waitchar
backspace:
        cmp     di,offset buffer
        je      waitchar
        call    [cs:getxy]
        dec     ah
        mov     cl,ah
        xor     ah,ah
        xor     ch,ch        
        call    [cs:setxy],cx,ax        
        call    [cs:showchar],' '
        call    [cs:setxy],cx,ax         
        dec     di
        mov     [byte ptr di],0
        jmp     waitchar
entere:
        mov     [byte ptr di],0
        cmp     di,offset buffer
        je      noret
        mov     si,offset temp
        call    [cs:addline]
        call    [cs:getitem],offset buffer,si,0,' '
        call    [cs:uppercase],si
        mov     bx,offset commands
        xor     bp,bp
        xor     dx,dx
tre:
        mov     di,[bx]
        cmp     di,0
        je      error
        call    [cs:evalue],si,di
        cmp     ax,dx
        jb      noadd
        mov     dx,ax
        mov     bp,bx
noadd:
        call    [cs:cmpstr],si,di
        je      strisok
        add     bx,8
        jmp     tre
strisok:
        mov     di,offset temp
        call    [cs:copy],offset buffer,di
        call    [cs:uppercase],di
        xor     cx,cx
        inc     cx
        call    [cs:getpointeritem],di,cx,' '
        mov     di,ax
        cmp     [byte ptr di-1],0
        jne     nopod
        mov     [byte ptr di],0
nopod:
        call    [cs:checksyntax],di,[word ptr bx+4],' '
        jc      errorprec
        mov     bx,[bx+2]
        call    bx
        jmp     replay
error:
        mov     di,offset buffer
        call    [cs:searchchar],di,'.'
        je      noaddext
        call    [cs:concat],offset extcom,di
noaddext:
        call    [cs:execfile],di
        jc      reallyerror
        xor     bp,bp
        jmp     replay
reallyerror:
        push    [word ptr cs: bp]
        push    offset error_syntax
        call    [cs:print]
        jmp     replay
errorprec:
        push    offset derror
        call    [cs:print]
        jmp     replay

code_exit:
        pop     ax
        retf

code_version:  
        call    [cs:print],offset version_text
        ret

version_text db 'Cos 2000 version 1.3.2Fr par \c04MrNop\c07',0

code_cls:
        call    [cs:clearscreen]
        ret

code_reboot:
        push    0ffffh
        push    00000h
        retf

code_command: 
        call    [cs:print],offset def
        mov     bx,offset commands
showalls:
        push    [word ptr bx+4]
        push    [word ptr bx+6]
        push    [word ptr bx]  
        call    [cs:print],offset commandes
        add     bx,8
        cmp     [word ptr bx],0
        jne     showalls
endoff:
        ret

def       db '\c02Liste des commandes internes\l\l\c07',0
commandes db '%0 \h10:\h12%0 \h70%0\l',0

code_detect:
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
        ret

thepci pciinf <>
thecpu cpu <>

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

code_mode:
        call    [cs:gettypeditem],di,0,' '
        and     al,1111b
        call    [cs:setvideomode],ax
        call    [cs:clearscreen]
        ret

code_dir:
        call    [cs:getserial] 
        push    eax
        mov     si,offset nomdisque
        call    [cs:getname],si 
        push    si
        push    offset present
        call    [cs:print]
        xor     ecx,ecx
        mov     di,offset bufferentry
        call    [cs:findfirstfile],di
        jc      nofiles
go:
        push    [word ptr (find di).result.fileattr]
        push    [(find di).result.filesize]
        push    [(find di).result.filetime]
        push    [(find di).result.filedate]
        push    [(find di).result.filetimecrea]
        push    [(find di).result.filedatecrea]
        lea     bx,[(find di).result.filename]
        push    bx
        push    offset line
        call    [cs:print]
        inc     ecx
        call    [cs:findnextfile],di
        jnc     go
nofiles:
        push    ecx
        push    offset filess
        call    [cs:print]
        ret
        
nomdisque db    13 dup (0)
bufferentry db  512 dup (0)
present db      '\c02Le volume insere est nomme %0, Numero de serie : %hD\l\l',0

line    db      '\c07%n   %d   %t   %d   %t   %z   %a\l',0
filess  db      '\l\l\c02%u Fichier(s) au total\l\c07',0

code_cd:
        call    [cs:gettypeditem],di,0,' '
        push    ax
        push    offset changing
        call    [cs:print]
        call    [cs:changedir],ax
        jnc     okchange
        push    offset errorchanging
        call    [cs:print]
okchange:
        ret
        
changing db     'Changement de repertoire vers %0\l',0
errorchanging db '\c04Impossible d''atteindre ce dossier\c07',0
        
code_kill:
        call    [cs:gettypeditem],di,0,' '
        push    ax
        push    offset killing
        call    [cs:print]
        call    [cs:mbfind],ax
        jc      nochanged
        call    [cs:mbfree],ax
        jnc     okchanged
nochanged:   
        call    [cs:print],offset errorkilling
okchanged:
        ret

killing db     'Fermeture du processus %0\l',0
errorkilling db '\c04Impossible de fermer ce processus\c07',0

code_stack:
push ebp
push esp
push ss
push ss
call [cs:print],offset stackshow
mov cx,12 ;12 derniers éléments
xor esi,esi
mov si,sp
sub si,2*12
showloop:
push [dword ptr ss:si]
push esi
push ss
push ss
call [cs:print],offset itemshow
inc si
inc si
cmp si,sp
jne notspshow
call [cs:print],offset stresp
notspshow:
cmp si,bp
jne nextshow
call [cs:print],offset strebp
nextshow:
dec cx
jnz showloop
ret

stackshow db '\l\c02Vidage de la pile systeme\l\l\c07'
             db 'Segment  SS  : 0x%hW\l'
             db 'Pointeur ESP : 0x%hD\l'
             db 'Pointeur EBP : 0x%hD\l'
             db 'Seg   :Adr    | Donnees',0
itemshow     db '\l0x%hW:0x%hW | 0x%hW',0

strebp db '<-- BP',0
stresp db '<-- SP',0

code_dump:
        call    [cs:gettypeditem],di,0,' '     
        call    [cs:mbfind],di
        jc      notmbfind
        mov     fs,ax 
        dec     ax
        dec     ax
        mov     gs,ax 
        cmp     [word ptr fs:0x0],'EC'
        jne     notace2
        push    offset oui ;CE? str0 2 
        jmp     suitelikeace2
notace2:
        push    offset non
suitelikeace2:
        cmp     [word ptr gs:mb.isnotlast],true
        je      notlast2
        push    offset oui ;CE? str0 2 
        jmp     suitelikelast2
notlast2:
        push    offset non
suitelikelast2:
        mov     dx,gs
        push    edx          ;Emplacement memoire hex 2
;parent
        cmp     [gs:mb.reference],0
        jne     nextdetect2
        push    cs
        push    offset none        ;parent lstr0 2x2 
        add     bx,[gs:mb.sizes]
        jmp     suitemn2
nextdetect2:
        mov     dx,[gs:mb.reference]
        dec     dx
        dec     dx
        push    dx                    ;parent lstr0 2x2 
        push    offset (mb).names
suitemn2:
        cmp     [gs: mb.isresident],true
        jne     notresident2
        push    offset oui        ;resident str0 2 
        jmp     suitelistmcb2
notresident2:
        push    offset non     ;resident str0 2
suitelistmcb2:
        xor     edx,edx
        mov     dx,[gs: mb.sizes]
        shl     edx,4
        push    edx
        push    gs                   ;nom lstr0 2x2 
        push    offset (mb).names
        push    offset dumpshow        ;ligne
        call    [cs:print]
        cmp     [word ptr fs:0x0],'EC'
        jne     endofdumpformoment
        push    [dword ptr fs:exe.starting]
        push    fs
        push    fs
        push    [dword ptr fs:exe.sections]
        push    fs
        push    fs
        push    [dword ptr fs:exe.imports]
        push    fs
        push    fs
        push    [dword ptr fs:exe.exports]
        push    fs
        push    fs
        cmp     [fs: exe.compressed],true
        jne     notcompressed
        push    offset oui
        jmp     suiteiscompressed
notcompressed:
        push    offset non
suiteiscompressed:
        push    [dword ptr fs:exe.checksum]
        push    [dword ptr fs:exe.major]
        call    [cs:print],offset dumpshowce
endofdumpformoment:
        ret
notmbfind:
        call    [cs:print],offset errornotmbfind
        ret

errornotmbfind db '\c04Impossible de trouver le bloc specifie\l\l\c07',0
        

dumpshow db '\l\c02Dump du bloc de memoire nomme %0P\l\l'
          db '\c02-----------------------------\l'
          db '\c02Informations du bloc memoire\c07\l'
          db 'Taille du bloc reserve   : %u\l'
          db 'Bloc resident en memoire : %0\l'
          db 'Parent du bloc           : %0P\l'
          db 'Adresse du bloc memoire  : 0x%hW:0x0000\l'
          db 'Dernier bloc en memoire  : %0\l'
          db 'Heberge un format CE     : %0\l',0
dumpshowce db '\c02-----------------------------\l'
           db 'Informations du bloc executable\c07\l'
           db 'Version de l''executable  : %u\l'
           db 'Somme de controle        : %hD\l'
           db 'Compression du code      : %0\l'
           db 'Exportation de fonctions : 0x%hW:0x%hW\l'
           db 'Importation de fonctions : 0x%hW:0x%hW\l'
           db 'Sections de donnees      : 0x%hW:0x%hW\l'
           db 'Point d''entree du code   : 0x%hW:0x%hW\l',0


code_sections:
        call    [cs:gettypeditem],di,0,' '     
        call    [cs:mbfind],di
        jc      notmbfindssections
        jmp     haveatargetsections
notmbfindssections:
        call    [cs:searchfile],di
        jc      notmbfindall
        call    [cs:projfile],di
        jc      notmbfindall
        call    [cs:mbfind],di
        jc      notmbfindall
haveatargetsections:
        mov     fs,ax 
        cmp     [word ptr fs:0x0],'EC'
        jne     errornotace2
        mov     si,[fs:exe.sections]
        cmp     si,0
        je      errornosections
        xor     edx,edx
        call    [cs:print],offset rets
showallsections: 
        add     si,4       
        push    fs
        push    si
        call    [cs:print],offset functions
        inc     edx
findnextsections:
        inc     si
        cmp     [byte ptr fs:si],0
        jne     findnextsections
        cmp     [dword ptr fs:si],0
        je      finishsections
        inc     si
        jmp     showallsections
finishsections:
        push    edx
        call    [cs:print],offset allsections
        ret

errornosections:
        call    [cs:print],offset errornosection
        ret

allsections           db '\c02\lIl y avait %u sections dans le bloc ou fichier\l\c07',0 
errornosection        db '\c02Aucune section dans le bloc ou fichier\l\c07',0 

code_exports:
        call    [cs:gettypeditem],di,0,' '     
        call    [cs:mbfind],di
        jc      notmbfindsimports
        jmp     haveatargetexports
notmbfindsexports:
        call    [cs:searchfile],di
        jc      notmbfindall
        call    [cs:projfile],di
        jc      notmbfindall
        call    [cs:mbfind],di
        jc      notmbfindall
haveatargetexports:
        mov     fs,ax 
        cmp     [word ptr fs:0x0],'EC'
        jne     errornotace2
        mov     si,[fs:exe.exports]
        cmp     si,0
        je      errornoexports
        xor     edx,edx
        call    [cs:print],offset rets
showallexports: 
        push    fs
        push    si
        call    [cs:print],offset functions
        inc     edx
findnextexports:
        inc     si
        cmp     [byte ptr fs:si],0
        jne     findnextexports
        add     si,3
        cmp     [dword ptr fs:si],0
        je      finishexports
        jmp     showallexports
finishexports:
        push    edx
        call    [cs:print],offset allexports
        ret

errornoexports:
        call    [cs:print],offset errornoexport
        ret

allexports           db '\c02\lIl y avait %u exportations dans le bloc ou fichier\l\c07',0 
errornoexport        db '\c02Aucune exportation dans le bloc ou fichier\l\c07',0  


code_imports:
        call    [cs:gettypeditem],di,0,' '     
        call    [cs:mbfind],di
        jc      notmbfindsimports
        jmp     haveatargetimports
notmbfindsimports:
        call    [cs:searchfile],di
        jc      notmbfindall
        call    [cs:projfile],di
        jc      notmbfindall
        call    [cs:mbfind],di
        jc      notmbfindall
haveatargetimports:
        mov     fs,ax 
        cmp     [word ptr fs:0x0],'EC'
        jne     errornotace2
        mov     si,[fs:exe.imports]
        cmp     si,0
        je      errornoimports
        xor     edx,edx
        call    [cs:print],offset rets
showallimports: 
        push    fs
        push    si
        call    [cs:print],offset functions
        inc     edx
findnextimports:
        inc     si
        cmp     [byte ptr fs:si],0
        jne     findnextimports
        add     si,5
        cmp     [dword ptr fs:si],0
        je      finishimports
        jmp     showallimports
finishimports:
        push    edx
        call    [cs:print],offset allimports
        ret

errornoimports:
        call    [cs:print],offset errornoimport
        ret

notmbfindall:
        call    [cs:print],offset errornotmborfilefind
        ret

errornotace2:
        call    [cs:print],offset errornotcefind
        ret

functions db '%0P\l',0
rets                 db '\l\l',0
allimports           db '\c02\lIl y avait %u importations dans le bloc ou fichier\l\c07',0 
errornoimport        db '\c02Aucune importation dans le bloc ou fichier\l\c07',0  
errornotcefind       db '\c04Le bloc ou le fichier spécifié n''est pas CE\l\c07',0       
errornotmborfilefind db '\c04Impossible de trouver le bloc ou le fichier specifie\l\c07',0

code_regs:
call [cs:savecontext],offset allregs
push 6
push eax
push eax
mov ax,[word ptr allregs.sss]
push 6
push eax
push eax
mov ax,[word ptr allregs.sgs]
push 6
push eax
push eax
mov ax,[word ptr allregs.sfs]
push 6
push eax
push eax
mov ax,[word ptr allregs.ses]
push 6
push eax
push eax
mov ax,[word ptr allregs.sds]
push 6
push eax
push eax
mov ax,[word ptr allregs.scs]
xor eax,eax
push 10
pushd [dword ptr allregs.seip]
pushd [dword ptr allregs.seip]
push 10
pushd [dword ptr allregs.sesp]
pushd [dword ptr allregs.sesp]
push 10
pushd [dword ptr allregs.sebp]
pushd [dword ptr allregs.sebp]
push 10
pushd [dword ptr allregs.sedi]
pushd [dword ptr allregs.sedi]
push 10
pushd [dword ptr allregs.sesi]
pushd [dword ptr allregs.sesi]
push 10
pushd [dword ptr allregs.sedx]
pushd [dword ptr allregs.sedx]
push 10
pushd [dword ptr allregs.secx]
pushd [dword ptr allregs.secx]
push 10
pushd [dword ptr allregs.sebx]
pushd [dword ptr allregs.sebx]
push 10
pushd [dword ptr allregs.seax]
pushd [dword ptr allregs.seax]
push 10
pushd [dword ptr allregs.seflags]
pushd [dword ptr allregs.seflags]
call [cs:print],offset registershow
ret

registershow db '\l\c02Liste des registres du Microprocesseur\l\l\c07'
             db '\c04CPU\h30FPU\c07\l'
             db 'EFGS: 0x%hD : %w |\h32ST(0): ??\l'
             db 'EAX : 0x%hD : %w |\h32ST(1): ??\l'
             db 'EBX : 0x%hD : %w |\h32ST(2): ??\l'
             db 'ECX : 0x%hD : %w |\h32ST(3): ??\l'
             db 'EDX : 0x%hD : %w |\h32ST(4): ??\l'
             db 'ESI : 0x%hD : %w |\h32ST(5): ??\l'
             db 'EDI : 0x%hD : %w |\h32ST(6): ??\l'
             db 'EBP : 0x%hD : %w |\h32ST(7): ??\l'
             db 'ESP : 0x%hD : %w |\h32\l'
             db 'EIP : 0x%hD : %w |\h32\l'
             db 'CS  :     0x%hW :     %w |\h32\l'
             db 'DS  :     0x%hW :     %w |\h32\l'
             db 'ES  :     0x%hW :     %w |\h32\l'
             db 'FS  :     0x%hW :     %w |\h32\l'
             db 'GS  :     0x%hW :     %w |\h32\l'
             db 'SS  :     0x%hW :     %w |\h32\l',0


allregs regs <>

code_irqs:
call    [cs:mbfind],offset interruptionbloc
jc      erroronint
call [cs:print],offset irqmsg1
mov     es,ax
xor     ebx,ebx
intoirq:
xor     eax,eax
mov     al,[bx+offset irqmap]
mov     dx,size ints
mul     dx
mov     si,ax
pushd  [dword ptr es:(ints si).vector1.data.off]
pushd  [dword ptr es:(ints si).vector1.data.seg]
call   [cs:isrequestirq],bx
jc     requested
push   ' '
jmp    suiterequested
requested:
push   'X'
suiterequested:
call   [cs:isinserviceirq],bx
jc     inservice
push   ' '
jmp    suiteinservice
inservice:
push   'X'
suiteinservice:
call   [cs:isenableirq],bx
jc     activatemat
push   ' '
jmp    suiteactivatemat
activatemat:
push   'X'
suiteactivatemat:
cmp    [es:(ints si).activated],1
je     activate2
push   ' '
jmp    suiteactivate2
activate2:
push   'X'
suiteactivate2:
cmp    [es:(ints si).locked],1
je     verrouille2
push   ' '
jmp    suiteverrouille2
verrouille2:
push   'X'
suiteverrouille2:
pushd  [dword ptr es:(ints si).calledlow]
pushd  [dword ptr es:(ints si).calledhigh]
pushd  [dword ptr es:(ints si).launchedlow]
pushd  [dword ptr es:(ints si).launchedhigh]
push  3
xor   eax,eax
mov   al,[bx+offset irqmap]
push  eax
push  3
push  ebx
call [cs:print],offset irqmsg2
inc   bl
cmp   bl,16
jb    intoirq
ret


irqmap db 8,9,10,11,12,13,14,15,0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77
irqmsg1 db '\l\c02Listes des IRQs\c07\l\l'
       db 'IRQ | Int | Appels         | Executions     |Ver|Act|IMR|ISR|IRR| Vecteur 1 \l',0
irqmsg2 db '%w | %w | 0x%hW%hD | 0x%hW%hD | %c | %c | %c | %c | %c | 0x%hW:0x%hW\l',0

code_int:
call    [cs:mbfind],offset interruptionbloc
jc      erroronint
mov     es,ax
call    [cs:gettypeditem],di,0,' '
xor     edi,edi
mov     di,ax
mov     cx,size ints
mul     cx
mov     si,ax
pushd  [dword ptr es:(ints si).vector8.data.off]
pushd  [dword ptr es:(ints si).vector8.data.seg]
pushd  [dword ptr es:(ints si).vector7.data.off]
pushd  [dword ptr es:(ints si).vector7.data.seg]
pushd  [dword ptr es:(ints si).vector6.data.off]
pushd  [dword ptr es:(ints si).vector6.data.seg]
pushd  [dword ptr es:(ints si).vector5.data.off]
pushd  [dword ptr es:(ints si).vector5.data.seg]
pushd  [dword ptr es:(ints si).vector4.data.off]
pushd  [dword ptr es:(ints si).vector4.data.seg]
pushd  [dword ptr es:(ints si).vector3.data.off]
pushd  [dword ptr es:(ints si).vector3.data.seg]
pushd  [dword ptr es:(ints si).vector2.data.off]
pushd  [dword ptr es:(ints si).vector2.data.seg]
pushd  [dword ptr es:(ints si).vector1.data.off]
pushd  [dword ptr es:(ints si).vector1.data.seg]
pushd  [dword ptr es:(ints si).calledlow]
pushd  [dword ptr es:(ints si).calledhigh]
pushd  [dword ptr es:(ints si).launchedlow]
pushd  [dword ptr es:(ints si).launchedhigh]
cmp    [es:(ints si).activated],1
je     activate
push   offset oui
jmp    suiteactivate
activate:
push   offset non
suiteactivate:
cmp    [es:(ints si).locked],1
je     verrouille
push   offset oui
jmp    suiteverrouille
verrouille:
push   offset non
suiteverrouille:
push    esi
push    es
push    es
push    edi
call    [cs:print],offset infosint
ret
erroronint:   
        call    [cs:print],offset errorint
okint:
        ret
       
interruptionbloc db '/interrupts',0
errorint db '\c04Le gestionnaire d''interruption n''est pas actif\l\c07',0
infosint db '\c07Le bloc d''interruption est charge en memoire et le gestionnaire est actif\l\l'
         db 'Interruption %u\l'
         db 'Pointeur : 0x%hW:0x%hW\l\c07'
         db 'Active : %0\l'
         db 'Verrouillage : %0\l'
         db 'Nombre d''appels : 0x%hD%hD\l'
         db 'Nombre de lancements : 0x%hD%hD\l'
         db '\c02Vecteur 1 : 0x%hW:0x%hW\l'
         db 'Vecteur 2 : 0x%hW:0x%hW\l'
         db 'Vecteur 3 : 0x%hW:0x%hW\l'
         db 'Vecteur 4 : 0x%hW:0x%hW\l'
         db 'Vecteur 5 : 0x%hW:0x%hW\l'
         db 'Vecteur 6 : 0x%hW:0x%hW\l'
         db 'Vecteur 7 : 0x%hW:0x%hW\l'
         db 'Vecteur 8 : 0x%hW:0x%hW\l\c07',0

code_refresh:
        call    [cs:initdrive]
        jnc     okrefresh
        call    [cs:print],offset errorrefreshing
        ret
okrefresh:
        call    [cs:getserial] 
        push    eax
        mov     si,offset nomdisque
        call    [cs:getname],si 
        push    si
        push    offset present
        call    [cs:print]
        ret

errorrefreshing db '\c04Impossible de lire le support',0
extcom  db      '.CE',0


code_mem:    
        call    [cs:print],offset msg
        xor     edx,edx
        xor     ebx,ebx
        xor     cx,cx
listmcb:
        call    [cs:mbget],cx
        jc      fino
        mov     fs,ax
        dec     ax
        dec     ax
        mov     gs,ax
        inc     cx
        cmp     [word ptr fs:0x0],'EC'
        jne     notace
        push    offset oui ;CE? str0 2 
        jmp     suitelikeace
notace:
        push    offset non
suitelikeace:
        mov     dx,fs
        push    edx          ;Emplacement memoire hex 2
;parent
        cmp     [gs:mb.reference],0
        jne     nextdetect
        push    cs
        push    offset none        ;parent lstr0 2x2 
        add     bx,[gs:mb.sizes]
        jmp     suitemn
nextdetect:
        mov     dx,[gs:mb.reference]
        dec     dx
        dec     dx
        push    dx                    ;parent lstr0 2x2 
        push    offset (mb).names
suitemn:
        cmp     [gs: mb.isresident],true
        jne     notresident
        push    offset oui        ;resident str0 2 
        jmp     suitelistmcb
notresident:
        push    offset non     ;resident str0 2
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
        ret
oui db     "oui",0
non db     "non",0
line2   db      "%0P\h15| %w\h24| %0\h30| %0P\h47| 0x%hW\h56| %0\l",0
fin     db      "\l\l\c02%u octets de memoire disponible\l\c07",0
msg     db      "\l\c02Plan de la memoire\c07\l\lNom            | Taille | Res | Parent         | Mem    | CE \l",0
none    db      "?????",0


;converti le jeux scancode/ascii en fr ax->ax
convertfr:
        push    dx si
        mov     si,offset fr
searchtouch:
        mov     dx,[cs: si]
        cmp     dx,0
        je      endofconv
        add     si,4
        cmp     dx,ax
        jne     searchtouch
        mov     ax,[cs: si-2]
endofconv:
        pop     dx si
        ret

fr:     db      '1', 02, '&', 02
        db      '!', 02, '1', 02
        db      '2', 03, '‚', 03
        db      '@', 03, '2', 03
        db      '3', 04, '"', 04
        db      '#', 04, '3', 04
        db      '4', 05, 39, 05
        db      '$', 05, '4', 05
        db      '5', 06, '(', 06
        db      '%', 06, '5', 06
        db      '6', 07, '-', 07
        db      '^', 07, '6', 07
        db      '7', 08, 'Š', 08
        db      '&', 08, '7', 08
        db      '8', 09, '_', 09
        db      '*', 09, '8', 09
        db      '9', 10, '‡', 10
        db      '(', 10, '9', 10
        db      '0', 11, '…', 11
        db      ')', 11, '0', 11
        db      '-', 12, ')', 12
        db      '_', 12, 'ø', 12
        db      'Q', 16, 'A', 16
        db      'q', 16, 'a', 16
        db      'W', 17, 'Z', 17
        db      'w', 17, 'z', 17
        db      '{', 26, '‰', 26
        db      '[', 26, 'ˆ', 26
        db      ']', 27, '$', 27
        db      '}', 27, 'œ', 27
        db      'A', 30, 'Q', 30
        db      'a', 30, 'q', 30
        db      ':', 39, 'M', 39
        db      ';', 39, 'm', 39
        db      39, 40, '—', 40
        db      '"', 40, '%', 40
        db      00, 40, '%', 40
        db      '\', 43, '*', 43
        db      '|', 43, 'æ', 43
        db      'Z', 44, 'W', 44
        db      'z', 44, 'w', 44
        db      'm', 50, ',', 50
        db      'M', 50, '?', 50
        db      ',', 51, ';', 51
        db      '<', 51, '.', 51
        db      '.', 52, ':', 52
        db      '>', 52, '/', 52
        db      '?', 53, 'õ', 53
        db      '/', 53, '!', 53
        db      '\', 86, '<', 86
        db      '|', 86, '>', 86
        db      00, 79h, '~', 03
        db      00, 7ah, '#', 04
        db      00, 7bh, '{', 05
        db      00, 7ch, '[', 06
        db      00, 7dh, '|', 07
        db      00, 7eh, '`', 08
        db      00, 7fh, '\', 09
        db      00, 80h, '^', 10
        db      00, 81h, '@', 11
        db      00, 82h, ']', 12
        db      00, 83h, '}', 13
        db      00, 00, 00, 00

commands dw     str_exit ,code_exit ,syn_exit ,help_exit
dw      str_version,code_version,syn_version,help_version
dw      str_cls ,code_cls ,syn_cls ,help_cls
dw      str_reboot ,code_reboot ,syn_reboot ,help_reboot
dw      str_command,code_command,syn_command,help_command
dw      str_mode ,code_mode ,syn_mode ,help_mode
dw      str_dir ,code_dir ,syn_dir ,help_dir
dw      str_refresh ,code_refresh ,syn_refresh ,help_refresh
dw      str_cd ,code_cd ,syn_cd ,help_cd
dw      str_mem ,code_mem ,syn_mem ,help_mem
dw      str_kill ,code_kill ,syn_kill ,help_kill
dw      str_int ,code_int ,syn_int ,help_int
dw      str_irqs ,code_irqs,syn_irqs ,help_irqs
dw      str_regs ,code_regs,syn_regs ,help_regs
dw      str_stack,code_stack,syn_stack,help_stack
dw      str_dump,code_dump,syn_dump,help_dump
dw      str_detect,code_detect,syn_detect,help_detect
dw      str_exports,code_exports,syn_exports,help_exports
dw      str_imports,code_imports,syn_imports,help_imports
dw      str_sections,code_sections,syn_sections,help_sections
dw      0

str_exit db     'QUIT',0
str_version db  'VERS',0
str_cls db      'CLEAR',0
str_reboot db   'REBOOT',0
str_command db  'CMDS',0
str_mode db     'MODE',0
str_dir db      'DIR',0
str_refresh db  'DISK',0
str_cd  db      'CD',0
str_mem db      'MEM',0
str_kill db     'KILL',0
str_int db      'INT',0
str_irqs db      'IRQS',0
str_regs db     'REGS',0
str_stack db    'STACK',0
str_dump db     'DUMP',0
str_detect db   'DETECT',0
str_exports db   'EXPORTS',0
str_imports db   'IMPORTS',0
str_sections db   'SECTIONS',0

syn_exit db     0
syn_version db  0
syn_cls db      0
syn_reboot db   0
syn_command db  0
syn_mode db     'FFh',0
syn_dir db      0
syn_refresh db  0
syn_cd  db      '?',0
syn_mem db      0
syn_kill  db    '?',0
syn_int db     'FFh',0
syn_irqs db      0
syn_regs db     0
syn_stack db    0
syn_dump db     '?',0
syn_detect db    0
syn_exports db    '?',0
syn_imports db    '?',0
syn_sections  db    '?',0

help_exit db    'Permet de quitter l''interpreteur',0
help_version db 'Affiche la version de COS',0
help_cls db     'Efface l''ecran',0
help_reboot db  'Redemarre l''ordinateur',0
help_command db 'Affiche le detail des commandes',0
help_mode db    'Modifie le mode video en cours',0
help_dir db     'Affiche le contenu du repertoire courant',0
help_refresh db 'Lit le support disquette insere',0
help_cd db      'Change le repertoire courant',0
help_mem db     'Affiche le plan de la memoire',0
help_kill db    'Termine le processus cible',0
help_int  db    'Affiche des informations sur l''interruption',0
help_irqs  db    'Affiche des informations sur les IRQs',0
help_regs db    'Affiche les registres du microprocesseur',0
help_stack db   'Affiche la pile systeme',0
help_dump db    'Affiche le contenu de la memoire',0
help_detect db  'Detecte et Affiche les peripheriques PCI et le CPU',0
help_exports db 'Affiche toutes les exportations du fichier specifie',0
help_imports db 'Affiche toutes les importations du fichier specifie',0
help_sections db 'Affiche toutes les sections du fichier specifie',0

derror  db      '\c04Erreur de Syntaxe !',0
error_syntax db '\c04La commande ou l''executable n''existe pas ! F1 pour %0',0
prompt  db      '\c07>',0
msginit db      '\m02\e\c07\l\lInterpreteur de commande COS V1.10\lSous license \c05GPL\c07 - Ecrit par \c04MrNop\l\c07Utilisez la commande CMDS pour connaitres les commandes disponibles\l',0


dir     db      32 dup (0)
buffer  db      256 dup (0)
temp    db      256 dup (0)

importing
use DETECT.LIB,cpuinfo
use DETECT.LIB,setinfo
use DETECT.LIB,pciinfo
use DETECT.LIB,getcardinfo
use DETECT.LIB,getpcisubclass
use DETECT.LIB,getpciclass
use DETECT.LIB,detectvmware
use VIDEO,clearscreen
use VIDEO,setvideomode
use VIDEO,getxy
use VIDEO,setxy
use VIDEO,addline
use VIDEO.LIB,showhex
use VIDEO.LIB,print
use VIDEO.LIB,showchar
use DISQUE,getdir
use DISQUE,getserial
use DISQUE,getname
use DISQUE,findfirstfile
use DISQUE,findnextfile
use DISQUE,execfile
use DISQUE,initdrive
use DISQUE,changedir
use DISQUE,searchfile
use DISQUE,projfile
use SYSTEME,mbget
use SYSTEME,mbfind
use SYSTEME,mbfindsb
use SYSTEME,mbfree
use SYSTEME,isenableirq
use SYSTEME,isinserviceirq
use SYSTEME,isrequestirq
use SYSTEME,savecontext
use STR0.LIB,uppercase
use STR0.LIB,evalue
use STR0.LIB,copy
use STR0.LIB,checksyntax
use STR0.LIB,searchchar
use STR0.LIB,concat
use STR0.LIB,getitem
use STR0.LIB,cmpstr
use STR0.LIB,getpointeritem
use STR0.LIB,getlength
use STR0.LIB,gettypeditem
endi
