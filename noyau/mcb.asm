.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h
include ..\include\divers.h

start:
maxfunc equ 13

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
        jmp     endofint                ;on termine l'int
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
         dw MBGet
         dw MBFind
         dw MBChown
         dw MBAlloc
         dw MBclean
         dw MBfindsb
         dw MBnonresident
         dw MBSearchfunc
         dw MBLoadfuncs
         ;dw MBdefrag
         ;dw MBcopy
         ;dw MBchname
         
FirstMB dw 0

;Resouds les dépendances du bloc de mémoire GS
MBloadfuncs:
       push    ax bx ecx dx si di ds es gs
       push    gs
       pop     ds
       cmp     word ptr ds:[exe.Checks],"EC"
       jne     notloaded
       mov     si,ds:[exe.import]
loadfuncs:
       cmp     word ptr [si],0
       je      endofloading
       call    MBSearchfunc
       jnc     toendoftext
       mov     bx,si
findend2:
        inc     bx
        cmp     byte ptr [bx], ':'
        jne     findend2
        mov     byte ptr [bx],0
        mov     ah,17
        int     48h
        jc      notloaded
        mov     byte ptr [bx],':'
        call    MBSearchfunc
        jc      notloaded
toendoftext:
        mov     al,[si]
        cmp     al,0
        je      oktonext2
        inc     si
        jmp     toendoftext
oktonext2:
        inc     si
        mov     [si],dx
        mov     [si+2],gs
        add     si,4
        jmp     loadfuncs
endofloading:
          clc
          pop gs es ds di si dx ecx bx ax
          ret
notloaded:
          stc
          pop gs es ds di si dx ecx bx ax
          ret





;Recherche une fonction pointé par DS:SI en mémoire et renvoie son adresse en GS:DX
MBSearchfunc:
        push    bx si di
        mov     bx,si
findend:
        inc     bx
        cmp     byte ptr [bx], ':'
        jne     findend
        mov     byte ptr [bx],0
        call    MBfind
        mov     byte ptr [bx],':'
        jc      notfoundattallthesb
        cmp     word ptr gs:[exe.checks],"EC"
        jne     notfoundattallthesb
        mov     di,gs:[exe.export]
        inc     bx
        inc     bx
functions:
        cmp     word ptr gs:[di],0
        je      notfoundattallthesb
        mov     si,bx
cmpnamesfunc:
        mov     al,gs:[di]
        cmp     al,ds:[si]
        jne     notfoundthesb
        cmp     al,0
        je      seemsok
        inc     si
        inc     di
        jmp     cmpnamesfunc
notfoundthesb:
        mov     al,gs:[di]
        cmp     al,0
        je      oktonext
        inc     di
        jmp     notfoundthesb
oktonext:
        inc     di
        inc     di
        inc     di
        jmp     functions
seemsok:
        mov     dx,gs:[di+1]
        clc
        pop     di si bx
        ret
notfoundattallthesb:
        stc
        pop     di si bx
        ret


;Mise a nivo de la mémoire (jonction de blocs libre)
MBclean:
        push    ax bx dx es gs
        mov	bx,cs:firstmb
	dec	bx
	dec	bx
	xor     ax,ax
	xor     dx,dx
searchfree3:
	mov     gs,bx
	cmp	gs:[MB.Check],'NH'
	jne	erroronsearch
        inc     bx
        inc     bx
	add	bx,gs:[MB.Sizes]
	cmp     word ptr gs:[MB.Sizes],0
	je      erroronsearch
	cmp	gs:[MB.Reference],Free
	jne     notfreeatall
	cmp     ax,0
	je      notmeetafree
	add     dx,gs:[MB.Sizes]
	mov     word ptr gs:[MB.Check],0
	mov	dword ptr gs:[MB.Names],0	
	mov	dword ptr gs:[MB.Names+4],0
	inc     dx
	inc     dx
	jmp     nottrigered
notmeetafree:	
        xor     dx,dx
	mov     ax,gs	
	jmp     nottrigered
notfreeatall:
        cmp     ax,0
        je      nottrigered
        mov     es,ax
        add     es:[MB.Sizes],dx
        xor     ax,ax
nottrigered:
	cmp	gs:[MB.IsNotLast],true
	je	searchfree3
	cmp     ax,0
	je      reallyfinish
	mov     es,ax
        add     es:[MB.Sizes],dx
        mov     es:[MB.IsNotLast],False
reallyfinish:
	clc
	pop     gs es dx bx ax
	ret
erroronsearch:
        stc
        pop     gs es dx bx ax
        ret


;Initialise les blocs de mémoire en prenant memorystart pour segment de base
MBinit:
	push	ax cx es
	cmp     cs:FirstMB,0
	jne     notforfree
	mov	ax,memorystart
	mov	cs:Firstmb,ax       	
        mov	cx,0A000h
	sub	cx,ax
	dec	ax
	dec	ax
	mov	es,ax
	cmp     es:[MB.Check],'NH'
	je      notforfree
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
	push	ax bx es
	mov	bx,gs
	mov     ax,bx
	dec     bx
	dec     bx
	mov	es,bx
	cmp	es:[MB.Reference],Free
	je	wasfree
	cmp	es:[MB.IsResident],true
	je	wasfree
	mov	es:[MB.IsResident],false
	mov	es:[MB.Reference],Free
	mov	dword ptr es:[MB.Names],'eerF'
	mov	dword ptr es:[MB.Names+4],0
        mov	bx,cs:firstmb
	dec	bx
	dec	bx
searchtofree:
	mov     gs,bx
	cmp	gs:[MB.Check],'NH'
	jne	wasfree
        inc     bx
        inc     bx
	add	bx,gs:[MB.Sizes]
	cmp     word ptr gs:[MB.Sizes],0
	je      wasfree
	cmp     ax,gs:[MB.Reference]
	jne     nottofree
	mov	gs:[MB.IsResident],false
	mov	gs:[MB.Reference],Free
	mov	dword ptr gs:[MB.Names],'eerF'
	mov	dword ptr gs:[MB.Names+4],0
nottofree:
        cmp	gs:[MB.IsNotLast],true
	je	searchtofree
        call    MBclean	
	pop	es bx ax
	ret
wasfree:
	stc
	pop	es bx ax
	ret
	
;Change le proprietaire de GS a dx
MBChown:
	push	bx es
	mov	bx,gs
	dec     bx
	dec     bx
	mov	es,bx
	cmp	es:[MB.Reference],Free
	je	wasfree2
	mov	es:[MB.Reference],dx
	pop	es bx
	ret
wasfree2:
	stc
	pop	es bx
	ret
	
;Alloue un bloc de CX caractere pour le process visé -> GS
MBAlloc:
        push    dx si bp ds
        mov     bp,sp
        mov     dx,ss:[bp+12]	
	push    cs
	pop     ds
	mov     si,offset data
	call    MBCreate
	call    MBChown
	pop     ds bp si dx
	ret
	
data db '/Data',0

;Renvoie en GS le MB n° cx  carry quand terminé
MBGet:
        push    bx dx
        mov	bx,cs:firstmb
	dec	bx
	dec	bx
	xor     dx,dx
searchfree2:
	mov     gs,bx
	cmp	gs:[MB.Check],'NH'
	jne	itsend
        inc     bx
        inc     bx
	add	bx,gs:[MB.Sizes]
	cmp     word ptr gs:[MB.Sizes],0
	je      itsend
	cmp     dx,cx
	je      foundmcb
	ja      itsend
        inc     dx
	cmp	gs:[MB.IsNotLast],true
	je	searchfree2
itsend:
	stc
	pop	dx bx
	ret
foundmcb:
	clc
	pop	dx bx
	ret		
	
;Renvoie en GS le MCB qui correspond a ds:si
MBFind:
        push    ax bx si di
        mov	bx,cs:firstmb
	dec	bx
	dec	bx
	mov     di,MB.Names
search:
	mov     gs,bx
	cmp	gs:[MB.Check],'NH'
	jne	itsend2
        inc     bx
        inc     bx
	add	bx,gs:[MB.Sizes]
	cmp     word ptr gs:[MB.Sizes],0
	je      itsend2
	push    si di
cmpnames:
        mov     al,gs:[di]
        cmp     al,ds:[si]
        jne     ok
        cmp     al,0
        je      ok
        inc     si
        inc     di
        jmp     cmpnames
ok:
        pop     di si
	je      foundmcb2
	cmp	gs:[MB.IsNotLast],true
	je	search
itsend2:
	stc
	pop	di si bx ax
	ret
foundmcb2:
        mov     bx,gs
        inc     bx
        inc     bx
        mov     gs,bx
	clc
	pop	di si bx ax
	ret
		
;Renvoie en GS le sous mcb qui correspond a ds:si et qui appartien a dx
MBFindsb:
        push    ax bx si di
        mov	bx,cs:firstmb
	dec	bx
	dec	bx
	mov     di,MB.Names
search2:
	mov     gs,bx
	cmp	gs:[MB.Check],'NH'
	jne	itsend3
        inc     bx
        inc     bx
	add	bx,gs:[MB.Sizes]
	cmp     word ptr gs:[MB.Sizes],0
	je      itsend3
	push    si di
cmpnames2:
        mov     al,gs:[di]
        cmp     al,ds:[si]
        jne     ok2
        cmp     al,0
        je      ok2
        inc     si
        inc     di
        jmp     cmpnames2
ok2:
        pop     di si
	jne     notfoundmcb2
	cmp     gs:[MB.Reference],dx
	je      foundmcb3
notfoundmcb2:
	cmp	gs:[MB.IsNotLast],true
	je	search2
itsend3:
	stc
	pop	di si bx ax
	ret
foundmcb3:
        mov     bx,gs
        inc     bx
        inc     bx
        mov     gs,bx
	clc
	pop	di si bx ax
	ret
	
;Creér un bloc de nom ds:si de taille cx (octets) -> n°segment dans GS
MBCreate:
        push    bp
        mov     bp,sp
        mov     gs,ss:[bp+6]
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
	mov	es:[MB.Reference],gs
	mov	es:[MB.IsResident],False
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
	inc     bx
	inc     bx	
        sub	ax,cx
	cmp     ax,0
	je      nofree
	dec	ax
	dec	ax
	mov	es:[MB.Sizes],cx
	add	cx,bx
	mov	es,cx	
	mov	es:[MB.IsNotLast],dl
	mov	es:[MB.IsResident],False
	mov	es:[MB.Reference],Free
	mov	es:[MB.Sizes],ax
	mov	dword ptr es:[MB.Names],'eerF'
	mov	dword ptr es:[MB.Names+4],0
	mov	es:[MB.Check],'NH'
nofree:
	mov	gs,bx
	clc
	pop	es di si dx cx bx ax
	pop     bp
	ret
wasntgood:
	stc
	pop	es di si dx cx bx ax
        pop     bp
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
	dec     bx
	mov	es,bx
	mov	es:[MB.IsResident],True
	pop	es bx
	ret
	
;Rend le segment GS résident
MBnonresident:
	push	bx es
	mov	bx,gs
	dec	bx
	dec     bx
	mov	es,bx
	mov	es:[MB.IsResident],False
	pop	es bx
	ret
	
end start
