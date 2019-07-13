
;Affiche le nombre hexa dans %0[dword]
proc biosprinth uses ax bx cx edx si di, num:dword
        mov     edx,[num]
        mov 	ah,09h
        mov     di,8
.hexaize:
        rol     edx,4
        mov     si,dx
	and	si,1111b
	mov	al,[cs:si+.tab]
	mov     cx,1
        cmp     al,32
        jb      .control
        mov     bx,7
        mov     ah,09h
        int     10h
.control:
        mov     ah,0Eh
        int     10h
        dec     di
        jnz     .hexaize
        ret
.tab db '0123456789ABCDEF'
endp

;Affiche le texte ASCIIZ pointé par %0
proc biosprint uses ax bx cx si, pointer:word
        mov    si,[pointer]
        mov    cx,1
        mov    bx,7
.again:
        lodsb
        or     al,al
        jz     .fin
        cmp    al,32
        jb     .control
        mov    ah,09h
        int    10h
.control:
        mov    ah,0Eh
        int    10h
        jmp    .again
.fin:
        ret
endp

proc enablea20 uses ax
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
endp

proc disablea20 uses ax
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
endp

a20wait:
        in      al,64h
        jmp     .suite
.suite:
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

proc flatmode uses eax bx ds
        push    cs
        pop     ds
        ; first, calculate the linear address of GDT
        xor     eax,eax
        mov     ax,ds
        shl     eax,4
        add     dword [.gdt+2],eax   ; store as GDT linear base addr
        ; now load the GDT into the GDTR
        lgdt    fword [.gdt]   ; load GDT base
	virtual at 0
	.descriptor descriptor
	end virtual
        mov     bx,1 * .descriptor.sizeof ; point to first descriptor
        cli                     ; turn off interrupts
        mov     eax,cr0         ; prepare to enter protected mode
        or      al,1            ; flip the PE bit
        mov     cr0,eax         ; we're now in protected mode
        jmp     .suite
.suite:
        mov     fs,bx           ; load the FS segment register
        and     al,0FEh         ; clear the PE bit again
        mov     cr0,eax         ; back to real mode
        jmp     .suite2
.suite2:
        sti                     ; resume handling interrupts
        ret                     ;
        
.gdt:
gdtitse descriptor .gdtend - .gdt - 1, .gdt, 0, 0, 0, 0  ; the GDT itself
gdtdata descriptor 0ffffh, 0, 0, 091h, 0cfh, 0          ; 4G data segment
.gdtend:
endp

;Attend l'appuie sur une touche
proc bioswaitkey uses ax
        xor    ax,ax
        int    16h
        ret
endp

firstmb dw 0


;Charge les sections du block %0
proc mbloadsection uses ax bx cx si di ds es, blocks:word
       	mov     ax,[blocks]
       	mov     es,ax
       	mov     ds,ax
        cmp     word [0],"EC"
        jne     .notace
        lea     si,[.toresov]
        mov     word [ss:si],0FFFFh
	virtual at 0
	.exe exe
	end virtual
        mov     bx,[ds:.exe.sections]
        cmp     bx,0
        je      .finishloading
.loading:
        cmp     dword [bx],0
        je      .finishloading
        mov     ax,bx
        add     ax,4
pushad
stdcall biosprint,ax
popad
        stdcall    mbcreate,ax,word [bx+2]
        jc      .error
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
.gonext:
        inc     bx
        cmp     byte [bx],0
        jne     .gonext
        inc     bx
        jmp     .loading
.finishloading:
        cmp     word [ss:si],0FFFFh
        je      .finishdepands
        stdcall    mbloadfuncs,word [ss:si]
        jc      .depandserror
        dec     si
        dec     si
        jmp     .finishloading
.finishdepands:
        ret
.notace:
        stc
        ret
.error:
        stc
        ret
.depandserror:
        stc
        ret
       .toresov dw 60 dup (0)
endp
        

;Initialise les blocs de mémoire en prenant memorystart pour segment de base
proc mbinit uses ax cx si di ds es
	cmp     [cs:firstmb],0
	jne     .alreadyok
	push    cs
	pop     ds
	mov     [cs:firstmb],memorystart
        mov     ax,memorystart-2
        mov     es,ax
        mov     si,afree
        xor     di,di
	virtual at 0
	.mb mb
	end virtual
        mov     cx,.mb.sizeof
        rep     movsb
	clc
	ret
.alreadyok:
	stc
	ret
endp

afree mb "HN",0,0,0,0A000h-memorystart,"Libre"
         db 0

;Creér un bloc de nom %0 de taille %1 (octets) -> n°segment dans AX
proc mbcreate uses bx cx dx si di ds es, blocks:word, size:word
        push    gs
        mov     ax,[ss:bp+4]
        mov     dx,ax
        dec     dx
        dec     dx
        mov     gs,dx
        cmp     word [gs:0x0],'NH'
        je      .oktoset
        mov     ax,memorystart
.oktoset:
        mov     gs,ax
        mov     cx,[size]	
	shr	cx,4
	inc	cx
	mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	mov     dl,true
.searchfree:
	cmp	dl,false
	je	.notenougtmem
	mov     es,bx
	virtual at 0
	.mb mb
	end virtual
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror
	cmp	[es:.mb.isnotlast],true
	sete    dl
	cmp	[es:.mb.reference],free
	jne	.notsogood
	mov	ax,[es:.mb.sizes]
	cmp	cx,ax
	ja	.notsogood
        mov     word [es:.mb.check],"NH"
	mov	[es:.mb.isnotlast],true
	mov	[es:.mb.reference],gs
	mov	[es:.mb.isresident],false
	lea     di,[es:.mb.names]
	push    cx
	mov 	cx,24/4
	mov     si,[blocks]
        cld
	rep     movsd
	pop     cx
	inc     bx
	inc     bx	
        sub	ax,cx
	cmp     ax,0
	je      .nofree
	dec	ax
	dec	ax
	mov	[es:.mb.sizes],cx
	add	cx,bx
	mov	es,cx
        mov     si,afree
        xor     di,di
        mov     cx,.mb.sizeof
        push    cs
        pop     ds
        cld
        rep     movsb	
	mov	[es:.mb.isnotlast],dl
	mov	[es:.mb.sizes],ax
.nofree:
	mov	ax,bx
	pop     gs
	clc
	ret
.notsogood:
        inc     bx
        inc     bx
	add	bx,[es:.mb.sizes]
	jmp	.searchfree
.memoryerror:
	pop     gs
	stc
	ret
.notenougtmem:
        pop     gs
        stc
        ret
endp

;Libère le bloc de mémoire %0 et ses sous blocs
proc mbfree uses ax bx cx si di ds es, blocks:word
	mov	bx,[blocks]
	mov     ax,bx
	dec     bx
	dec     bx
	mov	es,bx
	virtual at 0
	.mb mb
	end virtual
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror
	cmp	[es:.mb.reference],free
	je	.wasfree
	cmp	[es:.mb.isresident],true
	je	.wasresident
	mov	[es:.mb.reference],free
	push    cs
	pop     ds
	mov     si,.isfree
	lea     di,[es:.mb.names]
        mov     cx,6
        cld
        rep     movsb
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
.searchtofree:
	mov     es,bx
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror
        inc     bx
        inc     bx
	add	bx,[es:.mb.sizes]
	cmp     [es:.mb.sizes],0
	je      .nottofree
	cmp     ax,[es:.mb.reference]
	jne     .nottofree
	mov	[es:.mb.isresident],false
	mov	[es:.mb.reference],free
	mov     si,.isfree
	lea     di,[es:.mb.names]
        mov     cx,6
        cld
        rep     movsb
.nottofree:
        cmp	[es:.mb.isnotlast],true
	je	.searchtofree
        stdcall    mbclean	
	ret
.memoryerror:
	stc
	ret
.wasfree:
	stc
	ret
.wasresident:
	stc
	ret
        	
.isfree db "libre",0
endp

;Mise a nivo de la mémoire (jonction de blocs libre)
proc mbclean uses ax bx dx es gs
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	xor     ax,ax
	xor     dx,dx
.searchfree:
	mov     gs,bx
	virtual at 0
	.mb mb
	end virtual
	cmp	word [gs:.mb.check],"NH"
	jne	.memoryerror
        inc     bx
        inc     bx
	add	bx,[gs:.mb.sizes]
	cmp     word [gs:.mb.sizes],0
	je      .notenougtmem
	cmp	[gs:.mb.reference],free
	jne     .notfree
	cmp     ax,0
	je      .notmeetfree
	add     dx,[gs:.mb.sizes]
	mov     word [gs:.mb.check],0
	mov	dword [gs:.mb.names],0	
	inc     dx
	inc     dx
	jmp     .nottrigered
.notmeetfree:	
        xor     dx,dx
	mov     ax,gs	
	jmp     .nottrigered
.notfree:
        cmp     ax,0
        je      .nottrigered
        mov     es,ax
        add     [es:.mb.sizes],dx
        xor     ax,ax
.nottrigered:
	cmp	[gs:.mb.isnotlast],true
	je	.searchfree
	cmp     ax,0
	je      .reallyfinish
	mov     es,ax
        add     [es:.mb.sizes],dx
        mov     [es:.mb.isnotlast],false
.reallyfinish:
	clc
	ret
.notenougtmem:
        stc
        ret
.memoryerror:
	stc
	ret
endp

;Rend le segment %0 résident
proc mbresident uses bx es, blocks:word
	mov	bx,[blocks]
	dec	bx
	dec     bx
	mov	es,bx
	virtual at 0
	.mb mb
	end virtual
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror	
	mov	[es:.mb.isresident],true
	ret
.memoryerror:
        stc
        ret
endp
	
;Rend le segment %0 non résident
proc mbnonresident uses bx es, blocks:word
	mov	bx,[blocks]
	dec	bx
	dec     bx
	mov	es,bx
	virtual at 0
	.mb mb
	end virtual
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror	
	mov	[es:.mb.isresident],false
	ret
.memoryerror:
        stc
        ret
endp


;Change le proprietaire de %0 a %1
proc mbchown uses bx dx es,blocks:word, owner:word
	mov	bx,[blocks]
	dec     bx
	dec     bx
	mov	es,bx
	virtual at 0
	.mb mb
	end virtual
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror
	cmp	[es:.mb.reference],free
	je	.wasfree
	mov     dx,[owner]
	mov	[es:.mb.reference],dx
	ret
.memoryerror:
	stc
	ret
.wasfree:
	stc
	ret
endp
	
;Alloue un bloc /data de CX caractere pour le process appelant -> ax
proc mballoc uses si ds, size:word
	push    cs
	pop     ds
	stdcall    mbcreate,.data,[size]
	stdcall    mbchown,ax,word [ss:bp+4]
	ret

.data db '/data',0
endp

;Renvoie en AX le MB n° %0  carry quand terminé
proc mbget uses bx dx es, num:word
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	xor     dx,dx
.searchfree:
	mov     es,bx
	virtual at 0
	.mb mb
	end virtual
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror
        inc     bx
        inc     bx
	add	bx,[es:.mb.sizes]
	cmp     [es:.mb.sizes],0
	je      .memoryerror
	cmp     dx,[num]
	je      .foundmcb
	ja      .notfound
        inc     dx
	cmp	[es:.mb.isnotlast],true
	je	.searchfree
.memoryerror:
	stc
	ret
.foundmcb:
        mov     ax,es
        inc     ax
        inc     ax
	clc
	ret
.notfound:
 	stc
	ret
endp 		
	
;Renvoie en AX le MCB qui correspond a ds:%0
proc mbfind uses bx si di es, blocks:word
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	mov     si,[blocks]
.search:
	mov     es,bx
	virtual at 0
	.mb mb
	end virtual
	lea     di,[es:.mb.names]
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror
        inc     bx
        inc     bx
	add	bx,[es:.mb.sizes]
	cmp     [es:.mb.sizes],0
	je      .memoryerror
	push    si di
.cmpnames:
        mov     al,[es:di]
        cmp     al,[ds:si]
        jne     .ok
        cmp     al,0
        je      .ok
        inc     si
        inc     di
        jmp     .cmpnames
.ok:
        pop     di si
	je      .foundmcb
	cmp	[es:.mb.isnotlast],true
	je	.search
.notfound:
	stc
	ret
.memoryerror:
        stc
        ret
.foundmcb:
        mov     ax,es
        inc     ax
        inc     ax
	clc
	ret
endp

		
;Renvoie en AX le sous mcb qui correspond a %0 et qui appartien a %1
proc mbfindsb uses bx dx si di es, blocks:word, owner:word
        mov	bx,[cs:firstmb]
	dec	bx
	dec	bx
	mov     si,[blocks]
	virtual at 0
	.mb mb
	end virtual
	lea     di,[es:.mb.names]
	mov     dx,[owner]
.search:
	mov     es,bx
	cmp	word [es:.mb.check],"NH"
	jne	.memoryerror
        inc     bx
        inc     bx
	add	bx,[es:.mb.sizes]
	cmp     [es:.mb.sizes],0
	je      .memoryerror
	push    si di
.cmpnames:
        mov     al,[es:di]
        cmp     al,[ds:si]
        jne     .ok
        cmp     al,0
        je      .ok
        inc     si
        inc     di
        jmp     .cmpnames
.ok:
        pop     di si
	jne     .notfoundmcb
	cmp     [es:.mb.reference],dx
	je      .foundmcb
.notfoundmcb:
	cmp	[es:.mb.isnotlast],true
	je	.search
.notfound:
	stc
	ret
.foundmcb:
        mov     ax,es
        inc     ax
        inc     ax
	clc
	ret
.memoryerror:
        stc
        ret
endp

;Resouds les dépendances du bloc de mémoire %0
proc mbloadfuncs uses ax bx cx dx si ds, blocks:word
        mov     ds,[blocks]
        cmp     word [0],"EC"
        jne     .notace
	virtual at 0
	.exe exe
	end virtual
        mov     si,[ds:.exe.imports]
        cmp     si,0
        je      .endofloading
.loadfuncs:
        cmp     word [si],0
        je      .endofloading
        stdcall    mbsearchfunc,si
        jnc     .toendoftext
        mov     bx,si
;pushad
;stdcall biosprint,si
;popad
.findend:
        inc     bx
        cmp     byte [bx], ':'
        jne     .findend
        mov     byte [bx],0
        invoke    projfile,si
        mov     byte [bx],':'
        jc      .erroronload
;pushad
;stdcall biosprint,si
;popad
        stdcall    mbsearchfunc,si
        jc      .libnotexist
.toendoftext:
        mov     cl,[si]
        cmp     cl,0
        je      .oktonext
        inc     si
        jmp     .toendoftext
.oktonext:
        inc     si
        mov     [si],ax
        mov     [si+2],dx
        add     si,4
        jmp     .loadfuncs
.endofloading:
        clc
        ret
.notace:
        stc
        ret
.libnotexist:
        stc
        ret
.erroronload:
        stc
        ret
endp


;Recherche une fonction pointé par DS:%0 en mémoire et renvoie son adresse en DX:AX
proc mbsearchfunc uses bx si di es, func:word
        mov     bx,[func]
        mov     si,bx
.findend:
	virtual at 0
	.exe exe
	end virtual
        inc     bx
        cmp     byte [bx], ':'
        jne     .findend
        mov     byte [bx],0
        stdcall    mbfind,si
        mov     byte [bx],':'
        jc      .notfoundattallthesb
        mov     es,ax
        cmp     word [es:.exe.checks],"EC"
        jne     .notfoundattallthesb
        mov     di,[es:.exe.exports]
        inc     bx
        inc     bx
.functions:
        cmp     word [es:di],0
        je      .notfoundattallthesb
        mov     si,bx
.cmpnamesfunc:
        mov     al,[es:di]
        cmp     al,[ds:si]
        jne     .notfoundthesb
        cmp     al,0
        je      .seemsok
        inc     si
        inc     di
        jmp     .cmpnamesfunc
.notfoundthesb:
        mov     al,[es:di]
        cmp     al,0
        je      .oktonext
        inc     di
        jmp     .notfoundthesb
.oktonext:
        inc     di
        inc     di
        inc     di
        jmp     .functions
.seemsok:
        mov     dx,es
        mov     ax,[es:di+1]
        clc
        ret
.notfoundattallthesb:
        stc
        ret
endp
