.model tiny
.486
smart
.code

org 0100h

include ..\include\fat.h

start:
	jmp	tsr			;Saute à la routine résidente
names db 'DRIVE'			;Nom drivers
id    dw 1234h                ;Identifiant drivers
Tsr:
	cli				;Désactive interruptions logiciellement
	cmp	ax,cs:ID         	;Compare si test de chargement
	jne 	nomore		;Si pas test alors on continu
      rol   ax,3*4            ;Rotation de 3 chiffre de l'ID pour montrer que le drivers est chargé
	jmp 	itsok			;On termine l'int avec notre code d'ID preuve du bon chargement de VIDEO
nomore:
      cmp   ah,maxfunc
      jbe   noerrorint
      stc
      jmp   itsok
noerrorint:
      clc
	push 	bx
	mov 	bl,ah			;On calcule d'aprés le n° de fonction
	xor 	bh,bh			;quel sera l'entrée dans la table indexée
	shl 	bx,1			;des adresses fonctions.
	mov 	bx,cs:[bx+tables]	;On récupère cette adresse depuis la table
	mov 	cs:current,bx	;On la stocke temporairement pour obtenir les registres d'origine
	pop 	bx
      clc
      call 	cs:current		;Puis on execute la fonction
itsok:
	push 	bp		
	mov 	bp,sp			;On prend sp dans bp pour adresser la pile
	jnc 	noerror		;La fonction appelée a renvoyer une erreur :  Flag CARRY ?
      or    byte ptr [bp+6],1b;Si oui on le retranscrit sur le registre FLAG qui sera dépilé lors du IRET
      ;xor  eax,eax
      ;mov  ax,cs                   ;On récupère le segment et l'offset puis en renvoie l'adresse physique
      ;shl  eax,4                   ;de l'erreur.
      ;add  ax,cs:current
      jmp  endofint                ;on termine l'int
noerror:
	 and 	byte ptr [bp+6],0FEh;Si pas d'erreur on efface le Bit CARRY du FLAG qui sera dépilé lors du IRET
endofint:
       pop 	bp
	 sti				;On réactive les interruptions logiciellement
	 iret				;Puis on retourne au programme appelant.

current dw 0			;Mot temporaire qui contient l'adresse de la fonction appelée
tables  dw readsector
        dw writesector
        dw verifysector2
        dw initdrive
        dw loadfile
        dw compressrle
        dw decompressrle
	dw FindFirstfile
	dw Findnextfile    
	dw GetFreeSpace   
	dw Searchfile
	dw Getname
	dw Getserial
	dw changedir
	dw readcluster
	dw writecluster
	dw getdir
	dw projfile
	dw execfile

maxfunc equ 24

;DPT disquette 
mydpt DPT ?

;Secteur de boot
myboot bootSector ?

;Données Calculée
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
	mov	ecx,eax
	pop   	di bx eax
	ret
errorload:
	stc
	mov	ecx,0
	pop   	di bx eax
	ret
	
;============execfile (Fonction 18)===============
;Execute le fichier ds:si
;-> AH=18
;<- Flag Carry si erreur
;=====================================================
execfile:
	pushad
	pushf
        push    ds es fs gs
        call    projfile
        jc      reallyerror
        push    es
        push    cs
        mov     ax,offset arrive
        push    ax
        push    es
        push    0100h
        push    es
        push    es
        push    es
        pop     ds
        pop     fs
        pop     gs
        push    7202h
        popf
        sti
        db      0CBh
        arrive:
        cli
        pop     gs
        mov     ah,01
        int     49h
        pop     gs fs es ds
        popf
	popad
	ret
reallyerror:
        pop     gs fs es ds
        popf
	popad
	stc
	ret

;============projfile (Fonction 17)===============
;Charge le fichier ds:si sur un bloc mémoire -> ecx taille -> es bloc
;-> AH=17
;<- Flag Carry si erreur
;=====================================================
projfile:
	push	eax bx di ds gs
	push	cs
	pop	es
	call    uppercase
        mov     ah,5
	int     49h
	jnc      errorload2
	mov	di,offset tempfit
	call	searchfile
	jne   	errorload2
	jc	errorload2
	mov	eax,cs:tempfit.FileSize
	mov     ecx,eax
	add     ecx,19000
	push    ax
	mov     ah,2
	int     49h
	pop     ax
	jc      errorload2
	push    gs
	pop     es
	mov	cx,cs:tempfit.FileGroup
	mov     di,100h
	call	loadway
	jc    	errorload2
	clc
	mov	ecx,eax
	pop   	gs ds di bx eax
	ret
errorload2:
	stc
	mov	ecx,0
	pop   	gs ds di bx eax
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
;Initialise le lecteur pour une utilisation ultérieure
;-> AH=4
;<- Flag Carry si erreur
;=====================================================
InitDrive:
	push 	eax bx cx edx di ds es
	push 	cs
	pop 	ds
	push	cs
	pop	es
	mov	di,3
againtry:
        xor  	ax,ax
	mov	dx,0000h
        int  	13h
	mov	bx,offset myboot
	mov	ax,0201h
	mov	cx,0001h
	mov	dx,0000h
	int	13h
	jnc	oknoagaintry
	dec	di
	jnz	againtry
oknoagaintry:
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
FindFirstFile:
	push	cx ds di si
	call	FindFirstFileZ
	mov	cx,32
	rep	movsb
	pop	si di ds cx
	ret

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
;Renvois dans ES:DI un bloc d'info
FindnextFile:
	push	cx ds di si
	call	FindnextFileZ
	mov	cx,32
	rep	movsb
	pop	si di ds cx
	ret

;fait pointer ds:si sur la prochaine entrée du repertoire courant
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

;=============GetFreeSpace (Fonction 09H)===============
;Renvoie en EDX l'espace disque libre du volume
;-> AH=9
;<- Flag Carry si erreur
;=====================================================
GetFreeSpace:
	push  	eax
	xor	eax,eax
	call	getsector
	mul	cs:myboot.SectorSize
	shl	edx,16
	add	edx,eax
	pop   	eax
	ret

;ax=défectueux bx=libre
GetSector:
	push	cx dx
	mov	dx,cs:myboot.SectorsPerDrive
	sub	dx,cs:AddingValue
	xor	ax,ax
	xor	bx,bx
	mov	cx,0
goget:
	push	cx	
	call	getfat
	cmp	cx,0FF7h
	jne	notdefect
	inc	bx
notdefect:
	cmp	cx,0
	jne	notfree
	inc	ax
notfree:
	pop  	cx
	inc	cx
	dec	dx
	jnz	goget
	pop 	dx cx
	ret
errorfree:
	stc
	pop dx cx
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

;=============WRITECLUSTER (Fonction 15)===============
;Ecrit le cluster CX et le met en es:di
;-> AH=14
;<- Flag Carry si erreur
;=====================================================
writecluster:
	push	ax bx cx dx si
	mov	ax,cx
	mov	bl,cs:myboot.sectorspercluster
	xor	bh,bh
	mul	cx
	mov	cx,ax
	add	cx,cs:addingvalue
writesectors:
	call	writesector
	jc	errorwriteincluster
	add	si,cs:myboot.sectorsize
	inc	cx
	dec	bx
	jnz	writesectors
	clc
	pop	si dx cx bx ax
	ret
errorwriteincluster:
	stc
	pop	si dx cx bx ax
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
   
;=============WRITESECTOR (Fonction 02H)==============
;Ecrit le secteur CX pointé par ds:si
;-> AH=2
;<- Flag Carry si erreur
;=====================================================
WriteSector:
	push 	ax bx cx dx si es
	cmp 	cs:Lastread,cx
 	jne 	nodestruct
  	mov 	cs:Lastread,0ffffh
nodestruct:
	push 	ds
  	pop 	es
	mov	ax,cx
	xor   	dx,dx
	div   	cs:myboot.SectorsPerTrack
	inc   	dl
	mov 	bl,dl           
	xor 	dx,dx                   
	div 	cs:myboot.HeadsPerDrive
	mov 	dh,cs:myboot.BootDrive
	xchg 	dl,dh          
	mov 	cx,ax              
	xchg 	cl,ch             
	shl 	cl,6                
	or 	cl, bl         
	mov 	bx,si                         
	mov 	SI, 4
	mov 	AL,1
TryAgains:
  	mov 	AH, 3
  	int 	13h
  	jnc 	Dones
  	dec 	SI
  	jnz 	TryAgains
Dones:
  	pop 	es si dx cx bx ax
ret

;=============Getname (Fonction 11)==============
;Renvoie le nom en ES:DI
;-> AH=11
;<- Flag Carry si erreur
;=====================================================
getname:
	push 	ax cx dx si di ds es	
	push	cs
	pop	ds
	mov	dx,di
	mov	si,offset myboot.DriveName
	mov	cx,11
	rep	movsb
	mov	al,' '
	mov	di,dx
	mov	cx,11
	repne	scasb
	mov 	byte ptr es:[di],0
	pop 	es ds di si dx cx ax
	ret

;=============Getserial (Fonction 12)==============
;Renvoie le numéro de serie en EDX
;-> AH=12
;<- Flag Carry si erreur
;=====================================================
getserial:
	mov	edx,cs:myboot.serialnumber
	ret

;=============VERIFYSECTOR (Fonction 03H)==============
;Vérifie le secteur CX
;-> AH=3
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
VerifySector:
	push 	bx cx si di ds es
	push 	cs
	pop 	es
	push 	cs
	pop 	ds
	mov 	bx,offset bufferread
	call 	ReadSector        
	jc 	errorverify
	call 	inverse
	call 	WriteSector
	jc 	errorverify
	mov 	bx,offset bufferwrite
	call 	ReadSector        
	call 	inverse
	jc 	errorverify
	mov 	bx,offset bufferread
	call 	inverse
	call 	WriteSector
	jc 	errorverify
	mov 	cx,cs:myboot.SectorSize
	shr	cx,2
	mov 	si,offset bufferread
	mov 	di,offset bufferwrite
	cld
	rep 	cmpsd
errorverify:
	pop 	es ds di si cx bx
	ret

Inverse:
	mov 	si,cs:myboot.sectorsize
	shr	si,2
invert:
	shl 	si,2
	not 	dword ptr [bx+si-4]
	shr 	si,2
	dec 	si
	jnz 	invert
	ret

VerifySector2:
	call 	verifysector
	jne 	nook
	or 	byte ptr [bp+6],10b
nook:
	ret

;=============DecompressRle (Fonction 05H)==============
;decompress ds:si en es:di taille bp d‚compress‚ cx compress‚
;-> AH=5
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
DecompressRle:
	push 	cx dx si di
	mov 	dx,cx
	mov 	bp,di
decompression:
	mov 	eax,[si]
	cmp 	al,'/'
	jne 	nocomp
	cmp 	si,07FFFh-6
	jae 	thenen
	mov 	ecx,eax
	ror 	ecx,16
	cmp 	cl,'*'
	jne 	nocomp
	cmp 	byte ptr [si+4],'/'
	jne 	nocomp
	mov 	al,ch
	mov 	cl,ah
	xor 	ah,ah
	xor 	ch,ch
	rep 	stosb
	add 	si,5
	sub 	dx,5
	jnz 	decompression
	jmp 	thenen
nocomp:
	mov 	es:[di],al
	inc 	si
	inc 	di
	dec 	dx
	jnz 	decompression
thenen:
	mov 	ax,dx
	sub 	bp,di
	neg 	bp
	clc
	pop 	di si dx cx
	ret

;=============CompressRle (Fonction 06H)==============
;compress ds:si en es:di taille cx d‚compress‚ BP compress‚
;-> AH=6
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
CompressRle:
	push 	ax bx cx dx si di ds es
	mov 	bp,di
	xchg 	si,di
	push 	es
	push 	ds
	pop 	es
	pop 	ds
	mov 	dx,cx
	;mov 	bp,cx
againcomp:
	mov 	bx,di
	mov 	al,es:[di]
	mov 	cx,dx
	cmp 	ch,0
	je 	poo
	mov 	cl,0ffh
	;mov 	cx,bp
	;sub 	cx,di
	;mov 	ah,cl
poo:
	mov 	ah,cl
	inc 	di
	xor 	ch,ch
	repe 	scasb
	sub 	cl,ah
	neg 	cl
	cmp 	cl,6
	jbe 	nocomp2
	mov 	dword ptr [si],' * /'
	mov 	byte ptr [si+4],'/'
	mov 	[si+1],cl
	mov 	[si+3],al
	add 	si,5
	dec 	di
	xor 	ch,ch
	sub 	dx,cx
	jnz 	againcomp
	jmp 	fini
nocomp2:
	mov 	[si],al
	inc 	si
	inc 	bx
	mov 	di,bx
	dec 	dx
	jnz 	againcomp
fini:
	sub 	bp,si
	neg 	bp
	clc
	pop 	es ds di si dx cx bx ax
	ret

;=============Changedir (Fonction 13)==============
;Change le repertoire courant a DS:SI
;-> AH=13
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
Changedir:
	push	ax cx dx si di ds es
	push	cs
	pop	es
	;cmp	[si],005Ch ;'\',0 (root dir)
	mov	di,offset tempdir
	call	searchfile
	jc	noch
	mov	cx,cs:tempdir.Filegroup
	mov	cs:CurrentDir,cx
	mov	cs:EntryPlace,0
	mov	cs:adressdirectory,cx
	mov	cs:firstsearch,1
	cmp	cs:[di],'  ..'
	jne	notback
	cmp	cs:[di],'   .'
	je	theend
	mov	di,offset currentdirstr
	mov	cx,128
	mov	al,0
	repne	scasb
	mov	al,'\'
	std	
	repne	scasb
	cld
	inc 	di
	mov	byte ptr es:[di],0
	jmp	theend
notback:
	mov	di,offset currentdirstr
	mov	cx,128
	mov	al,0
	repne	scasb
	dec	di
	mov	al,'\'
	stosb
	mov	dx,di
	push	ds
	pop	es
	mov	di,si
	mov	cx,128
	mov	al,0
	repne	scasb
	sub	cx,128
	neg	cx
	push	cs
	pop	es
	mov	di,dx
	rep	movsb
theend:
	pop	es ds di si dx cx ax 
	clc
	ret
noch:
	pop	es ds di si dx cx ax 
	stc
	ret

tempdir db 32 dup (0)

;=============getdir (Fonction 16)==============
;Recupere le repertoire courant a ES:DI
;-> AH=16
;<- Flag Carry si erreur
;=====================================================
getdir:
	push	ax cx si di ds es
	push	es di
	push	cs
	pop	es
	mov	di,offset currentdirstr
	mov	cx,128
	mov	al,0
	repne	scasb
	sub	cx,128
	neg	cx
	pop	di es
	push	cs
	pop	ds
	mov	si,offset currentdirstr
	rep	movsb
	pop	es ds di si cx ax
	clc
	ret


bufferread  	equ $
bufferwrite 	equ $+2048
bufferentry	equ $+2048+2048
bufferFat 	equ $+2048+2048+2048

end start
