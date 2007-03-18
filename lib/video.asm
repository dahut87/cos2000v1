model tiny,stdcall
p486
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"

org 0h

header exe <"CE",1,0,0,offset exports,offset imports,,>

exporting
declare print
declare showdate
declare showtime
declare showname
declare showattr
declare showsize
declare showspace
declare showint
declare showsigned
declare showhex
declare showbin
declare showbcd
declare showstring
declare showstring0
declare showintr
declare showintl
ende

importing
use VIDEO,addline
use VIDEO,setcolor
use VIDEO,getxy
use VIDEO,setxy
use VIDEO,setvideomode
use VIDEO,setfont
use VIDEO,clearscreen
use VIDEO,enablescroll
use VIDEO,disablescroll
use VIDEO,showchar
endi
         

;================PRINT==============
;Affiche la chaine %0 en utilisant les parametres de formatage %x....%x
;-> %0 %x
;<-
;===================================
PROC print FAR
        ARG     @@pointer:word
        push    ax bx cx si di
        xor     di,di
        mov     si,[@@pointer]
@@strinaize0:
        mov     cl,[si]
        cmp     cl,0
        je      @@no0
        cmp     cl,'%'
        je      @@special
        cmp     cl,'\'
        je      @@special2
@@showit:
        xor     ch,ch
        call    [cs:showchar],cx,0FFFFh
        inc     si
        jmp     @@strinaize0
@@special:
        cmp     [byte ptr si+1],'%'
        jne     @@notshowit
        inc     si
        jmp     @@showit
@@notshowit:
        mov     cl,[byte ptr si+1]
        cmp     cl,'c'
        je      @@showchar
        cmp     cl,'u'
        je      @@showint
        cmp     cl,'v'
        je      @@showfixint
        cmp     cl,'w'
        je      @@showintr
        cmp     cl,'i'
        je      @@showsigned
        cmp     cl,'h'
        je      @@showhex
        cmp     cl,'b'
        je      @@showbin
        cmp     cl,'s'
        je      @@showstring
        cmp     cl,'0'
        je      @@showstring0
        cmp     cl,'y'
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
        cmp     [byte ptr si+2],'M'
        je      @@showmultchar
        call    [cs:showchar],[word ptr @@pointer+di+2],0FFFFh
        add     si,2
        add     di,2
        jmp     @@strinaize0
@@showmultchar:
        mov     cx,[offset @@pointer+di+2+2]
        cmp     cx,0
        je      @@nextfunc
@@showcharx:
        call    [cs:showchar],[word ptr @@pointer+di+2],0FFFFh
        dec     cx
        jnz     @@showcharx
@@nextfunc:
        add     si,3
        add     di,4
        jmp     @@strinaize0

@@showint:
        call    showint,[dword ptr @@pointer+di+2]
        add     si,2
        add     di,4
        jmp     @@strinaize0

@@showfixint:
        call    showintl,[word ptr @@pointer+di+6],[dword ptr @@pointer+di+2]
        add     di,6
        add     si,2
        jmp     @@strinaize0

@@showintr:
        call    showintr,[word ptr @@pointer+di+6],[dword ptr @@pointer+di+2]
        add     di,6
        add     si,2
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
        cmp     [byte ptr si+2],'P'
        je      @@showstring@@pointer
        call    showstring,[word ptr @@pointer+di+2]
        add     si,2
        add     di,2
        jmp     @@strinaize0
@@showstring@@pointer:
        push    ds
        mov     ds,[offset @@pointer+di+2+2]
        call    showstring,[word ptr @@pointer+di+2]
        add     si,3
        add     di,4
        pop     ds
        jmp     @@strinaize0

@@showstring0:
        cmp     [byte ptr si+2],'P'
        je      @@showstring0@@pointer
        call    showstring0,[word ptr offset @@pointer+di+2]
        add     si,2
        add     di,2
        jmp     @@strinaize0
@@showstring0@@pointer:
        push    ds
        mov     ds,[offset @@pointer+di+2+2]
        call    showstring0,[word ptr offset @@pointer+di+2]
        add     si,3
        add     di,4
        pop     ds
        jmp     @@strinaize0

@@showbcd:
        call    @@Chosesize
        call    showbcd
        jmp     @@strinaize0

@@showsize:
        call    showsize,[dword ptr offset @@pointer+di+2]
        add     si,2
        add     di,4
        jmp     @@strinaize0

@@showattr:
        call    showattr,[word ptr offset @@pointer+di+2]
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showname:
        call    showname,[word ptr offset @@pointer+di+2]
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showtime:
        call    showtime,[word ptr offset @@pointer+di+2]
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@showdate:
        call    showdate,[word ptr offset @@pointer+di+2]
        add     si,2
        add     di,2
        jmp     @@strinaize0

@@Chosesize:
        pop     cx
        push    [dword ptr offset @@pointer+di+2]
        add     di,4
        cmp     [byte ptr si+2],'B'
        je      @@byte
        cmp     [byte ptr si+2],'W'
        je      @@word
        cmp     [byte ptr si+2],'D'
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

@@special2:
        cmp     [byte ptr si+1],'\'
        jne     @@notshowit2
        inc     si
        jmp     @@showit
@@notshowit2:
        mov     cl,[byte ptr si+1]
        cmp     cl,'l'
        je      @@showline
        cmp     cl,'g'
        je      @@goto
        cmp     cl,'h'
        je      @@gotox
        cmp     cl,'c'
        je      @@color
        cmp     cl,'m'
        je      @@setvideomode
        cmp     cl,'e'
        je      @@clearscreen
        cmp     cl,'s'
        je      @@savestate
        cmp     cl,'r'
        je      @@restorestate
        cmp     cl,'i'
        je      @@enablescroll
        cmp     cl,'j'
        je      @@disablescroll
        cmp     cl,'f'
        je      @@setfont
        clc
        jmp     @@no0

@@color:
        mov     al,[si+2]
        sub     al,'0'
        shl     al,4
        add     al,[si+3]
        sub     al,'0'
        xor     ah,ah
        call    [cs:setcolor],ax
        add     si,4
        jmp     @@strinaize0

@@gotox:
        mov     bh,[si+2]
        sub     bh,'0'
        mov     bl,bh
        shl     bl,3
        add     bl,bh
        add     bl,bh
        add     bl,[si+3]
        sub     bl,'0'
        xor     bh,bh
        call    [cs:getxy]
        xor     ah,ah
        call    [cs:setxy],bx,ax
        add     si,4
        jmp     @@strinaize0

@@setvideomode:
        mov     ah,[si+2]
        sub     ah,'0'
        mov     al,ah
        shl     al,3
        add     al,ah
        add     al,ah
        add     al,[si+3]
        sub     al,'0'
        xor     ah,ah
        call    [cs:setvideomode]
        add     si,4
        jmp     @@strinaize0

@@setfont:
        mov     ah,[si+2]
        sub     ah,'0'
        mov     al,ah
        shl     al,3
        add     al,ah
        add     al,ah
        add     al,[si+3]
        sub     al,'0'
        xor     ah,ah
        call    [cs:setfont],ax
        add     si,4
        jmp     @@strinaize0

@@showline:
        call    [cs:addline]
        add     si,2
        jmp     @@strinaize0

@@clearscreen:
        call    [cs:clearscreen]
        add     si,2
        jmp     @@strinaize0

@@savestate:
        mov     ah,40
        int     47h
        add     si,2
        jmp     @@strinaize0

@@restorestate:
        mov     ah,41
        int     47h
        add     si,2
        jmp     @@strinaize0

@@enablescroll:
        call    [cs:enablescroll]
        add     si,2
        jmp     @@strinaize0

@@disablescroll:
        call    [cs:disablescroll]
        add     si,2
        jmp     @@strinaize0

@@goto:
        mov     ah,[si+2]
        sub     ah,'0'
        mov     al,ah
        shl     al,3
        add     al,ah
        add     al,ah
        add     al,[si+3]
        sub     al,'0'
        xor     ah,ah
          ;
        mov     bh,[si+5]
        sub     bh,'0'
        mov     bl,bh
        shl     bl,3
        add     bl,bh
        add     bl,bh
        add     bl,[si+6]
        sub     bl,'0'
        xor     bh,bh
        call    [cs:setxy],ax,bx
        mov     ah,25
        int     47h
        add     si,7
        jmp     @@strinaize0

@@no0:
        add     di,bp
        mov     ax,[ss:bp]   ;BP
        mov     bx,[ss:bp+2] ;IP
        mov     cx,[ss:bp+4] ;CS
        mov     [ss:di],ax
        mov     [ss:di+2],bx
        mov     [ss:di+4],cx
        mov     bp,di
        pop     di si cx bx ax
        mov     sp,bp
        ret

ENDP print


;================SHOWDATE==============
;Affiche la date contenu en %0
;-> %0
;<-
;======================================
PROC showdate FAR
        ARG     @dates:word
	USES	edx
	xor	edx,edx
	mov	dx,[@dates]
	and	dx,11111b
	call	showintl,2,edx	
	call	[cs:showchar],'/',0FFFFh
	mov	dx,[@dates]
	shr	dx,5
	and	dx,111b
	call	showintl,2,edx	
	call	[cs:showchar],'/',0FFFFh
	mov	dx,[@dates]
	shr	dx,8
	and	dx,11111111b
	add	dx,1956
	call	showintl,2,edx	
	ret
ENDP showdate

;================SHOWTIME==============
;Affiche l'heure contenu en %0
;-> %0
;<-
;======================================
PROC showtime FAR
        ARG     @times:word
	USES 	edx
	xor 	edx,edx
	mov	dx,[@times]
	shr	dx,11
	and	dx,11111b
	call	showintl,2,edx
	call	[cs:showchar],':',0FFFFh
	mov	dx,[@times]
	shr	dx,5
	and	dx,111111b
	call	showintl,2,edx
	call	[cs:showchar],':',0FFFFh
	mov	dx,[@times]
	and	dx,11111b
	shl	dx,1
	call	showintl,2,edx
	ret
ENDP showtime
	
;================SHOWNAME==============
;Affiche le nom pointé par ds:%0
;-> ds:%0
;<-
;======================================
PROC showname FAR
        ARG     @thename:word
	USES	cx,si
	mov     si,[@thename]
	xor	cx,cx
@@showthename:
	call	[cs:showchar],[word ptr ds:si],0FFFFh
	inc	si
	inc	cx
	cmp	cx,8
	jne	@@suiteaname
	call	[cs:showchar],' ',0FFFFh
@@suiteaname:
	cmp	cx,8+3
	jb	@@showthename
	ret
ENDP showname

;================SHOWATTR==============
;Affiche les attributs spécifié par %0
;-> %0
;<-
;======================================
PROC showattr FAR
        ARG     @attr:word
       	push    0FFFFh
	test 	[@attr],00000001b
	je	@@noreadonly
	push    'L'	
	jmp	@@readonly
@@noreadonly:
	push    '-'
@@readonly:
	call	[cs:showchar]
	push    0FFFFh
	test 	[@attr],00000010b
	je	@@nohidden
	push    'C'	
	jmp	@@hidden
@@nohidden:
	push    '-'
@@hidden:
	call	[cs:showchar]
	push    0FFFFh
	test 	[@attr],00000100b
	je	@@nosystem
	push    'S'	
	jmp	@@system
@@nosystem:
	push    '-'
@@system:
	call	[cs:showchar]
	push    0FFFFh
	test 	[@attr],00100000b
	je	@@noarchive
	push    'A'	
	jmp	@@archive
@@noarchive:
	push    '-'
@@archive:
	call	[cs:showchar]
	push    0FFFFh
	test 	[@attr],00010000b
	je	@@nodirectory
	push    'R'	
	jmp	@@directory
@@nodirectory:
	push    '-'
@@directory:
	call	[cs:showchar]
	ret
ENDP showattr

;================SHOWSIZE==============
;Affiche le nom pointé par %0
;-> %0
;<-
;======================================
PROC showsize FAR
        ARG     @thesize:dword
	USES 	edx,ds
	push	cs
	pop	ds
	mov     edx,[@thesize]
	cmp	edx,1073741824
	ja	@@giga
	cmp	edx,1048576*9
	ja	@@mega
	cmp	edx,1024*9
	ja	@@kilo
	call	showintr,4,edx
	call	showstring0,offset unit
	jmp	@@finsize
@@kilo:
	shr	edx,10
	call	showintr,4,edx
	call	showstring0,offset unitkilo
	jmp	@@finsize
@@mega:
	shr	edx,20
	call	showintr,4,edx
	call	showstring0,offset unitmega
	jmp	@@finsize
@@giga:
	shr	edx,30
	call	showintr,4,edx
	call	showstring0,offset unitgiga
@@finsize:
	ret

unit db ' o ',0
unitkilo db ' ko',0
unitmega db ' mo',0
unitgiga db ' go',0
ENDP showsize

;==========SHOWSPACE===========
;met un espace aprés le curseur
;->
;<-
;==============================
PROC showspace FAR
        call	[cs:showchar],' ',0FFFFh
        clc
	ret
ENDP showspace


;==========SHOWINT===========
;Affiche un entier %0 aprés le curseur
;-> %0
;<-
;============================
PROC showint FAR
        ARG     @integer:dword
	USES	eax,bx,cx,edx,esi
      	xor	cx,cx
	mov   	eax,[@integer]
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
@@decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	[cs:bx],dl
	dec   	bx
      	cmp   	ax,0
      	jne   	@@decint
	mov	ax,cx
@@showinteger:
	inc	bx
	mov	cl,[cs:bx]
        call	[cs:showchar],cx,0FFFFh
	dec	ax
	jnz	@@showinteger
	ret

showbuffer 	db 50 dup (0FFh)
ENDP showint

;==========SHOWINTL===========
;Affiche un entier %0 aprés le curseur de taille %1 caractère centré a gauche
;-> %0 un entier  % taille en caractères
;<-
;===============================
PROC showintl FAR
        ARG     @sizeofint:word,@integer:dword
	USES	eax,bx,cx,edx,esi,di
	mov	di,[@sizeofint]
      	xor	cx,cx
	mov   	eax,[@integer]
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
@@decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	[cs:bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	@@nomuch
      	cmp   	ax,0
      	jne   	@@decint
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
@@rego:
	mov 	[byte ptr cs:bx],'0'
	dec    	bx
	dec    	cx
	jnz	@@rego
	jmp 	@@finishim
@@nomuch:
	mov	ax,di
@@finishim:
@@showinteger:
	inc	bx
	mov     cl,[cs:bx]
        call	[cs:showchar],cx,0FFFFh
	dec	ax
	jnz	@@showinteger
	ret
ENDP showintl

;==========SHOWINTR===========
;Affiche un entier %0 aprés le curseur de taille %1 caractère centré a droite
;-> %0 un entier  % taille en caractères
;<-
;===============================
PROC showintr FAR
        ARG     @sizeofint:word,@integer:dword
	USES	eax,bx,cx,edx,esi,di
	mov	di,[@sizeofint]
      	xor	cx,cx
	mov   	eax,[@integer]
      	mov   	esi,10
      	mov   	bx,offset showbuffer+27
@@decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	[cs:bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	@@nomuch
      	cmp   	ax,0
      	jne   	@@decint
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
@@rego:
	mov 	[byte ptr cs:bx],' '
	dec    	bx
	dec    	cx
	jnz	@@rego
	jmp 	@@finishim
@@nomuch:
	mov	ax,di
@@finishim:
@@showinteger:
	inc	bx
	mov	cl,[cs:bx]
        call	[cs:showchar],cx,0FFFFh
	dec	ax
	jnz	@@showinteger
	ret
ENDP showintr

;==========SHOWSIGNED===========
;Affiche un entier %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;===============================
PROC showsigned FAR
        ARG     @sizeofint:word,@integer:dword=taille
	USES 	ebx,cx,edx
	mov	ebx,[@integer]	
	mov	cx,[@sizeofint]	
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
	call 	[cs:showchar],'-',0FFFFh
@@notsigned:
	call 	showint,edx,0FFFFh
	ret
ENDP showsigned

;==========SHOWHEX===========
;Affiche un nombre hexadécimal %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
PROC showhex FAR
        ARG     @sizeofint:word,@integer:dword=taille
        USES  	ax,bx,cx,edx
       	mov     edx,[@integer]
       	mov   	cx,[@sizeofint]
       	mov     ax,cx
	shr   	ax,2
       	sub   	cx,32
       	neg   	cx
       	shl   	edx,cl
@@Hexaize:
       	rol   	edx,4
       	mov   	bx,dx
       	and   	bx,0fh
       	mov   	cl,[cs:bx+offset Tab]
        call	[cs:showchar],cx,0FFFFh
       	dec   	al
       	jnz   	@@Hexaize
       	ret

Tab 	db '0123456789ABCDEF'
ENDP showhex

;==========SHOWBIN===========
;Affiche un nombre binaire %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
PROC showbin FAR
        ARG     @sizeofint:word,@integer:dword=taille
       	USES   	ax,cx,edx
        mov     edx,[@integer]
       	mov   	cx,[@sizeofint]
       	sub     cx,32
       	neg     cx
       	shl     edx,cl
       	mov   	ax,[@sizeofint]
@@binaize:
        rol     edx,1
        mov     cl,'0'
        adc     cl,0
        call	[cs:showchar],cx,0FFFFh
        dec     al
        jnz     @@binaize
        ret
ENDP showbin

;==========SHOWBCD===========
;Affiche un nombre en BCD %0 de taille %1 aprés le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
PROC showbcd FAR
        ARG     @sizeofint:word,@integer:dword
        USES    ax,cx,edx
        mov     edx,[@integer]
        mov     ax,[@sizeofint]
        mov     cx,ax
        shr     ax,2
        sub     cx,32
        neg     cx
        shl     edx,cl
@@BCDaize:
        rol     edx,4
        mov     cl,dl
        and     cl,0fh
        add     cl,'0'
        call	[cs:showchar],cx,0FFFFh
        dec     al
        jnz     @@BCDaize
        ret
ENDP showbcd

;==========SHOWSTRING===========
;Affiche une chaine de caractère pointée par ds:%1 aprés le curseur
;-> ds:%1 pointeur chaine type pascal
;<-
;===============================
PROC showstring FAR
        ARG     @pointer:word
        USES    bx,si
        mov     si,[@pointer]
        mov     bl,[si]
@@strinaize:
        inc     si
        call	[cs:showchar],[word ptr si],0FFFFh
        dec     bl
        jnz     @@strinaize
        ret
ENDP showstring

;==========SHOWSTRING0===========
;Affiche une chaine de caractère pointée par ds:%1 aprés le curseur
;-> ds:%1 pointeur chaine type zéro terminal
;<-
;================================
PROC showstring0 FAR
        ARG     @pointer:word
        USES    cx,si
        mov     si,[@pointer]	
@@strinaize0:
        mov     cl,[si]
        cmp     cl,0
        je      @@no0
        call	[cs:showchar],cx,0FFFFh	
        inc     si
        jmp     @@strinaize0
@@no0:
        ret
ENDP showstring0

