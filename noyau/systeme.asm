.model tiny
.486
smart
.code

org 0100h

include ..\include\fat.h

start:
push cs
push cs
push cs
push cs
pop ds
pop es
pop fs
pop gs
	;xor 	ax,ax
	;mov 	ds,ax
	;mov 	si,7C00h
mov si,offset eepop
	mov 	di,offset myboot
	mov 	cx,type bootsector
	push 	cs
	pop 	es
	rep 	movsb
jmp noone

eepop db 0,0,0
bootdb  db     'COS2000A'                ;Fabricant + n�s�rie Formatage
sizec   dw      512                      ;octet/secteur
        db      1                        ;secteur/cluster
reserv  dw      1                        ;secteur reserv�
nbfat   db      2                        ;nb de copie de la FAT
nbfit   dw      224                      ;taille rep racine
allclu  dw      2880                     ;nb secteur du volume si < 32 m�g
        db      0F0h                     ;Descripteur de m�dia
fatsize dw      9                        ;secteur/FAT
nbtrack dw      18                       ;secteur/piste       
head    dw      2                        ;nb de t�teb de lecture/�criture
hidden  dd      0                        ;nombre de secteur cach�s
        dd      0                        ;si nbsecteur = 0 nbsect                                       ; the number of sectors
bootdrv db      0                        ;Lecteur de d�marrage
bootsig db      0                        ;NA
        db      29h                      ;boot signature 29h
bootsig2 dd     01020304h                ;no de serie
pope    db      'COS2000    '            ;nom de volume
        db      'FAT12   '               ;FAT


	xor ax,ax
	mov es,ax
	mov di,1Eh*4
	lds si,es:[di]
	mov es:[di],cs
	mov word ptr es:[di],offset myDPT
	push cs
	pop es
	mov cx,type DPT
	rep movsb
	mov ax,cs:[Bootsector.SectorsPerTrack]
	mov es:[DPT.SectorPerTracks],al    
noone:
	push 	cs
	push 	cs
	push 	cs
	push 	cs
	pop 	ds
	pop 	es
	pop 	fs
	pop 	gs

	call 	InitDrive

	mov	si,offset premice
	mov	bx,7
	call	showstr
	mov	si,offset next
	call	showstr
	mov	si,offset conf
	call	showstr
	mov	al,0
	mov	cx,2000
	mov	di,offset loadinglist
	rep	stosb
	mov	di,offset loadinglist
	call	loadfile
	jc 	noconfread

	mov	si,offset debut
	mov	bx,7
	call	showstr
	mov	bx,500h
	xor	cx,cx
	mov  	si,offset loadinglist
suiteloading:
	call 	readline
	jc	noconfload
	push	bx si
	mov	bl,7
	mov	si,offset next
	call	showstr
	pop	si bx
	call	showstr
	mov	dx,bx
	push	bx si
	mov	bx,7
	mov	si,offset address
	call	showstr
	mov	cx,16
	call	showhex
	mov	si,offset addressend
	call	showstr
	xor	bp,bp
	mov	dx,ax
	cmp	ax,8h
	jb	noadder
	cmp	ax,10h
	ja	noadder
	mov	bp,1	
	sub	dx,8
	jmp	haveirq
noadder:
	cmp	ax,70h
	jb	noadd
	cmp	ax,78h
	ja	noadd
	mov	bp,1
	sub	dx,68h
haveirq:
	mov	si,offset irqs
	call	showstr
	mov	cx,4
	call	showhex
	mov	si,offset irqsend
	call	showstr
noadd:
	pop	si bx
	cmp	bp,1
	jne	install
	call	replacehandler
	jmp	suites
install:
	call 	installhandler
suites:	
	jc 	nohandlerload
	add	bx,0F00h
	inc	cx
	call 	nextline
	jnz 	suiteloading

	mov	si,offset fini
	mov	bl,7
	call	showstr
	mov	si,offset next
	call	showstr
	mov	si,offset prompt
	call	showstr
	mov     ax,6000h
      	mov     es,ax
        push    ax
        mov     di,0100h
        push    di
	call 	loadfile
	jc	nopromptload
        push    7202h
        popf
	push	es
	push	es
	push	es
	pop	ds
	pop	fs
	pop	gs
        db      0CBh

nopromptload:
	mov	si,offset prompte
	mov	bl,4
	call	showstr
	jmp	erroron

nohandlerload:
	mov	si,offset handlere
	mov	bl,4
	call	showstr
	jmp	erroron

noconfread:
	mov	si,offset confee
	mov	bl,4
	call	showstr
	jmp	erroron

noconfload:
	mov	di,si
	mov	si,offset confe
	mov	bl,4
	call	showstr
	mov	dx,cx
	mov	cx,16
	call	showhex
	mov	si,offset confe2
	mov	bl,3
	call	showstr
	mov	dx,di
	mov	cx,16
	call	showhex

erroron:
	push 	cs
	pop 	ds
	mov 	si,offset erreur
	mov 	bl,4
	call 	showstr
	mov 	ax,0
	int 	16h
	push 	0FFFFh
	push 	0
	db 	0CBh

address db ' [',0
addressend db ':0100] ',0
irqs db ' (IRQ ',0
irqsend db ')',0
prompt db 'commande.exe',0
conf db 'systeme.ini',0
premice 	db 0Dh,0Ah,'Chargement du fichier de configuration:',0
debut 	db 0Dh,0Ah,'Chargement des pilotes systeme:',0
fini	db 0Dh,0Ah,'Chargement de l''interpreteur de commande:',0
next db 0Dh,0Ah,'   - ',0
prompte db 0Dh,0Ah,'Erreur lors du chargement de l''interpreteur',0
handlere db 0Dh,0Ah,'Erreur lors du chargement des pilotes',0
confe db 0Dh,0Ah,'Erreur dans le fichier de configuration a la ligne ',0
confee db 0Dh,0Ah,'Erreur de lecture du fichier de configuration',0
confe2 db ' caractere ',0
erreur 	db 0Dh,0Ah,'Pressez une touche pour redemarrer...',0

;==positionne si sur l'entr�e suivante de la loading liste jusqu'a equal
nextline:
push ax cx di
mov di,si
mov al,0Ah
mov cx,20
repnz scasb
mov si,di
cmp byte ptr [di],0
pop di cx ax
ret

;==Lit la loading list et initialise SI(Fichier) BX(adresse) AX(interruption)
readline:
push cx dx di es
push ds
pop es
;Voir taille de la ligne -> DX
mov di,si
mov al,0Dh
mov cx,20
repne scasb
sub cx,20
neg cx
mov dx,cx
;N� interruption ??
mov di,si
mov al,'('
repne scasb
jne noaddr
;Non, je recherche l'int positionnement parenthese de fin
mov al,')'
repne scasb
jne errorlist
;Je lit l'interruption dans DL
xor dl,dl
xor cx,cx
dec di
readingint:
dec di
mov al,[di]
cmp al,'('
je finishint
call eval
jc errorlist
shl ax,cl
add dl,al
add cx,4
cmp cx,8
ja errorlist
jmp readingint
noaddr:
dec di
mov dl,0
finishint:
;mise d'un 0 a la fin du nom
mov byte ptr [di],0
mov al,dl
pop es di dx cx
clc
ret
errorlist:
sub di,si
mov si,di
pop es di dx cx
stc
ret


;return carry si pas hexa pour al et renvoie dans al la valeur d�cimale
eval:
push si
xor si,si 
searchex:
cmp al,cs:[si+offset hexas]
je endsearchex
inc si
cmp si,15
jbe searchex
pop si
stc
ret
endsearchex:
mov ax,si
pop si
clc
ret

hexas db '0123456789ABCDEF',0

;==============================Affiche le nombre nb hexa en EDX de taille CX et couleur BL==============
ShowHex:
        push    ax bx cx edx si di
        mov     di,cx
        sub     cx,32
        neg     cx
        shl     edx,cl
        shr     di,2
        mov 	ah,0Eh
        and 	bx,1111b
Hexaize:
        rol     edx,4
        mov     si,dx
	and	si,1111b
	mov	al,[si+offset tab]
        int 	10h
        dec     di
        jnz     Hexaize
        pop     di si edx cx bx ax
        ret
Tab db '0123456789ABCDEF'

;==============================Affiche une chaine DS:SI de couleur BL==============
showstr:
        push ax bx si
again:
        lodsb
        or al,al
        jz fin
        mov ah,0Eh
        and bx,1111b
        int 10h
        jmp again
        fin:
        pop si bx ax
        ret

;================================================
;Routine de gestion de handler
;================================================

;remplace le handler pointer par ds:si en bx:100h interruption ax
replacehandler:
push ax bx cx si di ds es
mov es,bx
mov di,0100h
call loadfile
jc reph
mov bx,ax
call getint
mov es:[102h],si
mov es:[104h],ds
call setint
reph:
pop es ds di si cx bx ax
ret
      
;install le handler pointer par ds:si en bx:100h interruption ax
installhandler:
push bx cx di es
mov es,bx
mov di,100h
call loadfile
jc insh
mov bx,ax
call setint
insh:
pop es di cx bx
ret
                              
;met es:di le handle de l'int bx
setint:
push ax bx ds
cli
shl bx,2
xor ax,ax
mov ds,ax
mov ds:[bx],di
mov ds:[bx+2],es
pop ds bx ax
sti
ret

;met ds:si le handle de l'int bx
getint:
push ax bx es
shl bx,2
xor ax,ax
mov es,ax
mov si,es:[bx]
mov ds,es:[bx+2]
pop es bx ax
ret 

;================================================
;Routine de gestion de systeme de fichier FAT12
;================================================

;DPT disquette 
mydpt DPT ?

;Secteur de boot
myboot bootSector ?

;Donn�es Calcul�e
clustersize		dw	0
TracksPerHead 		dw 	0
DriveSize         	dd     	0
AdressBoot		dw	0
AdressFat		dw	0
AdressParent      	dw     	0
AdressData		dw	0 
AddingValue		dw     	0
CurrentDir		dw	0 ;En cluster
CurrentDirStr		db      128 dup (0)

;Pour recherches
EntryPlace		dw	0 ;En octet
AdressDirectory		dw	0 ;En cluster
firstsearch		dw	1 ;Premiere requete ?

getfat:
	push  	ax bx dx si
	mov	ax,cx
	mov	bx,ax
	and   	bx,0000000000000001b
	shr   	ax,1
	mov   	cx,3
	mul   	cx
	mov   	si,offset bufferfat
	add   	si,ax
	cmp   	bx,0h
	jnz   	evenfat
oddfat:	
	mov	dx,cs:[si]
      	and   	dx,0FFFh
    	mov   	cx,dx
      	jmp   	endfat
evenfat:
      	mov   	dx,cs:[si+1]
      	and   	dx,0FFF0h
      	shr   	dx,4
      	mov   	cx,dx
endfat:
	cmp	dx,0FF0h
	jbe	nocarry
	stc
	pop 	si dx bx ax
	ret
nocarry:
	clc
	pop 	si dx bx ax
	ret

;============loadfile (Fonction 4)===============
;Charge le fichier ds:si en es:di ->ecx taille
;-> AH=4
;<- Flag Carry si erreur
;=====================================================
loadfile:
	push	eax bx di
	push	es di
	push	cs
	pop	es
	mov	di,offset tempfit
	call	searchfile
	pop	di es
	jne   	errorload
	jc	errorload
	mov	cx,cs:tempfit.FileGroup
	mov	eax,cs:tempfit.FileSize
	call	loadway
	jc    	errorload
	clc
	;mov	ecx,eax
	pop   	di bx eax
	ret
errorload:
	stc
	mov	ecx,0
	pop   	di bx eax
	ret

tempfit db 32 dup (0)

;=============SearchFile (Fonction 10)===============
;Renvois dans ES:DI la fit du fichier DS:SI et non equal si pas existant
;-> AH=10
;<- Flag Carry si erreur
;=====================================================
SearchFile:
	push	ax cx ds si di es
	call	uppercase
	push	ds si
	call	findfirstfilez
	push	ds
	pop	es
	mov	di,si
	pop	si ds
	jc	errorsearch
	jmp	founded
nextsearch:
	push	ds si
	call	findnextfilez
	push	ds
	pop	es
	mov	di,si
	pop	si ds
founded:
	cmp	byte ptr cs:[di],0
	je	notgood
	cmp	byte ptr cs:[di+FileAttr],0Fh
	je	nextsearch
	call	cmpnames
	jc    	nextsearch
okfound:
	push	cs
	pop	ds
	mov	si,di
	pop	es di
	push	di es
	mov	cx,32
	rep	movsb
	clc
	pop	es di si ds cx ax
	ret
notgood:
	cmp   	si,0FF5h
	pop	es di si ds cx ax
	ret
errorsearch:
	stc
	pop	es di si ds cx ax
	ret

;Transforme la chaine ds:si en maj
uppercase: 
	push 	si ax
	mov 	di,si
uppercaser:
	mov 	al,ds:[si]
	cmp 	al,0
	je 	enduppercase
	cmp 	al,'a'
	jb 	nonmaj
	cmp 	al,'z'
	ja 	nonmaj
	sub 	al,'a'-'A'
	mov 	ds:[si],al
nonmaj:
	inc 	si
	jmp 	uppercaser
enduppercase:
	clc
	pop 	ax si
	ret

;Compare le nom ds:si '.' avec es:di 
CmpNames:
	push 	ax cx si di
	mov 	cx,8
	repe 	cmpsb
	jne 	nequal
	inc 	si
nequal:
	cmp 	byte ptr [si-1],'.'
	jne 	trynoext
	mov 	al,' '
	rep 	scasb
	mov 	cx,3
	rep 	cmpsb
	jne 	notequal
	cmp 	byte ptr [si],0
	jne 	notequal
	cmp 	cx,0
	jl 	notequal
itok:
	pop 	di si cx ax
	ret
trynoext:
	cmp	byte ptr [si-1],0
	jne	notequal
	jmp	itok
notequal:
	stc
	pop 	di si cx ax
	ret

;charge le fichier de de groupe CX et de taille eax
LoadWay:
	push	eax bx dx si di ecx ds es			
	cmp   	eax,0
	je	Zeroload
	rol	eax,16
	mov	dx,ax
	ror	eax,16
	div	cs:clusterSize
	mov	bx,ax
	cmp	bx,1
	jb	adjustlast
Loadfat:
	call	readcluster
	jc 	noway
	add	di,cs:clusterSize
	call	getfat
	dec	bx
	jnz	loadfat
AdjustLast:
	push  	es di
	push	cs
	pop 	es
	mov	di,offset bufferread
	mov	si,di
	call	Readcluster
	pop   	di es
	jc	noway
	mov	cx,dx
	push	cs
	pop	ds
	rep	movsb
zeroload:
	clc
	pop	es ds ecx di si dx bx eax
	ret
noway:	
	stc
	pop	es ds ebp di si dx bx eax
	ret

;=============INITDRIVE (Fonction 04H)===============
;Initialise le lecteur pour une utilisation ult�rieure
;-> AH=4
;<- Flag Carry si erreur
;=====================================================
InitDrive:
	push 	eax bx cx edx di ds es
	push 	cs
	pop 	ds
	push	cs
	pop	es
	mov	cs:lastseg,0
	mov	cs:lastoff,0
	mov 	cs:LastRead,0
	mov	ax,myboot.sectorsize
	mov	bl,myboot.SectorsPerCluster
	xor	bh,bh
	mul	bx
	mov	clustersize,ax
	mov 	bx,myboot.HiddenSectorsL
	adc 	bx,myboot.HiddenSectorsH
	mov 	AdressBoot,bx
	add 	bx,myboot.ReservedSectors
	mov 	AdressFat,bx
	xor 	ax,ax
	mov 	al,myboot.FatsPerDrive
	mul 	myboot.SectorsPerFat
	add 	bx,ax
	mov 	AdressParent,bx
	mov 	AdressDirectory,bx
	mov 	ax,32                 
	mul 	myboot.DirectorySize
	div 	myboot.SectorSize
	add 	bx,ax
	mov 	AdressData,bx
	sub	bx,2
	mov	AddingValue,bx
	mov 	ax,myboot.SectorsPerDrive
	div 	myboot.SectorsPerTrack
	xor 	dx,dx
	div 	myboot.HeadsPerDrive     
	mov 	TracksPerHead,ax
	xor	eax,eax
	mov	ax,myboot.SectorsPerDrive
	sub	ax,AdressData
	mul	myboot.SectorSize
	shl   	edx,16
	add   	edx,eax
	mov	DriveSize,edx
	mov	CurrentDir,0
	mov	EntryPlace,0
	mov	adressdirectory,0
	mov	firstsearch,1
	mov	currentdirstr,0
	mov	di,offset bufferfat
	mov	dx,myboot.SectorsPerFat
	mov	cx,AdressFat
SeeFat:
	call	readsector
	jc	ErrorInit
	add	di,myboot.SectorSize
	inc	cx
	dec	dx
	jnz	seefat
	clc
	pop 	es ds di edx cx bx eax
	ret
ErrorInit:
	stc
	pop 	es ds di edx cx bx eax
	ret

;=============FindFirstFile (Fonction 7)==============
;Renvois dans ES:DI un bloc d'info
;-> AH=7
;<- Flag Carry si erreur
;=====================================================
FindFirstFileZ:
	push 	cx
	mov 	cx,cs:CurrentDir
	mov 	cs:AdressDirectory,cx
	xor	cx,cx
	mov 	cs:EntryPlace,cx
	mov	cs:firstsearch,1
	call 	findnextfileZ
	pop 	cx
	ret

;=============FindnextFile (Fonction 8)==============
;Renvois dans ES:DI un bloc d'info
;-> AH=8
;<- Flag Carry si erreur
;=====================================================
;fait pointer ds:si sur la prochaine entr�e du repertoire courant
FindnextFileZ:
	push	ax bx cx es di
	push	cs
	pop	ds
	mov	cx,cs:AdressDirectory
	mov	bx,cs:Entryplace
FindnextFileagain:
	cmp	cs:firstsearch,1
	je	first
	add	bx,32
	cmp	bx,cs:clusterSize
	jb	nopop
first:
	mov	di,offset bufferentry
	push	cs
	pop	es
	mov	bx,0
	cmp	cs:currentdir,0
	jne	notrootdir
	cmp	cs:firstsearch,1
	je	noaddfirst1
	inc	cx
noaddfirst1:
	add	cx,cs:adressparent
	mov	al,myboot.sectorspercluster
readroot:
	call	readsector
	jc	notwell
	add	di,myboot.sectorsize
	dec	al
	jnz	readroot
	sub	cx,cs:adressparent
	jmp	nopop
notrootdir:
	cmp	cs:firstsearch,1
	je	noaddfirst2
	call	getfat
noaddfirst2:
	jc	notwell
	call	readcluster
	jc	notwell
nopop:
	mov	cs:firstsearch,0
	mov	si,offset bufferentry
	add	si,bx
	cmp	byte ptr cs:[si],0
	je	notwell
	mov	cs:entryplace,bx
	mov	cs:AdressDirectory,cx
	cmp	byte ptr cs:[si],0E5h
	je	findnextfileagain
	cmp	byte ptr cs:[si+fileattr],28h
	je	findnextfileagain
	cmp	byte ptr cs:[si+fileattr],0Fh
	je	findnextfileagain
	clc
	pop	di es cx bx ax
	ret
notwell:
	stc
	pop	di es cx bx ax
	ret


;=============READCLUSTER (Fonction 14)===============
;Lit le secteur CX et le met en es:di
;-> AH=14
;<- Flag Carry si erreur
;=====================================================
readcluster:
	push	ax bx cx dx di
	mov	ax,cx
	mov	bl,cs:myboot.sectorspercluster
	xor	bh,bh
	mul	bx
	mov	cx,ax
	add	cx,cs:addingvalue
readsectors:
	call	readsector
	jc	errorreadincluster
	add	di,cs:myboot.sectorsize
	inc	cx
	dec	bl
	jnz	readsectors
	clc
	pop	di dx cx bx ax
	ret
errorreadincluster:
	stc
	pop	di dx cx bx ax
	ret

;=============READSECTOR (Fonction 01H)===============
;Lit le secteur CX et le met en es:di
;-> AH=1
;<- Flag Carry si erreur
;=====================================================
ReadSector:
	push 	ax bx cx dx si
	cmp 	cx,cs:lastread
	jne  	gom
	mov	ax,es
	cmp	cs:lastseg,ax
	jne   	gom
	cmp	di,cs:lastoff
	jne   	gom
	jmp	done
gom:
	mov	cs:lastseg,ax
	mov	cs:lastoff,di
	mov 	cs:LastRead,cx
	mov	ax,cx
	xor   	dx,dx
	div   	cs:myboot.SectorsPerTrack
	inc   	dl
	mov 	bl,dl           
	xor 	dx,dx                   
	div 	cs:myboot.HeadsPerDrive
	mov 	dh,cs:myboot.bootdrive
	xchg 	dl,dh          
	mov 	cx,ax              
	xchg 	cl,ch             
	shl 	cl,6                
	or 	cl,bl       
	mov 	bx,di                           
	mov 	SI,4
	mov 	AL,1
TryAgain:
  	mov 	AH, 2
  	int 	13h
  	jnc 	Done
  	dec 	SI
  	jnz 	TryAgain
Done:
  	pop 	si dx cx bx ax
ret

lastread dw 0
lastseg  dw 0
lastoff  dw 0
   
bufferread  	equ $
bufferFat 	equ $+2048
bufferentry	equ $+2048+2048
loadinglist	equ $+2048+2048+2048
end start