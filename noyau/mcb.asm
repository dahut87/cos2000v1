.model tiny
.486
smart
.code

org 0100h

include ..\include\mem.h
include ..\include\divers.h

start:
maxfunc equ 9

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
         
FirstMB dw 0

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
pushad
 mov ah,0Dh
 mov cx,16
 mov dx,1999h
 int 47h
popad
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

;==============================Affiche le nombre nb hexa en EDX de taille CX et couleur BL==============
ShowHex:
        push    ax bx cx edx si di
        mov     di,cx
        sub     cx,32
        neg     cx
        shl     edx,cl
        shr     di,2
        mov 	ah,09h
        and 	bx,1111b
Hexaize:
        rol     edx,4
        mov     si,dx
	and	si,1111b
	mov	al,cs:[si+offset tab]
	push    cx
	mov     cx,1
        cmp     al,32
        jb       control2
        mov         ah,09h
        int       10h
control2:
        mov    ah,0Eh
        int    10h
        pop     cx
        dec     di
        jnz     Hexaize
        pop     di si edx cx bx ax
        ret
Tab db '0123456789ABCDEF'

;==============================Affiche une chaine DS:SI de couleur BL==============
showstr:
        push ax bx cx si
        mov cx,1
again:
        lodsb
        or al,al
        jz fin
        and bx,0111b
        cmp al,32
        jb  control
        mov ah,09h
        int 10h
control:
        mov ah,0Eh
        int 10h
        jmp again
        fin:
        pop si cx bx ax
        ret


;================================================
;Routine de débogage
;================================================
regdata:
eaxr dd 0
ebxr dd 0
ecxr dd 0
edxr dd 0
esir dd 0
edir dd 0
espr dd 0
ebpr dd 0
csr dw 0
dsr dw 0
esr dw 0
fsr dw 0
gsr dw 0
ssr dw 0

reg db 0Dh,0Ah,"eax : ",0
    db 0Dh,0Ah,"ebx : ",0
    db 0Dh,0Ah,"ecx : ",0
    db 0Dh,0Ah,"edx : ",0
    db 0Dh,0Ah,"esi : ",0
    db 0Dh,0Ah,"edi : ",0
    db 0Dh,0Ah,"esp : ",0
    db 0Dh,0Ah,"ebp : ",0
    db 0Dh,0Ah,"cs  : ",0
    db 0Dh,0Ah,"ds  : ",0
    db 0Dh,0Ah,"es  : ",0
    db 0Dh,0Ah,"fs  : ",0
    db 0Dh,0Ah,"gs  : ",0
    db 0Dh,0Ah,"ss  : ",0

showreg:
pushad
pushf
push ds
mov cs:[eaxr],eax
mov cs:[ebxr],ebx
mov cs:[ecxr],ecx
mov cs:[edxr],edx
mov cs:[esir],esi
mov cs:[edir],edi
mov cs:[espr],esp
mov cs:[ebpr],ebp
mov cs:[csr],cs
mov cs:[dsr],ds
mov cs:[esr],es
mov cs:[fsr],fs
mov cs:[gsr],gs
mov cs:[ssr],ss
push cs
pop ds
mov si,offset poppp
call Showstr
mov si,offset reg
mov di,offset regdata
mov bx,7
showregs:
cmp byte ptr cs:[si+6],":"
jne endshowregs
call Showstr
cmp byte ptr cs:[si+4]," "
je segsss
mov edx,cs:[di]
mov cx,32
call Showhex
add di,4
jmp showmax
segsss:
mov dx,cs:[di]
mov cx,16
call Showhex
add di,2
showmax:
add si,9
mov bp,dx
push si
mov si,offset beginds
call showstr
mov si,bp
mov cx,8
mov al,0
letshow:
mov dl,ds:[si]
inc si
call showhex
inc al
cmp al,10
jb letshow
mov si,offset ende
call showstr
mov si,offset begines
call showstr
mov si,bp
mov cx,8
mov al,0
letshow2:
mov dl,es:[si]
inc si
call showhex
inc al
cmp al,10
jb letshow2
mov si,offset ende
call showstr
pop si
jmp showregs
endshowregs:
mov si,offset poppp
call Showstr
xor ax,ax
int 16h
pop ds
popf
popad
ret
begines db ' es[',0
beginds db ' ds[',0
ende db '] ',0	
	
	
	
	
poppp db '*********',0	
	
	
	
	
	
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
	dec	ax
	dec	ax
	cmp     ax,0
	js	nofree
	je      nofree
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
	mov	es,bx
	mov	es:[MB.IsResident],True
	pop	es bx
	ret
	
end start
