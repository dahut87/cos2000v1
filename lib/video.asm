.model tiny
.486
smart
locals
.code
org 0h

include ..\include\mem.h

start:
header exe <,1,0,,,,offset exports,>

exports:
         db "print",0
         dw print
         db "showdate",0
         dw showdate
         db "showtime",0
         dw showtime
         db "showname",0
         dw showname
         db "showattr",0
         dw showattr
         db "showsize",0
         dw showsize
         db "showspace",0
         dw showspace
         db "showline",0
         dw showline
         db "showchar",0
         dw showchar
         db "showint",0
         dw ShowInt
         db "Showsigned",0
         dw Showsigned
         db "showhex",0
         dw ShowHex
         db "showbin",0
         dw Showbin
         db "showbcd",0
         dw ShowBCD
         db "showstring",0
         dw showstring
         db "showstring0",0
         dw showstring0
         dw 0

;================PRINT==============
;Affiche la chaine %0 en utilisant les parametres de formatage %x....%x
;-> %0 %x
;<-
;===================================
print PROC FAR
        ARG     pointer:word=taille
        push    bp
        mov     bp,sp
        push    cx si di
        xor     di,di
        mov     si,[pointer]
@@strinaize0:
        mov     cl,[si]
        cmp     cl,0
        je      @@no0
        cmp     cl,'%'
        je      @@special
@@showit:
        call	charout	
        inc     si
        jmp     @@strinaize0
@@special:
        cmp     byte ptr [si+1],'%'
        jne     @@notshowit
        inc     si
        jmp     @@showit
@@notshowit:
        mov     cl,byte ptr [si+1]
        cmp     cl,'c'
        je      @@showchar
        cmp     cl,'i'
        je      @@showint
        cmp     cl,'j'
        je      @@showsigned
        cmp     cl,'h'
        je      @@showhex
        cmp     cl,'b'
        je      @@showbin
        cmp     cl,'s'
        je      @@showstring
        cmp     cl,'0'
        je      @@showstring0
        cmp     cl,'d'
        je      @@showbcd
        cmp     cl,'z'
        je      @@showsize
        cmp     cl,'a'
        je      @@showattr
        cmp     cl,'n'
        je      @@showname
        cmp     cl,'t'
        je      @@showtime
        cmp     cl,'d'
        je      @@showdate
        clc
        jmp     @@no0

@@showchar:
        push    word ptr [offset pointer+di+2]
        call    showchar
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showint:
        push    dword ptr [offset pointer+di+2]
        call    showint
        add     si,2
        add     di,4
        jmp     @@strinaize0

@@showsigned:
        call    @@Chosesize
        call    showsigned
        jmp     @@strinaize0

@@showhex:
        call    @@Chosesize
        call    showhex
        jmp     @@strinaize0

@@showbin:
        call    @@Chosesize
        call    showbin
        jmp     @@strinaize0

@@showstring:
        push    word ptr [offset pointer+di+2]
        call    showstring
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showstring0:
        push    word ptr [offset pointer+di+2]
        call    showstring0
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showbcd:
        call    @@Chosesize
        call    showbcd
        jmp     @@strinaize0

@@showsize:
        push    dword ptr [offset pointer+di+2]
        call    showsize
        add     si,2
        add     di,4
        jmp     @@strinaize0

@@showattr:
        push    word ptr [offset pointer+di+2]
        call    showattr
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showname:
        push    word ptr [offset pointer+di+2]
        call    showname
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showtime:
        push    word ptr [offset pointer+di+2]
        call    showtime
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showdate:
        push    word ptr [offset pointer+di+2]
        call    showdate
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@Chosesize:
        pop     cx
        push    dword ptr [offset pointer+di+2]
        add     di,4
        cmp     byte ptr [si+2],'B'
        je      @@byte
        cmp     byte ptr [si+2],'W'
        je      @@word
        cmp     byte ptr [si+2],'D'
        je      @@dword
        dec     si

@@word:
        push    16
        add     si,3
        push    cx
        retn

@@byte:
        push    8
        add     si,3
        push    cx
        retn

@@dword:
        push    32
        add     si,3
        push    cx
        retn


@@no0:
        add     di,bp
        add     di,2
        mov     cx,ss:[bp+2]
        mov     ss:[di+2],cx
        mov     cx,ss:[bp+4]
        mov     ss:[di+4],cx
        mov     cx,ss:[bp]
        mov     ss:[di],cx
        mov     bp,di
        pop     di si cx
        mov     sp,bp
        pop     bp
        retf

print ENDP
;================TESTS==============
;met dans DX le contenu de %0
;-> %0
;<-
;===================================
tests PROC FAR
        ARG     date:word=taille
        push    bp
       	mov     bp,sp
	push	ax cx edx
        mov     dx,[date]
	pop	edx cx ax
	pop     bp
	retf    taille
tests ENDP

;================SHOWDATE==============
;Affiche la date contenu en %0
;-> %0
;<-
;======================================
ShowDate PROC FAR
        ARG     date:word=taille
        push    bp
       	mov     bp,sp
	push	edx
	xor	edx,edx
	mov	dx,[date]
	and	dx,11111b
	push    edx
	push    2
	call	showfixint
	push    '/'
	call	showchar
	mov	dx,[date]
	shr	dx,5
	and	dx,111b
	push    edx
	push    2
	call	showfixint
	push	'/'
	call	showchar
	mov	dx,[date]
	shr	dx,8
	and	dx,11111111b
	add	dx,1956
	push    edx
	push    4
	call	showfixint
	pop	edx
	pop     bp
	retf    taille
ShowDate ENDP

;================SHOWTIME==============
;Affiche l'heure contenu en %0
;-> %0
;<-
;======================================
ShowTime PROC FAR
        ARG     time:word=taille
        push    bp
       	mov     bp,sp
	push 	edx
	xor 	edx,edx
	mov	dx,[time]
	shr	dx,11
	and	dx,11111b
	push    edx
	push    2
	call	showfixint
	push    ':'
	call	showchar
	mov	dx,[time]
	shr	dx,5
	and	dx,111111b
	push    edx
	push    2
	call	showfixint
	push    ':'
	call	showchar
	mov	dx,[time]
	and	dx,11111b
	shl	dx,1
	push    edx
	push    2
	call	showfixint
	pop	edx
	pop     bp
	retf    taille
ShowTime ENDP
	
;================SHOWNAME==============
;Affiche le nom pointé par ds:%0
;-> ds:%0
;<-
;======================================
ShowName PROC FAR
        ARG     thename:word=taille
        push    bp
       	mov     bp,sp
	push	cx si
	mov     si,[thename]
	xor	cx,cx
@@showthename:
	push    word ptr ds:[si]
	call	showchar
	inc	si
	inc	cx
	cmp	cx,8
	jne	@@suiteaname
	push    ' '
	call	showchar
@@suiteaname:
	cmp	cx,8+3
	jb	@@showthename
	pop	si cx
	pop     bp
	retf    taille
ShowName ENDP

;================SHOWATTR==============
;Affiche les attributs spécifié par %0
;-> %0
;<-
;======================================
ShowAttr PROC FAR
        ARG     attr:word=taille
        push    bp
       	mov     bp,sp
	test 	[attr],00000001b
	je	@@noreadonly
	push    'L'	
	jmp	@@readonly
@@noreadonly:
	push    '-'
@@readonly:
	call	showchar
	test 	[attr],00000010b
	je	@@nohidden
	push    'C'	
	jmp	@@hidden
@@nohidden:
	push    '-'
@@hidden:
	call	showchar
	test 	[attr],00000100b
	je	@@nosystem
	push    'S'	
	jmp	@@system
@@nosystem:
	push    '-'
@@system:
	call	showchar
	test 	[attr],00100000b
	je	@@noarchive
	push    'A'	
	jmp	@@archive
@@noarchive:
	push    '-'
@@archive:
	call	showchar
	test 	[attr],00010000b
	je	@@nodirectory
	push    'R'	
	jmp	@@directory
@@nodirectory:
	push    '-'
@@directory:
	call	showchar
	pop	bp
	retf    taille
ShowAttr ENDP

;================SHOWSIZE==============
;Affiche le nom pointé par %0
;-> %0
;<-
;======================================
ShowSize PROC FAR
        ARG     thesize:dword=taille
        push    bp
       	mov     bp,sp
	push 	edx ds
	push	cs
	pop	ds
	mov     edx,[thesize]
	cmp	edx,1073741824
	ja	@@giga
	cmp	edx,1048576*9
	ja	@@mega
	cmp	edx,1024*9
	ja	@@kilo
	push    edx
	push    4
	call	showintR
	push    offset unit
	call	showstring0
	jmp	@@finsize
@@kilo:
	shr	edx,10
	push    edx
	push    4
	call	showintR
	push    offset unitkilo
	call	showstring0
	jmp	@@finsize
@@mega:
	shr	edx,20
	push    edx
	push    4
	call	showintR
	push    offset unitmega
	call	showstring0
	jmp	@@finsize
@@giga:
	shr	edx,30
	push    edx
	push    4
	call	showintR
	push    offset unitgiga
	call	showstring0
@@finsize:
	pop	ds edx
        pop     bp
	retf    taille

unit db ' o ',0
unitkilo db ' ko',0
unitmega db ' mo',0
unitgiga db ' go',0
ShowSize ENDP

;==========SHOWSPACE===========
;met un espace aprés le curseur
;->
;<-
;==============================
showspace PROC FAR
        push    bp
       	mov     bp,sp
	push 	cx
	mov   	cl,' '
        call  	charout
        clc
        pop   	cx
        pop     bp
	retf
showspace ENDP

;==========SHOWLINE===============
;remet le curseur text a la ligne avec un retfour chariot
;->
;<-
;=================================
showline PROC FAR
        push     ax
        mov      ah,06
        int      47h
        pop      ax
	retf
 showline ENDP

;==========SHOWCHAR===========
;met un caractère de code ASCII %0 aprés le curseur
;-> %0
;<-
;=============================
showchar PROC FAR
        ARG     char:word=taille
        push    bp
       	mov     bp,sp
       	push    cx
        mov     cx,[char]
	call	charout
	pop     cx
	pop     bp
	retf    taille
showchar ENDP

;==========SHOWINT===========
;Affiche un entier %0 aprés le curseur
;-> %0
;<-
;============================
ShowInt PROC FAR
        ARG     integer:dword=taille
        push    bp
       	mov     bp,sp
	push	eax bx cx edx esi
      	xor	cx,cx
	mov   	eax,[integer]
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
@@decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	cs:[bx],dl
	dec   	bx
      	cmp   	ax,0
      	jne   	@@decint
	mov	ax,cx
@@showinteger:
	inc	bx
	mov	cl,cs:[bx]
	call	charout
	dec	ax
	jnz	@@showinteger
      	pop   	esi edx cx bx eax
      	pop     bp
	retf    taille

showbuffer 	db 50 dup (0FFh)
ShowInt ENDP

;==========SHOWFIXINT===========
;Affiche un entier %0 aprés le curseur de taille %1
;-> %0 un entier
;<-
;===========================================
ShowfixInt PROC FAR
        ARG     sizeofint:word,integer:dword=taille
        push    bp
       	mov     bp,sp
	push	eax bx cx edx esi di
	mov	di,[sizeofint]
      	xor	cx,cx
	mov   	eax,[integer]
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
@@decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	cs:[bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	@@nomuch
      	cmp   	ax,0
      	jne   	@@decint
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
@@rego:
	mov 	byte ptr cs:[bx],'0'
	dec    	bx
	dec    	cx
	jnz	@@rego
	jmp 	@@finishim
@@nomuch:
	mov	ax,di
@@finishim:
@@showinteger:
	inc	bx
	mov     cl,cs:[bx]
	call	charout
	dec	ax
	jnz	@@showinteger
      	pop  	di esi edx cx bx eax
      	pop     bp
	retf    taille
ShowfixInt ENDP

;==========SHOWINTR===========
;Affiche un entier %0 aprés le curseur de taille %1
;-> %0 %1
;<-
;=============================
ShowIntR PROC FAR
        ARG     sizeofint:word,integer:dword=taille
        push    bp
       	mov     bp,sp
	push	eax bx cx edx esi di
	mov	di,[sizeofint]
      	xor	cx,cx
	mov   	eax,[integer]
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
@@decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	cs:[bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	@@nomuch
      	cmp   	ax,0
      	jne   	@@decint
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
@@rego:
	mov 	byte ptr cs:[bx],' '
	dec    	bx
	dec    	cx
	jnz	@@rego
	jmp 	@@finishim
@@nomuch:
	mov	ax,di
@@finishim:
@@showinteger:
	inc	bx
	mov	cl,cs:[bx]
	call	charout
	dec	ax
	jnz	@@showinteger
      	pop  	di esi edx cx bx eax
      	pop     bp
	retf    taille
ShowIntR ENDP

;==========SHOWSIGNED===========
;Affiche un entier %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;==============================================
Showsigned PROC FAR
        ARG     sizeofint:word,integer:dword=taille
        push    bp
       	mov     bp,sp
	push 	ebx cx edx
	mov	ebx,[integer]	
	mov	cx,[sizeofint]	
	xor	edx,edx
	cmp     cx,1
	ja 	@@signed16
	mov	dl,bl
	cmp	dl,7Fh
	jbe	@@notsigned
	neg 	dl
	jmp	@@showminus
@@signed16:
	cmp     cx,2
	ja 	@@signed32
	mov 	dx,bx
	cmp	dx,7FFFh
	jbe	@@notsigned
	neg	dx
	jmp	@@showminus
@@signed32:	
	mov	edx,ebx
	cmp	edx,7FFFFFFFh
	jbe	@@notsigned
	neg 	edx
@@showminus:
	push    '-'
	call 	showchar
@@notsigned:
        push    edx
	call 	showint
	pop 	edx cx ebx
	pop     bp
	retf    taille
Showsigned ENDP

;==========SHOWHEX===========
;Affiche un nombre hexadécimal %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
ShowHex PROC FAR
        ARG     sizeofint:word,integer:dword=taille
        push    bp
       	mov     bp,sp
       	push  	ax bx cx edx
       	mov     edx,[integer]
       	mov   	cx,[sizeofint]
	shr   	ax,2
       	sub   	cx,32
       	neg   	cx
       	shl   	edx,cl
       	mov   	ax,[sizeofint]
	shr   	ax,2
@@Hexaize:
       	rol   	edx,4
       	mov   	bx,dx
       	and   	bx,0fh
       	mov   	cl,cs:[bx+offset Tab]
       	call	charout
       	dec   	al
       	jnz   	@@Hexaize
       	pop   	edx cx bx ax
       	pop     bp
       	retf    taille

Tab 	db '0123456789ABCDEF'
ShowHex ENDP

;==========SHOWBIN===========
;Affiche un nombre binaire %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
Showbin PROC FAR
        ARG     sizeofint:word,integer:dword=taille
        push    bp
       	mov     bp,sp
       	push   	ax cx edx
        mov     edx,[integer]
       	mov   	cx,[sizeofint]
       	sub     cx,32
       	neg     cx
       	shl     edx,cl
       	mov   	ax,[sizeofint]
@@binaize:
        rol     edx,1
        mov     cl,'0'
        adc     cl,0
        call	charout
        dec     al
        jnz     @@binaize
        pop     edx cx ax
        pop     bp
        retf    taille
Showbin ENDP

;==========SHOWBCD===========
;Affiche un nombre en BCD %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
ShowBCD PROC FAR
        ARG     sizeofint:word,integer:dword=taille
        push    bp
       	mov     bp,sp
        push    ax cx edx
        mov     edx,[integer]
        mov     ax,[sizeofint]
        shr     ax,2
        sub     cx,32
        neg     cx
        shl     edx,cl
@@BCDaize:
        rol     edx,4
        mov     cl,dl
        and     cl,0fh
        add     cl,'0'
        call    charout
        dec     al
        jnz     @@BCDaize
        pop     edx cx ax
        pop     bp
        retf    taille
ShowBCD ENDP

;==========SHOWSTRING===========
;Affiche une chaine de caractère pointée par ds:%1 aprés le curseur
;-> ds:%1 pointeur chaine type pascal
;<-
;===============================
showstring PROC FAR
        ARG     pointer:word=taille
        push    bp
       	mov     bp,sp
        push    bx cx si
        mov     si,[pointer]
        mov     bl,[si]
@@strinaize:
        inc     si
        mov     cl,[si]
        call	charout
        dec     bl
        jnz     @@strinaize
        pop     si cx bx
        pop     bp
        retf    taille
showstring ENDP

;==========SHOWSTRING0===========
;Affiche une chaine de caractère pointée par ds:%1 aprés le curseur
;-> ds:%1 pointeur chaine type zéro terminal
;<-
;================================
showstring0 PROC FAR
        ARG     pointer:word=taille
        push    bp
        mov     bp,sp
        push    cx si
        mov     si,[pointer]	
@@strinaize0:
        mov     cl,[si]
        cmp     cl,0
        je      @@no0
        call	charout	
        inc     si
        jmp     @@strinaize0
@@no0:
        pop     si cx
        pop     bp
        retf    taille
showstring0 ENDP

;Envoie le caractère CL vers l'ecran
charout PROC NEAR
push ax bx cx
         mov ah,0Eh
         mov bl,7
         mov al,cl
         int 10h
pop cx bx ax
ret

        ;push ax dx
        ;mov  ah,7
        ;mov  dl,cl
        ;int  47h
        ;pop  dx ax
        ;ret
charout ENDP

end start
