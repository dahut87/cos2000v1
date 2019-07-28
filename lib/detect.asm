use16
align 1

include "..\include\mem.h"
include "..\include\cpu.h"
include "..\include\pci.h"

org 0h

header exe 1,exports,0,0,0

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
        
proc detectvmware uses eax ebx ecx edx	
	mov	eax,564D5868h
	mov	ebx,12345h
	mov	ecx,00Ah
	mov	edx,5658h
	in	ax,dx
	cmp     ebx,564D5868h
	ret
endp

;renvoie un pointer dx:ax vers la classe %0
proc getpciclass uses di, class:word
        mov     di,[class]
        and     di,0FFh
        shl     di,1
        mov     ax,[cs:classes+di]
        mov     dx,cs
        ret
endp

;renvoie un pointer dx:ax vers la sous-classe de %1 et de classe %0
proc getpcisubclass uses di, class:word,subclass:word
        mov     di,[class]
        and     di,0FFh
        shl     di,1
        mov     di,[cs:classesd+di]
        mov     dx,[subclass]
        and     dx,0FFh
        cmp     dx,80h
        jne     .suiteac
        mov     ax,divers
        jmp     .found
.suiteac:
        shl     dx,1
        add     di,dx
        mov     ax,[cs:di]
.found:
        mov     dx,cs
        ret
endp
        
divers db 'divers',0
        
classes:
dw class0
dw class1
dw class2
dw class3
dw class4
dw class5
dw class6
dw class7
dw class8
dw class9
dw class10
dw class11
dw class12
dw class13
dw class14
dw class15
dw class16
dw class17
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
dw class0d
dw class1d
dw class2d
dw class3d
dw class4d
dw class5d
dw class6d
dw class7d
dw class8d
dw class9d
dw class10d
dw class11d
dw class12d
dw class13d
dw class14d
dw class15d
dw class16d
dw class17d

class0d:
dw subclass00
dw subclass01
subclass00 db 'divers',0
subclass01 db 'vga',0

class1d:
dw subclass10
dw subclass11
dw subclass12
dw subclass13
dw subclass14
subclass10 db 'scsi',0
subclass11 db 'ide',0
subclass12 db 'disquette',0
subclass13 db 'ipi',0
subclass14 db 'raid',0

class2d:
dw subclass20
dw subclass21
dw subclass22
dw subclass23
dw subclass24
subclass20 db 'ethernet',0
subclass21 db 'token ring',0
subclass22 db 'fddi',0
subclass23 db 'atm',0
subclass24 db 'isdn',0

class3d:
dw subclass30
dw subclass31
dw subclass32
subclass30 db 'vga',0
subclass31 db 'xga',0
subclass32 db '3D',0

class4d:
dw subclass40
dw subclass41
dw subclass42
subclass40 db 'video',0
subclass41 db 'audio',0
subclass42 db 'telephonie',0

class5d:
dw subclass50
dw subclass51
subclass50 db 'ram',0
subclass51 db 'flash',0

class6d:
dw subclass60
dw subclass61
dw subclass62
dw subclass63
dw subclass64
dw subclass65
dw subclass66
dw subclass67
dw subclass68
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
dw subclass70
dw subclass71
dw subclass72
dw subclass73
subclass70 db 'serie',0
subclass71 db 'parallele',0
subclass72 db 'serie multiport',0
subclass73 db 'modem',0

class8d:
dw subclass80
dw subclass81
dw subclass82
dw subclass83
dw subclass84
subclass80 db 'pic',0
subclass81 db 'dma',0
subclass82 db 'timer',0
subclass83 db 'rtc',0
subclass84 db 'hotplug',0

class9d:
dw subclass90
dw subclass91
dw subclass92
dw subclass93
dw subclass94
subclass90 db 'clavier',0
subclass91 db 'stylo',0
subclass92 db 'souris',0
subclass93 db 'scanner',0
subclass94 db 'joystick',0

class10d:
dw subclass100
subclass100 db 'station',0

class11d:
dw subclass110
dw subclass111
dw subclass112
dw subclass113
dw subclass114
subclass110 db '386',0
subclass111 db '486',0
subclass112 db 'pentium',0
subclass113 db 'alpha',0
subclass114 db 'coprocesseur',0

class12d:
dw subclass120
dw subclass121
dw subclass122
dw subclass123
dw subclass124
dw subclass125
subclass120 db 'firewire',0
subclass121 db 'access',0
subclass122 db 'ssa',0
subclass123 db 'usb',0
subclass124 db 'fibre',0
subclass125 db 'smbus',0

class13d:
dw subclass130
dw subclass131
dw subclass132
subclass130 db 'irda',0
subclass131 db 'ir',0
subclass132 db 'rf',0

class14d:
dw subclass140
subclass140 db 'IO arch',0

class15d:
dw subclass150
dw subclass151
dw subclass152
dw subclass153
subclass150 db 'tv',0
subclass151 db 'audio',0
subclass152 db 'voix',0
subclass153 db 'donnees',0

class16d:
dw subclass160
dw subclass161
subclass160 db 'reseau',0
subclass161 db 'jeux',0

class17d:
dw subclass170
subclass170 db 'dpio',0

        
;al=bus cl=deviceid ch=func es:di
proc getcardinfo uses eax bx di, bus:word,device:word,function:word,pointer:word 
        mov     di,[pointer]
        cmp     [function],0
        je      .amultiorfirst
        stdcall    pcireadbyte,[bus],[device],0,pcidata.typed
        and     al,multifunction
        cmp     al,0
        jne     .amultiorfirst
        mov     word [di],0000h
        jmp     .notexist
.amultiorfirst:
        xor     bx,bx
.goinfos:
        stdcall    pcireadword,[bus],[device],[function],bx
        inc     bl
        inc     bl
        cmp     bl,2
        ja      .notzarb
        cmp     ax,0FFFFh
        je      .notexist
        cmp     ax,00000h
        je      .notexist
.notzarb:
        mov     [ds:di],ax
        inc     di
        inc     di
        cmp     bl,40h
        jbe     .goinfos
        clc
        ret
.notexist:
        stc
        ret
endp

;lit un octet du bus %0 device %1 function %2 nø %3 et le met en AL
proc pcireadbyte uses bx dx, bus:word,device:word,function:word,pointer:word    
        mov     al,byte [bus]
        mov     ah,80h
        shl     eax,16
        mov     ah,byte [device]
        shl     ah,3
        or      ah,byte [function]
        mov     bl,byte [pointer]
        mov     al,bl
        and     al,0fch
        mov     dx,config1addr
        out     dx,eax
        mov     dx,config1data
        and     bl,3
        or      dl,bl
        in      al,dx
        ret
endp

;lit 2 octet du bus %0 device %1 function %2 nø %3 et le met en AX
proc pcireadword uses bx dx, bus:word,device:word,function:word,pointer:word    
        mov     al,byte [bus]
        mov     ah,80h
        shl     eax,16
        mov     ah,byte [device]
        shl     ah,3
        or      ah,byte [function]
        mov     bl,byte [pointer]
        mov     al,bl
        and     al,0fch
        mov     dx,config1addr
        out     dx,eax
        mov     dx,config1data
        and     bl,3
        or      dl,bl
        in      ax,dx
        ret
endp

;lit 4 octet du bus %0 device %1 function %2 nø %3 et le met en EAX
proc pcireaddword uses bx dx, bus:word,device:word,function:word,pointer:word
        mov     al,byte [bus]
        mov     ah,80h
        shl     eax,16
        mov     ah,byte [device]
        shl     ah,3
        or      ah,byte [function]
        mov     bl,byte [pointer]
        mov     al,bl
        and     al,0fch
        mov     dx,config1addr
        out     dx,eax
        mov     dx,config1data
        and     bl,3
        or      dl,bl
        in      eax,dx
        ret
endp          	

;Prob avec str pci
;renvoie en %0 la structure pciinf carry if error
proc pciinfo uses ax bx cx edx edi, pointer:word
    	mov 	ax,0B101h
	xor	edi,edi
	mov	edx," PCI"
    	int 	1Ah
    	jc  	.errorpci
    	cmp 	dx,04350h
    	jne 	.errorpci
    	cmp     ah,0
    	jne     .errorpci
    	mov     di,[pointer]
	virtual at di
  		.pciinf pciinf
	end virtual
    	mov     [.pciinf.version_major],bh
    	mov     [.pciinf.version_minor],bl
    	mov     [.pciinf.types],al
    	mov     [.pciinf.maxbus],cl    	
	clc
    	ret
.errorpci:
    	stc 	
        ret
endp

        
;retourne en DS:%1 les set supporté du processeur par rapport a la struct %0
proc setinfo uses bx si di, pointer:word,set:word     
        mov      di,[set]
        lea      si,[ds:cpu.mmx]
        add      si,[pointer]
        mov      bx,.theset
.set:
        cmp      word [cs:bx],0FFFFh
        je       .endofset
        cmp      byte [si],1
        jne      .nextset
        push     bx
        mov      bx,[cs:bx]
.put:
        mov      al,[cs:bx]
        cmp      al,0
        je       .enofput
        mov      [di],al
        inc      bx
        inc      di
        jmp      .put
.enofput:
        pop      bx
 .nextset:
        inc      bx
        inc      bx
        inc      si
        jmp      .set
 .endofset:
        mov      byte [di],0
        ret
        
.theset dw .mmx
         dw .mmx2
         dw .sse
         dw .sse2
         dw .sse3
         dw .fpu
         dw .now3d
         dw .now3d2
         dw .htt
         dw .apic
         dw 0FFFFh
         
.mmx      db "MMX ",0
.mmx2     db "MMX2 ",0
.now3d    db "3dNow! ",0
.now3d2   db "3dNow Extended! ",0
.htt      db "HyperThreading",0
.sse      db "SSE ",0
.sse2     db "SSE2 ",0
.sse3     db "SSE3 ",0
.apic     db "APIC ",0
.fpu      db "FPU ",0

endp
        
;retourne en DS:%0 les capacités du processeur
proc cpuinfo uses eax ebx ecx edx si di ds es, pointer:word
        push     ds
        pop      es
        mov      di,[pointer]
        mov      al,0
        mov      cx,cpu.sizeof
        cld
        rep      stosb
        mov      di,[pointer]
        call     nocpuid                                 ;Test si cpuid est dispo
        je       .nocpuidatall
        xor      eax,eax
        cpuid                                        ;Fonction 0 de CPUID
        mov      dword [cpu.vendor],ebx               ;Vendeur sur 13 octets
        mov      dword [cpu.vendor+4],edx
        mov      dword [cpu.vendor+8],ecx
        mov      byte [cpu.vendor+12],0
        cmp      eax,1
        jb       .nofonc1
        mov      eax,1
        cpuid                                        ;Fonction 1 de CPUID
        mov      ebx,eax                                  ;infos de model
        and      ebx,1111b
        mov      [cpu.stepping],bl
        shr      eax,4
        mov      ebx,eax
        and      ebx,1111b
        mov      [cpu.models],bl
        shr      eax,4
        mov      ebx,eax
        and      ebx,1111b
        mov      [cpu.family],bl
        shr      eax,4
        mov      ebx,eax
        and      ebx,11b
        mov      [cpu.types],bl
        shr      eax,2
        mov      ebx,eax
        and      ebx,1111b
        mov      [cpu.emodels],bl
        shr      eax,4
        mov      [cpu.efamily],al
        mov      ebx,edx
        and      ebx,1                                    ;infos de jeu d'instruction
        setnz    [cpu.fpu]
        mov      ebx,edx
        and      ebx,100000000000000000000000b
        setnz    [cpu.mmx]
        mov      ebx,edx
        and      ebx,10000000000000000000000000b
        setnz    [cpu.sse]
        mov      ebx,edx
        and      ebx,100000000000000000000000000b
        setnz    [cpu.sse2]
        mov      ebx,ecx
        and      ebx,1b
        setnz    [cpu.sse3]
        mov      ebx,edx
        and      ebx,10000000000000000000000000000b
        setnz    [cpu.htt]
.nofonc1:
        mov      eax,80000000h                            ;Fonction 80000000 de CPUID
        cpuid
        cmp      eax,80000001h
        jb       .nofonc8
        mov      eax,80000001h                            ;Fonction 80000000 de CPUID
        cpuid
        mov      ebx,edx
        and      ebx,10000000000000000000000b
        setnz    [cpu.mmx2]
        mov      ebx,edx
        and      ebx,1000000000000000000000000000000b
        setnz    [cpu.now3d]
        mov      ebx,edx
        and      ebx,10000000000000000000000000000000b
        setnz    [cpu.now3d2]
        mov      ebx,edx
        and      ebx,1000000000b
        setnz    [cpu.apic]
.nofonc8:
        mov      si,.marks
        push     cs
        pop      ds
.search:
        mov      di,[pointer]
        mov      cx,12
        cld
        rep      cmpsb
        jne      .notthegood
        cmp      cx,0
        jne      .notthegood
        mov      cl,[si]
        inc      si
        mov      di,[pointer]
        cld
        rep      movsb
        mov      al,0
        stosb
        mov      di,[pointer]
        cmp      [es:cpu.family],15
        jne      .notextended
        mov      al,[es:cpu.efamily]
        mov      ah,[es:cpu.emodels]
        mov      di,[si+2]
        jmp      .searchmodel
.notextended:
        mov      al,[es:cpu.family]
        mov      ah,[es:cpu.models]
        mov      di,[si]
.searchmodel:
        cmp      [di],ax
        jne      .notgoodfamily
        mov      si,di
        inc      si
        inc      si
        lea      di,[es:cpu.names]
        add      di,[pointer]
.copystr:
        mov      al,[si]
        mov      [es:di],al
        inc      si
        inc      di
        cmp      al,0
        jne      .copystr
        jmp      .endofsearch
.notgoodfamily:
        inc      di
.nextelement:
        inc      di
        cmp      byte [di-1],0
        jne      .nextelement
        jmp      .searchmodel
.notthegood:
       inc       si
       cmp       word [si],0FFFFh
       jne       .notthegood
       inc       si
       inc       si
       cmp       word [si],0FFFFh
       je        .endofsearch
       jmp       .search
.endofsearch:
       ret
.nocpuidatall:
       ret

;tableau avec vendeur taille + chainereelle + pointeur famille + pointeur famille etendue

.marks db "GenuineIntel",5,"Intel"
        dw .intelfamily,.intelfamilye
        dw 0FFFFh

        db "AuthenticAMD",3,"Amd"
        dw .amdfamily,.amdfamilye
        dw 0FFFFh

        db "CyrixInstead",5,"Cyrix"
        dw .cyrixfamily,.cyrixfamilye
        dw 0FFFFh
        dw 0FFFFh


;tableau avec famille modele et chaine 0

.intelfamily:
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

.intelfamilye:
db 0,0,"Pentium IV (0.18 µm)",0
db 0,1,"Pentium IV (0.18 µm)",0
db 0,2,"Pentium IV (0.13 µm)",0
db 0,3,"Pentium IV (0.09 µm)",0
db 1,0,"Itanium 2 (IA-64)",0
db 0FFh,0FFh,"Inconnu",0

.amdfamily:
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

.amdfamilye:
db 0,4,"Athlon 64",0
db 0,5,"Athlon 64 FX/Opteron",0
db 0FFh,0FFh,"Inconnu",0

.cyrixfamily:
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

.cyrixfamilye:
db 0FFh,0FFh,"Inconnu",0

endp

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
          

