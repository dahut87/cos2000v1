.model tiny
.486
smart
.code

org 0100h

include ..\include\pci.h

start:
call getpciinfos
mov pciversion,bx
mov nbbus,cl
mov pcitype,al

mov si,offset msg
mov ah,13
int 47h
mov ah,6
int 47h

mov si,offset pcivers
mov ah,13
int 47h
xor edx,edx
mov dx,bx
xchg dl,dh
mov cx,8
mov ah,0Ah
int 47h
mov si,offset poin
mov ah,13
int 47h
shr dx,8
mov ah,0Ah
int 47h
mov si,offset pcivers2
mov ah,13
int 47h
mov ah,6
int 47h

mov si,offset nbbuses
mov ah,13
int 47h
xor edx,edx
mov dl,nbbus
inc dl
mov ah,08
int 47h
mov ah,06
int 47h

mov si,offset typesof
mov ah,13
int 47h
mov di,offset types
mov bx,7
mov al,pcitype
vote:
bt ax,bx
jnc nowas
shl bx,1
mov si,[di+bx]
mov ah,13
int 47h
mov si,offset spac
mov ah,13
int 47h
shr bx,1
nowas:
dec bx
jns vote
mov ah,6
int 47h

xor ax,ax
xor cx,cx
mov di,offset infos
search:
call Getallfunctionsinfos
jc stopthis

push cx di
mov si,offset msg1
mov ah,13
int 47h
mov cx,16
xor edx,edx
mov dx,[di+pci.device]
mov ah,0Ah
int 47h
mov si,offset msg2
mov ah,13
int 47h
mov dx,[di+pci.vendor]
mov ah,0Ah
int 47h
mov si,offset msg3
mov ah,13
int 47h
mov cl,[di+pci.class]
mov ch,[di+pci.subclass]
mov di,offset temp
call getpciclass
mov si,di
mov ah,13
int 47h
mov si,offset poin
mov ah,13
int 47h
mov di,offset temp
call getpcisubclass
mov si,di
mov ah,13
int 47h
mov ah,06
int 47h
pop di cx

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
xor ax,ax
int 16h
db 0CBh

msg3 db ' Classe:',0
msg1 db 'Peripherique :',0
msg2 db ' Constructeur :',0 
msg db 'COS2000 hardware detecteur V1.1',0
pcivers  db 'BIOS PCI version ',0
pcivers2 db ' a ete detecte !',0
nbbuses db 'Nombre de bus : ',0
typesof db 'Caracterisques PCI: ',0
poin db '.',0
virg db ', ',0
spac db ' ',0
temp db 128 dup (0)

types 	dw	config1
	dw	config2
	dw    	poin
	dw    	poin
	dw	config3
	dw	config4	
	dw    	poin
	dw	poin
  
config1    db 'Config Mechanism 1',0
config2    db 'Config Mechanism 2',0
config3    db 'Special Cycle Mechanism 1',0
config4    db 'Special Cycle Mechanism 2',0

PciVersion dw 0
Nbbus	     db 0
PciType    db 0
infos db 256 dup (0)

;fonction 0-7  bus 0-255   device 0-31

;renvoie en es:di de classe cl
getpciclass:
push ax cx si di ds es
push es
push di
mov di,cx
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
pop es ds di si cx ax 
ret

;renvoie en es:di la sous-classe de ch et de classe cl
getpcisubclass:
push ax cx si di ds es
push es
push di
mov di,cx
and di,0FFh
shl di,1
mov di,[offset classesd+di]
xchg ch,cl
xor ch,ch
cmp cx,80h
jne suiteac
mov di,offset divers
jmp found
suiteac:
shl cx,1
add di,cx
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
pop es ds di si cx ax 
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
subclass63 db 'mc',0
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
subclass80 db 'pic 8259a',0
subclass81 db 'dma 8237',0
subclass82 db 'tim 8254',0

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
subclass120 db 'firewire',0
subclass121 db 'access',0
subclass122 db 'ssa',0
subclass123 db 'usb',0

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

;al=bus cl=deviceid ch=func es:di
Getallfunctionsinfos:
    push ax bx dx di
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

end start
