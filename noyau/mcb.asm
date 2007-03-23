
exporting
declare biosprinth
declare biosprint
declare mbinit
declare mbcreate
declare mbfree
declare mbclean
declare mbresident
declare mbnonresident
declare mbchown
declare mballoc
declare mbfind
declare mbfindsb
declare mbget
declare mbloadfuncs
declare mbsearchfunc
declare bioswaitkey
declare mbloadsection
declare enableirq
declare enableirq
declare readmaskirq
declare readirr
declare readisr
declare seteoi
declare enablea20
declare disablea20
declare flatmode
ende

include "8259a.asm"

;Affiche le nombre hexa dans %0[dword]
PROC biosprinth FAR
        ARG     @num:dword
        USES    ax,bx,cx,edx,si,di
        mov     edx,[@num]
        mov 	ah,09h
        mov     di,8
@@hexaize:
        rol     edx,4
        mov     si,dx
	and	si,1111b
	mov	al,[cs:si+offset @@tab]
	mov     cx,1
        cmp     al,32
        jb      @@control
        mov     bx,7
        mov     ah,09h
        int     10h
@@control:
        mov     ah,0Eh
        int     10h
        dec     di
        jnz     @@hexaize
        ret
@@tab db '0123456789ABCDEF'
endp biosprinth

;Affiche le texte ASCIIZ pointé par %0
PROC biosprint FAR
        ARG    @pointer:word
        USES   ax,bx,cx,si
        mov    si,[@pointer]
        mov    cx,1
        mov    bx,7
@@again:
        lodsb
        or     al,al
        jz     @@fin
        cmp    al,32
        jb     @@control
        mov    ah,09h
        int    10h
@@control:
        mov    ah,0Eh
        int    10h
        jmp    @@again
@@fin:
        ret
endp biosprint

PROC enablea20 FAR
        USES    ax
        mov     al,0d1h
        out     64h,al
        call    a20wait
        mov     al,0dfh
        out     60h,al
        call    a20wait
        ;mov     al,0ffh
        ;out     64h,al
        ;call    a20wait
        ret
endp enablea20

PROC disablea20 FAR
        USES    ax
        mov     al,0d1h
        out     64h,al
        call    a20wait
        mov     al,0DDh
        out     60h,al
        call    a20wait
        ;mov     al,0ffh
        ;out     64h,al
        ;call    a20wait
        ret
endp disablea20

a20wait:
        in      al,64h
        jmp     @@suite
@@suite:
        and     al,2
        jnz     a20wait
        ret
;par le system control port A
;in al,92h
;or al,2
;out 92h,al

;par le system control port A
;in al,92h
;and al,not 2
;out 92h,al

PROC flatmode FAR
        USES    eax,bx,ds
        push    cs
        pop     ds
        ; first, calculate the linear address of GDT
        xor     eax,eax
        mov     ax,ds
        shl     eax,4
        add     [dword ptr offset @@gdt+2],eax   ; store as GDT linear base addr
        ; now load the GDT into the GDTR
        lgdt    [fword ptr offset @@gdt]   ; load GDT base
        mov     bx,1 * size descriptor ; point to first descriptor
        cli                     ; turn off interrupts
        mov     eax,cr0         ; prepare to enter protected mode
        or      al,1            ; flip the PE bit
        mov     cr0,eax         ; we're now in protected mode
        jmp     @@suite
@@suite:
        mov     fs,bx           ; load the FS segment register
        and     al,0FEh         ; clear the PE bit again
        mov     cr0,eax         ; back to real mode
        jmp     @@suite2
@@suite2:
        sti                     ; resume handling interrupts
        ret                     ;
        
@@gdt descriptor <offset @@gdtend - offset @@gdt - 1, offset @@gdt, 0, 0, 0, 0>  ; the GDT itself
      descriptor <0ffffh, 0, 0, 091h, 0cfh, 0>          ; 4G data segment
@@gdtend:
endp flatmode

;Attend l'appuie sur une touche
PROC bioswaitkey FAR
        xor    ax,ax
        int    16h
        ret
endp bioswaitkey

firstmb dw 0


;Charge les sections du block %0
PROC mbloadsection FAR
        ARG     @blocks:word
       	USES    ax,bx,cx,si,di,ds,es
       	LOCAL   @@toresov:word:60
       	mov     ax,[@blocks]
       	mov     es,ax
       	mov     ds,ax
        cmp     [word ptr 0],"EC"
        jne     @@notace
        lea     si,[@@toresov]
        mov     [word ptr ss:si],0FFFFh
        mov     bx,[ds:exe.sections]
        cmp     bx,0
        je      @@finishloading
@@loading:
        cmp     [dword ptr bx],0
        je      @@finishloading
        mov     ax,bx
        add     ax,4
pushad
call biosprint,ax
popad
        call    mbcreate,ax,[word ptr bx+2]
        jc      @@error
        inc     si
        inc     si
        mov     [ss:si],ax
        push    si
        mov     si,[bx]
        xor     di,di
        mov     es,ax
        mov     cx,[bx+2]
        cld
        rep     movsb
        pop     si
        add     bx,4
@@gonext:
        inc     bx
        cmp     [byte ptr bx],0
        jne     @@gonext
        inc     bx
        jmp     @@loading
@@finishloading:
        cmp     [word ptr ss:si],0FFFFh
        je      @@finishdepands
        call    mbloadfuncs,[word ptr ss:si]
        jc      @@depandserror
        dec     si
        dec     si
        jmp     @@finishloading
@@finishdepands:
        ret
@@notace:
        stc
        ret
@@error:
        stc
        ret
@@depandserror:
        stc
        ret
endp mbloadsection
        

;Initialise les blocs de mémoire en prenant memorystart pour segment de base
PROC mbinit FAR
	USES    ax,cx,si,di,ds,es	
	cmp     [cs:firstmb],0
	jne     @@alreadyok
	push    cs
	pop     ds
	mov     [cs:firstmb],memorystart
        mov     ax,memorystart-2
        mov     es,ax
        mov     si,offset afree
        xor     di,di
        mov     cx,size mb
        rep     movsb
	clc
	ret
@@alreadyok:
	stc
	ret
endp mbinit

afree mb <"HN",0,0,0,0A000h-memorystart,"Libre">
         db 0

;Creér un bloc de nom %0 de taille %1 (octets) -> n°segment dans AX
PROC mbcreate FAR
        ARG     @blocks:word,@size:word
        USES	bx,cx,dx,si,di,ds,es
        push    gs
        mov     gs,[ss:bp+4]
        mov     cx,[@size]	
	shr	cx,4
	inc	cx
	mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	mov     dl,true
@@searchfree:
	cmp	dl,false
	je	@@notenougtmem
	mov     es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror
	cmp	[es:mb.isnotlast],true
	sete    dl
	cmp	[es:mb.reference],free
	jne	@@notsogood
	mov	ax,[es:mb.sizes]
	cmp	cx,ax
	ja	@@notsogood
        mov     [word ptr es:mb.check],"NH"
	mov	[es:mb.isnotlast],true
	mov	[es:mb.reference],gs
	mov	[es:mb.isresident],false
	lea     di,[es:mb.names]
	push    cx
	mov 	cx,24/4
	mov     si,[@blocks]
        cld
	rep     movsd
	pop     cx
	inc     bx
	inc     bx	
        sub	ax,cx
	cmp     ax,0
	je      @@nofree
	dec	ax
	dec	ax
	mov	[es:mb.sizes],cx
	add	cx,bx
	mov	es,cx
        mov     si,offset afree
        xor     di,di
        mov     cx,size mb
        push    cs
        pop     ds
        cld
        rep     movsb	
	mov	[es:mb.isnotlast],dl
	mov	[es:mb.sizes],ax
@@nofree:
	mov	ax,bx
	pop     gs
	clc
	ret
@@notsogood:
        inc     bx
        inc     bx
	add	bx,[es:mb.sizes]
	jmp	@@searchfree
@@memoryerror:
	pop     gs
	stc
	ret
@@notenougtmem:
        pop     gs
        stc
        ret
endp mbcreate

;Libère le bloc de mémoire %0 et ses sous blocs
PROC mbfree FAR
        ARG     @blocks:word
	USES	ax,bx,cx,si,di,ds,es
	mov	bx,[@blocks]
	mov     ax,bx
	dec     bx
	dec     bx
	mov	es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror
	cmp	[es:mb.reference],free
	je	@@wasfree
	cmp	[es:mb.isresident],true
	je	@@wasresident
	mov	[es:mb.reference],free
	push    cs
	pop     ds
	mov     si,offset @@isfree
	lea     di,[es:mb.names]
        mov     cx,6
        cld
        rep     movsb
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
@@searchtofree:
	mov     es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror
        inc     bx
        inc     bx
	add	bx,[es:mb.sizes]
	cmp     [es:mb.sizes],0
	je      @@nottofree
	cmp     ax,[es:mb.reference]
	jne     @@nottofree
	mov	[es:mb.isresident],false
	mov	[es:mb.reference],free
        mov     cx,6
        cld
        rep     movsb
@@nottofree:
        cmp	[es:mb.isnotlast],true
	je	@@searchtofree
        call    mbclean	
	ret
@@memoryerror:
	stc
	ret
@@wasfree:
	stc
	ret
@@wasresident:
	stc
	ret
        	
@@isfree db "libre",0
endp mbfree

;Mise a nivo de la mémoire (jonction de blocs libre)
PROC mbclean FAR
        USES    ax,bx,dx,es,gs
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	xor     ax,ax
	xor     dx,dx
@@searchfree:
	mov     gs,bx
	cmp	[word ptr gs:mb.check],"NH"
	jne	@@memoryerror
        inc     bx
        inc     bx
	add	bx,[gs:mb.sizes]
	cmp     [word ptr gs:mb.sizes],0
	je      @@notenougtmem
	cmp	[gs:mb.reference],free
	jne     @@notfree
	cmp     ax,0
	je      @@notmeetfree
	add     dx,[gs:mb.sizes]
	mov     [word ptr gs:mb.check],0
	mov	[dword ptr gs:mb.names],0	
	inc     dx
	inc     dx
	jmp     @@nottrigered
@@notmeetfree:	
        xor     dx,dx
	mov     ax,gs	
	jmp     @@nottrigered
@@notfree:
        cmp     ax,0
        je      @@nottrigered
        mov     es,ax
        add     [es:mb.sizes],dx
        xor     ax,ax
@@nottrigered:
	cmp	[gs:mb.isnotlast],true
	je	@@searchfree
	cmp     ax,0
	je      @@reallyfinish
	mov     es,ax
        add     [es:mb.sizes],dx
        mov     [es:mb.isnotlast],false
@@reallyfinish:
	clc
	ret
@@notenougtmem:
        stc
        ret
@@memoryerror:
	stc
	ret
endp mbclean

;Rend le segment %0 résident
PROC mbresident FAR
        ARG     @blocks:word
	USES	bx,es
	mov	bx,[@blocks]
	dec	bx
	dec     bx
	mov	es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror	
	mov	[es:mb.isresident],true
	ret
@@memoryerror:
        stc
        ret
endp mbresident
	
;Rend le segment %0 non résident
PROC mbnonresident FAR
        ARG     @blocks:word
	USES	bx,es
	mov	bx,[@blocks]
	dec	bx
	dec     bx
	mov	es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror	
	mov	[es:mb.isresident],false
	ret
@@memoryerror:
        stc
        ret
endp mbnonresident


;Change le proprietaire de %0 a %1
PROC mbchown FAR
        ARG     @blocks:word,@owner:word
	USES	bx,dx,es
	mov	bx,[@blocks]
	dec     bx
	dec     bx
	mov	es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror
	cmp	[es:mb.reference],free
	je	@@wasfree
	mov     dx,[@owner]
	mov	[es:mb.reference],dx
	ret
@@memoryerror:
	stc
	ret
@@wasfree:
	stc
	ret
endp mbchown
	
;Alloue un bloc /data de CX caractere pour le process appelant -> ax
PROC mballoc FAR
        ARG     @size:word
        USES    ax,si,ds	
	push    cs
	pop     ds
	call    mbcreate,offset @@data,[@size]
	call    mbchown,ax,[word ptr ss:bp+4]
	ret

@@data db '/data',0
endp mballoc

;Renvoie en AX le MB n° %0  carry quand terminé
PROC mbget FAR
        ARG     @num:word
        USES    bx,dx,es
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	xor     dx,dx
@@searchfree:
	mov     es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror
        inc     bx
        inc     bx
	add	bx,[es:mb.sizes]
	cmp     [es:mb.sizes],0
	je      @@memoryerror
	cmp     dx,[@num]
	je      @@foundmcb
	ja      @@notfound
        inc     dx
	cmp	[es:mb.isnotlast],true
	je	@@searchfree
@@memoryerror:
	stc
	ret
@@foundmcb:
        mov     ax,es
        inc     ax
        inc     ax
	clc
	ret
@@notfound:
 	stc
	ret
endp mbget 		
	
;Renvoie en AX le MCB qui correspond a ds:%0
PROC mbfind FAR
        ARG     @blocks:word
        USES    bx,si,di,es
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	mov     si,[@blocks]
@@search:
	mov     es,bx
	lea     di,[es:mb.names]
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror
        inc     bx
        inc     bx
	add	bx,[es:mb.sizes]
	cmp     [es:mb.sizes],0
	je      @@memoryerror
	push    si di
@@cmpnames:
        mov     al,[es:di]
        cmp     al,[ds:si]
        jne     @@ok
        cmp     al,0
        je      @@ok
        inc     si
        inc     di
        jmp     @@cmpnames
@@ok:
        pop     di si
	je      @@foundmcb
	cmp	[es:mb.isnotlast],true
	je	@@search
@@notfound:
	stc
	ret
@@memoryerror:
        stc
        ret
@@foundmcb:
        mov     ax,es
        inc     ax
        inc     ax
	clc
	ret
endp mbfind

		
;Renvoie en AX le sous mcb qui correspond a %0 et qui appartien a %1
PROC mbfindsb FAR
        ARG     @blocks:word,@owner:word
        USES    bx,dx,si,di,es
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	mov     si,[@blocks]
	lea     di,[es:mb.names]
	mov     dx,[@owner]
@@search:
	mov     es,bx
	cmp	[word ptr es:mb.check],"NH"
	jne	@@memoryerror
        inc     bx
        inc     bx
	add	bx,[es:mb.sizes]
	cmp     [es:mb.sizes],0
	je      @@memoryerror
	push    si di
@@cmpnames:
        mov     al,[es:di]
        cmp     al,[ds:si]
        jne     @@ok
        cmp     al,0
        je      @@ok
        inc     si
        inc     di
        jmp     @@cmpnames
@@ok:
        pop     di si
	jne     @@notfoundmcb
	cmp     [es:mb.reference],dx
	je      @@foundmcb
@@notfoundmcb:
	cmp	[es:mb.isnotlast],true
	je	@@search
@@notfound:
	stc
	ret
@@foundmcb:
        mov     ax,es
        inc     ax
        inc     ax
	clc
	ret
@@memoryerror:
        stc
        ret
endp mbfindsb

;Resouds les dépendances du bloc de mémoire %0
PROC mbloadfuncs FAR
        ARG     @blocks:word
        USES    ax,bx,cx,dx,si,ds
        mov     ds,[@blocks]
        cmp     [word ptr 0],"EC"
        jne     @@notace
        mov     si,[ds:exe.imports]
        cmp     si,0
        je      @@endofloading
@@loadfuncs:
        cmp     [word ptr si],0
        je      @@endofloading
        call    mbsearchfunc,si
        jnc     @@toendoftext
        mov     bx,si
pushad
call biosprint,si
popad
@@findend:
        inc     bx
        cmp     [byte ptr bx], ':'
        jne     @@findend
        mov     [byte ptr bx],0
        call    [cs:projfile],si
        jc      @@erroronload
        mov     [byte ptr bx],':'
pushad
call biosprint,si
popad
        call    mbsearchfunc,si
        jc      @@libnotexist
@@toendoftext:
        mov     cl,[si]
        cmp     cl,0
        je      @@oktonext
        inc     si
        jmp     @@toendoftext
@@oktonext:
        inc     si
        mov     [si],ax
        mov     [si+2],dx
        add     si,4
        jmp     @@loadfuncs
@@endofloading:
        clc
        ret
@@notace:
        stc
        ret
@@libnotexist:
        stc
        ret
@@erroronload:
        stc
        ret
endp mbloadfuncs


;Recherche une fonction pointé par DS:%0 en mémoire et renvoie son adresse en DX:AX
PROC mbsearchfunc FAR
        ARG     @func:word
        USES    bx,si,di,es
        mov     bx,[@func]
        mov     si,bx
@@findend:
        inc     bx
        cmp     [byte ptr bx], ':'
        jne     @@findend
        mov     [byte ptr bx],0
        call    mbfind,si
        mov     [byte ptr bx],':'
        jc      @@notfoundattallthesb
        mov     es,ax
        cmp     [word ptr es:exe.checks],"EC"
        jne     @@notfoundattallthesb
        mov     di,[es:exe.exports]
        inc     bx
        inc     bx
@@functions:
        cmp     [word ptr es:di],0
        je      @@notfoundattallthesb
        mov     si,bx
@@cmpnamesfunc:
        mov     al,[es:di]
        cmp     al,[ds:si]
        jne     @@notfoundthesb
        cmp     al,0
        je      @@seemsok
        inc     si
        inc     di
        jmp     @@cmpnamesfunc
@@notfoundthesb:
        mov     al,[es:di]
        cmp     al,0
        je      @@oktonext
        inc     di
        jmp     @@notfoundthesb
@@oktonext:
        inc     di
        inc     di
        inc     di
        jmp     @@functions
@@seemsok:
        mov     dx,es
        mov     ax,[es:di+1]
        clc
        ret
@@notfoundattallthesb:
        stc
        ret
endp mbsearchfunc
