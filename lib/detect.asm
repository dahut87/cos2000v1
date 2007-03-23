model tiny,stdcall
p586
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\cpu.h"
include "..\include\pci.h"

org 0h

header exe <"CE",1,0,0,offset exports,,,>

exporting
declare cpuinfo
declare setinfo
declare pciinfo
declare getpciclass
declare getpcisubclass
declare getcardinfo
declare pcireadbyte
declare pcireadword
declare pcireaddword
declare detectvmware
ende
        
PROC detectvmware FAR
	USES	eax,ebx,ecx,edx
	mov	eax,564D5868h
	mov	ebx,12345h
	mov	ecx,00Ah
	mov	edx,5658h
	in	ax,dx
	cmp     ebx,564D5868h
	ret
endp detectvmware

;renvoie un pointer dx:ax vers la classe %0
PROC getpciclass FAR
        ARG     @class:word
        USES    di
        mov     di,[@class]
        and     di,0FFh
        shl     di,1
        mov     ax,[cs:offset classes+di]
        mov     dx,cs
        ret
endp getpciclass

;renvoie un pointer dx:ax vers la sous-classe de %1 et de classe %0
PROC getpcisubclass FAR
        ARG     @class:word,@subclass:word
        USES    di
        mov     di,[@class]
        and     di,0FFh
        shl     di,1
        mov     di,[cs:offset classesd+di]
        mov     dx,[@subclass]
        and     dx,0FFh
        cmp     dx,80h
        jne     @@suiteac
        mov     ax,offset divers
        jmp     @@found
@@suiteac:
        shl     dx,1
        add     di,dx
        mov     ax,[cs:di]
@@found:
        mov     dx,cs
        ret
endp getpcisubclass
        
divers db 'divers',0
        
classes:
dw offset class0
dw offset class1
dw offset class2
dw offset class3
dw offset class4
dw offset class5
dw offset class6
dw offset class7
dw offset class8
dw offset class9
dw offset class10
dw offset class11
dw offset class12
dw offset class13
dw offset class14
dw offset class15
dw offset class16
dw offset class17
class0 db 'ancien',0
class1 db 'stockage',0
class2 db 'reseau',0
class3 db 'affichage',0
class4 db 'multimedia',0
class5 db 'memoire',0
class6 db 'pont',0
class7 db 'communication',0
class8 db 'systeme',0
class9 db 'acquisition',0
class10 db 'dock',0
class11 db 'processeur',0
class12 db 'bus serie',0
class13 db 'sans fil',0
class14 db 'intelligent',0
class15 db 'satellite',0
class16 db 'cryptage',0
class17 db 'traitement signal',0


;Classes et sous classes
classesd:
dw offset class0d
dw offset class1d
dw offset class2d
dw offset class3d
dw offset class4d
dw offset class5d
dw offset class6d
dw offset class7d
dw offset class8d
dw offset class9d
dw offset class10d
dw offset class11d
dw offset class12d
dw offset class13d
dw offset class14d
dw offset class15d
dw offset class16d
dw offset class17d

class0d:
dw offset subclass00
dw offset subclass01
subclass00 db 'divers',0
subclass01 db 'vga',0

class1d:
dw offset subclass10
dw offset subclass11
dw offset subclass12
dw offset subclass13
dw offset subclass14
subclass10 db 'scsi',0
subclass11 db 'ide',0
subclass12 db 'disquette',0
subclass13 db 'ipi',0
subclass14 db 'raid',0

class2d:
dw offset subclass20
dw offset subclass21
dw offset subclass22
dw offset subclass23
dw offset subclass24
subclass20 db 'ethernet',0
subclass21 db 'token ring',0
subclass22 db 'fddi',0
subclass23 db 'atm',0
subclass24 db 'isdn',0

class3d:
dw offset subclass30
dw offset subclass31
dw offset subclass32
subclass30 db 'vga',0
subclass31 db 'xga',0
subclass32 db '3D',0

class4d:
dw offset subclass40
dw offset subclass41
dw offset subclass42
subclass40 db 'video',0
subclass41 db 'audio',0
subclass42 db 'telephonie',0

class5d:
dw offset subclass50
dw offset subclass51
subclass50 db 'ram',0
subclass51 db 'flash',0

class6d:
dw offset subclass60
dw offset subclass61
dw offset subclass62
dw offset subclass63
dw offset subclass64
dw offset subclass65
dw offset subclass66
dw offset subclass67
dw offset subclass68
subclass60 db 'hote',0
subclass61 db 'isa',0
subclass62 db 'eisa',0
subclass63 db 'mca',0
subclass64 db 'pci',0
subclass65 db 'pcmcia',0
subclass66 db 'nubus',0
subclass67 db 'cardbus',0
subclass68 db 'RACEway',0

class7d:
dw offset subclass70
dw offset subclass71
dw offset subclass72
dw offset subclass73
subclass70 db 'serie',0
subclass71 db 'parallele',0
subclass72 db 'serie multiport',0
subclass73 db 'modem',0

class8d:
dw offset subclass80
dw offset subclass81
dw offset subclass82
dw offset subclass83
dw offset subclass84
subclass80 db 'pic',0
subclass81 db 'dma',0
subclass82 db 'timer',0
subclass83 db 'rtc',0
subclass84 db 'hotplug',0

class9d:
dw offset subclass90
dw offset subclass91
dw offset subclass92
dw offset subclass93
dw offset subclass94
subclass90 db 'clavier',0
subclass91 db 'stylo',0
subclass92 db 'souris',0
subclass93 db 'scanner',0
subclass94 db 'joystick',0

class10d:
dw offset subclass100
subclass100 db 'station',0

class11d:
dw offset subclass110
dw offset subclass111
dw offset subclass112
dw offset subclass113
dw offset subclass114
subclass110 db '386',0
subclass111 db '486',0
subclass112 db 'pentium',0
subclass113 db 'alpha',0
subclass114 db 'coprocesseur',0

class12d:
dw offset subclass120
dw offset subclass121
dw offset subclass122
dw offset subclass123
dw offset subclass124
dw offset subclass125
subclass120 db 'firewire',0
subclass121 db 'access',0
subclass122 db 'ssa',0
subclass123 db 'usb',0
subclass124 db 'fibre',0
subclass125 db 'smbus',0

class13d:
dw offset subclass130
dw offset subclass131
dw offset subclass132
subclass130 db 'irda',0
subclass131 db 'ir',0
subclass132 db 'rf',0

class14d:
dw offset subclass140
subclass140 db 'IO arch',0

class15d:
dw offset subclass150
dw offset subclass151
dw offset subclass152
dw offset subclass153
subclass150 db 'tv',0
subclass151 db 'audio',0
subclass152 db 'voix',0
subclass153 db 'donnees',0

class16d:
dw offset subclass160
dw offset subclass161
subclass160 db 'reseau',0
subclass161 db 'jeux',0

class17d:
dw offset subclass170
subclass170 db 'dpio',0

        
;al=bus cl=deviceid ch=func es:di
PROC getcardinfo FAR
        ARG     @bus:word,@device:word,@function:word,@pointer:word
        USES    eax,bx,di
        mov     di,[@pointer]
        cmp     [@function],0
        je      @@amultiorfirst
        call    pcireadbyte,[@bus],[@device],0,offset (pcidata).typed
        and     al,multifunction
        cmp     al,0
        jne     @@amultiorfirst
        mov     [word ptr di],0000h
        jmp     @@notexist
@@amultiorfirst:
        xor     bx,bx
@@goinfos:
        call    pcireadword,[@bus],[@device],[@function],bx
        inc     bl
        inc     bl
        cmp     bl,2
        ja      @@notzarb
        cmp     ax,0FFFFh
        je      @@notexist
        cmp     ax,00000h
        je      @@notexist
@@notzarb:
        mov     [ds:di],ax
        inc     di
        inc     di
        cmp     bl,40h
        jbe     @@goinfos
        clc
        ret
@@notexist:
        stc
        ret
endp getcardinfo

;lit un octet du bus %0 device %1 function %2 nø %3 et le met en AL
PROC pcireadbyte FAR
        ARG     @bus:word,@device:word,@function:word,@pointer:word
        USES    bx,dx
        mov     al,[byte ptr @bus]
        mov     ah,80h
        shl     eax,16
        mov     ah,[byte ptr @device]
        shl     ah,3
        or      ah,[byte ptr @function]
        mov     bl,[byte ptr @pointer]
        mov     al,bl
        and     al,0fch
        mov     dx,config1addr
        out     dx,eax
        mov     dx,config1data
        and     bl,3
        or      dl,bl
        in      al,dx
        ret
endp pcireadbyte

;lit 2 octet du bus %0 device %1 function %2 nø %3 et le met en AX
PROC pcireadword FAR
        ARG     @bus:word,@device:word,@function:word,@pointer:word
        USES    bx,dx
        mov     al,[byte ptr @bus]
        mov     ah,80h
        shl     eax,16
        mov     ah,[byte ptr @device]
        shl     ah,3
        or      ah,[byte ptr @function]
        mov     bl,[byte ptr @pointer]
        mov     al,bl
        and     al,0fch
        mov     dx,config1addr
        out     dx,eax
        mov     dx,config1data
        and     bl,3
        or      dl,bl
        in      ax,dx
        ret
endp pcireadword

;lit 4 octet du bus %0 device %1 function %2 nø %3 et le met en EAX
PROC pcireaddword FAR
        ARG     @bus:word,@device:word,@function:word,@pointer:word
        USES    bx,dx
        mov     al,[byte ptr @bus]
        mov     ah,80h
        shl     eax,16
        mov     ah,[byte ptr @device]
        shl     ah,3
        or      ah,[byte ptr @function]
        mov     bl,[byte ptr @pointer]
        mov     al,bl
        and     al,0fch
        mov     dx,config1addr
        out     dx,eax
        mov     dx,config1data
        and     bl,3
        or      dl,bl
        in      eax,dx
        ret
endp pcireaddword          	

;Prob avec str pci
;renvoie en %0 la structure pciinf carry if error
PROC pciinfo FAR
        ARG     @pointer:word
        USES    ax,bx,cx,edx,edi
    	mov 	ax,0B101h
	xor	edi,edi
	mov	edx," PCI"
    	int 	1Ah
    	jc  	@@errorpci
    	cmp 	dx,04350h
    	jne 	@@errorpci
    	cmp     ah,0
    	jne     @@errorpci
    	mov     di,[@pointer]
    	mov     [(pciinf di).version_major],bh
    	mov     [(pciinf di).version_minor],bl
    	mov     [(pciinf di).types],al
    	mov     [(pciinf di).maxbus],cl    	
	clc
    	ret
@@errorpci:
    	stc 	
        ret
endp pciinfo

        
;retourne en DS:%1 les set supporté du processeur par rapport a la struct %0
PROC setinfo FAR
        ARG      @pointer:word,@set:word
        USES     bx,si,di
        mov      di,[@set]
        lea      si,[ds:cpu.mmx]
        add      si,[@pointer]
        mov      bx,offset @@theset
@@set:
        cmp      [word ptr cs:bx],0FFFFh
        je       @@endofset
        cmp      [byte ptr si],1
        jne      @@nextset
        push     bx
        mov      bx,[cs:bx]
@@put:
        mov      al,[cs:bx]
        cmp      al,0
        je       @@enofput
        mov      [di],al
        inc      bx
        inc      di
        jmp      @@put
@@enofput:
        pop      bx
 @@nextset:
        inc      bx
        inc      bx
        inc      si
        jmp      @@set
 @@endofset:
        mov      [byte ptr di],0
        ret
        
@@theset dw offset @@mmx
         dw offset @@mmx2
         dw offset @@sse
         dw offset @@sse2
         dw offset @@sse3
         dw offset @@fpu
         dw offset @@now3d
         dw offset @@now3d2
         dw offset @@htt
         dw offset @@apic
         dw 0FFFFh
         
@@mmx      db "MMX ",0
@@mmx2     db "MMX2 ",0
@@now3d    db "3dNow! ",0
@@now3d2   db "3dNow Extended! ",0
@@htt      db "HyperThreading",0
@@sse      db "SSE ",0
@@sse2     db "SSE2 ",0
@@sse3     db "SSE3 ",0
@@apic     db "APIC ",0
@@fpu      db "FPU ",0

endp setinfo
        
;retourne en DS:%0 les capacités du processeur
PROC cpuinfo FAR
        ARG      @pointer:word
        USES     eax,ebx,ecx,edx,si,di,ds,es
        push     ds
        pop      es
        mov      di,[@pointer]
        mov      al,0
        mov      cx,size cpu
        cld
        rep      stosb
        mov      di,[@pointer]
        call     nocpuid                                 ;Test si cpuid est dispo
        je       @@nocpuidatall
        xor      eax,eax
        cpuid                                        ;Fonction 0 de CPUID
        mov      [dword ptr (cpu di).vendor],ebx               ;Vendeur sur 13 octets
        mov      [dword ptr (cpu di+4).vendor],edx
        mov      [dword ptr (cpu di+8).vendor],ecx
        mov      [byte ptr (cpu di+12).vendor],0
        cmp      eax,1
        jb       @@nofonc1
        mov      eax,1
        cpuid                                        ;Fonction 1 de CPUID
        mov      ebx,eax                                  ;infos de model
        and      ebx,1111b
        mov      [(cpu di).stepping],bl
        shr      eax,4
        mov      ebx,eax
        and      ebx,1111b
        mov      [(cpu di).models],bl
        shr      eax,4
        mov      ebx,eax
        and      ebx,1111b
        mov      [(cpu di).family],bl
        shr      eax,4
        mov      ebx,eax
        and      ebx,11b
        mov      [(cpu di).types],bl
        shr      eax,2
        mov      ebx,eax
        and      ebx,1111b
        mov      [(cpu di).emodels],bl
        shr      eax,4
        mov      [(cpu di).efamily],al
        mov      ebx,edx
        and      ebx,1                                    ;infos de jeu d'instruction
        setnz    [(cpu di).fpu]
        mov      ebx,edx
        and      ebx,100000000000000000000000b
        setnz    [(cpu di).mmx]
        mov      ebx,edx
        and      ebx,10000000000000000000000000b
        setnz    [(cpu di).sse]
        mov      ebx,edx
        and      ebx,100000000000000000000000000b
        setnz    [(cpu di).sse2]
        mov      ebx,ecx
        and      ebx,1b
        setnz    [(cpu di).sse3]
        mov      ebx,edx
        and      ebx,10000000000000000000000000000b
        setnz    [(cpu di).htt]
@@nofonc1:
        mov      eax,80000000h                            ;Fonction 80000000 de CPUID
        cpuid
        cmp      eax,80000001h
        jb       @@nofonc8
        mov      eax,80000001h                            ;Fonction 80000000 de CPUID
        cpuid
        mov      ebx,edx
        and      ebx,10000000000000000000000b
        setnz    [(cpu di).mmx2]
        mov      ebx,edx
        and      ebx,1000000000000000000000000000000b
        setnz    [(cpu di).now3d]
        mov      ebx,edx
        and      ebx,10000000000000000000000000000000b
        setnz    [(cpu di).now3d2]
        mov      ebx,edx
        and      ebx,1000000000b
        setnz    [(cpu di).apic]
@@nofonc8:
        mov      si,offset @@marks
        push     cs
        pop      ds
@@search:
        mov      di,[@pointer]
        mov      cx,12
        cld
        rep      cmpsb
        jne      @@notthegood
        cmp      cx,0
        jne      @@notthegood
        mov      cl,[si]
        inc      si
        mov      di,[@pointer]
        cld
        rep      movsb
        mov      al,0
        stosb
        mov      di,[@pointer]
        cmp      [es:(cpu di).family],15
        jne      @@notextended
        mov      al,[es:(cpu di).efamily]
        mov      ah,[es:(cpu di).emodels]
        mov      di,[si+2]
        jmp      @@searchmodel
@@notextended:
        mov      al,[es:(cpu di).family]
        mov      ah,[es:(cpu di).models]
        mov      di,[si]
@@searchmodel:
        cmp      [di],ax
        jne      @@notgoodfamily
        mov      si,di
        inc      si
        inc      si
        lea      di,[es:cpu.names]
        add      di,[@pointer]
@@copystr:
        mov      al,[si]
        mov      [es:di],al
        inc      si
        inc      di
        cmp      al,0
        jne      @@copystr
        jmp      @@endofsearch
@@notgoodfamily:
        inc      di
@@nextelement:
        inc      di
        cmp      [byte ptr di-1],0
        jne      @@nextelement
        jmp      @@searchmodel
@@notthegood:
       inc       si
       cmp       [word ptr si],0FFFFh
       jne       @@notthegood
       inc       si
       inc       si
       cmp       [word ptr si],0FFFFh
       je        @@endofsearch
       jmp       @@search
@@endofsearch:
       ret
@@nocpuidatall:
       ret

;tableau avec vendeur taille + chainereelle + pointeur famille + pointeur famille etendue

@@marks db "GenuineIntel",5,"Intel"
        dw @@intelfamily,@@intelfamilye
        dw 0FFFFh

        db "AuthenticAMD",3,"Amd"
        dw @@amdfamily,@@amdfamilye
        dw 0FFFFh

        db "CyrixInstead",5,"Cyrix"
        dw @@cyrixfamily,@@cyrixfamilye
        dw 0FFFFh
        dw 0FFFFh


;tableau avec famille modele et chaine 0

@@intelfamily:
db 4,0,"486 DX-25/33",0
db 4,1,"486 DX-50",0
db 4,2,"486 SX",0
db 4,3,"486 DX/2",0
db 4,4,"486 SL",0
db 4,5,"486 SX/2",0
db 4,7,"486 DX/2-WB",0
db 4,8,"486 DX/4",0
db 4,9,"486 DX/4-WB",0
db 5,0,"Pentium 60/66 A-step",0
db 5,1,"Pentium 60/66",0
db 5,2,"Pentium 75 - 200",0
db 5,3,"OverDrive PODP5V83",0
db 5,4,"Pentium MMX",0
db 5,7,"Mobile Pentium 75-200",0
db 5,8,"Mobile Pentium MMX",0
db 6,0,"Pentium Pro A-step",0
db 6,1,"Pentium Pro",0
db 6,3,"Pentium II (Klamath)",0
db 6,5,"Pentium II (Deschutes)",0
db 6,6,"Mobile Pentium II",0
db 6,7,"Pentium III (Katmai)",0
db 6,8,"Pentium III (Coppermine)",0
db 6,9,"Mobile Pentium III",0
db 6,10,"Pentium III (0.18 µm)",0
db 6,11,"Pentium III (0.13 µm)",0
db 7,0,"Itanium (IA-64)",0
db 0FFh,0FFh,"Inconnu",0

@@intelfamilye:
db 0,0,"Pentium IV (0.18 µm)",0
db 0,1,"Pentium IV (0.18 µm)",0
db 0,2,"Pentium IV (0.13 µm)",0
db 0,3,"Pentium IV (0.09 µm)",0
db 1,0,"Itanium 2 (IA-64)",0
db 0FFh,0FFh,"Inconnu",0

@@amdfamily:
db 4,3,"486 DX/2",0
db 4,7,"486 DX/2-WB",0
db 4,8,"486 DX/4",0
db 4,9,"486 DX/4-WB",0
db 4,14,"Am5x86-WT",0
db 4,15,"Am5x86-WB",0
db 5,0,"K5/SSA5",0
db 5,1,"K5 (PR120/133)",0
db 5,2,"K5 (PR166)",0
db 5,3,"K5 (PR200)",0
db 5,6,"K6 (0.30 µm)",0
db 5,7,"K6 (0.25 µm)",0
db 5,8,"K6-2",0
db 5,9,"K6-3",0
db 5,13,"K6-2+/K6-III+ (0.18 µm)",0
db 6,0,"Athlon (25 µm)",0
db 6,1,"Athlon (25 µm)",0
db 6,2,"Athlon (18 µm)",0
db 6,3,"Duron",0
db 6,4,"Athlon (Thunderbird)",0
db 6,6,"Athlon (Palamino)",0
db 6,7,"Duron (Morgan)",0
db 6,8,"Athlon (Thoroughbred)",0
db 6,10,"Athlon (Barton)",0
db 0FFh,0FFh,"Inconnu",0

@@amdfamilye:
db 0,4,"Athlon 64",0
db 0,5,"Athlon 64 FX/Opteron",0
db 0FFh,0FFh,"Inconnu",0

@@cyrixfamily:
db 4,4,"MediaGX",0
db 5,2,"6x86/6x86L",0
db 5,4,"MediaGX MMX Enhanced",0
db 6,0,"MII (6x86MX)",0
db 6,5,"VIA Cyrix M2 core",0
db 6,6,"WinChip C5A",0
db 6,7,"WinChip C5B/WinChip C5C",0
db 6,8,"WinChip C5N",0
db 6,9,"WinChip C5XL/WinChip C5P",0
db 0FFh,0FFh,"Inconnu",0

@@cyrixfamilye:
db 0FFh,0FFh,"Inconnu",0

endp cpuinfo

;Test si CPUID est supporté oui=not Equal
nocpuid:
          pushfd
          pop      eax
          xor      eax,00200000h
          push     eax
          popfd
          pushfd
          pop      eax
          cmp      eax,ebx
          ret
          

