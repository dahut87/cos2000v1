FirstMB dw 0

;Initialise les blocs de mémoire
MBinit:
	push	ax cx es
	mov	ax,gs
	mov	cs:Firstmb,ax
	dec	ax
	mov	es,ax
	mov	cx,0A000h
	sub	cx,ax
	dec	cx
	mov   es:[MB.Reference],Free
	mov   es:[MB.Sizes],cx
	mov   es:[MB.Check],'NH'
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
	dec   bx
	mov	es,bx
	cmp	es:[MB.Check],'NH'
	je	notforfree
	mov	es:[MB.IsResident],0
	mov	es:[MB.Reference],Free
	mov	dword ptr es:[MB.Names],'eerF'
	mov	dword ptr es:[MB.Names+4],0
	pop	es bx
	ret	

;Creér un bloc de nom ds:si de taille cx (octets) -> n°segement dans GS
MBCreate:
	push	ax bx cx dx si di es	
	shr	cx,4
	inc	cx
	mov	bx,cs:firstmb
	dec	bx
searchfree:
	mov   es,bx
	cmp	es:[MB.Check],'NH'
	jne	wasntgood
	cmp	es:[MB.IsNotLast],True
	sete  dl
	cmp	es:[MB.Reference],Free
	je	weregood
	cmp	dl,False
	je	wasntgood	
notsogood:
	inc	bx
	add	bx,es:[MB.Sizes]
	jmp	searchfree
weregood:
	mov	ax,es:[MB.Sizes]
	cmp	cx,ax
	ja	notsogood
	mov	es:[MB.IsNotLast],True 
	mov	es:[MB.Reference],cs
	mov	es:[MB.IsResident],False
	mov	es:[MB.Sizes],cx
	mov   di,MB.Names
	push	ax cx
	mov 	cx,8
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
      mov   word ptr es:[MB.Check],'NH'
	sub	ax,cx
	dec	ax
	js	nofree
	inc   bx
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

;Rend le segment GS résident
MBresident:
	push	bx es
	mov	bx,gs
	dec	bx
	mov	es,bx
	mov	es:[MB.IsResident],True
	pop	es bx
	ret
