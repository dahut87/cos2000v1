.model tiny
.486
smart
.code

org 0h

include ..\include\pci.h
include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
call getpciinfos
mov [pciversion],bx
mov [nbbus],cl
mov [pcitype],al

xor edx,edx
mov dl,[nbbus]
inc dl
push edx
mov dx,[pciversion]
push edx
mov dx,[pciversion]
shr dx,8
push edx
push offset msg
call [print]

mov di,offset types
mov bx,7
mov al,pcitype
vote:
bt ax,bx
jnc nowas
shl bx,1
push word ptr [di+bx]
call [print]
shr bx,1
nowas:
dec bx
jns vote
push offset return
call [print]

xor ax,ax
xor cx,cx
mov si,offset infos
search:
mov di,si
call Getallfunctionsinfos
jc stopthis
mov dh,[si+pci.subclass]
mov dl,[si+pci.class]
;sousclasse
mov di,offset subclasse
call getpcisubclass
push di
;classe
mov di,offset classe
call getpciclass
push di
;fonction
mov dl,ch
push edx
;device
mov dl,cl
push edx
;bus
mov dl,al
push edx
;device
mov dx,[si+pci.device]
push edx
;vendeur
mov dx,[si+pci.vendor]
push edx

push offset msg2
call [print]

inc ch
cmp ch,7
jbe search
stopthis:
xor ch,ch
inc cl
cmp cl,31
jbe search
xor cl,cl
inc al
cmp al,16
jbe search
retf

msg db "COS2000 hardware detecteur V1.6\lBIOS PCI version %hB.%hB a ete detecte !\lNombre de bus : %u\lCaracterisques PCI: ",0
msg2 db "Peripherique :%hW Constructeur :%hW Id :%hB.%hB.%hB Classe :%0.%0\l",0
return db "\l",0
classe db 128 dup (0)
subclasse db 128 dup (0)

types 	dw	config1
	dw	config2
	dw    	null
	dw    	null
	dw	config3
	dw	config4	
	dw    	null
	dw	null
	
null       db 'indefini',0
config1    db 'Config Mechanism 1',0
config2    db 'Config Mechanism 2',0
config3    db 'Special Cycle Mechanism 1',0
config4    db 'Special Cycle Mechanism 2',0

PciVersion dw 0
Nbbus	     db 0
PciType    db 0
infos db 256 dup (0)

;fonction 0-7  bus 0-255   device 0-31

;renvoie en es:di de classe dl
getpciclass:
push ax cx dx si di ds es
push es
push di
mov di,dx
and di,0FFh
shl di,1
mov di,[offset classes+di]
mov cx,0FFh
mov al,0
push cs
pop es
repne scasb
sub cx,0FFh
neg cx
sub di,cx
mov si,di
push cs
pop ds
pop di
pop es
rep movsb
pop es ds di si dx cx ax
ret

;renvoie en es:di la sous-classe de dh et de classe dl
getpcisubclass:
push ax cx dx si di ds es
push es
push di
mov di,dx
and di,0FFh
shl di,1
mov di,[offset classesd+di]
xchg dh,dl
xor dh,dh
cmp dx,80h
jne suiteac
mov di,offset divers
jmp found
suiteac:
shl dx,1
add di,dx
mov di,[di]
found:
mov cx,0FFh
mov al,0
push cs
pop es
repne scasb
sub cx,0FFh
neg cx
sub di,cx
mov si,di
push cs
pop ds
pop di
pop es
rep movsb
pop es ds di si dx cx ax
ret
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
class0 db 'Ancien',0
class1 db 'Stockage',0
class2 db 'Reseau',0
class3 db 'Affichage',0
class4 db 'Multimedia',0
class5 db 'Memoire',0
class6 db 'Pont',0
class7 db 'Communication',0
class8 db 'Systeme',0
class9 db 'Acquisition',0
class10 db 'Dock',0
class11 db 'Processeur',0
class12 db 'Bus serie',0

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
subclass10 db 'scsi',0
subclass11 db 'ide',0
subclass12 db 'disquette',0
subclass13 db 'ipi',0

class2d:
dw offset subclass20
dw offset subclass21
dw offset subclass22
subclass20 db 'ethernet',0
subclass21 db 'token ring',0
subclass22 db 'fddi',0

class3d:
dw offset subclass30
dw offset subclass31
subclass30 db 'vga',0
subclass31 db 'xga',0

class4d:
dw offset subclass40
dw offset subclass41
subclass40 db 'video',0
subclass41 db 'audio',0

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
subclass60 db 'hote',0
subclass61 db 'isa',0
subclass62 db 'eisa',0
subclass63 db 'mca',0
subclass64 db 'pci',0
subclass65 db 'pcmcia',0
subclass66 db 'nubus',0
subclass67 db 'cardbus',0

class7d:
dw offset subclass70
dw offset subclass71
subclass70 db 'serie',0
subclass71 db 'parallele',0

class8d:
dw offset subclass80
dw offset subclass81
dw offset subclass82
subclass80 db 'pic',0
subclass81 db 'dma',0
subclass82 db 'timer',0

class9d:
dw offset subclass90
dw offset subclass91
dw offset subclass92
subclass90 db 'clavier',0
subclass91 db 'stylo',0
subclass92 db 'souris',0

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
subclass120 db 'firewire',0
subclass121 db 'access',0
subclass122 db 'ssa',0
subclass123 db 'usb',0
subclass124 db 'smbus',0

;bx pci version, cl nbbus, al pci type
getPciInfos:
	push 	dx
    	mov 	ax,0B101h
	xor	edi,edi
	mov	edx," PCI"
    	int 	1Ah
    	jc  	ErrorPci
    	cmp 	dx,04350h
    	jne 	ErrorPci
	clc
    	pop 	dx
    	ret
errorpci:
    	stc 
    	pop 	dx    	
      ret

;al=bus cl=deviceid ch=func es:di
Getallfunctionsinfos:
    push ax bx dx di
    cmp  ch,0
    je   amultiorfirst
    mov  bl,0Eh
    push cx
    xor  ch,ch
    call getfunctioninfo
    pop  cx
    and  dl,80h
    cmp  dl,0
    jne  amultiorfirst
    mov  word ptr [di],0000h
    jmp  notexist
amultiorfirst:
    xor bl,bl
goinfos:
    call getfunctioninfo
    inc  bl
    cmp  bl,2
    ja   notzarb
    cmp  dl,0FFh
    je   notexist
notzarb:
    mov  es:[di],dl
    inc  di
    cmp  bl,255
    jb   goinfos 
    pop  di
    push di
    cmp  word ptr [di],0000h
    je   notexist
    clc
    pop di dx bx ax
    ret
notexist:
    stc
    pop di dx bx ax
    ret
    
    ; PCI TYPE 1
;*******************************************************************
config1_addr	equ 0CF8h
config1_data	equ 0CFCh

pci_type1_detect:
                 mov     dx, config1_addr+3
                 mov     al, 01h
                 out     dx,al
                 mov     dx,config1_addr
	         in      eax,dx
	         mov     ecx,eax
		 mov     eax,80000000h
		 out     dx,eax
		 in      eax,dx
		 cmp     eax,80000000h
		 jne     endofdetectiontype1
		 mov     eax,ecx
		 out     dx,eax
endofdetectiontype1:		
		 ret

                 ;al=bus bl=index cl=deviceid ch=func->dl
getfunctioninfo:
    push eax bx cx
    mov ah,80h
    shl eax,16
    mov ah,cl
    shl ah,3
    or ah,ch
    mov al,bl
    and al,0fch
    mov dx,0cf8h
    out dx,eax
    mov dx,0CFCh
    and bl,3
    or  dl,bl
    in  al,dx
    mov dl,al
    pop cx bx eax
    ret	


; PCI TYPE 2
;*******************************************************************
config2_reg0	equ 0CFBh
config2_reg1	equ 0CF8h
config2_reg2    equ 0CFAh

pci_type2_detect:
                 xor     ax,ax
                 mov     dx,config2_reg0
                 out     dx,ax
                 mov     dx,config2_reg1
                 out     dx,ax
                 mov     dx,config2_reg2
                 out     dx,ax
                 mov     ax,config2_reg1
                 in      al,dx
                 cmp     al,0
                 jne     endofdetectiontype2
                 mov     ax,config2_reg0
                 in      al,dx
                 cmp     al,0
                 jne     endofdetectiontype2
endofdetectiontype2:
                    ret
                    
imports:
        db "VIDEO.LIB::print",0
print   dd 0
        dw 0

end start
