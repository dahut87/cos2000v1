.model tiny
.486
smart
.code

org 0100h

include ..\include\mem.h
include ..\include\divers.h

start:
maxfunc equ 4

	jmp	tsr			;Saute à la routine résidente
nameed db 'MB'			;Nom drivers
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
tables dw MBinit		;Table qui contient les adresses de toutes les fonctions de VIDEO (WORD)
         dw MBFree
         dw MBCreate
         dw MBresident

FirstMB dw 0

;Initialise les blocs de mémoire en prenant memorystart pour segment de base
MBinit:
	push	ax cx es
	mov	ax,memorystart
	mov	cs:Firstmb,ax       	
        mov	cx,0A000h
	sub	cx,ax
	dec	ax
	dec	ax
	mov	es,ax
	mov     es:[MB.Reference],Free
	mov     es:[MB.Sizes],cx
	mov     es:[MB.Check],'NH'
	mov	dword ptr es:[MB.Names],'eerF'	
	mov	dword ptr es:[MB.Names+4],0
	mov	es:[MB.IsNotLast],False
	clc
	pop	es cx ax
	ret
notforfree:
	stc
	pop	es cx ax
	ret

;Libère le bloc de mémoire GS
MBFree:
	push	bx es
	mov	bx,gs
	dec     bx
	dec     bx
	mov	es,bx
	cmp	es:[MB.Check],'NH'
	je	notforfree
	mov	es:[MB.IsResident],0
	mov	es:[MB.Reference],Free
	mov	dword ptr es:[MB.Names],'eerF'
	mov	dword ptr es:[MB.Names+4],0
	pop	es bx
	ret

;Renvoie en GS le MB n° bx
MBGet:
	

;Creér un bloc de nom ds:si de taille cx (octets) -> n°segment dans GS
MBCreate:
	push	ax bx cx dx si di es	
	shr	cx,4
	inc	cx
	mov	bx,cs:firstmb
	dec	bx
	dec	bx
	mov     dl,1
searchfree:
	cmp	dl,False
	je	wasntgood
	mov   es,bx
	cmp	es:[MB.Check],'NH'
	jne	wasntgood
	cmp	es:[MB.IsNotLast],True
	sete  dl
	cmp	es:[MB.Reference],Free
	jne	notsogood
	mov	ax,es:[MB.Sizes]
	cmp	cx,ax
	ja	notsogood
        mov   word ptr es:[MB.Check],'NH'
	mov	es:[MB.IsNotLast],True
	mov	es:[MB.Reference],cs
	mov	es:[MB.IsResident],False
	mov	es:[MB.Sizes],cx
	mov     di,MB.Names
	push	ax cx
	mov 	cx,32
loops:
	mov	dh,[si]
	inc 	si
	dec	cx
	jz	endofloops
	cmp	dh,0
	je 	endofloops
	mov	es:[di],dh
	inc	di
	jmp	loops
endofloops:
	inc	cx
	mov	al,0
	rep	stosb
	pop	cx ax
	sub	ax,cx
	dec	ax
	dec	ax
	;js	nofree
	inc     bx
	inc     bx
	mov	gs,bx
	add	bx,cx
	mov	es,bx	
	mov	es:[MB.IsNotLast],dl
	mov	es:[MB.IsResident],False
	mov	es:[MB.Reference],Free
	mov	es:[MB.Sizes],ax
	mov	dword ptr es:[MB.Names],'eerF'
	mov	dword ptr es:[MB.Names+4],0
	mov	es:[MB.Check],'NH'
nofree:
	clc
	pop	es di si dx cx bx ax
	ret
wasntgood:
	stc
	pop	es di si dx cx bx ax
	ret
notsogood:
        inc     bx
        inc     bx
	add	bx,es:[MB.Sizes]
	jmp	searchfree

;Rend le segment GS résident
MBresident:
	push	bx es
	mov	bx,gs
	dec	bx
	mov	es,bx
	mov	es:[MB.IsResident],True
	pop	es bx
	ret
	
end start
