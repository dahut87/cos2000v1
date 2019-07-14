use16
align 1

include "..\include\fat.h"
include "..\include\mem.h"
include "..\include\divers.h"
include "..\include\pci.h"
include "..\include\cpu.h"

org     0h

header exe 1,0,imports,0,realstart

realstart:
        invoke    print, msginit
        xor     bp,bp
replay:
        invoke    addline
noret:
        invoke    addline
        mov     di,dir
        invoke    getdir,di
        invoke    print,di
        invoke    print,prompt
        mov     di, buffer
waitchar:
        xor     ax,ax
        int     16h
        invoke    convertfr
        cmp     ah,59
        jne     norr
        cmp     bp,0
        je      waitchar
        invoke    print,word [cs: bp]
        invoke    copy,word [cs: bp],di
        invoke    getlength,di
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
        cmp     di, buffer+256
        je      waitchar
        mov     [di],al
        inc     di
        invoke    showchar,ax
        jmp     waitchar
escape:
        cmp     di, buffer
        je      waitchar
        invoke    getxy
        mov     dx,buffer
        mov     cx,di
        sub     cx,dx
        js      waitchar
        je      waitchar
        sub     ah,cl
        mov     cl,ah
        xor     ah,ah
        xor     ch,ch
        invoke    setxy,cx,ax
        mov     di,buffer
        mov     byte [di],0
        jmp     waitchar
backspace:
        cmp     di,buffer
        je      waitchar
        invoke    getxy
        dec     ah
        mov     cl,ah
        xor     ah,ah
        xor     ch,ch        
        invoke    setxy,cx,ax        
        invoke    showchar,' '
        invoke    setxy,cx,ax         
        dec     di
        mov     byte [di],0
        jmp     waitchar
entere:
        mov     byte [di],0
        cmp     di,buffer
        je      noret
        mov     si,temp
        invoke    addline
        invoke    getitem,buffer,si,0,' '
        invoke    uppercase,si
        mov     bx,commands
        xor     bp,bp
        xor     dx,dx
tre:
        mov     di,[bx]
        cmp     di,0
        je      error
        invoke    evalue,si,di
        cmp     ax,dx
        jb      noadd
        mov     dx,ax
        mov     bp,bx
noadd:
        invoke    cmpstr,si,di
        je      strisok
        add     bx,8
        jmp     tre
strisok:
        mov     di, temp
        invoke    copy,buffer,di
        invoke    uppercase,di
        xor     cx,cx
        inc     cx
        invoke    getpointeritem,di,cx,' '
        mov     di,ax
        cmp     byte [di-1],0
        jne     nopod
        mov     byte [di],0
nopod:
        invoke    checksyntax,di,word [bx+4],' '
        jc      errorprec
        mov     bx,[bx+2]
        invoke    bx
        jmp     replay
error:
        mov     di,buffer
        invoke    searchchar,di,'.'
        je      noaddext
        invoke    concat, extcom,di
noaddext:
        invoke    execfile,di
        jc      reallyerror
        xor     bp,bp
        jmp     replay
reallyerror:
        push    word [cs: bp]
        push    error_syntax
        invoke    print
        jmp     replay
errorprec:
        push    derror
        invoke    print
        jmp     replay

code_exit:
        pop     ax
        retf

code_version:  
        invoke    print, version_text
        ret

version_text db 'Cos 2000 version 1.4Fr par \c04MrNop\c07',0

code_cls:
        invoke    clearscreen
        ret

code_reboot:
        push    0ffffh
        push    00000h
        retf

code_command: 
        invoke    print, def
        mov     bx, commands
showalls:
        push    word [bx+4]
        push    word [bx+6]
        push    word [bx]  
        invoke    print, commandes
        add     bx,8
        cmp     word [bx],0
        jne     showalls
endoff:
        ret

def       db '\c02Liste des commandes internes\l\l\c07',0
commandes db '%0 \h10:\h12%0 \h70%0\l',0

code_detect:
        invoke    print,msg_cpu_detect
        invoke    cpuinfo,thecpu
        invoke    setinfo,thecpu, temp
        invoke    print,msg_ok2
        push    temp
        xor     eax,eax
        mov     al,[thecpu.family]
        push    eax
        mov     al,[thecpu.models]
        push    eax
        mov     al,[thecpu.stepping]
        push    eax
        push     thecpu.names
        push     thecpu.vendor
        invoke    print, msg_cpu_detect_inf
        invoke    print, msg_pci
        invoke    pciinfo, thepci
        jc      nopci
        invoke    print, msg_ok2
        xor     eax,eax
        mov     al,[thepci.maxbus]
        push    eax
        mov     al,[thepci.version_minor]
        push    eax
        mov     al,[thepci.version_major]
        push    eax
        invoke    print, msg_pci_info
        invoke    print, msg_pci_enum
        xor     ebx,ebx
        xor     ecx,ecx
        xor     si,si
searchpci:
        invoke    getcardinfo,bx,cx,si, temp
        jc      stopthis
	virtual at temp
	.pcidata pcidata
	end virtual
        mov     al,[.pcidata.subclass]
        push    ax
        mov     al,[.pcidata.class]
        push    ax
        invoke    getpcisubclass
        push    dx
        push    ax
        mov     al,[.pcidata.class]
        xor     ah,ah
        push    ax
        invoke    getpciclass
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
        invoke    print, msg_pci_card
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
        invoke    print, msg_echec2
next:
        invoke    detectvmware
        jne     novirtual
        invoke    print, msg_vmware
novirtual:
        ret

thepci pciinf
thecpu cpu 

msg_ok2            db "\h70 [\c02  Ok  \c07]\l",0
msg_echec2         db "\h70 [\c0CPasser\c07]\l",0
msg_cpu_detect     db "Dectection du processeur",0
msg_cpu_detect_inf db "  -Fondeur  : %0\l  -Modele   : %0\l  -Revision : %u\l  -Version  : %u\l  -Famille  : %u\l  -Technologies: %0\l",0
msg_pci            db "Detection des systemes PCI",0
msg_pci_info       db "  -Version  : %yB.%yB\l  -Numero bus max: %u\l",0
msg_pci_enum       db "  -Enumeration des peripheriques PCI:\l"
                   db "   | Vendeur | Modele |Bus |Dev.|Func|Classe.Sous-classe\l",0
msg_pci_card       db "   | 0x%hW  | 0x%hW |%w|%w|%w|%0P.%0P\l",0
msg_vmware         db "\c04 VMWare a ete detecte !!!\c07\l",0

code_mode:
        invoke    gettypeditem,di,0,' '
        and     al,1111b
        invoke    setvideomode,ax
        invoke    clearscreen
        ret

code_dir:
        invoke    getserial
        push    eax
        mov     si, nomdisque
        invoke    getname,si 
        push    si
        push     present
        invoke   print
        xor     ecx,ecx
        mov     di, bufferentry
        invoke    findfirstfile,di
        jc      nofiles
go:
	virtual at di
	.find find
	end virtual
        push    word [.find.result.fileattr]
        push    [.find.result.filesize]
        push    [.find.result.filetime]
        push    [.find.result.filedate]
        push    [.find.result.filetimecrea]
        push    [.find.result.filedatecrea]
        lea     bx,[.find.result.filename]
        push    bx
        push     line
        invoke    print
        inc     ecx
        invoke    findnextfile,di
        jnc     go
nofiles:
        push    ecx
        push     filess
        invoke    print
        ret
        
nomdisque db    13 dup (0)
bufferentry db  512 dup (0)
present db      '\c02Le volume insere est nomme %0, Numero de serie : %hD\l\l',0

line    db      '\c07%n   %d   %t   %d   %t   %z   %a\l',0
filess  db      '\l\l\c02%u Fichier(s) au total\l\c07',0

code_cd:
        invoke    gettypeditem,di,0,' '
        push    ax
        push     changing
        invoke    print
        invoke    changedir,ax
        jnc     okchange
        push     errorchanging
        invoke   print
okchange:
        ret
        
changing db     'Changement de repertoire vers %0\l',0
errorchanging db '\c04Impossible d''atteindre ce dossier\c07',0
        
code_kill:
        invoke    gettypeditem,di,0,' '
        push    ax
        push     killing
        invoke    print
        invoke    mbfind,ax
        jc      nochanged
        invoke    mbfree,ax
        jnc     okchanged
nochanged:   
        invoke    print, errorkilling
okchanged:
        ret

killing db     'Fermeture du processus %0\l',0
errorkilling db '\c04Impossible de fermer ce processus\c07',0

code_stack:
push ebp
push esp
push ss
push ss
invoke print, stackshow
mov cx,12 ;12 derniers éléments
xor esi,esi
mov si,sp
sub si,2*12
showloop:
push dword [ss:si]
push esi
push ss
push ss
invoke print, itemshow
inc si
inc si
cmp si,sp
jne notspshow
invoke print, stresp
notspshow:
cmp si,bp
jne nextshow
invoke print, strebp
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


code_setbuffer:
        invoke    gettypeditem,di,0,' '
        invoke    setbuffer,ax

code_getbuffer:
        mov     si, diskbuffers
        invoke    getbuffer,si
        xor     ecx,ecx
        mov     cx,[diskbuffers.current]
        push    ecx
        mov     cx,[diskbuffers.size]
        push    ecx
        invoke    print, showbuffers
        mov     si, diskbuffers.chain
        xor     bx,bx
showbuffer:
        cmp     word [si],0FFFFh
        jne     notnoted
        push     noted
        jmp     islikeit
notnoted:
        cmp     word [si],0FFFEh
        jne     notempty
        push     empty
        jmp     islikeit
notempty: 
        push    dword [si]
        push     occup
islikeit:
        cmp     bx,[diskbuffers.current]
        jne     notthecurrent
        invoke    showchar,'*'
        jmp     okletsgo
notthecurrent:
        invoke    showchar,' '
okletsgo:
        invoke    print
        inc     si
        inc     si
        inc     bx
        dec     cx
        jnz     showbuffer
        ret

empty db '\c06------',0
noted db '\c07------',0
occup db '\c170x%hW',0
showbuffers db '\l\c02Contenu des tampons disquette\l\l\c07'
            db 'Nombre de tampons alloues : %u\l'
            db 'Dernier element du tampon : %u\l\l',0

diskbuffers diskbuffer 

code_dump:
        invoke    gettypeditem,di,0,' '     
        invoke    mbfind,di
        jc      notmbfind
        mov     fs,ax 
        dec     ax
        dec     ax
        mov     gs,ax 
        cmp     word [fs:0x0],'EC'
        jne     notace2
        push     oui ;CE? str0 2 
        jmp     suitelikeace2
notace2:
        push     non
suitelikeace2:
        cmp     word [gs:mb.isnotlast],true
        je      notlast2
        push     oui ;CE? str0 2 
        jmp     suitelikelast2
notlast2:
        push     non
suitelikelast2:
        mov     dx,gs
        push    edx          ;Emplacement memoire hex 2
;parent
        cmp     [gs:mb.reference],0
        jne     nextdetect2
        push    cs
        push     none        ;parent lstr0 2x2 
        add     bx,[gs:mb.sizes]
        jmp     suitemn2
nextdetect2:
        mov     dx,[gs:mb.reference]
        dec     dx
        dec     dx
        push    dx                    ;parent lstr0 2x2 
        push     mb.names
suitemn2:
        cmp     [gs: mb.isresident],true
        jne     notresident2
        push     oui        ;resident str0 2 
        jmp     suitelistmcb2
notresident2:
        push     non     ;resident str0 2
suitelistmcb2:
        xor     edx,edx
        mov     dx,[gs:mb.sizes]
        shl     edx,4
        push    edx
        push    gs                   ;nom lstr0 2x2 
        push     mb.names
        push     dumpshow        ;ligne
        invoke    print
        cmp     word [fs:0x0],'EC'
        jne     endofdumpformoment
        push    dword [fs:exe.starting]
        push    fs
        push    fs
        push    dword [fs:exe.sections]
        push    fs
        push    fs
        push    dword [fs:exe.imports]
        push    fs
        push    fs
        push    dword [fs:exe.exports]
        push    fs
        push    fs
        cmp     [fs:exe.compressed],true
        jne     notcompressed
        push     oui
        jmp     suiteiscompressed
notcompressed:
        push     non
suiteiscompressed:
        push    dword [fs:exe.checksum]
        push    dword [fs:exe.major]
        invoke    print, dumpshowce
endofdumpformoment:
        ret
notmbfind:
        invoke    print, errornotmbfind
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
        invoke    gettypeditem,di,0,' '     
        invoke    mbfind,di
        jc      notmbfindssections
        jmp     haveatargetsections
notmbfindssections:
        invoke    searchfile,di
        jc      notmbfindall
        invoke    projfile,di
        jc      notmbfindall
        invoke    mbfind,di
        jc      notmbfindall
haveatargetsections:
        mov     fs,ax 
        cmp     word [fs:0x0],'EC'
        jne     errornotace2
        mov     si,[fs:exe.sections]
        cmp     si,0
        je      errornosections
        xor     edx,edx
        invoke    print, rets
showallsections: 
        add     si,4       
        push    fs
        push    si
        invoke    print, functions
        inc     edx
findnextsections:
        inc     si
        cmp     byte [fs:si],0
        jne     findnextsections
        cmp     dword [fs:si],0
        je      finishsections
        inc     si
        jmp     showallsections
finishsections:
        push    edx
        invoke    print, allsections
        ret

errornosections:
        invoke    print, errornosection
        ret

allsections           db '\c02\lIl y avait %u sections dans le bloc ou fichier\l\c07',0 
errornosection        db '\c02Aucune section dans le bloc ou fichier\l\c07',0 

code_exports:
        invoke    gettypeditem,di,0,' '     
        invoke    mbfind,di
        jc      notmbfindsimports
        jmp     haveatargetexports
notmbfindsexports:
        invoke    searchfile,di
        jc      notmbfindall
        invoke    projfile,di
        jc      notmbfindall
        invoke    mbfind,di
        jc      notmbfindall
haveatargetexports:
        mov     fs,ax 
        cmp     word [fs:0x0],'EC'
        jne     errornotace2
        mov     si,[fs:exe.exports]
        cmp     si,0
        je      errornoexports
        xor     edx,edx
        invoke    print, rets
showallexports: 
        push    fs
        push    si
        invoke    print, functions
        inc     edx
findnextexports:
        inc     si
        cmp     byte [fs:si],0
        jne     findnextexports
        add     si,3
        cmp     dword [fs:si],0
        je      finishexports
        jmp     showallexports
finishexports:
        push    edx
        invoke    print, allexports
        ret

errornoexports:
        invoke    print, errornoexport
        ret

allexports           db '\c02\lIl y avait %u exportations dans le bloc ou fichier\l\c07',0 
errornoexport        db '\c02Aucune exportation dans le bloc ou fichier\l\c07',0  


code_imports:
        invoke    gettypeditem,di,0,' '     
        invoke    mbfind,di
        jc      notmbfindsimports
        jmp     haveatargetimports
notmbfindsimports:
        invoke    searchfile,di
        jc      notmbfindall
        invoke    projfile,di
        jc      notmbfindall
        invoke    mbfind,di
        jc      notmbfindall
haveatargetimports:
        mov     fs,ax 
        cmp     word [fs:0x0],'EC'
        jne     errornotace2
        mov     si,[fs:exe.imports]
        cmp     si,0
        je      errornoimports
        xor     edx,edx
        invoke    print, rets
showallimports: 
        push    fs
        push    si
        invoke    print, functions
        inc     edx
findnextimports:
        inc     si
        cmp     byte [fs:si],0
        jne     findnextimports
        add     si,5
        cmp     dword [fs:si],0
        je      finishimports
        jmp     showallimports
finishimports:
        push    edx
        invoke    print, allimports
        ret

errornoimports:
        invoke    print, errornoimport
        ret

notmbfindall:
        invoke    print, errornotmborfilefind
        ret

errornotace2:
        invoke    print, errornotcefind
        ret

functions db '%0P\l',0
rets                 db '\l\l',0
allimports           db '\c02\lIl y avait %u importations dans le bloc ou fichier\l\c07',0 
errornoimport        db '\c02Aucune importation dans le bloc ou fichier\l\c07',0  
errornotcefind       db '\c04Le bloc ou le fichier spécifié n''est pas CE\l\c07',0       
errornotmborfilefind db '\c04Impossible de trouver le bloc ou le fichier specifie\l\c07',0

code_regs:
invoke savecontext, allregs
push 6
push eax
push eax
mov ax,word [allregs.sss]
push 6
push eax
push eax
mov ax,word [allregs.sgs]
push 6
push eax
push eax
mov ax,word [allregs.sfs]
push 6
push eax
push eax
mov ax,word [allregs.ses]
push 6
push eax
push eax
mov ax,word [allregs.sds]
push 6
push eax
push eax
mov ax,word [allregs.scs]
xor eax,eax
push 10
pushd dword [allregs.seip]
pushd dword [allregs.seip]
push 10
pushd dword [allregs.sesp]
pushd dword [allregs.sesp]
push 10
pushd dword [allregs.sebp]
pushd dword [allregs.sebp]
push 10
pushd dword [allregs.sedi]
pushd dword [allregs.sedi]
push 10
pushd dword [allregs.sesi]
pushd dword [allregs.sesi]
push 10
pushd dword [allregs.sedx]
pushd dword [allregs.sedx]
push 10
pushd dword [allregs.secx]
pushd dword [allregs.secx]
push 10
pushd dword [allregs.sebx]
pushd dword [allregs.sebx]
push 10
pushd dword [allregs.seax]
pushd dword [allregs.seax]
push 10
pushd dword [allregs.seflags]
pushd dword [allregs.seflags]
invoke print, registershow
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


allregs regs 

code_irqs:
invoke    mbfind, interruptionbloc
jc      erroronint
invoke print, irqmsg1
mov     es,ax
xor     ebx,ebx
intoirq:
xor     eax,eax
mov     al,[bx+ irqmap]
mov     dx,ints.sizeof
mul     dx
mov     si,ax
virtual at si
.ints ints
end virtual
pushd  dword [es:.ints.vector1.data.off]
pushd  dword [es:.ints.vector1.data.seg]
invoke   isrequestirq,bx
jc     requested
push   ' '
jmp    suiterequested
requested:
push   'X'
suiterequested:
invoke   isinserviceirq,bx
jc     inservice
push   ' '
jmp    suiteinservice
inservice:
push   'X'
suiteinservice:
invoke   isenableirq,bx
jc     activatemat
push   ' '
jmp    suiteactivatemat
activatemat:
push   'X'
suiteactivatemat:
virtual at si
.ints ints
end virtual
cmp    [es:.ints.activated],1
je     activate2
push   ' '
jmp    suiteactivate2
activate2:
push   'X'
suiteactivate2:
virtual at si
.ints ints
end virtual
cmp    [es:.ints.locked],1
je     verrouille2
push   ' '
jmp    suiteverrouille2
verrouille2:
push   'X'
suiteverrouille2:
virtual at si
.ints ints
end virtual
pushd  dword [es:.ints.calledlow]
pushd  dword [es:.ints.calledhigh]
pushd  dword [es:.ints.launchedlow]
pushd  dword [es:.ints.launchedhigh]
push  3
xor   eax,eax
mov   al,[bx+ irqmap]
push  eax
push  3
push  ebx
invoke print, irqmsg2
inc   bl
cmp   bl,16
jb    intoirq
ret


irqmap db 8,9,10,11,12,13,14,15,0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77
irqmsg1 db '\l\c02Listes des IRQs\c07\l\l'
       db 'IRQ | Int | Appels         | Executions     |Ver|Act|IMR|ISR|IRR| Vecteur 1 \l',0
irqmsg2 db '%w | %w | 0x%hW%hD | 0x%hW%hD | %c | %c | %c | %c | %c | 0x%hW:0x%hW\l',0

code_int:
invoke    mbfind, interruptionbloc
jc      erroronint
mov     es,ax
invoke    gettypeditem,di,0,' '
xor     edi,edi
mov     di,ax
mov     cx,ints.sizeof
mul     cx
mov     si,ax
virtual at si
.ints ints
end virtual
pushd  dword [es:.ints.vector8.data.off]
pushd  dword [es:.ints.vector8.data.seg]
pushd  dword [es:.ints.vector7.data.off]
pushd  dword [es:.ints.vector7.data.seg]
pushd  dword [es:.ints.vector6.data.off]
pushd  dword [es:.ints.vector6.data.seg]
pushd  dword [es:.ints.vector5.data.off]
pushd  dword [es:.ints.vector5.data.seg]
pushd  dword [es:.ints.vector4.data.off]
pushd  dword [es:.ints.vector4.data.seg]
pushd  dword [es:.ints.vector3.data.off]
pushd  dword [es:.ints.vector3.data.seg]
pushd  dword [es:.ints.vector2.data.off]
pushd  dword [es:.ints.vector2.data.seg]
pushd  dword [es:.ints.vector1.data.off]
pushd  dword [es:.ints.vector1.data.seg]
pushd  dword [es:.ints.calledlow]
pushd  dword [es:.ints.calledhigh]
pushd  dword [es:.ints.launchedlow]
pushd  dword [es:.ints.launchedhigh]
cmp    [es:.ints.activated],1
je     activate
push   oui
jmp    suiteactivate
activate:
push   non
suiteactivate:
virtual at si
.ints ints
end virtual
cmp    [es:.ints.locked],1
je     verrouille
push    oui
jmp    suiteverrouille
verrouille:
push    non
suiteverrouille:
push    esi
push    es
push    es
push    edi
invoke    print, infosint
ret
erroronint:   
        invoke    print,errorint
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
        invoke    initdrive
        jnc     okrefresh
        invoke    print,errorrefreshing
        ret
okrefresh:
        invoke    getserial
        push    eax
        mov     si,nomdisque
        invoke    getname,si 
        push    si
        push    present
        invoke    print
        ret

errorrefreshing db '\c04Impossible de lire le support',0
extcom  db      '.CE',0


code_mem:    
        invoke    print, msg
        xor     edx,edx
        xor     ebx,ebx
        xor     cx,cx
listmcb:
        invoke    mbget,cx
        jc      fino
        mov     fs,ax
        dec     ax
        dec     ax
        mov     gs,ax
        inc     cx
        cmp     word [fs:0x0],'EC'
        jne     notace
        push    oui ;CE? str0 2 
        jmp     suitelikeace
notace:
        push    non
suitelikeace:
        mov     dx,fs
        push    edx          ;Emplacement memoire hex 2
;parent
        cmp     [gs:mb.reference],0
        jne     nextdetect
        push    cs
        push    none        ;parent lstr0 2x2 
        add     bx,[gs:mb.sizes]
        jmp     suitemn
nextdetect:
        mov     dx,[gs:mb.reference]
        dec     dx
        dec     dx
        push    dx                    ;parent lstr0 2x2 
        push    mb.names
suitemn:
        cmp     [gs: mb.isresident],true
        jne     notresident
        push    oui        ;resident str0 2 
        jmp     suitelistmcb
notresident:
        push    non     ;resident str0 2
suitelistmcb:
        xor     edx,edx
        mov     dx,[gs: mb.sizes]
        shl     edx,4
        push    6                    ;decimal 4 + type 2
        push    edx
        push    gs                   ;nom lstr0 2x2 
        push    mb.names
        push    line2         ;ligne
        invoke    print
        jmp     listmcb
fino:
        shl     ebx,4
        push    ebx
        push    fin
        invoke    print
        ret
oui db     "oui",0
non db     "non",0
line2   db      "%0P\h15| %w\h24| %0\h30| %0P\h47| 0x%hW\h57| %0\l",0
fin     db      "\l\l\c02%u octets de memoire disponible\l\c07",0
msg     db      "\l\c02Plan de la memoire\c07\l\lNom du bloc    | Taille | Res | Bloc parent    | Adresse | CE \l",0
none    db      "?????",0


;converti le jeux scancode/ascii en fr ax->ax
convertfr:
        push    dx si
        mov     si, fr
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
dw      str_getbuffer,code_getbuffer,syn_getbuffer,help_getbuffer
dw      str_setbuffer,code_setbuffer,syn_setbuffer,help_setbuffer
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
str_getbuffer db 'GETBUFFER',0
str_setbuffer db 'SETBUFFER',0

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
syn_getbuffer db 0
syn_setbuffer db 'FFh',0

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
help_getbuffer db 'Renvoi le contenu et la configuration des tampons disquette',0
help_setbuffer db 'Fixe la taille des tampons disquette',0

derror  db      '\c04Erreur de Syntaxe !',0
error_syntax db '\c04La commande ou l''executable n''existe pas ! F1 pour %0',0
prompt  db      '\c07>',0
msginit db      '\m02\e\c07\l\lInterpreteur de commande COS V1.11\lSous license \c05GPL\c07 - Ecrit par \c04MrNop\l\c07Utilisez la commande CMDS pour connaitres les commandes disponibles\l',0


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
use DISQUE,getbuffer
use DISQUE,setbuffer
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
