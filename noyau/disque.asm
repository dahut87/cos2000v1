model tiny,stdcall
p486
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\fat.h"

org 0h

header exe <"CE",1,0,0,offset exports,offset imports,,>


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
ende
	
importing
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
mydpt dpt <>

;Secteur de boot
myboot bootinfo <>

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


PROC getfat near
	uses  	ax,bx,dx,si,ds,es
   push    cs
   pop     ds
   
   push cs
   pop es
   call    [cs:mbfindsb],offset datafat,cs
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
	ret
nocarry:
	clc
	ret
endp getfat 

;============loadfile===============
;Charge le fichier ds:%0 en ds:%1 ->ax taille
;-> AH=4
;<- Flag Carry si erreur
;=====================================================
PROC loadfile FAR
    ARG     @name:word,@pointer:word
    LOCAL   @@temp:word:48
	USES	cx,si,di,ds,es
   	push    ss
	pop     es 
    lea     di,[@@temp]
    push    ds di 
    mov     si,[@name]
    mov     cx,48/4
    cld
    rep     movsd
   	push    ss
	pop     ds
    pop     di es
	call	searchfile,di
	jne   	errorload
	jc	    errorload
	mov	    cx,[(find di).result.filegroup]
	mov	    eax,[(find di).result.filesize]
    push    es
    pop     ds
    call    loadway,cx,eax,[@pointer]
	jc    	errorload
	clc
	ret
errorload:
	stc
	xor eax,eax
	ret
endp loadfile
	
;============execfile (Fonction 18)===============
;Execute le fichier ds:si
;-> AH=18
;<- Flag Carry si erreur
;=====================================================
PROC execfile FAR
        ARG     @file:word
        pushad
        push    ds es fs gs
        call    projfile,[@file]
        jc      @@reallyerrornoblock
        call    [cs:mbchown],ax,[word ptr ss:bp+4]
        jc      @@reallyerror
        call    [cs:mbloadfuncs],ax
        jc      @@reallyerror
        call    [cs:mbloadsection],ax
        jc      @@reallyerror
        push    ax
        push    ax
        pop     ds
        push    cs
        push    offset @@arrive
        push    ds
        push    [word ptr (exe).starting]
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
@@arrive:
        cli
        pop     ax
        call    [cs:mbfree],ax
        pop     gs fs es ds
	    popad
        clc
	    ret
@@reallyerror:
        call    [cs:mbfree],ax
@@reallyerrornoblock:
        pop     gs fs es ds
	    popad
	    stc
	    ret
endp execfile

;============projfile (Fonction 17)===============
;Charge le fichier ds:%0 sur un bloc mémoire -> eax taille -> es bloc
;-> ax bloc mémoire
;<- Flag Carry si erreur
;=====================================================
PROC projfile FAR
ARG     @pointer:word
LOCAL   @@temp:word:64
USES	cx,si,di,ds,es
   	push    ss
	pop     es 
    lea     di,[@@temp]
    push    di
    mov     si,[@pointer]
    mov     cx,64/4
    cld
    rep     movsd
   	push    ss
	pop     ds
    pop     di 
	call	uppercase,di
    call    [cs:mbfind],di
    jnc     @@errorload
	call    searchfile,di
	jne   	@@errorload
	jc	    @@errorload	
	mov	    eax,[es:(find di).result.filesize]
	call    [cs:mbcreate],di,ax
	jc      @@errorload
	mov     ds,ax
    mov     cx,[es:(find di).result.filegroup]
   	mov	    eax,[es:(find di).result.filesize]
    call    loadway,cx,eax,0
	jc    	@@errorload
	mov     ax,ds
	clc
	ret
@@errorload:
	xor eax,eax
	stc
	ret
endp projfile


;=============SearchFile===============
;Renvois dans ds:%0 et non equal si pas existant
;->
;<- Flag Carry si erreur
;======================================
PROC searchfile FAR
ARG     @pointer:word
	USES	bx,cx,si,di,ds,es
	mov     si,[@pointer]
	lea     bx,[es:(find si).result]
	call	uppercase,si
	call	findfirstfile,si	
    jc	    @@errorsearch
	jmp	    @@founded
@@nextsearch:
	call	findnextfile,si
    jc	    @@errorsearch	
@@founded:
	cmp	    [byte ptr bx],0
	je	    @@notgood
	cmp	    [byte ptr bx+entries.fileattr],0Fh
	je	     @@nextsearch	
	call	cmpnames,si,bx
    jc    	@@nextsearch
@@okfound:
	clc
	ret
@@notgood:
	cmp   	si,0FF5h
	ret
@@errorsearch:
	stc
	ret
endp searchfile

;Transforme la chaine ds:%0 en maj
PROC uppercase FAR
        ARG     @strs:word
	USES 	si,ax
	mov     si,[@strs]
@@uppercaser:
	mov 	al,[si]
	cmp 	al,0
	je 	@@enduppercase
	cmp 	al,'a'
	jb 	@@nonmaj
	cmp 	al,'z'
	ja 	@@nonmaj
	sub 	al,'a'-'A'
	mov 	[si],al
@@nonmaj:
	inc 	si
	jmp 	@@uppercaser
@@enduppercase:
	clc
	ret
endp uppercase

;Compare le nom ds:%0 '.' avec ds:%1
PROC cmpnames FAR
        ARG     @off1:word,@off2:word
	USES 	ax,cx,si,di,es
	mov     si,[@off1]
	mov     di,[@off2]
    cmp     [byte ptr si],"."
    jne     @@notaredir
    cmp     [word ptr si],".."
    jne     @@onlyonedir
    cmp     [word ptr di],".."   
    je      @@itok
    jmp     @@notequal
@@onlyonedir:
    cmp     [word ptr di]," ."
    je      @@itok
@@notaredir:
	push    ds
	pop     es             	
	mov 	cx,8
	repe 	cmpsb
	jne 	@@nequal
	inc 	si
	jmp     @@equal
@@nequal:
        cmp 	[byte ptr es:di-1],' '
        jne     @@notequal	
@@equal:
	cmp 	[byte ptr si-1],'.'
	jne 	@@trynoext
	mov 	al,' '
	rep 	scasb
	mov 	cx,3
	rep 	cmpsb
	jne 	@@nequal2
        inc     si
        jmp     @@equal2
@@nequal2:
        cmp 	[byte ptr es:di-1],' '
        jne     @@notequal
@@equal2:
	cmp 	[byte ptr si-1],0
	jne     @@notequal
@@itok:
    clc
	ret
@@notequal:
	stc
	ret	
@@trynoext:
	cmp	[byte ptr si-1],0
	jne	@@notequal
	jmp	@@itok
endp cmpnames

;charge le fichier de de groupe CX et de taille eax
PROC loadway NEAR
     ARG     @sector:word,@size:dword,@offset:word
	USES 	eax,bx,cx,dx,si,di,ds,es
    push  ds
    pop   es
    mov   eax,[@size]		
	cmp   eax,0
	je	  @@zeroload
	rol	  eax,16
	mov	  dx,ax
	ror	  eax,16
	div	  [cs:clustersize]
	mov	  bx,ax
	mov   cx,[@sector]
	mov   di,[@offset]
	cmp	  bx,1
	jb	  @@adjustlast
@@loadfat:
	call   readcluster,cx,di
	jc 	   @@noway
	add	   di,[cs:clustersize]
	call   getfat
	dec	   bx
	jnz	   @@loadfat
@@adjustlast:
    cmp     dx,0
    je      @@zeroload
	push	cs
	pop 	ds
	mov	    si,offset bufferread
	call	readcluster,cx,si
	jc	    @@noway
	mov	    cx,dx   
	cld
	rep	movsb
@@zeroload:
	clc
	ret
@@noway:	
	stc
	ret
endp loadway	

;=============INITDRIVE===============
;Initialise le lecteur pour une utilisation ultérieure
;->
;<- Flag Carry si erreur
;=====================================
PROC initdrive FAR
	USES 	eax,bx,cx,edx,si,di,ds,es
	push 	cs
	pop 	ds
	push	cs
	pop	es
	mov	di,3
@@againtry:
        xor  	ax,ax
	mov	dl,[support]
	xor     dh,dh
        int  	13h
	mov	bx,offset bufferread
	mov	ax,0201h
	mov	cx,0001h
        mov     dl,[support]
        xor     dh,dh
	int	13h
	jnc	@@oknoagaintry
	dec	di
	jnz	@@againtry
@@oknoagaintry:
        mov     si,offset bufferread+3
        mov     di,offset myboot
        mov     cx,size myboot
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
        mov     ax,[myboot.sectorsperfat]
       	mul	[myboot.sectorsize]
        call    [cs:mbfindsb],offset datafat,cs
        jnc     @@hadafatbloc
        call    [cs:mbcreate],offset datafat,ax
        jc      @@errorinit
        call    [cs:mbresident],ax
        jc      @@errorinit
        call    [cs:mbchown],ax,cs
        jc      @@errorinit
@@hadafatbloc:
	mov	dx,[myboot.sectorsperfat]
	mov	cx,[adressfat]
        xor     di,di
        ;mov      di,offset fatter
        mov     ds,ax
@@seefat:
	call	readsector,cx,di
	jc	@@errorinit
	add	di,[cs:myboot.sectorsize]
	inc	cx
	dec	dx
	jnz	@@seefat
	clc
	ret
@@errorinit:
	stc
	ret
endp initdrive

datafat db '/fat',0

;=============FindFirstFile==============
;Renvois dans DS:%1 un bloc d'info
;->
;<- Flag Carry si erreur
;========================================
PROC findfirstfile FAR
        ARG     @pointer:word
	USES	cx,si
	mov     si,[@pointer]
	mov 	cx,[cs:currentdir]
	mov 	[(find si).adressdirectory],cx
	xor	    cx,cx
	mov 	[(find si).entryplace],cx
	mov	    [(find si).firstsearch],1
	call 	findnextfile,[@pointer]
	ret
endp findfirstfile

;=============FindnextFile==============
;Renvois dans DS:%0 un bloc d'info
;->
;<- Flag Carry si erreur
;=======================================
PROC findnextfile FAR
        ARG     @pointer:word
	USES	ax,bx,cx,di,si,ds,es
	push    cs
	push    ds
	pop     es
	pop     ds
	mov     si,[@pointer]	
	mov	    cx,[es:(find si).adressdirectory]
	mov	    bx,[es:(find si).entryplace]
@@findnextfileagain:
	cmp	    [es:(find si).firstsearch],1
	je	    @@first
	add	    bx,size entries
	cmp	    bx,[cs:clustersize]
	jb	    @@nopop
@@first:
	mov	    di,offset bufferentry
	mov	    bx,0
	cmp	    [cs:currentdir],0
	jne	@@notrootdir
	cmp	[es:(find si).firstsearch],1
	je	@@noaddfirst1
	inc	cx
@@noaddfirst1:
	add	cx,[cs:adressparent]
	mov	al,[cs:myboot.sectorspercluster]
@@readroot:
	call	readsector,cx,di
	jc	@@notwell
	add	di,[cs:myboot.sectorsize]
	dec	al
	jnz	@@readroot
	sub	cx,[cs:adressparent]
	jmp	@@nopop
@@notrootdir:
	cmp	[es:(find si).firstsearch],1
	je	@@noaddfirst2
	call	getfat
@@noaddfirst2:
	jc	@@notwell
	call	readcluster,cx,di
	jc	@@notwell
@@nopop:
	mov	[es:(find si).firstsearch],0
	mov di,offset bufferentry
	add	di,bx
	cmp	[byte ptr di],0
	je	@@notwell
	mov	[es:(find si).entryplace],bx
	mov	[es:(find si).adressdirectory],cx
	cmp	[byte ptr di],0E5h
	je	@@findnextfileagain
	cmp	[byte ptr di+entries.fileattr],28h
	je	@@findnextfileagain
	cmp	[byte ptr di+entries.fileattr],0Fh
	je	@@findnextfileagain
	mov si,di
    mov di,[@pointer]
    lea di,[es:(find di).result]	
	mov	cx,size entries
	cld
	rep	movsb
	clc
	ret
@@notwell:
	stc
	ret
endp findnextfile

;=============GetFreeSpace===============
;Renvoie en EDX l'espace disque libre du volume
;->
;<- Flag Carry si erreur
;========================================
PROC getfreespace FAR
	USES  	eax,bx
	xor	eax,eax
	call	getsector
	mul	[cs:myboot.sectorsize]
	shl	edx,16
	add	edx,eax
	pop   	eax
	ret
endp getfreespace

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


;=============READCLUSTER===============
;Lit le secteur %0 et le met en ds:%1
;->
;<- Flag Carry si erreur
;=======================================
PROC readcluster FAR
        ARG     @sector:word,@pointer:word
	USES	ax,bx,dx,si
	mov	al,[cs:myboot.sectorspercluster]
	xor	ah,ah
    mov bx,ax
	mul	[@sector]
	add	ax,[cs:addingvalue]
	mov     si,[@pointer]
@@readsectors:
	call	readsector,ax,si
	jc	@@errorreadincluster
	add	si,[cs:myboot.sectorsize]
	inc	ax
	dec	bx
	jnz	@@readsectors
	clc
	ret
@@errorreadincluster:
	stc
	ret
endp readcluster

;=============WRITECLUSTER===============
;Ecrit le cluster %0 et le met en ds:%1
;->
;<- Flag Carry si erreur
;=====================================================
PROC writecluster FAR
        ARG     @sector:word,@pointer:word
	USES	ax,bx,dx,si
	mov	al,[cs:myboot.sectorspercluster]
	xor	ah,ah
    mov bx,ax
	mul	[@sector]
	add	ax,[cs:addingvalue]
	mov     si,[@pointer]
@@writesectors:
	call	writesector,ax,si
	jc	@@errorwriteincluster
	add	si,[cs:myboot.sectorsize]
	inc	ax
	dec	bx
	jnz	@@writesectors
	clc
	ret
@@errorwriteincluster:
	stc
	ret
endp writecluster

;=============READSECTOR===============
;Lit le secteur %0 et le met en ds:%1
;->
;<- Flag Carry si erreur
;======================================
PROC readsector FAR
        ARG     @sector:word,@pointer:word
	USES 	ax,bx,cx,dx,si,es
	push    ds
	pop     es
	mov	ax,[@sector]
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
	or 	cl,bl       
	mov 	bx,[@pointer]
	mov 	si,4
	mov 	al,1
@@tryagain:
  	mov 	ah, 2
  	int 	13h
  	jnc 	@@done
  	dec 	si
  	jnz 	@@tryagain
@@done:
        ret
endp readsector
   
;=============WRITESECTOR============
;Ecrit le secteur %0 pointé par ds:%0
;->
;<- Flag Carry si erreur
;====================================
PROC writesector FAR
        ARG     @sector:word,@pointer:word
	USES 	ax,bx,cx,dx,si,es
	push    ds
	pop     es
	mov	ax,[@sector]
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
	mov 	bx,[@pointer]
	mov 	si,4
	mov 	al,1
@@tryagain:
  	mov 	ah, 3
  	int 	13h
  	jnc 	@@done
  	dec 	si
  	jnz 	@@tryagain
@@done:
        ret
endp writesector

;=============Getname==============
;Renvoie le nom en DS:%0
;-> AH=11
;<- Flag Carry si erreur
;==================================
PROC getname FAR
        ARG     @pointer:word
	USES 	ax,cx,si,di,ds,es	
	push    ds
	pop     es
        push	cs
	pop	ds
	mov	di,[@pointer]
	mov	si,offset myboot.drivename
	mov	cx,11
	rep	movsb
	mov	al,' '
	mov	di,[@pointer]
	mov	cx,11
	repne	scasb
	mov 	[byte ptr es:di],0
	ret
endp getname
;=============Getserial==============
;Renvoie le numéro de serie en EAX
;->
;<- Flag Carry si erreur
;====================================
PROC getserial FAR
	mov	eax,[cs:myboot.serialnumber]
	ret
endp getserial

;=============VERIFYSECTOR==============
;Vérifie le secteur %0
;->
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=======================================
PROC verifysector FAR
    ARG     @sector:word
	USES 	ecx,si,di,ds,es
	push 	cs
	pop 	es
	push 	cs
	pop 	ds
	mov 	si,offset bufferread
	call 	readsector,cx,si
	call 	inverse
	call 	writesector,cx,si
	jc 	@@errorverify

	mov 	si,offset bufferwrite
	call 	readsector,cx,si	
	call 	inverse
	jc 	@@errorverify
	
	mov 	si,offset bufferread
	call 	inverse
	call 	writesector,cx,si
	jc 	@@errorverify
	
	xor     ecx,ecx
	mov 	cx,[cs:myboot.sectorsize]
	shr	cx,2
	mov 	si,offset bufferread
	mov 	di,offset bufferwrite
	cld
	rep 	cmpsd
@@errorverify:
	ret

endp verifysector

inverse:
    push    si cx
	xor     cx,cx
invert:
	not 	[dword ptr si]
	add 	si,4
	add     cx,4
	cmp     cx,[cs:myboot.sectorsize]
	jb 	    invert
	pop     cx si
	ret

;=============DecompressRle (Fonction 05H)==============
;decompress ds:si en es:di taille bp d‚compress‚ cx compress‚
;-> AH=5
;<- Flag Carry si erreur, Flag Equal si secteurs égaux
;=====================================================
decompressrle:
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
	cmp 	[byte ptr si+4],'/'
	jne 	nocomp
	mov 	al,ch
	mov 	cl,ah
	xor 	ah,ah
	xor 	ch,ch
	cld
	rep 	stosb
	add 	si,5
	sub 	dx,5
	jnz 	decompression
	jmp 	thenen
nocomp:
	mov 	[es:di],al
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
compressrle:
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
	mov 	al,[es:di]
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
	mov 	[dword ptr si],' * /'
	mov 	[byte ptr si+4],'/'
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
PROC changedir FAR
ARG     @pointer:word
LOCAL   @@temp:word:64
USES	cx,si,di,ds,es
   	push    ss
	pop     es 
    lea     di,[@@temp]
    push    di
    mov     si,[@pointer]
    mov     cx,64/4
    cld
    rep     movsd
   	push    ss
	pop     ds
    pop     di 
	call    searchfile,di
	jne   	@@noch
	jc	    @@noch	
	;cmp	[si],005Ch ;'/',0 (root dir)
	mov	  cx,[es:(find di).result.filegroup]
	mov	[cs:currentdir],cx
	mov	[cs:adressdirectory],cx
	cmp	[dword ptr es:(find di).result.filename],'   .'
	je	@@theend
	cmp	[dword ptr es:(find di).result.filename],'  ..'
	jne	@@notback
    push      cs
    push      cs
    pop       ds
    pop       es
	mov	di,offset currentdirstr
	mov	cx,128
	mov	al,0
	cld
	repne	scasb
	mov	al,'/'
	std	
	repne	scasb
	inc 	di
	mov	[byte ptr es:di],0
	jmp	@@theend
@@notback:
    push      cs
    push      cs
    pop       ds
    pop       es
	mov	di,offset currentdirstr
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
	lea     di,[@@temp]
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
@@theend:
	clc
	ret
@@noch:
	stc
	ret
endp changedir

;=============getdir==============
;Recupere le repertoire courant a DS:%0
;->
;<- Flag Carry si erreur
;=================================
PROC getdir FAR
        ARG     @pointer:word
	USES	ax,cx,si,di,ds,es
	push	cs
	pop	es
	mov	di,offset currentdirstr
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
	mov	si,offset currentdirstr
	mov     di,[@pointer]
	cld
	rep	movsb
	clc
	ret
endp getdir
	
bufferread  	db 512 dup (0)
bufferwrite 	db 512 dup (0)
bufferentry	db 512 dup (0)
;fatter db 9*512 dup (0)
