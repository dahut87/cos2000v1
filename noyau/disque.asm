include "..\include\mem.h"
include "..\include\fat.h"

org 0h

header exe 1


exporting		
declare readsector
declare writesector
declare verifysector
declare initdrive
declare loadfile
declare compressrle
declare decompressrle
declare findfirstfile
declare findnextfile
declare getfreespace
declare searchfile
declare getname
declare getserial
declare changedir
declare readcluster
declare writecluster
declare getdir
declare projfile
declare execfile
declare getbuffer
declare setbuffer
ende
	
importing
use SYSTEME,biosprint
use SYSTEME,biosprinth
use SYSTEME,mbfindsb
use SYSTEME,mbfree
use SYSTEME,mbcreate
use SYSTEME,mbresident
use SYSTEME,mbfind
use SYSTEME,mbchown
use SYSTEME,mbloadfuncs
use SYSTEME,mbloadsection
endi


;DPT disquette 
mydpt dpt

;Secteur de boot
myboot bootinfo

;Parametres
support                 db      0
nbbuffer                db      0

;Données Calculée
clustersize		dw	0
tracksperhead 		dw 	0
drivesize         	dd     	0
adressboot		dw	0
adressfat		dw	0
adressparent      	dw     	0
adressdirectory         dw      0
adressdata		dw	0
addingvalue		dw     	0
currentdir		dw	0 ;En cluster
currentdirstr		db      128 dup (0)


proc getfat	uses ax bx dx si ds es
   push    cs
   pop     ds
   push cs
   pop es
   invoke    mbfindsb,datafat,cs
   mov     es,ax
	mov	ax,cx
	mov	bx,ax
	and   	bx,0000000000000001b
	shr   	ax,1
	mov   	cx,3
	mul   	cx	
 ;mov     si,offset fatter
        xor     si,si
	add   	si,ax
	cmp   	bx,0h
	jnz   	evenfat
oddfat:	
	mov	ax,[es:si]
      	and   	ax,0FFFh
    	mov   	cx,ax
      	jmp   	endfat
evenfat:
      	mov   	ax,[es:si+1]
      	and   	ax,0FFF0h
      	shr   	ax,4
      	mov   	cx,ax
endfat:
	cmp	ax,0FF0h
	jbe	nocarry
	stc
	retf
nocarry:
	clc
	retf
endp 

;============loadfile===============
;Charge le fichier ds:%0 en ds:%1 ->ax taille
;-> AH=4
;<- Flag Carry si erreur
;=====================================================
proc loadfile uses cx si di ds es, name:word,pointer:word
local temp[48]:WORD
   	push    ss
	pop     es 
    lea     di,[temp]
    push    ds di 
    mov     si,[name]
    mov     cx,48/4
    cld
    rep     movsd
   	push    ss
	pop     ds
    pop     di es
	stdcall	searchfile,di
	jne   	errorload
	jc	    errorload
	virtual at di
  		.find find
	end virtual
	mov	    cx,[.find.result.filegroup]
	mov	    eax,[.find.result.filesize]
    push    es
    pop     ds
    stdcall    loadway,cx,eax,[pointer]
	jc    	errorload
	clc
	retf
errorload:
	stc
	xor eax,eax
	retf
endp
	
;============execfile (Fonction 18)===============
;Execute le fichier ds:si
;-> AH=18
;<- Flag Carry si erreur
;=====================================================
proc execfile, file:word
        pushad
        push    ds es fs gs
        mov     di,[file]
	    stdcall	uppercase,di
        stdcall    projfile,di
        jc      .reallyerrornoblock
        invoke    mbfind,di
        jc      .reallyerror
        invoke    mbchown,ax,word [ss:bp+4]
        jc      .reallyerror
        push    ax
        pop     ds
        cmp     word [ds:0x0],'EC'
        jne     .reallyerror
        push    ax
        push    cs
        push    .arrive
        push    ds
	virtual at 0
  		.exe exe
	end virtual
        push    word [.exe.starting]
        push    ds
        push    ds
        push    ds
        pop     es
        pop     fs
        pop     gs
        push    7202h
        xor     eax,eax
        xor     ebx,ebx
        xor     ecx,ecx
        xor     edx,edx
        xor     esi,esi
        xor     edi,edi
        xor     ebp,ebp
        popf
        sti
        db      0CBh
.arrive:
        ;cli
        ;pop     ax
        ;invoke    mbfree,ax
        invoke    mbfree
        pop     gs fs es ds
	    popad
        clc
	    retf
.reallyerror:
        invoke    mbfree,ax
.reallyerrornoblock:
        pop     gs fs es ds
	    popad
	    stc
	    retf
endp

;============projfile (Fonction 17)===============
;Charge le fichier ds:%0 sur un bloc mémoire -> eax taille 
;-> eax taille fichier
;<- Flag Carry si erreur
;=====================================================
proc projfile uses cx si di ds es, pointer:word
local   temp[64]:WORD
   	push    ss
	pop     es 
    lea     di,[temp]
    push    di
    mov     si,[pointer]
    mov     cx,64/4
    cld
    rep     movsd
   	push    ss
	pop     ds
    pop     di 
pushad
invoke biosprint,di
popad
	stdcall	uppercase,di
    invoke    mbfind,di
    jnc     .notace
	stdcall    searchfile,di
	jne   	.errorload
	jc	    .errorload
	virtual at di
  		.find find
	end virtual	
	mov	    eax,[es:.find.result.filesize]
	invoke    mbcreate,di,ax
	jc      .errorload
    invoke    mbchown,ax,word [ss:bp+4]
    jc      .errorload
	mov     ds,ax
    mov     cx,[es:.find.result.filegroup]
   	mov	    eax,[es:.find.result.filesize]
    stdcall    loadway,cx,eax,0
	jc    	.errorload
    cmp     word [ds:0x0],'EC'
    jne     .notace
        invoke    mbloadfuncs,ds
        jc      .errorload
        invoke    mbloadsection,ds
        jc      .errorload
 .notace:
	clc
	retf
.errorload:
	xor eax,eax
	stc
	retf
endp


;=============SearchFile===============
;Renvois dans ds:%0 et non equal si pas existant
;->
;<- Flag Carry si erreur
;======================================
proc searchfile uses bx cx si di ds es, pointer:word
	mov     si,[pointer]
	virtual at si
  		.find find
	end virtual
	lea     bx,[es:.find.result]
	stdcall	uppercase,si
	stdcall	findfirstfile,si	
    jc	    .errorsearch
	jmp	    .founded
.nextsearch:
	stdcall	findnextfile,si
    jc	    .errorsearch	
.founded:
	cmp	    byte [bx],0
	je	    .notgood
	virtual at bx
  		.entries entries
	end virtual
	cmp	    byte [.entries.fileattr],0Fh
	je	     .nextsearch	
	stdcall	cmpnames,si,bx
    jc    	.nextsearch
.okfound:
	clc
	retf
.notgood:
	cmp   	si,0FF5h
	retf
.errorsearch:
	stc
	retf
endp

;Transforme la chaine ds:%0 en maj
proc uppercase uses si ax, strs:word 	
	mov     si,[strs]
.uppercaser:
	mov 	al,[si]
	cmp 	al,0
	je 	.enduppercase
	cmp 	al,'a'
	jb 	.nonmaj
	cmp 	al,'z'
	ja 	.nonmaj
	sub 	al,'a'-'A'
	mov 	[si],al
.nonmaj:
	inc 	si
	jmp 	.uppercaser
.enduppercase:
	clc
	retf
endp

;Compare le nom ds:%0 '.' avec ds:%1
proc cmpnames uses ax cx si di es, off1:word,off2:word
	mov     si,[off1]
	mov     di,[off2]
    cmp     byte [si],"."
    jne     .notaredir
    cmp     word [si],".."
    jne     .onlyonedir
    cmp     word [di],".."   
    je      .itok
    jmp     .notequal
.onlyonedir:
    cmp     word [di]," ."
    je      .itok
.notaredir:
	push    ds
	pop     es             	
	mov 	cx,8
	repe 	cmpsb
	jne 	.nequal
	inc 	si
	jmp     .equal
.nequal:
        cmp 	byte [es:di-1],' '
        jne     .notequal	
.equal:
	cmp 	byte [si-1],'.'
	jne 	.trynoext
	mov 	al,' '
	rep 	scasb
	mov 	cx,3
	rep 	cmpsb
	jne 	.nequal2
        inc     si
        jmp     .equal2
.nequal2:
        cmp 	byte [es:di-1],' '
        jne     .notequal
.equal2:
	cmp 	byte [si-1],0
	jne     .notequal
.itok:
    clc
	retf
.notequal:
	stc
	retf	
.trynoext:
	cmp	byte [si-1],0
	jne	.notequal
	jmp	.itok
endp

;charge le fichier de de groupe %0 et de taille %1
proc loadway uses eax bx cx dx si di ds es, sector:word,size:dword,offset:word
    push  ds
    pop   es
    mov   eax,[size]		
	cmp   eax,0
	je	  .zeroload
	rol	  eax,16
	mov	  dx,ax
	ror	  eax,16
	div	  [cs:clustersize]
	mov	  bx,ax
	mov   cx,[sector]
	mov   di,[offset]
	cmp	  bx,1
	jb	  .adjustlast
.loadfat:
	stdcall   readcluster,cx,di
	jc 	   .noway
	add	   di,[cs:clustersize]
	stdcall   getfat
	dec	   bx
	jnz	   .loadfat
.adjustlast:
    cmp     dx,0
    je      .zeroload
	push	cs
	pop 	ds
	mov	    si,bufferread
	stdcall	readcluster,cx,si
	jc	    .noway
	mov	    cx,dx   
	cld
	rep	movsb
.zeroload:
	clc
	retf
.noway:	
	stc
	retf
endp	

;=============INITDRIVE===============
;Initialise le lecteur pour une utilisation ultérieure
;->
;<- Flag Carry si erreur
;=====================================
proc initdrive uses eax bx cx edx si di ds es
	push 	cs
	pop 	ds
	push	cs
	pop	es
	mov	di,3
.againtry:
        xor  	ax,ax
	mov	dl,[support]
	xor     dh,dh
        int  	13h
	mov	bx,bufferread
	mov	ax,0201h
	mov	cx,0001h
        mov     dl,[support]
        xor     dh,dh
	int	13h
	jnc	.oknoagaintry
	dec	di
	jnz	.againtry
.oknoagaintry:
        mov     si,bufferread+3
        mov     di,myboot
        mov     cx,myboot.sizeof
        cld
        rep     movsb
	mov	ax,[myboot.sectorsize]
	mov	bl,[myboot.sectorspercluster]
	xor	bh,bh
	mul	bx
	mov	[clustersize],ax
	mov 	bx,[myboot.hiddensectorsl]
	adc 	bx,[myboot.hiddensectorsh]
	mov 	[adressboot],bx
	add 	bx,[myboot.reservedsectors]
	mov 	[adressfat],bx
	xor 	ax,ax
	mov 	al,[myboot.fatsperdrive]
	mul 	[myboot.sectorsperfat]
	add 	bx,ax
	mov 	[adressparent],bx
	mov 	[adressdirectory],bx
	mov 	ax,32                 
	mul 	[myboot.directorysize]
	div 	[myboot.sectorsize]
	add 	bx,ax
	mov 	[adressdata],bx
	sub	bx,2
	mov	[addingvalue],bx
	mov 	ax,[myboot.sectorsperdrive]
	div 	[myboot.sectorspertrack]
	xor 	dx,dx
	div 	[myboot.headsperdrive]
	mov 	[tracksperhead],ax
	xor	eax,eax
	mov	ax,[myboot.sectorsperdrive]
	sub	ax,[adressdata]
	mul	[myboot.sectorsize]
	shl   	edx,16
	add   	edx,eax
	mov	[drivesize],edx
	mov	[currentdir],0
	mov	[adressdirectory],0
	mov	[currentdirstr],0
       xor     eax,eax
        mov     ax,[buffer.size]
       	mul	[myboot.sectorsize]
        invoke    mbfindsb,databuffer,cs
        jnc     .hadabufferblock
        invoke    mbcreate,databuffer,ax
        jc      .errorinit
        invoke    mbresident,ax
        jc      .errorinit
        invoke    mbchown,ax,cs
        jc      .errorinit
.hadabufferblock:
    mov  [buffer.current],0FFFFh
    mov  ax,0FFFFh
    mov  cx,[buffer.size]
    mov  di,buffer.chain
    cld
    rep  stosw
        xor     eax,eax
        mov     ax,[myboot.sectorsperfat]
       	mul	[myboot.sectorsize]
        invoke    mbfindsb,datafat,cs
        jnc     .hadafatbloc
        invoke    mbcreate,datafat,ax
        jc      .errorinit
        invoke    mbresident,ax
        jc      .errorinit
        invoke    mbchown,ax,cs
        jc      .errorinit
.hadafatbloc:
	mov	dx,[myboot.sectorsperfat]
	mov	cx,[adressfat]
        xor     di,di
        ;mov      di,offset fatter
        mov     ds,ax
.seefat:
	stdcall	readsector,cx,di
	jc	.errorinit
	add	di,[cs:myboot.sectorsize]
	inc	cx
	dec	dx
	jnz	.seefat
	clc
	retf
.errorinit:
	stc
	retf
endp

datafat db '/fat',0
databuffer db '/buffer',0

buffer diskbuffer

;=============FindFirstFile==============
;Renvois dans DS:%1 un bloc d'info
;->
;<- Flag Carry si erreur
;========================================
proc findfirstfile uses cx si, pointer:word
	mov     si,[pointer]
	mov 	cx,[cs:currentdir]
	virtual at si
  		.find find
	end virtual
	mov 	[.find.adressdirectory],cx
	xor	    cx,cx
	mov 	[.find.entryplace],cx
	mov	    [.find.firstsearch],1
	stdcall 	findnextfile,[pointer]
	retf
endp

;=============FindnextFile==============
;Renvois dans DS:%0 un bloc d'info
;->
;<- Flag Carry si erreur
;=======================================
proc findnextfile	uses ax bx cx di si ds es, pointer:word
	push    cs
	push    ds
	pop     es
	pop     ds
	mov     si,[pointer]	
	virtual at si
  		.find find
	end virtual
	mov	    cx,[es:.find.adressdirectory]
	mov	    bx,[es:.find.entryplace]
.findnextfileagain:
	cmp	    [es:.find.firstsearch],1
	je	    .first
	virtual at 0
  		.entries2 entries
	end virtual
	add	    bx,.entries2.sizeof
	cmp	    bx,[cs:clustersize]
	jb	    .nopop
.first:
	mov	    di,bufferentry
	mov	    bx,0
	cmp	    [cs:currentdir],0
	jne	.notrootdir
	cmp	[es:.find.firstsearch],1
	je	.noaddfirst1
	inc	cx
.noaddfirst1:
	add	cx,[cs:adressparent]
	mov	al,[cs:myboot.sectorspercluster]
.readroot:
	stdcall	readsector,cx,di
	jc	.notwell
	add	di,[cs:myboot.sectorsize]
	dec	al
	jnz	.readroot
	sub	cx,[cs:adressparent]
	jmp	.nopop
.notrootdir:
	cmp	[es:.find.firstsearch],1
	je	.noaddfirst2
	stdcall	getfat
.noaddfirst2:
	jc	.notwell
	stdcall	readcluster,cx,di
	jc	.notwell
.nopop:
	mov	[es:.find.firstsearch],0
	mov di,bufferentry
	add	di,bx
	cmp	byte [di],0
	je	.notwell
	mov	[es:.find.entryplace],bx
	mov	[es:.find.adressdirectory],cx
	cmp	byte [di],0E5h
	je	.findnextfileagain
	virtual at di
  		.entries entries
	end virtual
	cmp	byte [.entries.fileattr],28h
	je	.findnextfileagain
	cmp	byte [.entries.fileattr],0Fh
	je	.findnextfileagain
	mov si,di
    mov di,[pointer]
	virtual at di
  		.find2 find
	end virtual
    lea di,[es:.find2.result]	
	mov	cx,.entries2.sizeof
	cld
	rep	movsb
	clc
	retf
.notwell:
	stc
	retf
endp

;=============GetFreeSpace===============
;Renvoie en EDX l'espace disque libre du volume
;->
;<- Flag Carry si erreur
;========================================
proc getfreespace uses eax bx
	xor	eax,eax
	stdcall	getsector
	mul	[cs:myboot.sectorsize]
	shl	edx,16
	add	edx,eax
	pop   	eax
	retf
endp

;ax=défectueux bx=libre
getsector:
	push	cx dx
	mov	dx,[cs:myboot.sectorsperdrive]
	sub	dx,[cs:addingvalue]
	xor	ax,ax
	xor	bx,bx
	mov	cx,0
goget:
	push	cx	
	stdcall	getfat
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


;=============READCLUSTER===============
;Lit le secteur %0 et le met en ds:%1
;->
;<- Flag Carry si erreur
;=======================================
proc readcluster uses ax bx dx si, sector:word,pointer:word
	mov	al,[cs:myboot.sectorspercluster]
	xor	ah,ah
    mov bx,ax
	mul	[sector]
	add	ax,[cs:addingvalue]
	mov     si,[pointer]
.readsectors:
	stdcall	readsector,ax,si
	jc	.errorreadincluster
	add	si,[cs:myboot.sectorsize]
	inc	ax
	dec	bx
	jnz	.readsectors
	clc
	retf
.errorreadincluster:
	stc
	retf
endp

;=============WRITECLUSTER===============
;Ecrit le cluster %0 et le met en ds:%1
;->
;<- Flag Carry si erreur
;=====================================================
proc writecluster uses ax bx dx si, sector:word,pointer:word
	mov	al,[cs:myboot.sectorspercluster]
	xor	ah,ah
    mov bx,ax
	mul	[sector]
	add	ax,[cs:addingvalue]
	mov     si,[pointer]
.writesectors:
	stdcall	writesector,ax,si
	jc	.errorwriteincluster
	add	si,[cs:myboot.sectorsize]
	inc	ax
	dec	bx
	jnz	.writesectors
	clc
	retf
.errorwriteincluster:
	stc
	retf
endp


;=============READSECTOR===============
;Lit le secteur %0 et le met en ds:%1
;->
;<- Flag Carry si erreur
;======================================
proc readsector uses ax bx cx dx si di ds es, sector:word,pointer:word
    local   tempsec:WORD
    push    ds
    push    cs
    pop     ds
    invoke    mbfindsb,databuffer,cs
    pop     ds
    mov     es,ax
    jc      .error
    mov     si,buffer.chain
    xor     cx,cx
    mov     ax,[sector]
    mov     bx,0FFFFh
.searchbuffer:
    cmp     [cs:si],ax
    je      .preprepcopy
    cmp     word [cs:si],0FFFEh
    jne     .notfree
    mov     bx,cx
.notfree: 
    cmp     word [cs:si],0FFFFh
    je      .theend
    inc     si
    inc     si
    inc     cx
    cmp     cx,[cs:buffer.size]
    jb      .searchbuffer
.theend:
    cmp     bx,0FFFFh
    jnz     .prepread
    cmp     cx,[cs:buffer.size]
    jb      .read 
    mov     cx,[cs:buffer.current]
.searchnext:
    inc     cx
    cmp     cx,[cs:buffer.size]
    jb      .read
    xor     cx,cx
    jmp     .read
.prepread:
    mov     cx,bx
.read: 
    mov     [cs:buffer.current],cx   
    mov     [tempsec],cx
    mov     ax,[cs:myboot.sectorsize]
    mul     cx
    mov     di,ax
	mov	    ax,[sector]
	xor   	dx,dx
	div   	[cs:myboot.sectorspertrack]
	inc   	dl
	mov 	bl,dl           
	xor 	dx,dx                   
	div 	[cs:myboot.headsperdrive]
	mov 	dh,[cs:support]
	xchg 	dl,dh          
	mov 	cx,ax              
	xchg 	cl,ch             
	shl 	cl,6                
	or 	    cl,bl       
	mov 	bx,di
	mov 	si,3
.tryagain:
	mov 	ax,0201h
  	int 	13h
  	jnc 	.prepcopy
  	dec 	si
  	jnz 	.tryagain
    mov     bx,[tempsec]
    shl     bx,1
    mov     word [bx+buffer.chain],0FFFEh
.error:
    stc
    retf
.preprepcopy:
    mov     [tempsec],cx
.prepcopy:
    mov     bx,[tempsec]
    mov     ax,[tempsec]
    mov     cx,[sector]
    shl     bx,1
    mov     [cs:bx+buffer.chain],cx
    mov     cx,[cs:myboot.sectorsize]
    mul     cx
    mov     di,ax
.copy:
    push    ds
    push    es
    pop     ds
    pop     es
    mov     si,di
    mov     di,[pointer]
    cld 
    rep     movsb
.done:
    retf
endp

;=============SETBUFFER============
;change la taille des buffers a %0
;->
;<- Flag Carry si erreur
;====================================
proc setbuffer uses ax cx di ds es, size:word
    push    cs
    push    cs
    pop     ds
    pop     es
    invoke    mbfindsb,databuffer,cs
    jc      .nodatabuffer
    invoke    mbfree,ax
.nodatabuffer:
    mov  ax,[size]
    mov  cx,ax
    mov  [buffer.size],ax
       	mul	[myboot.sectorsize]
        invoke    mbcreate,databuffer,ax
        jc      .errorinit
        invoke    mbresident,ax
        jc      .errorinit
        invoke    mbchown,ax,cs
        jc      .errorinit
    mov  [buffer.current],0FFFFh
    mov  ax,0FFFFh
    mov  di,buffer.chain
    cld
    rep  stosw
    clc
    retf
.errorinit:
    stc
    retf
endp

;=============GETBUFFER============
;renvoie la structure de buffer en %0
;->
;<- Flag Carry si erreur
;====================================
proc getbuffer uses ax cx di ds es, pointer:word
    push    cs
    push    ds
    pop     es
    pop     ds
    mov     si,buffer
    mov     di,[pointer]
    mov     cx,buffer.sizeof
    cld
    rep     movsb
    clc
    retf
endp
   
;=============WRITESECTOR============
;Ecrit le secteur %0 pointé par ds:%1
;->
;<- Flag Carry si erreur
;====================================
proc writesector uses ax bx cx dx si es, sector:word,pointer:word
	push    ds
	pop     es
	mov	ax,[sector]
	xor   	dx,dx
	div   	[cs:myboot.sectorspertrack]
	inc   	dl
	mov 	bl,dl           
	xor 	dx,dx                   
	div 	[cs:myboot.headsperdrive]
	mov 	dh,[cs:support]
	xchg 	dl,dh          
	mov 	cx,ax              
	xchg 	cl,ch             
	shl 	cl,6                
	or 	cl, bl         
	mov 	bx,[pointer]
	mov 	si,3
.tryagain:
	mov 	ax,0301h
  	int 	13h
  	jnc 	.done
  	dec 	si
  	jnz 	.tryagain
.done:
        retf
endp

;=============Getname==============
;Renvoie le nom en DS:%0
;-> AH=11
;<- Flag Carry si erreur
;==================================
proc getname uses ax cx si di ds es, pointer:word 		
	push    ds
	pop     es
        push	cs
	pop	ds
	mov	di,[pointer]
	mov	si,myboot.drivename
	mov	cx,11
	rep	movsb
	mov	al,' '
	mov	di,[pointer]
	mov	cx,11
	repne	scasb
	mov 	byte [es:di],0
	retf
endp
;=============Getserial==============
;Renvoie le numéro de serie en EAX
;->
;<- Flag Carry si erreur
;====================================
proc getserial FAR
	mov	eax,[cs:myboot.serialnumber]
	retf
endp

;=============VERIFYSECTOR==============
;Vérifie le secteur %0
;->
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=======================================
proc verifysector uses ecx si di ds es, sector:word 	
	push 	cs
	pop 	es
	push 	cs
	pop 	ds
	mov 	si,bufferread
	stdcall 	readsector,cx,si
	stdcall 	inverse
	stdcall 	writesector,cx,si
	jc 	.errorverify

	mov 	si,bufferwrite
	stdcall 	readsector,cx,si	
	stdcall 	inverse
	jc 	.errorverify
	
	mov 	si,bufferread
	stdcall 	inverse
	stdcall 	writesector,cx,si
	jc 	.errorverify
	
	xor     ecx,ecx
	mov 	cx,[cs:myboot.sectorsize]
	shr	cx,2
	mov 	si,bufferread
	mov 	di,bufferwrite
	cld
	rep 	cmpsd
.errorverify:
	retf

endp

inverse:
    push    si cx
	xor     cx,cx
invert:
	not 	dword [si]
	add 	si,4
	add     cx,4
	cmp     cx,[cs:myboot.sectorsize]
	jb 	    invert
	pop     cx si
	retf

;=============DecompressRle (Fonction 05H)==============
;decompress ds:si en es:di taille bp d‚compress‚ cx compress‚
;-> AH=5
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
proc decompressrle uses	ecx dx si di ds es,seg1:word,off1:word,seg2:word,off2:word,size:word
    mov     ds,[seg1]
    mov     es,[seg2]
    mov     si,[off1]
    mov     di,[off2]
	mov 	dx,[size]
.decompression:
	mov 	eax,[ds:si]
	cmp 	al,'/'
	jne 	.nocomp
	cmp 	si,07FFFh-6
	jae 	.thenen
	mov 	ecx,eax
	ror 	ecx,16
	cmp 	cl,'*'
	jne 	.nocomp
	cmp 	byte [ds:si+4],'/'
	jne 	.nocomp
	mov 	al,ch
	mov 	cl,ah
	xor 	ah,ah
	xor 	ch,ch
	cld
	rep 	stosb
	add 	si,5
	sub 	dx,5
	jnz 	.decompression
	jmp 	.thenen
.nocomp:
	mov 	[es:di],al
	inc 	si
	inc 	di
	dec 	dx
	jnz 	.decompression
.thenen:
    xor     eax,eax
	mov 	ax,di
	sub 	ax,[off2]  
	clc
	retf
endp

;=============CompressRle (Fonction 06H)==============
;compress ds:si en es:di taille cx d‚compress‚ BP compress‚
;-> AH=6
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
proc compressrle uses ax bx cx dx si di ds es, seg1:word,off1:word,seg2:word,off2:word,size:word
    mov     es,[seg1]
    mov     ds,[seg2]
    mov     di,[off1]
    mov     si,[off2]
	mov 	dx,[size]
.againcomp:
	mov 	bx,di
	mov 	al,[es:di]
	mov 	cx,dx
	cmp 	ch,0
	je 	    .poo
	mov 	cl,0ffh
	;mov 	cx,bp
	;sub 	cx,di
	;mov 	ah,cl
.poo:
	mov 	ah,cl
	inc 	di
	xor 	ch,ch
	repe 	scasb
	sub 	cl,ah
	neg 	cl
	cmp 	cl,6
	jbe 	.nocomp2
	mov 	dword [si],' * /'
	mov 	byte [si+4],'/'
	mov 	[si+1],cl
	mov 	[si+3],al
	add 	si,5
	dec 	di
	xor 	ch,ch
	sub 	dx,cx
	jnz 	.againcomp
	jmp 	.fini
.nocomp2:
	mov 	[si],al
	inc 	si
	inc 	bx
	mov 	di,bx
	dec 	dx
	jnz 	.againcomp
.fini:
    mov     ax,si
	sub 	ax,[off2]
	clc
	retf
endp

;=============Changedir (Fonction 13)==============
;Change le repertoire courant a DS:SI
;-> AH=13
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
proc changedir uses cx si di ds es, pointer:word
local   temp[64]:WORD	
   	push    ss
	pop     es 
    lea     di,[temp]
    push    di
    mov     si,[pointer]
    mov     cx,64/4
    cld
    rep     movsd
   	push    ss
	pop     ds
    pop     di 
	stdcall    searchfile,di
	jne   	.noch
	jc	    .noch	
	;cmp	[si],005Ch ;'/',0 (root dir)
	virtual at di
  		.find find
	end virtual
	mov	  cx,[es:.find.result.filegroup]
	mov	[cs:currentdir],cx
	mov	[cs:adressdirectory],cx
	cmp	dword [es:.find.result.filename],'   .'
	je	.theend
	cmp	dword [es:.find.result.filename],'  ..'
	jne	.notback
    push      cs
    push      cs
    pop       ds
    pop       es
	mov	di,currentdirstr
	mov	cx,128
	mov	al,0
	cld
	repne	scasb
	mov	al,'/'
	std	
	repne	scasb
	inc 	di
	mov	byte [es:di],0
	jmp	.theend
.notback:
    push      cs
    push      cs
    pop       ds
    pop       es
	mov	di,currentdirstr
	mov	cx,128
	mov	al,0
	cld
	repne	scasb
	dec	di
	mov	al,'/'
	cld
        stosb
	mov	dx,di
	push	ss
	pop	es
	lea     di,[temp]
    mov     si,di
	mov	cx,128
	mov	al,0
	cld
        repne	scasb
	sub	cx,128
	neg	cx
    push    ss
    pop     ds
	push	cs
	pop	es
	mov	di,dx
	cld
        rep	movsb
.theend:
	clc
	retf
.noch:
	stc
	retf
endp

;=============getdir==============
;Recupere le repertoire courant a DS:%0
;->
;<- Flag Carry si erreur
;=================================
proc getdir uses ax cx si di ds es, pointer:word
	push	cs
	pop	es
	mov	di,currentdirstr
	mov	cx,128
	mov	al,0
	cld
	repne	scasb
	sub	cx,128
	neg	cx
	push    ds
	pop     es
	push	cs
	pop	ds
	mov	si,currentdirstr
	mov     di,[pointer]
	cld
	rep	movsb
	clc
	retf
endp
	
bufferread  	db 512 dup (0)
bufferwrite 	db 512 dup (0)
bufferentry	db 512 dup (0)
;fatter db 9*512 dup (0)
