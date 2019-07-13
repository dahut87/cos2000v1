use16
align 1

include "..\include\mem.h"

org 0h

header exe 1

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
declare showchar
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
use VIDEO,showchars
use VIDEO,savestate
use VIDEO,restorestate
endi
         

;================PRINT==============
;Affiche la chaine %0 en utilisant les parametres de formatage %x....%x
;-> %0 %x
;<-
;===================================
proc print pointer:word  
 	  push    ax bx cx si di
        xor     di,di
        mov     si,[pointer]
.strinaize0:
        mov     cl,[si]
        cmp     cl,0
        je      .no0
        cmp     cl,'%'
        je      .special
        cmp     cl,'\'
        je      .special2
.showit:
        xor     ch,ch
        invoke    showchars,cx,0FFFFh
        inc     si
        jmp     .strinaize0
.special:
        cmp     byte [si+1],'%'
        jne     .notshowit
        inc     si
        jmp     .showit
.notshowit:
        mov     cl,byte [si+1]
        cmp     cl,'c'
        je      .showchars
        cmp     cl,'u'
        je      .showint
        cmp     cl,'v'
        je      .showfixint
        cmp     cl,'w'
        je      .showintr
        cmp     cl,'i'
        je      .showsigned
        cmp     cl,'h'
        je      .showhex
        cmp     cl,'b'
        je      .showbin
        cmp     cl,'s'
        je      .showstring
        cmp     cl,'0'
        je      .showstring0
        cmp     cl,'y'
        je      .showbcd
        cmp     cl,'z'
        je      .showsize
        cmp     cl,'a'
        je      .showattr
        cmp     cl,'n'
        je      .showname
        cmp     cl,'t'
        je      .showtime
        cmp     cl,'d'
        je      .showdate
        clc
        jmp     .no0

.showchars:
        cmp     byte [si+2],'M'
        je      .showmultchar
        invoke    showchars,word [pointer+di+2],0FFFFh
        add     si,2
        add     di,2
        jmp     .strinaize0
.showmultchar:
        mov     cx,[pointer+di+2+2]
        cmp     cx,0
        je      .nextfunc
.showcharsx:
        invoke    showchars,word [pointer+di+2],0FFFFh
        dec     cx
        jnz     .showcharsx
.nextfunc:
        add     si,3
        add     di,4
        jmp     .strinaize0

.showint:
        stdcall    showint,dword [pointer+di+2]
        add     si,2
        add     di,4
        jmp     .strinaize0

.showfixint:
        stdcall    showintl,word [pointer+di+6],dword [pointer+di+2]
        add     di,6
        add     si,2
        jmp     .strinaize0

.showintr:
        stdcall    showintr,word [pointer+di+6],dword [pointer+di+2]
        add     di,6
        add     si,2
        jmp     .strinaize0

.showsigned:
        call    .Chosesize
        stdcall    showsigned
        jmp     .strinaize0

.showhex:
        call    .Chosesize
        stdcall    showhex
        jmp     .strinaize0

.showbin:
        call    .Chosesize
        stdcall    showbin
        jmp     .strinaize0

.showstring:
        cmp     byte [si+2],'P'
        je      .showstring.pointer
        stdcall    showstring,word [pointer+di+2]
        add     si,2
        add     di,2
        jmp     .strinaize0
.showstring.pointer:
        push    ds
        mov     ds,[pointer+di+2+2]
        stdcall    showstring,word [pointer+di+2]
        add     si,3
        add     di,4
        pop     ds
        jmp     .strinaize0

.showstring0:
        cmp     byte [si+2],'P'
        je      .showstring0.pointer
        stdcall    showstring0,word [pointer+di+2]
        add     si,2
        add     di,2
        jmp     .strinaize0
.showstring0.pointer:
        push    ds
        mov     ds,[pointer+di+2+2]
        stdcall    showstring0,word [pointer+di+2]
        add     si,3
        add     di,4
        pop     ds
        jmp     .strinaize0

.showbcd:
        call    .Chosesize
        stdcall    showbcd
        jmp     .strinaize0

.showsize:
        stdcall    showsize,dword [pointer+di+2]
        add     si,2
        add     di,4
        jmp     .strinaize0

.showattr:
        stdcall    showattr,word [pointer+di+2]
        add     si,2
        add     di,2
        jmp     .strinaize0

.showname:
        stdcall    showname,word [pointer+di+2]
        add     si,2
        add     di,2
        jmp     .strinaize0

.showtime:
        stdcall    showtime,word [pointer+di+2]
        add     si,2
        add     di,2
        jmp     .strinaize0

.showdate:
        stdcall    showdate,word [pointer+di+2]
        add     si,2
        add     di,2
        jmp     .strinaize0

.Chosesize:
        pop     cx
        push    dword [pointer+di+2]
        add     di,4
        cmp     byte [si+2],'B'
        je      .byte
        cmp     byte [si+2],'W'
        je      .word
        cmp     byte [si+2],'D'
        je      .dword
        dec     si

.word:
        push    16
        add     si,3
        push    cx
        ret

.byte:
        push    8
        add     si,3
        push    cx
        ret

.dword:
        push    32
        add     si,3
        push    cx
        ret

.special2:
        cmp     byte [si+1],'\'
        jne     .notshowit2
        inc     si
        jmp     .showit
.notshowit2:
        mov     cl,byte [si+1]
        cmp     cl,'l'
        je      .showline
        cmp     cl,'g'
        je      .goto
        cmp     cl,'h'
        je      .gotox
        cmp     cl,'c'
        je      .color
        cmp     cl,'m'
        je      .setvideomode
        cmp     cl,'e'
        je      .clearscreen
        cmp     cl,'s'
        je      .savestate
        cmp     cl,'r'
        je      .restorestate
        cmp     cl,'i'
        je      .enablescroll
        cmp     cl,'j'
        je      .disablescroll
        cmp     cl,'f'
        je      .setfont
        clc
        jmp     .no0

.color:
        mov     al,[si+2]
        sub     al,'0'
        shl     al,4
        add     al,[si+3]
        sub     al,'0'
        xor     ah,ah
        invoke    setcolor,ax
        add     si,4
        jmp     .strinaize0

.gotox:
        mov     bh,[si+2]
        sub     bh,'0'
        mov     bl,bh
        shl     bl,3
        add     bl,bh
        add     bl,bh
        add     bl,[si+3]
        sub     bl,'0'
        xor     bh,bh
        invoke    getxy
        xor     ah,ah
        invoke    setxy,bx,ax
        add     si,4
        jmp     .strinaize0

.setvideomode:
        mov     ah,[si+2]
        sub     ah,'0'
        mov     al,ah
        shl     al,3
        add     al,ah
        add     al,ah
        add     al,[si+3]
        sub     al,'0'
        xor     ah,ah
        invoke    setvideomode,ax
        add     si,4
        jmp     .strinaize0

.setfont:
        mov     ah,[si+2]
        sub     ah,'0'
        mov     al,ah
        shl     al,3
        add     al,ah
        add     al,ah
        add     al,[si+3]
        sub     al,'0'
        xor     ah,ah
        invoke    setfont,ax
        add     si,4
        jmp     .strinaize0

.showline:
        invoke    addline
        add     si,2
        jmp     .strinaize0

.clearscreen:
        invoke    clearscreen
        add     si,2
        jmp     .strinaize0

.savestate:
        invoke    savestate
        add     si,2
        jmp     .strinaize0

.restorestate:
        invoke    restorestate
        add     si,2
        jmp     .strinaize0

.enablescroll:
        invoke    enablescroll
        add     si,2
        jmp     .strinaize0

.disablescroll:
        invoke    disablescroll
        add     si,2
        jmp     .strinaize0

.goto:
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
        invoke    setxy,ax,bx
        add     si,7
        jmp     .strinaize0

.no0:
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
        retf
endp


;================SHOWDATE==============
;Affiche la date contenu en %0
;-> %0
;<-
;======================================
proc showdate uses edx, dates:word
	xor	edx,edx
	mov	dx,[dates]
	and	dx,11111b
	stdcall	showintl,2,edx	
	invoke	showchars,'/',0FFFFh
	mov	dx,[dates]
	shr	dx,5
	and	dx,111b
	stdcall	showintl,2,edx	
	invoke	showchars,'/',0FFFFh
	mov	dx,[dates]
	shr	dx,8
	and	dx,11111111b
	add	dx,1956
	stdcall	showintl,2,edx	
	retf
endp

;================SHOWTIME==============
;Affiche l'heure contenu en %0
;-> %0
;<-
;======================================
proc showtime uses edx, times:word 	
	xor 	edx,edx
	mov	dx,[times]
	shr	dx,11
	and	dx,11111b
	stdcall	showintl,2,edx
	invoke	showchars,':',0FFFFh
	mov	dx,[times]
	shr	dx,5
	and	dx,111111b
	stdcall	showintl,2,edx
	invoke	showchars,':',0FFFFh
	mov	dx,[times]
	and	dx,11111b
	shl	dx,1
	stdcall	showintl,2,edx
	retf
endp
	
;================SHOWNAME==============
;Affiche le nom pointe par ds:%0
;-> ds:%0
;<-
;======================================
proc showname uses cx si, thename:word
	mov     si,[thename]
	xor	cx,cx
.showthename:
	invoke	showchars,word [ds:si],0FFFFh
	inc	si
	inc	cx
	cmp	cx,8
	jne	.suiteaname
	invoke	showchars,' ',0FFFFh
.suiteaname:
	cmp	cx,8+3
	jb	.showthename
	retf
endp

;================SHOWATTR==============
;Affiche les attributs specifie par %0
;-> %0
;<-
;======================================
proc showattr, attr:word
       push    0FFFFh
	test 	[attr],00000001b
	je	.noreadonly
	push    'L'	
	jmp	.readonly
.noreadonly:
	push    '-'
.readonly:
	invoke	showchars
	push    0FFFFh
	test 	[attr],00000010b
	je	.nohidden
	push    'C'	
	jmp	.hidden
.nohidden:
	push    '-'
.hidden:
	invoke	showchars
	push    0FFFFh
	test 	[attr],00000100b
	je	.nosystem
	push    'S'	
	jmp	.system
.nosystem:
	push    '-'
.system:
	invoke	showchars
	push    0FFFFh
	test 	[attr],00100000b
	je	.noarchive
	push    'A'	
	jmp	.archive
.noarchive:
	push    '-'
.archive:
	invoke	showchars
	push    0FFFFh
	test 	[attr],00010000b
	je	.nodirectory
	push    'R'	
	jmp	.directory
.nodirectory:
	push    '-'
.directory:
	invoke	showchars
	retf
endp

;================SHOWSIZE==============
;Affiche le nom pointe par %0
;-> %0
;<-
;======================================
proc showsize uses edx ds, thesize:dword
	push	cs
	pop	ds
	mov     edx,[thesize]
	cmp	edx,1073741824
	ja	.giga
	cmp	edx,1048576*9
	ja	.mega
	cmp	edx,1024*9
	ja	.kilo
	stdcall	showintr,4,edx
	stdcall	showstring0,unit
	jmp	.finsize
.kilo:
	shr	edx,10
	stdcall	showintr,4,edx
	stdcall	showstring0,unitkilo
	jmp	.finsize
.mega:
	shr	edx,20
	stdcall	showintr,4,edx
	stdcall	showstring0,unitmega
	jmp	.finsize
.giga:
	shr	edx,30
	stdcall	showintr,4,edx
	stdcall	showstring0,unitgiga
.finsize:
	retf

unit db ' o ',0
unitkilo db ' ko',0
unitmega db ' mo',0
unitgiga db ' go',0
endp

;==========SHOWSPACE===========
;met un espace apres le curseur
;->
;<-
;==============================
proc showspace
        invoke	showchars,' ',0FFFFh
        clc
	retf
endp


;==========SHOWINT===========
;Affiche un entier %0 apres le curseur
;-> %0
;<-
;============================
proc showint uses eax bx cx edx esi, integer:dword
local showbuffer[50]:BYTE
      	xor	cx,cx
	mov   	eax,[integer]
      	mov   	esi,10
      	lea   	bx,[showbuffer+27]
.decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	[cs:bx],dl
	dec   	bx
      	cmp   	ax,0
      	jne   	.decint
	mov	ax,cx
.showinteger:
	inc	bx
	mov	cl,[cs:bx]
        invoke	showchars,cx,0FFFFh
	dec	ax
	jnz	.showinteger
	retf
endp

;==========SHOWINTL===========
;Affiche un entier %0 apres le curseur de taille %1 caractere centre a gauche
;-> %0 un entier  % taille en caracteres
;<-
;===============================
proc showintl uses eax bx cx edx esi di, sizeofint:word,integer:dword
local showbuffer[50]:BYTE
	mov	di,[sizeofint]
      	xor	cx,cx
	mov   	eax,[integer]
      	mov   	esi,10
      	lea   	bx,[showbuffer+27]
.decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	[cs:bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	.nomuch
      	cmp   	ax,0
      	jne   	.decint
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
.rego:
	mov 	byte [cs:bx],'0'
	dec    	bx
	dec    	cx
	jnz	.rego
	jmp 	.finishim
.nomuch:
	mov	ax,di
.finishim:
.showinteger:
	inc	bx
	mov     cl,[cs:bx]
        invoke	showchars,cx,0FFFFh
	dec	ax
	jnz	.showinteger
	retf
endp

;==========SHOWINTR===========
;Affiche un entier %0 apres le curseur de taille %1 caractere centre a droite
;-> %0 un entier  % taille en caracteres
;<-
;===============================
proc showintr uses eax bx cx edx esi di, sizeofint:word,integer:dword	
local showbuffer[50]:BYTE
	mov	di,[sizeofint]
      	xor	cx,cx
	mov   	eax,[integer]
      	mov   	esi,10
      	lea   	bx,[showbuffer+27]
.decint:
      	xor   	edx,edx
      	div   	esi
      	add   	dl,'0'
      	inc   	cx
      	mov   	[cs:bx],dl
	dec   	bx
	cmp 	cx,di
	jae 	.nomuch
      	cmp   	ax,0
      	jne   	.decint
	mov 	ax,di
  	xchg 	cx,di
	sub 	cx,di
.rego:
	mov 	byte [cs:bx],' '
	dec    	bx
	dec    	cx
	jnz	.rego
	jmp 	.finishim
.nomuch:
	mov	ax,di
.finishim:
.showinteger:
	inc	bx
	mov	cl,[cs:bx]
        invoke	showchars,cx,0FFFFh
	dec	ax
	jnz	.showinteger
	retf
endp

;==========SHOWSIGNED===========
;Affiche un entier %0 de taille %1 apres le curseur
;-> %0 un entier, %1 la taille
;<-
;===============================
proc showsigned uses ebx cx edx, sizeofint:word,integer:dword
	mov	ebx,[integer]	
	mov	cx,[sizeofint]	
	xor	edx,edx
	cmp     cx,1
	ja 	.signed16
	mov	dl,bl
	cmp	dl,7Fh
	jbe	.notsigned
	neg 	dl
	jmp	.showminus
.signed16:
	cmp     cx,2
	ja 	.signed32
	mov 	dx,bx
	cmp	dx,7FFFh
	jbe	.notsigned
	neg	dx
	jmp	.showminus
.signed32:	
	mov	edx,ebx
	cmp	edx,7FFFFFFFh
	jbe	.notsigned
	neg 	edx
.showminus:
	invoke 	showchars,'-',0FFFFh
.notsigned:
	stdcall 	showint,edx
	retf
endp

;==========SHOWHEX===========
;Affiche un nombre hexadecimal %0 de taille %1 apres le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
proc showhex uses ax bx cx edx, sizeofint:word,integer:dword 	
       	mov     edx,[integer]
       	mov   	cx,[sizeofint]
       	mov     ax,cx
	shr   	ax,2
       	sub   	cx,32
       	neg   	cx
       	shl   	edx,cl
.Hexaize:
       	rol   	edx,4
       	mov   	bx,dx
       	and   	bx,0fh
       	mov   	cl,[cs:bx+Tab]
        invoke	showchars,cx,0FFFFh
       	dec   	al
       	jnz   	.Hexaize
       	retf

Tab 	db '0123456789ABCDEF'
endp

;==========SHOWBIN===========
;Affiche un nombre binaire %0 de taille %1 apres le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
proc showbin uses ax cx edx, sizeofint:word,integer:dword	
        mov     edx,[integer]
       	mov   	cx,[sizeofint]
       	sub     cx,32
       	neg     cx
       	shl     edx,cl
       	mov   	ax,[sizeofint]
.binaize:
        rol     edx,1
        mov     cl,'0'
        adc     cl,0
        invoke	showchars,cx,0FFFFh
        dec     al
        jnz     .binaize
        retf
endp

;==========SHOWBCD===========
;Affiche un nombre en BCD %0 de taille %1 apres le curseur
;-> %0 un entier, %1 la taille
;<-
;============================
proc showbcd uses ax cx edx, sizeofint:word,integer:dword
        mov     edx,[integer]
        mov     ax,[sizeofint]
        mov     cx,ax
        shr     ax,2
        sub     cx,32
        neg     cx
        shl     edx,cl
.BCDaize:
        rol     edx,4
        mov     cl,dl
        and     cl,0fh
        add     cl,'0'
        invoke	showchars,cx,0FFFFh
        dec     al
        jnz     .BCDaize
        retf
endp

;==========SHOWSTRING===========
;Affiche une chaine de caractere pointee par ds:%1 apres le curseur
;-> ds:%1 pointeur chaine type pascal
;<-
;===============================
proc showstring uses bx si, pointer:word
        mov     si,[pointer]
        mov     bl,[si]
.strinaize:
        inc     si
        invoke	showchars,word [si],0FFFFh
        dec     bl
        jnz     .strinaize
        retf
endp

;==========showchars===========
;Affiche un caractere %0 apres le curseur
;-> %0 caractere 
;<-
;===============================
proc showchar, pointer:word
        invoke	showchars,[pointer],0FFFFh
        retf
endp

;==========SHOWSTRING0===========
;Affiche une chaine de caractere pointee par ds:%1 apres le curseur
;-> ds:%1 pointeur chaine type zero terminal
;<-
;================================
proc showstring0 uses cx si, pointer:word 
        mov     si,[pointer]	
.strinaize0:
        mov     cl,[si]
        cmp     cl,0
        je      .no0
        invoke	showchars,cx,0FFFFh	
        inc     si
        jmp     .strinaize0
.no0:
        retf
endp

