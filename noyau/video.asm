.model tiny
.486
smart
.code

org 0100h

include ..\include\bmp.h

start:
	jmp	tsr			;Saute à la routine résidente
names db 'VIDEO'			;Nom drivers
id    dw 1234h                ;Identifiant drivers
Tsr:
	cli				;Désactive interruptions logiciellement
	cmp 	ax,cs:ID         	;Compare si test de chargement
	jne 	nomore		;Si pas test alors on continu
      rol     ax,3*4            ;Rotation de 3 chiffre de l'ID pour montrer que le drivers est chargé
	jmp 	itsok			;On termine l'int avec notre code d'ID preuve du bon chargement de VIDEO
nomore:
        cmp     ah,maxfunc
        jbe     noerrorint
        stc
        jmp     itsok
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
        or      byte ptr [bp+6],1b;Si oui on le retranscrit sur le registre FLAG qui sera dépilé lors du IRET
        ;xor   eax,eax
        ;mov     ax,cs                   ;On récupère le segment et l'offset puis en renvoie l'adresse physique
        ;shl     eax,4                   ;de l'erreur.
        ;add     ax,cs:current
        ;jmp     endofint                ;on termine l'int
noerror:
	and 	byte ptr [bp+6],0FEh;Si pas d'erreur on efface le Bit CARRY du FLAG qui sera dépilé lors du IRET
endofint:
	pop 	bp
	sti				;On réactive les interruptions logiciellement
	iret				;Puis on retourne au programme appelant.

current dw 0			;Mot temporaire qui contient l'adresse de la fonction appelée
tables dw setvideomode		;Table qui contient les adresses de toutes les fonctions de VIDEO (WORD)
         dw getvideomode
         dw clearscreen
         dw setfont
         dw loadfont
         dw showspace
         dw showline
         dw showchar
         dw showint
         dw showsigned
         dw showhex
         dw showbin
         dw showstring
         dw showstring0
         dw showcharat
         dw showintat
         dw showsignedat
         dw showhexat
         dw showbinat
         dw showstringat
         dw showstring0at
         dw setcolor
         dw getcolor
         dw scrolldown
         dw getxy
         dw setxy2
         dw savescreen
         dw restorescreen
         dw page2to1
         dw page1to2
         dw xchgPages
         dw savepage1
         dw changelineattr
         dw waitretrace
         dw getvgainfos
         dw loadbmppalet
         dw showbmp
         dw viewbmp
         dw savedac
         dw restoredac
         dw savestate
         dw restorestate
         dw enablescroll
         dw disablescroll
	 dw showdate
	 dw showtime
	 dw showname
	 dw showattr
	 dw showsize

;================================Table des modes videos (64 BYTES) ============================================
;40*25 16 couleurs
mode0        DB 67H,00H,  03H,08H,03H,00H,02H
             DB 2DH,27H,28H,90H,2BH,0A0H,0BFH,01FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,8EH,8FH,14H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,08H,00H
             DB 40,25

;80*25 16 couleurs
mode1        DB 67H,00H,  03H,00H,03H,00H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,1FH,96H,0B9H,0A3h,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,08H,00H
             DB 80,25

;80*50 16 couleurs
mode2        DB 63H, 00H, 03H,01H,03H,01H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9CH,8EH,8FH,28H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             DB 80,50        
                             
;100*50 16 couleurs
mode3        DB 067H,00H,03H,01H,03H,01H,02H
             DB 70H,63H,64H,85H,68H,84H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9Ch,08EH,8FH,32H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             DB 100,50        

;100*60 16 couleurs
mode4        DB 0A7H,00H,03H,01H,03H,01H,02H
             DB 70H,63H,64H,85H,68H,84H,0FFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,0E7H,8EH,0DFH,32H,1FH,0DFH,0E5H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             DB 100,60

;320*200 256 couleurs 
mode5        DB 63H, 00H,  03H,01H,0FH,00H,06H
             DB 5FH,4FH,50H,82H,54H,80H,0BFH,1FH,00H,41H,00H,00H,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,00H,96H,0B9H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 40,25  

;320*400 256 couleurs 
mode6     DB 063H, 00H,  03H,01H,0FH,00H,06H
             DB 5FH,4FH,50H,82H,54H,80H,0BFH,1FH,00H,40H,00H,00H,00H,00H,00H,00H
             DB 9CH,8EH,8FH,28H,00H,96H,0B9H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 40,50

;320*480 256 couleurs 
mode7 	DB 0E3H, 00H,  03H,01H,0FH,00H,06H
             DB 5FH,4FH,50H,82H,54H,80H,0BH,3EH,00H,40H,00H,00H,00H,00H,00H,00H
             DB 0EAH,0ACH,0DFH,28H,00H,0E7H,06H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04h,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 40,60

;360*480 256 couleurs 
mode8 DB 0E7H, 00H,  03H,01H,0FH,00H,06H
             DB 6BH,59H,5AH,8EH,5EH,8AH,0DH,3EH,00H,40H,00H,00H,00H,00H,00H,00H
             DB 0EAH,0ACH,0DFH,2DH,00H,0E7H,06H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04h,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 45,60

;400*600 256 couleurs 
mode9 DB 0E7H, 00H,  03H,01H,0FH,00H,06H
		 DB 74h,63h,64h,97h,68h,95h,86h,0F0h,00h,60h,00h,00h,00h,00h,00h,00h
		 DB 5Bh,8Dh,57h,32h,00h,60h,80h,0E3h,0FFh
 		 DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04h,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 50,75

DATABLOCKSIZE equ 40
DATABLOCK 	  equ $
;============================================DATABLOCK=========================================================
lines 	db 0
columns 	db 0
x           db 0
y 		db 0
xy		dw 0
colors 	db 7
mode 		db 0FFh
pagesize 	dw 0
pages       db 0
font		db 0
graphic 	db 0
xg		dw 0
yg		dw 0
style		dw 0
nbpage    	db 0
pagesshowed db 0
plane       db 0
xyg		dw 0
linesize    dw 0
adress     	dw 0
base 		dw 0
scrolling       db 1

;=======================================Equivalence pour la clarté du code========================================
Sequencer 	equ 03C4h
misc 		equ 03C2h
CCRT 		equ 03D4h
Attribs 	equ 03C0h
graphics    	equ 03CEh
statut 		equ 03DAh

maxfunc equ 48
maxmode	equ 9
planesize	equ 64000
;============================================Fonctions de l'int VIDEO===========================================

;=============ENABLESCROLLING (Fonction 02AH)=========
;Autorise le d‚filement
;-> AH=42
;<- 
;=====================================================
 EnableScroll:
        mov     cs:scrolling,1
        ret

;=============DISABLESCROLLING (Fonction 2Bh)=========
;D‚sactive le d‚filement
;-> AH=43
;<- 
;=====================================================
DisableScroll:
        mov     cs:scrolling,0
        ret

;================SHOWDATE (Fonction 2Ch)==============
;Affiche la date contenu en DX
;-> AH=44
;<- 
;=====================================================
ShowDate:
	push	ax cx edx
	mov	ax,dx
	mov	cx,2
	xor	edx,edx
	mov	dx,ax
	and	dx,11111b
	call	showfixint
	mov	dl,'/'
	call	showchar
	mov	dx,ax
	shr	dx,5
	and	dx,111b
	call	showfixint
	mov	dl,'/'
	call	showchar
	mov	dx,ax
	shr	dx,8
	and	dx,11111111b
	add	dx,1956
	mov	cx,4
	call	showfixint
	pop	edx cx ax
	ret

;================SHOWTIME (Fonction 2Dh)==============
;Affiche l'heure contenu en DX
;-> AH=45
;<- 
;=====================================================
ShowTime:
	push 	ax cx edx
	mov	ax,dx
	mov	cx,2
	xor 	edx,edx
	mov	dx,ax
	shr	dx,11
	and	dx,11111b
	call	showfixint
	mov	dl,':'
	call	showchar
	mov	dx,ax
	shr	dx,5
	and	dx,111111b
	call	showfixint
	mov	dl,':'
	call	showchar
	mov	dx,ax
	and	dx,11111b
	shl	dx,1
	call	showfixint
	pop	edx cx ax
	ret

;================SHOWNAME (Fonction 2Eh)==============
;Affiche le nom pointé par SI
;-> AH=46
;<- 
;=====================================================
ShowName:
	push	cx dx si
	xor	cx,cx
showthename:
	mov	dl,ds:[si]
	call	showchar
	inc	si
	inc	cx
	cmp	cx,8
	jne	suiteaname
	mov	dl,' '
	call	showchar
suiteaname:
	cmp	cx,8+3
	jb	showthename
	pop	si dx cx
	ret

;================SHOWATTR (Fonction 2Fh)==============
;Affiche les attributs spécifié par DL
;-> AH=47
;<- 
;=====================================================
ShowAttr:
	push	dx
	mov	al,dl	

	test 	al,00000001b
	je	noreadonly
	mov	dl,'L'	
	jmp	readonly
noreadonly:
	mov	dl,'-'
readonly:
	call	showchar

	test 	al,00000010b
	je	nohidden
	mov	dl,'C'	
	jmp	hidden
nohidden:
	mov	dl,'-'
hidden:
	call	showchar

	test 	al,00000100b
	je	nosystem
	mov	dl,'S'	
	jmp	system
nosystem:
	mov	dl,'-'
system:
	call	showchar

	test 	al,00100000b
	je	noarchive
	mov	dl,'A'	
	jmp	archive
noarchive:
	mov	dl,'-'
archive:
	call	showchar

	test 	al,00010000b
	je	nodirectory
	mov	dl,'R'	
	jmp	directory
nodirectory:
	mov	dl,'-'
directory:
	call	showchar

	pop	dx
	ret

;================SHOWSIZE (Fonction 30h)==============
;Affiche le nom pointé par DI
;-> AH=48
;<- 
;=====================================================
ShowSize:
	push 	cx edx si ds
	push	cs
	pop	ds
	mov	cx,4
	cmp	edx,1073741824
	ja	giga
	cmp	edx,1048576*9
	ja	mega
	cmp	edx,1024*9
	ja	kilo
	call	showintR
	mov	si,offset unit
	call	showstring0
	jmp	finsize
kilo:
	shr	edx,10
	call	showintR
	mov	si,offset unitkilo
	call	showstring0
	jmp	finsize
mega:
	shr	edx,20
	call	showintR
	mov	si,offset unitmega
	call	showstring0
	jmp	finsize
giga:
	shr	edx,30
	call	showintR
	mov	si,offset unitgiga
	call	showstring0
finsize:
	pop	ds si edx cx
	ret

unit db ' o ',0
unitkilo db ' ko',0
unitmega db ' mo',0
unitgiga db ' go',0

;=============SetVideoMode (Fonction 00h)=========
;Fixe le mode vidéo courant a AL
;-> AH=0, AL mode d'écran
;<- Carry if error
;=================================================
setvideomode:
	push 	ax cx dx di
      cmp   al,maxmode
	ja	errorsetvideomode
	cmp    cs:mode,5h
	jb	nographic
	cmp	al,5h
	jae	nographic
	call	initvideo
nographic:
        cmp    cs:mode,0FFh
        jne    noinit
	call	initvideo
noinit:
	mov 	cs:mode,al
	xor 	ah,ah
	mov 	di,ax
	shl 	di,6
	add 	di,offset mode0 
	mov 	dx,misc
	mov 	al,cs:[di]
	out 	dx,al
	inc 	di              
	mov 	dx,statut
	mov 	al,cs:[di]
	out 	dx,al 
	inc 	di              
	mov 	dx,sequencer
	xor 	ax,ax
initsequencer:
	mov 	ah,cs:[di]
	out 	dx,ax
	inc 	al
	inc 	di
	cmp 	al,4
	jbe 	initsequencer    
	mov 	ax,0E11h
	mov 	dx,ccrt
	out 	dx,ax           
	xor 	ax,ax
initcrt:
	mov 	ah,cs:[di]
	out 	dx,ax
	inc 	al
	inc 	di
	cmp 	al,24
	jbe 	initcrt          
      mov   dx,graphics
	xor 	ax,ax
initgraphic:
	mov 	ah,cs:[di]
	out 	dx,ax
	inc 	al
	inc 	di
	cmp 	al,8
	jbe 	initgraphic
	mov 	dx,statut
	in 	al,dx                          
	mov 	dx,attribs
	xor 	ax,ax
initattribs:
	mov 	ah,cs:[di]
	push 	ax
	in 	ax,dx
	pop	ax
	out 	dx,al
	xchg 	ah,al
	out 	dx,al
	xchg 	ah,al
	inc 	al
	inc	di
	cmp 	al,20
	jbe	initattribs
	mov 	al,20h
	out 	dx,al
	mov 	al,cs:[di]
	mov 	cs:columns,al
	mov 	ah,cs:[di+1]
	mov 	cs:lines,ah
	mul 	ah
	shl 	ax,1
  	cmp   cs:mode,5
      setae cs:graphics
      jb    istext
	shl   ax,3
istext:
	mov 	cs:pagesize,ax
	mov	ax,planesize
	xor	dx,dx
	div	cs:pagesize
	mov	cs:nbpage,al
      mov   al,cs:[di-36]
	xor 	ah,ah
      shl   ax,2
	mov   cl,cs:graphics
	shr   ax,cl
      mov   cs:linesize,ax
      mov   ax,cs:[di-43]
      mov   cs:adress,ax
	mov	cs:base,ax
      mov   cs:pages,0
	pop 	di dx cx ax
	ret
errorsetvideomode:
	pop 	di dx cx ax
	ret

initvideo:
	push 	bx cx si ds
;xor bx,bx
;mov ds,bx
;lds si,ds:[43h*4]
	push 	cs
	pop 	ds
	mov 	si,offset font8x8
	mov 	cl,8	
      	mov 	bl,1
	call 	loadfont
	mov 	si,offset font8x16
	mov 	cl,16	
      	mov 	bl,0
	call 	loadfont
	mov 	cs:pagesize,64000
	call 	clearscreen
	pop 	ds si cx bx
	ret

;=============GetVideoMode (Fonction 01h)=========
;Renvoie le mode vidéo courant dans AL
;-> AH=1
;<- AL mode d'écran
;=================================================
getvideomode:
	mov 	al,cs:mode
	ret

;=============CLEARSCREEN (Fonction 02h)=========
;Efface l'ecran graphique ou texte
;-> AH=2
;<- 
;================================================
clearscreen:
	push 	eax cx dx di es
	mov 	cx,cs:pagesize
	mov	di,cs:adress
	shr 	cx,2
        cmp   byte ptr cs:graphics,1
	jne 	erasetext
	mov  	ax,0A000h  
	mov 	es,ax       
erasegraph:
	mov	ah,0
gogot:
	push  ax cx
	mov   cl,ah
	mov   ah,1
	shl   ah,cl
	mov   al,2
        mov   dx,sequencer
	out   dx,ax
	pop   cx ax
	push 	si di cx eax
	mov	eax,00000000h
	rep 	stosd
	pop 	eax cx di si
        inc   ah
	cmp	ah,3
        jbe   gogot
	jmp 	enderase
erasetext:
	mov 	ax,0B800h
	mov 	es,ax
	mov 	eax,07200720h
	cld
	rep 	stosd
enderase:
        mov     cs:x,0
        mov     cs:y,0
        mov     cs:xg,0
        mov     cs:yg,0
        mov     cs:xy,0
        mov     cs:xyg,0
        mov     cs:plane,0
        pop 	es di dx cx eax
	ret             


;=============SetFont (Fonction 03h)=========
;Active la font cl parmi les 8
;-> AH=3, CL n° font
;<- Carry if error
;============================================
setfont:
	push 	ax cx dx
	cmp	cl,7
      	ja    	errorsetfont
	mov	cs:font,cl
	mov 	ah,cl
	and 	cl,11b
	and 	ah,0100b
	shl 	ah,2
	add 	ah,cl
      	mov   	dx,sequencer
	mov 	al,3
	out 	dx,ax
	pop	dx cx ax
        ret
errorsetfont:
	pop 	dx cx ax
	ret    

;=============GetFont (Fonction 0xh)=========
;Récupère le n° de la font active
;-> AH=x
;<- CL n° font, Carry if error
;============================================
Getfont:
	push 	ax cx dx
	cmp	cl,7
      	ja    	errorgetfont
	mov	cs:font,cl
	mov 	ah,cl
	and 	cl,11b
	and 	ah,0100b
	shl 	ah,2
	add 	ah,cl
      	mov   	dx,sequencer
	mov 	al,3
	out 	dx,ax
	pop	dx cx ax
	ret        
errorgetfont:
	stc
	pop 	dx cx ax
	ret    

;=============LoadFont (Fonction 04h)==========
;Charge une police pointée par ds:si dans la carte vidéo sous n°font BL, taille police dans CL
;-> AH=4, BL n°font, DS:SI pointeur vers Font, CL taille police 
;<- Carry if error
;===========================================
loadfont:
	push 	ax bx cx dx si di es
	cmp	bl,7
      	ja    	errorloadfont
	xor	di,di
      	cli  
      	mov   	dx,sequencer
doseq:   
	mov 	ax,cs:[di+offset reg1]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6
	jbe 	doseq
      	mov   	dx,graphics 
doseq2:   
	mov 	ax,cs:[di+offset reg1]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6+6
	jbe 	doseq2
	sti
	mov 	ax,0A000h
	mov	es,ax
	mov 	dx,256
	mov 	al,0
	xor 	bh,bh
	cmp 	bl,4
	jb 	isless
	sub	bl,4
	shl 	bl,1
	inc 	bl
	jmp 	okmake
isless:
	shl 	bl,1
okmake:
	mov 	di,bx
	shl 	di,13
	mov 	bh,cl
	mov 	bl,cl
	sub 	bl,32
	neg 	bl
	xor 	cx,cx
	cld
popz:
	mov 	cl,bh
	rep 	movsb
	mov 	cl,bl
	rep 	stosb
	dec 	dx
	jnz 	popz 
	xor 	di,di
      	mov   	dx,sequencer
doseqs:   
	mov 	ax,cs:[di+offset reg2]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6
	jbe 	doseqs
        	mov     	dx,graphics 
doseqs2:   
	mov 	ax,cs:[di+offset reg2]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6+6
	jbe 	doseqs2
	pop 	es di si dx cx bx ax
	ret    
errorloadfont:
	stc
	pop 	es di si dx cx bx ax
	ret
  
reg2 	dw 0100h, 0302h, 0304h, 0300h 
     	dw 0004h, 1005h, 0E06h 
reg1 	dw 0100h, 0402h, 0704h, 0300h
     	dw 0204h, 0005h, 0406h                

;==========SHOWSPACE (Fonction 05h)===========
;met un espace aprés le curseur
;-> AH=5
;<- 
;=============================================
showspace:
	push 	cx
	mov   	cl,' '
        mov   	ch,cs:colors
        call  	charout
        clc
        pop   	cx
	ret

;==========SHOWLINE (Fonction 06h)===============
;remet le curseur text a la ligne avec un retour chariot
;-> AH=6
;<-
;================================================
showline:
        push    bx cx 
	mov 	bl,cs:y
	xor 	bh,bh
	mov 	cl,cs:lines
      	sub     cl,2
	cmp 	bl,cl
      	jne     scro
	dec 	bl
	mov	cx,1
	cmp	byte ptr cs:graphics,0
	je	okscro
	mov	cx,8
okscro:
	call	scrolldown
scro:
	inc 	bl
        call    setxy2
        pop     cx bx
	ret

;==========SHOWCHAR (Fonction 07h)===========
;met un caractère de code ASCII DL aprés le curseur
;-> AH=7, DL code ASCII du caractère
;<- 
;============================================
showchar:
	push 	cx
	mov	cl,dl
	mov 	ch,cs:colors
	call	charout
	pop 	cx
	ret

;==========SHOWINT (Fonction 08h)===========
;Affiche un entier EDX aprés le curseur
;-> AH=8, EDX un entier
;<- 
;===========================================
ShowInt:
	push	eax bx cx edx esi
      	xor	cx,cx
	mov   	eax,edx
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	cs:[bx],dl
	dec   	bx
      	cmp   	ax,0
      	jne   	decint
	mov	ax,cx
	mov	ch,cs:colors
showinteger:
	inc	bx
	mov	cl,cs:[bx]
	call	charout
	dec	ax
	jnz	showinteger
      	pop   	esi edx cx bx eax 
	ret   
    
showbuffer 	db 35 dup (0FFh)

;==========SHOWFIXINT (Fonction h)===========
;Affiche un entier EDX aprés le curseur de taille cx
;-> AH=8, EDX un entier et al="cara"
;<- 
;===========================================
ShowfixInt:
	push	eax bx cx edx esi di
	mov	di,cx
      	xor	cx,cx
	mov   	eax,edx
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
decint2:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	cs:[bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	nomuch
      	cmp   	ax,0
      	jne   	decint2
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
rego:
	mov 	byte ptr cs:[bx],'0'
	dec    	bx
	dec    	cx
	jnz	rego
	jmp 	finishim
nomuch:
	mov	ax,di
finishim:
	mov	ch,cs:colors
showinteger2:
	inc	bx
	mov	cl,cs:[bx]
	call	charout
	dec	ax
	jnz	showinteger2
      	pop  	di esi edx cx bx eax 
	ret   

;==========SHOWINTR (Fonction h)===========
;Affiche un entier EDX aprés le curseur de taille cx
;-> AH=8, EDX un entier
;<- 
;===========================================
ShowIntR:
	push	eax bx cx edx esi di
	mov	di,cx
      	xor	cx,cx
	mov   	eax,edx
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
decint3:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	cs:[bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	nomuch
      	cmp   	ax,0
      	jne   	decint3
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
rego2:
	mov 	byte ptr cs:[bx],' '
	dec    	bx
	dec    	cx
	jnz	rego2
	jmp 	finishim2
nomuch2:
	mov	ax,di
finishim2:
	mov	ch,cs:colors
showinteger3:
	inc	bx
	mov	cl,cs:[bx]
	call	charout
	dec	ax
	jnz	showinteger3
      	pop  	di esi edx cx bx eax 
	ret   

;==========SHOWSIGNED (Fonction 09h)===========
;Affiche un entier EDX de taille CX aprés le curseur
;-> AH=9, EDX un entier, CX la taille
;<- 
;==============================================
Showsigned:
	push 	ebx edx
	mov	ebx,edx
	xor	edx,edx
	cmp     cx,8
	ja 	signed16
	mov	dl,bl
	cmp	dl,7Fh
	jbe	notsigned
	neg 	dl
	jmp	showminus
signed16:
	cmp     cx,16
	ja 	signed32
	mov 	dx,bx
	cmp	dx,7FFFh
	jbe	notsigned
	neg	dx
	jmp	showminus
signed32:	
	mov	edx,ebx
	cmp	edx,7FFFFFFFh
	jbe	notsigned
	neg 	edx
showminus:
	push  	dx
	mov 	dl,'-'
	call 	showchar
      	pop   	dx
notsigned:
	call 	showint 
	pop 	edx ebx
	ret

;==========SHOWHEX (Fonction 0Ah)===========
;Affiche un nombre hexadécimal EDX de taille CX aprés le curseur
;-> AH=10, EDX un entier, CX la taille
;<- 
;===========================================
ShowHex:
       	push  	ax bx cx edx
       	mov   	ax,cx
	shr   	ax,2
       	sub   	cx,32
       	neg   	cx
       	shl   	edx,cl
       	mov   	ch,cs:colors
Hexaize:
       	rol   	edx,4
       	mov   	bx,dx
       	and   	bx,0fh
       	mov   	cl,cs:[bx+offset Tab]
       	call	charout
       	dec   	al
       	jnz   	Hexaize
       	pop   	edx cx bx ax
       	ret

Tab 	db '0123456789ABCDEF'

;==========SHOWBIN (Fonction 0Bh)===========
;Affiche un nombre binaire EDX de taille CX aprés le curseur
;-> AH=11, EDX un entier, CX la taille
;<- 
;===========================================
Showbin:
       	push   	ax cx edx
       	mov    	ax,cx
       	sub    cx,32
       	neg    cx
       	shl    edx,cl
       	mov    ch,cs:colors
binaize:
       rol    edx,1
       mov    cl,'0'
       adc    cl,0  
	 call	  charout
       dec    al
       jnz    binaize
       pop    edx cx ax
       ret

;==========SHOWBCD (Fonction 0xh)===========
;Affiche un nombre en BCD EDX de taille CX aprés le curseur
;-> AH=x, EDX un entier, CX la taille
;<- 
;===========================================
ShowBCD:
       push   ax cx edx
       mov    ax,cx
	 shr    ax,2
       sub    cx,32
       neg    cx
       shl    edx,cl
       mov    ch,cs:colors
BCDaize:
       rol    edx,4
       mov    cl,dl
       and    cl,0fh
       add    cl,'0'
	 call	  charout
       dec    al
       jnz    BCDaize
       pop    edx cx ax
       ret

;==========SHOWSTRING (Fonction 0Ch)===========
;Affiche une chaine de caractère pointée par DS:SI aprés le curseur
;-> AH=12, DS:SI pointeur chaine type pascal
;<- 
;==============================================
showstring:
       push   bx cx si
       mov    bl,[si]
       mov    ch,cs:colors
strinaize:
       inc    si
       mov    cl,[si]
	 call	  charout
       dec    bl
       jnz    strinaize
       pop    si cx bx
       ret

;==========SHOWSTRING0 (Fonction 0Dh)===========
;Affiche une chaine de caractère pointée par DS:SI aprés le curseur
;-> AH=13, DS:SI pointeur chaine type zéro terminal
;<- 
;===============================================
showstring0:
       push   cx si	
       mov    ch,cs:colors
strinaize0:
       mov    cl,[si]
       cmp    cl,0
       je     no0
	 call	  charout	
	 inc    si
       jmp    strinaize0
no0:
       pop    si cx
       ret

;==========SHOWCHARAT (Fonction 0Eh)===========
;met un caractère de code ASCII DL en (x;y) (BH;BL)
;-> AH=14, DL code ASCII du caractère, BH coordonnées x, BL coordonnées y
;<- 
;==============================================
showcharat:
	 push  es di
	 call  setxy
	 call  showchar
	 pop 	 di es
	 ret

;==========SHOWINTAT (Fonction 0Fh)===========
;Affiche un entier EDX en (x;y) (BH;BL)
;-> AH=15, EDX entier, BH coordonnées x, BL coordonnées y
;<- 
;==============================================
showintat:
	 push  es di
	 call  setxy
	 call  showint
	 pop 	 di es
	 ret

;==========SHOWSIGNEDAT (Fonction 10h)===========
;Affiche un entier EDX de taille CX aprés le curseur en (x;y) (BH;BL)
;-> AH=16, EDX entier, BH coordonnées x, BL coordonnées y
;<- 
;==============================================
showsignedat:
	 push  es di
	 call  setxy
	 call  showsigned
	 pop 	 di es
	 ret

;==========SHOWHEXAT (Fonction 11h)===========
;Affiche un nombre hexadécimal EDX de taille CX en (x;y) (BH;BL)
;-> AH=17, EDX un entier, CX la taille, BH coordonnées x, BL coordonnées y
;<- 
;==============================================
showhexat:
	 push  es di
	 call  setxy
	 call  showhex
	 pop 	 di es
	 ret

;==========SHOWBINAT (Fonction 012h)===========
;Affiche un nombre binaire EDX de taille CX en (x;y) (BH;BL)
;-> AH=18, EDX un entier, CX la taille, BH coordonnées x, BL coordonnées y
;<- 
;=============================================
showbinat:
	 push  es di
	 call  setxy
	 call  showbin
	 pop 	 di es
	 ret

;==========SHOWSTRINGAT (Fonction 13h)===========
;Affiche une chaine de caractère pointée par DS:SI en (x;y) (BH;BL)
;-> AH=19, DS:SI pointeur chaine type pascal, BH coordonnées x, BL coordonnées y
;<- 
;================================================
showstringat:
	 push   es di
	 call   setxy
	 call   showstring
	 pop 	  di es
	 ret
 
;==========SHOWSTRING0AT (Fonction 14h)===========
;Affiche une chaine de caractère pointée par DS:SI en (x;y) (BH;BL)
;-> AH=20, DS:SI pointeur chaine type zéro terminal, BH coordonnées x, BL coordonnées y
;<- 
;=================================================
showstring0at:
	push 	 es di
	call	 setxy
	call 	 showstring0
	pop 	 di es
	ret

;==========SETCOLOR (Fonction 15h)=========
;Change les attributs du texte a CL
;-> AH=21 ,CL couleur
;<- 
;=========================================
setcolor:
	mov 	cs:colors,CL
	ret

;==========GETCOLOR (Fonction 16h)=========
;Récupère les attributs du texte dans CL
;-> AH=22
;<- CL couleur
;=========================================
getcolor:
	mov 	cl,cs:colors
	ret

;==========SETSTYLE (Fonction xh)=========
;Change le style du texte a CL
;-> AH=x ,CX style
;<- 
;=========================================
setstyle:
	mov 	cs:style,CX
	ret

;==========GETSTYLE (Fonction xh)=========
;Récupère le style du texte dans CL
;-> AH=x
;<- CX style
;=========================================
getstyle:
	mov 	cx,cs:style
	ret

;==========SCROLLDOWN (Fonction 17h)=========
;defile de cx lines vers le bas
;-> AH=23, CX lines à défiler vers le bas
;<- 
;=============================
scrolldown:
	push 	ax cx dx si di ds es
        cmp     cs:scrolling,0
        je      graphp
	mov 	ax,cx
	mul 	cs:linesize
	mov 	si,ax
	mov 	cx,cs:pagesize
	sub 	cx,si
	mov 	di,cs:adress
	cld
	cmp   byte ptr cs:graphics,1
	jne 	textp
	mov  	ax,0A000h  
	mov 	es,ax
	mov 	ds,ax           
	shr   cx,2    
transfert:
	mov	ah,0
gogo:
	push  ax cx
	mov   cl,ah
	mov   ah,1
	shl   ah,cl
	mov   al,2
      mov   dx,sequencer
	out   dx,ax
	pop   cx ax
	mov   al,4
      mov   dx,graphics
	out   dx,ax
	push 	si di cx
	rep 	movsd
	pop 	cx di si
      inc   ah
	cmp	ah,3
	jbe   gogo
	jmp   graphp
textp:
	mov 	ax,0B800h
	mov 	es,ax
	mov 	ds,ax
	rep 	movsb
graphp:
	pop 	es ds di si dx cx ax
	ret

;==========GETXY (Fonction 18h)=========
;Change les coordonnées du curseur a X:BH,Y:BL
;-> AH=24
;<- BH coordonnées x, BL coordonnées y
;=============================
getxy:
	mov 	bh,cs:x
	mov 	bl,cs:y
	ret

;==========SETXY (Fonction 19h)=========
;Change les coordonnées du curseur a X:BH,Y:BL
;-> AH=25, BH coordonnées x, BL coordonnées y
;<- 
;=====================================
setxy:
	push 	ax bx cx dx
	mov 	cs:x,bh
	mov 	cs:y,bl
	mov 	al,bl
	mov 	bl,bh
	xor 	bh,bh
	mov	di,cs:adress
	add 	di,bx
	mul 	cs:columns
	add 	di,ax
	shl 	di,1
	mov 	cs:xy,di
	cmp	byte ptr cs:graphics,1
	jne	oktext
	mov	bl,cs:x
	mov	cl,cs:y
	xor	bh,bh
	xor	ch,ch
	shl	bx,3
	shl	cx,3
	call	setxyg
	jmp   endofsetxy
oktext:
	mov 	ax,0B800h
	mov 	es,ax
endofsetxy:
	pop 	dx cx bx ax
	ret

setxy2:
	push	es di
	call 	setxy
	pop 	di es
	ret

;==========SETXYG (Fonction 0xh)=========
;Change les coordonnées du curseur graphique a X:BX,Y:CX
;-> AH=x, BX coordonnées x, CX coordonnées y
;<- ES:DI pointeur sur pixel avec plan de bit ajusté
;======================================
setxyg:
     	push 	ax bx cx dx
	mov	cs:xg,bx
	mov	cs:yg,cx
      mov   ax,cx
      mov	cl,bl   
      mul  	cs:linesize                           
      shr   bx,2
      add  	ax,bx
      mov   di,ax
      and   cl,3                    
      mov   ah,1                        
      shl   ah,cl
      mov   al,2                   
      mov   dx, 3c4h       
      out   dx,ax       
	mov	cs:plane,cl
	mov	cs:xyg,di       
      mov   ax,0A000h      
      mov  	es,ax                  
	pop 	dx cx bx ax
	ret

;==========SHOWPIXEL (Fonction 0xh)=========
;Affiche un pixel de couleur AL en X:BX,Y:CX
;-> AH=x, BX coordonnées x, CX coordonnées y, AL couleur
;<- 
;=========================================
showpixel:
     	push 	ax bx cx dx di bp es
      mov   bp,ax
	mov   ax,cx
      mov	cl,bl   
      mul  	cs:linesize                           
      shr   bx,2
      add  	ax,bx
      mov   di,ax
	add   di,cs:adress
      and   cl,3                    
      mov   ah,1                        
      shl   ah,cl
      mov   al,2                   
      mov   dx,sequencer
      out   dx,ax       
      mov   bx,0A000h      
      mov  	es,bx
	mov	ax,bp              
	mov	es:[di],al	 	
	pop	es bp di dx cx bx ax
	ret

;==========SHOWPIXEL (Fonction 0xh)=========
;Récupère en al la couleur du pixel de coordonnées X:BX,Y:CX
;-> AH=x, BX coordonnées x, CX coordonnées y, AL couleur
;<- 
;=========================================
getpixel:
     	push 	ax bx cx dx di bp es
      mov   bp,ax
	mov   ax,cx
      mov	cl,bl   
      mul  	cs:linesize                           
      shr   bx,2
      add  	ax,bx
      mov   di,ax
	add   di,cs:adress
      and   cl,3 
	mov	ah,cl                                      
      mov   al,4                   
      mov   dx,graphics
      out   dx,ax       
      mov   bx,0A000h      
      mov  	es,bx
	mov	ax,bp
           
	mov	al,es:[di] 	
	pop	es bp di dx cx bx ax
	ret

;==========LOADBMPPALET (Fonction 0xh)=========
;Charge la palette du BMP pointée par DS:SI
;-> AH=x, DS:SI BMP
;<- 
;=============================================
loadbmppalet:
	push 	ax bx cx dx
	mov 	bx,0400h+36h-4
	mov 	cx,100h
	mov 	dx, 3c8h
paletteload:
	mov 	al, cl
	dec 	al
	out 	dx, al
	inc 	dx
	mov 	al,[bx+si+2]
	shr 	al,2
	out 	dx, al
	mov 	al,[bx+si+1]
	shr 	al,2
	out 	dx, al
	mov 	al,[bx+si]
	shr 	al,2
	out 	dx, al
	sub 	bx,4
	dec 	dx
	dec 	cl
	jnz 	paletteload
	pop 	dx cx bx ax
	ret

;==========VIEWBMP (Fonction 0xh)=========
;Affiche le BMP pointée par DS:SI en X:BX, Y:CX avec la préparation de la palette
;<- AH=x, DS:SI BMP, BX coordonnées X, CX coordonnées Y
;->
;=========================================
viewbmp:
	call	loadbmppalet
	call	showbmp
	ret

;==========SHOWBMP (Fonction 0xh)=========
;Affiche le BMP pointée par DS:SI en X:BX, Y:CX
;<- AH=x, DS:SI BMP, BX coordonnées X, CX coordonnées Y
;->
;=========================================
showbmp:
	push 	ax bx cx dx
	cmp	word ptr ds:[si+BMP_file.BMP_FileType],"MB"
	jne     errorshowing
	mov 	cs:xc,bx
	mov 	cs:yc,cx
	xor 	cx,cx
	xor 	bx,bx
	xor 	dx,dx
bouclette:
	mov 	al,[si+bx+436h]
	push 	bx cx
	sub 	cx,cs:yc
	neg 	cx
	mov 	bx,dx
	add 	bx,cs:xc
	call 	showpixel
	pop 	cx bx
	inc 	bx
	inc 	dx
	cmp 	dx,[si+offset BMP_File.BMP_width]
	jb 	bouclette
	xor 	dx,dx
	inc 	cx
	cmp 	cx,[si+offset BMP_File.BMP_height]
	jb 	bouclette
	clc
	pop 	dx cx bx ax
	ret
	
errorshowing:
        stc
        pop  dx cx bx ax
        ret
        
xc dw 0
yc dw 0

;==========GETVGAINFO (Fonction 0xh)=========
;Renvoie un bloc de donnée en ES:DI sur l'état de la carte graphique
;<- AH=x, ES:DI pointeur
;->
;=============================================
Getvgainfos:
	push 	cx si di ds
	push 	cs
	pop 	ds
	mov 	cx,datablocksize
	mov 	si,offset datablock
	cld
	rep 	movsb
	pop 	ds di si cx
	ret

;==========WAITRETRACE (Fonction 0xh)=========
;Synchronisation avec la retrace verticale
;<- AH=x
;->
;=============================================
waitretrace:
	push 	ax dx
	mov 	dx,3DAh
waitr:
	in 	al,dx
	test 	al,8
	jz 	waitr
	pop 	dx ax
	ret

;Ecrit le caractère ASCII CL attribut CH aprés le curseur, en le mettant à jours
charout:
	push 	ax bx cx dx di es
	cmp	byte ptr cs:graphics,1
	jne	textaccess
	mov	dx,cx
	mov	di,dx
	and 	di,11111111b
	shl 	di,3
	add 	di,offset font8x8
	xor 	bx,bx
	xor 	cx,cx
	mov 	ah,cs:[di]
bouclet:
	mov 	al,dh
	rol	ah,1
	jc 	colored
	shr	al,4
	bt    word ptr cs:style,0
	jc    transparent
colored:
	and	al,1111b
	push 	bx cx
	add   cx,cs:yg
	add 	bx,cs:xg
	call 	showpixel
	pop 	cx bx
transparent:
	inc 	bx
	cmp 	bx,8
	jb 	bouclet
	xor 	bx,bx
	inc 	di
	mov	ah,cs:[di]
	inc 	cx
	cmp 	cx,8
	jb 	bouclet
	add 	cs:xg,8
	mov	cx,cs:linesize
	shl	cx,2
	cmp	cs:xg,cx
	jb	adjusttext
	mov	cs:xg,0
	add	cs:yg,8
	jmp	adjusttext
textaccess:
	mov	ax,0B800h
	mov	es,ax
	mov	di,cs:xy
	mov	es:[di],cx
	add	cs:xy,2
adjusttext:
      inc     cs:x
	mov	  cl,cs:columns
	cmp	  cs:x,cl
	jb	  noadjusted
      call    showline
noadjusted:
	;mov 	dx,3D4h
	;mov 	al,0Eh
	;mov 	di,offset xy
	;mov 	ah,cs:[di]
	;out 	dx,ax
	;mov 	ah,cs:[di+1]
	;dec 	al
	;out 	dx,ax
	pop 	es di dx cx bx ax
	ret






;===================================sauve l'ecran rapidement================
SaveScreen:
        push    cx si di ds es
        mov     cx,0B800H
        mov     ds,cx
        push    cs
        pop     es
        mov     cx,cs:pagesize
        shr     cx,2
        xor     si,si
        mov     di,offset Copy2
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===================================sauve l'ecran rapidement en es:di================
SaveScreento:
        push    cx si di ds 
        mov     cx,0B800H
        mov     ds,cx
        mov     cx,cs:pagesize
        shr     cx,2
        xor     si,si
        cld
        rep     movsd
        pop     ds di si cx 
        ret   

;===================================sauve l'ecran rapidement================
Savepage1:
        push    cx si di ds es
        mov     cx,0B800H
        mov     ds,cx
        push    cs
        pop     es
        mov     cx,cs:pagesize
        shr     cx,2
        xor     si,si
        mov     di,offset Copy
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===================================sauve l'ecran rapidement================
RestoreScreen:
        push    cx si di ds es
        mov     cx,0B800H
        mov     es,cx
        push    cs
        pop     ds
        mov     cx,cs:pagesize
        shr     cx,2
        mov     si,offset Copy2
        xor     di,di
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===================================restore l'ecran rapidement de ds:si================
RestoreScreenfrom:
        push    cx si di ds es
        mov     cx,0B800H
        mov     es,cx
        mov     cx,cs:pagesize
        shr     cx,2
        xor     di,di
        cld
        rep     movsd
        pop     es ds di si cx 
        ret   

;===============================Page2to1============================
Page2to1:
        push    cx si di ds es
        mov     cx,0B800H
        mov     es,cx
        mov     ds,cx
        mov     cx,cs:pagesize
        shr     cx,2
        mov     si,4000
        xor     di,di
        cld
        rep     movsd
        pop     es ds di si cx 
        ret

;===============================Page1to2============================
Page1to2:
        push    cx si di ds es
        mov     cx,0B800H
        mov     es,cx
        mov     ds,cx
        mov     cx,cs:pagesize
        shr     cx,2
        mov     di,4000
        xor     si,si
        cld
        rep     movsd
        pop     ds es di si cx 
        ret
 
;===============================xchgPages============================
xchgPages:
        push    cx si di ds es
        call    savepage1
        call    page2to1
        mov     cx,0B800H
        mov     es,cx
        push    cs
        pop     ds
        mov     cx,cs:pagesize
        shr     cx,2
        mov     si,offset Copy
        mov     di,4000
        rep     movsd
        pop     es ds di si cx 
        ret

;Sauve l'‚tat de la carte en es:di
savestate:
push cx si di ds 
push cs
pop ds
mov cx,datablocksize
mov si,offset lines
cld
rep movsb
call savescreento
pop ds di si cx
ret

;R‚cupŠre l'‚tat de la carte en ds:si    
restorestate:
push ax cx si di es
mov al,[si+7]
cmp cs:mode,al
je nochangemode
mov ah,0
call setvideomode
nochangemode:
push cs
pop es
mov cx,datablocksize
mov di,offset lines
cld
rep movsb
call restorescreenfrom
pop es di si cx ax
ret       

;sauve le DAC
savedac:
push ax cx dx di
mov dx,3C7h
mov cx,256
mov di,offset dac
save:
mov al,cl
dec al
out dx,al
inc dx
inc dx
in al,dx
mov cs:[di],al
inc di
in al,dx
mov cs:[di],al
inc di
in al,dx
mov cs:[di],al
inc di
dec dx
dec dx
dec cx
jne save 
pop di dx cx ax
ret

;restore le DAC
restoredac:
push ax cx dx si
xor ax,ax
mov dx,3C8h
mov cx,256
mov si,offset dac
save2:
mov al,cl
dec al
out dx,al
inc dx 
mov al,cs:[si]
inc si
out dx,al
mov al,cs:[si]
inc si 
out dx,al
mov al,cs:[si]
inc si  
out dx,al
dec dx
dec cx
jne save2
pop si dx cx ax
ret

;couleur al pour ligne di  A SUPPRIMER
changelineattr:
push ax bx di es
mov bx,ax
mov ax,0B800h
mov es,ax
mov ax,di
mul cs:columns
mov di,ax
shl di,1
mov al,cs:columns
inc di
popep:
mov es:[di],bl
add di,2
dec al
jnz popep
pop es di bx ax
ret   

font8x8:
include ..\include\pol8x8.inc
font8x16:
include ..\include\pol8x16.inc

copy 		equ $
copy2           equ $+8192
dac             equ $+8192+8192

end start
