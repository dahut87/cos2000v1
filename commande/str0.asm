model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

header exe <"CE",1,0,0,offset exports,,,>


exporting
declare checksyntax
declare cmpitems
declare gettypeditem
declare gettyped
declare whatisitem
declare whatis
declare strtoadress
declare strisadress
declare strisname
declare strisbase
declare strtoint
declare left
declare right
declare middle
declare fill
declare replaceallchar
declare searchchar
declare invert
declare cmpstr
declare evalue
declare insert
declare delete
declare copy
declare concat
declare compressdelimiter
declare setnbitems
declare getitemsize
declare getitem
declare getpointeritem
declare getnbitems
declare getlength
declare setlength
declare uppercase
declare onecase
declare lowercase
declare invertcase
ende

;Librairie qui prend en charge le format de STR ASCIIZ
;# nombre   8
;? str      7
;& nom      6

;High          Low
;0 variable    4 hex
;1 byte        3 dec
;2 word        2 oct
;3 3 octets    1 bin
;4 dword       5 adresse
;5 5 octets    6 nom
;6 ...         7 str
	;       8 nombre

;Renvoie carry si la syntaxe de ds:si n'est pas respect‚ par rapport a es:di
PROC checksyntax FAR
        ARG     @src:word,@dest:word,@delim:word
        USES    ax,bx,cx,dx,si,di,ds,es
        LOCAL   @@temp:word:256
        push    ss
        pop     es
        lea     si,[@@temp]
        mov     di,[@dest]
        call    copy,[@src],si
        call    xch 
        call    compressdelimiter,si,[@delim]
        call    getnbitems,si,[@delim]
        mov     bx,ax
        call    xch 
        call    getnbitems,di,[@delim]
        cmp     bx,ax
        jne     @@notequalatall
        xor     cx,cx
@@itemer:
        call    xch 
        call    whatisitem,si,cx,[@delim]
        mov     dx,ax
        call    xch 
        call    whatisitem,di,cx,[@delim]
        cmp     ax,dx
        jne     @@prob
        cmp     al,6
        jb      @@equal
        call    cmpitems
        je      @@equal
@@prob:
        cmp     dl,4
        ja      @@nonumber
        cmp     dl,8
        je      @@equal
        ;cmp     al,4
        ;jne     @@notequalatall
        cmp     dh,ah
        ja      @@notequalatall
        jmp     @@equal
@@nonumber:
        cmp     al,7
        jne     @@nostr
        cmp     ah,0
        jne     @@notequalatall
        jmp     @@equal
@@nostr:
        cmp     al,6
        jne     @@noname
        cmp     dl,6
        jne     @@noname
        cmp     ah,0
        jne     @@notequalatall
        jmp     @@equal
@@noname:
        cmp     al,8
        je      @@equal
        jmp     @@notequalatall
@@equal:
        inc     cx
        cmp     cx,bx
        jne     @@itemer
        cld
@@ackno: 
        ret
@@notequalatall:
        stc
        jmp     @@ackno
endp checksyntax

xch:
        push    es
        push    ds
        pop     es
        pop     ds
        ret


;Compare les ‚l‚ments cx de deux chaine ds:si et es:di
PROC cmpitems FAR
        ARG     @src:word,@dest:word,@item:word,@delim:word
        USES    ax,cx,si,di,es
        push    ds
        pop     es 
        call    getpointeritem,[@src],[@item],[@delim]
        mov     si,ax
        call    getitemsize,[@src],[@item],[@delim]
        mov     di,[@dest]
        mov     cx,ax    
        cld 
        rep     cmpsb
        clc
        ret
endp cmpitems

                                
;Renvoie l'‚l‚ment cx de ds:si dans edx si nb et dans es:di si str ou name
PROC gettypeditem FAR
        ARG     @src:word,@item:word,@delim:word
        USES    bx,cx,si,di
        mov     si,[@src]
        mov     cx,[@item]
        call    getpointeritem,si,cx,[@delim]
        mov     di,ax
        inc     cx
        call    getpointeritem,si,cx,[@delim]
        mov     si,ax
        dec     si
        mov     cl,0
        xchg    cl,[ds:si]
        call    gettyped,di
        xchg    cl,[ds:si]
        clc
        ret
endp gettypeditem


;Renvoie eax si nb et dans ds:eax si str ou name
PROC gettyped FAR
        ARG     @src:word
        USES    si
        mov     si,[@src]
        xor     eax,eax
        call    whatis,si
        cmp     al,1
        je      @@bin
        cmp     al,2
        je      @@oct
        cmp     al,3
        je      @@dec
        cmp     al,4
        je      @@hex
        cmp     al,5
        je      @@pointer
        mov     ax,si
        jmp     @@endofgettypeditem
@@bin:
        call    strtoint,si,2
        jmp     @@endofgettypeditem
@@oct:
        call    strtoint,si,8
        jmp     @@endofgettypeditem
@@dec:
        call    strtoint,si,10
        jmp     @@endofgettypeditem
@@hex:
        call    strtoint,si,16
        jmp     @@endofgettypeditem
@@pointer:
        call    strtoadress,si
@@endofgettypeditem:
        clc
        ret   
endp gettyped  

;Renvoie dans ax le type de la str0 point‚e par ds:%0 ‚l‚ment %1 delim %3
PROC whatisitem FAR
        ARG     @src:word,@item:word,@delim:word
        USES    bx,cx,si,di
        mov     si,[@src]
        mov     cx,[@item]
        call    getpointeritem,si,cx,[@delim]
        mov     di,ax
        inc     cx
        call    getpointeritem,si,cx,[@delim]
        mov     si,ax
        dec     si
        mov     cl,0
        xchg    cl,[ds:si]
        call    whatis,di
        xchg    cl,[ds:si]
        clc
        ret
endp whatisitem

;Renvoie dans ax le type de la str0 point‚e par ds:%0
;High          Low
;0 variable    4 hex
;1 byte        3 dec
;2 word        2 oct
;3 3 octets    1 bin
;4 dword       5 adresse
;5 5 octets    6 name
;6 ...         7 str
PROC whatis FAR
        ARG     @src:word
        USES    bx,cx,edx,si
        mov     si,[@src]
        xor     cx,cx
        mov     cl,2 
        call    strisbase,si,cx
        jnc     @@finbase
        mov     cl,8
        call    strisbase,si,cx
        jnc     @@finbase
        mov     cl,10
        call    strisbase,si,cx
        jnc     @@finbase
        mov     cl,16
        call    strisbase,si,cx
        jc      @@testadress
@@finbase:
        mov     bx,cx
        xor     ch,ch
        mov     al,[cs:bx+offset basenn-2]
        push    eax
        call    strtoint,si,cx
        mov     edx,eax
        pop     eax 
        cmp     edx,0000FFFFh
        ja      @@bits32
        cmp     dx,00FFh
        ja      @@bits16
        mov     ah,1
        jmp     @@endofwhat
@@bits16:
        mov     ah,2
        jmp     @@endofwhat
@@bits32:
        mov     ah,4
        jmp     @@endofwhat
@@testadress:
        call    strisadress,si
        jc      @@testname
        mov     ax,0005h
        jmp     @@endofwhat
@@testname:
        call    strisname
        jc      @@testnumber
        xor     ah,ah
        cmp     [byte ptr si],'&'
        je      @@okname
        call    getlength,si
        mov     ah,al
@@okname:
	    mov     al,06h
	    jmp     @@endofwhat
@@testnumber:
        cmp     [byte ptr si],'#'
        jne     @@testvarstr
        xor     ah,ah
	    mov     al,08h
        jmp     @@endofwhat
@@testvarstr:    
        xor     ah,ah   
        cmp     [byte ptr si],'?'
        je      @@okvarstr
        call    getlength,si
        mov     ah,al
@@okvarstr:
	    mov     al,07h
@@endofwhat:
        clc
        ret
endp whatis



;Renvoie non carry si la str ds:si point‚e peut ˆtre une adresse
PROC strtoadress FAR
        ;push
        stc
        ;pop
        ret
endp strtoadress
        

;Renvoie en es:di le pointeur str0 ds:si
PROC strisadress FAR
        ;push
        stc
        ;pop
        ret
endp strisadress

;Renvoie non carry si la str ds:%0 point‚e peut ˆtre un nom de fichier
PROC strisname FAR
        ARG     @src:word
        USES    ax,si,di
        mov     si,[@src] 
@@isname:
        mov     al,[si]
        inc     si
        cmp     al,0
        je      @@itsok
        mov     di,offset non
@@verify:
        mov     ah,[cs:di]
        inc     di
        cmp     ah,0FFh
        je      @@isname
        cmp     ah,al
        jne     @@verify
        stc
        jmp     @@itsdead
@@itsok:
        clc
@@itsdead:        
        ret
endp strisname

non db '/<>|"?*:\',01,0FFh

;Renvoie non carry si le texte point‚ par %0 est de la base %1
PROC strisbase FAR
        ARG     @src:word,@base:word
        USES    ax,cx,si,di,es
        push    cs
        pop     es
        mov     si,[@src] 
@@isstrbase:
        mov     al,[si]         
        cmp     al,0
        je      @@okbase
        mov     cx,[@base] 
        xor     ch,ch
        mov     di,cx
        cmp     al,[es:di-2+offset basen]
        je      @@verifbase
        xor     ch,ch
        inc     cl
        mov     di,offset base
        cld
        repne   scasb
        cmp     cx,0
        je      @@nobase
        inc     si
        jmp     @@isstrbase
@@okbase:
        clc
@@endbase:
        ret
@@verifbase:
        cmp     [byte ptr si+1],0
        je      @@okbase  
@@nobase:
        stc
        jmp     @@endbase  
endp strisbase

base   db '0123456789ABCDEF'
basen  db 'b     o d     h'            
basenn db 1,0,0,0,0,0,2,0,3,0,0,0,0,0,4


;Converti un str %0 de base %1 en int dans eax
PROC strtoint FAR
        ARG     @src:word,@base:word
        USES    ebx,ecx,edx,si,edi,es
        push    cs
        pop     es
        mov     si,[@src]
@@gotos:         
        cmp     [byte ptr si+1], 0
        je      @@oklo
        inc     si
        jmp     @@gotos
@@oklo:
        mov     edi,1
        xor     ebx,ebx
@@baseto:                        
        cmp     [@src],si
        ja      @@endbaseto
        mov     al,[si]
        xor     ecx,ecx
        mov     cl,[byte ptr @base]
        inc     cl
        push    di
        mov     di,offset base
        cld
        repne   scasb
        pop     di
        jne     @@noop
        sub     cl,[byte ptr @base]
        neg     cl
        mov     eax,edi
        mul     ecx
        add     ebx,eax
        mov     eax,edi
        mov     cl,[byte ptr @base]
        mul     ecx
        mov     edi,eax
@@noop:
        dec     si
        jmp     @@baseto
@@endbaseto:
        mov     eax,ebx
        clc
        ret  
endp strtoint


;Renvoie en ds:%1 la partie de %2 caractŠres a partir de la gauche de ds:%0
PROC left FAR
        ARG     @src:word,@dest:word,@nb:word
        USES    ax,cx,si,di,es
        push    ds
        pop     es 
        mov     si,[@src] 
        mov     di,[@dest] 
        mov     cx,[@nb]
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        ret
endp left

;Renvoie en ds:%1 la partie de %2 caractŠres a partir de la droite de ds:%0
PROC right FAR
        ARG     @src:word,@dest:word,@nb:word
        USES    ax,cx,si,di,es
        push    ds
        pop     es  
        mov     si,[@src] 
        mov     di,[@dest]
        call    getlength,si
        add     si,ax
        sub     si,[@nb]
        mov     cx,[@nb]
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        ret
endp right

;Renvoie en ds:%1 la partie de %3 caractŠres a partir de la position %2 de ds:%0
PROC middle FAR
        ARG     @src:word,@dest:word,@item:word,@nb:word
        USES    ax,cx,si,di,es
        push    ds
        pop     es   
        mov     si,[@src]   
        mov     di,[@dest]
        mov     cx,[@nb]   
        add     si,[@item] 
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        ret
endp middle

;Rempli de %3 caractŠres %2 a partir de la position %1 de ds:%0
PROC fill FAR
        ARG     @src:word,@item:word,@char:word,@nb:word
        USES    ax,cx,si,di,es
        push    ds
        pop     es
        mov     di,[@src]
        add     di,[@item]
        mov     ax,[@char]
        mov     cx,[@nb]
        cld
        rep     stosb
        clc
        ret
endp fill

;Remplace tout les caractŠres %1 de ds:%0 par des caractŠres %2
PROC replaceallchar FAR
        ARG     @src:word,@char1:word,@char2:word
        USES    ax,cx,dx,di,es
        mov     di,[@src]
        call    getlength,di
        mov     cx,ax
        mov     ax,[@char1]
        mov     dx,[@char2]
        push    ds
        pop     es
@@findandchange:
        repne   scasb
        cmp     cx,0
        je      @@endofchange
        mov     [es:di-1],dl
        jmp     @@findandchange
@@endofchange:
        clc
        ret
endp replaceallchar

;Recherche un caractŠre dl dans la chaŒne ds:%0
PROC searchchar FAR
        ARG     @src:word,@char:word
        USES    cx,di,es
        mov     di,[@src]
        call    getlength,di
        mov     cx,ax
        push    ds
        pop     es
        mov     ax,[@char]
        repne   scasb
        mov     ax,di
        dec     ax
        clc
        ret
endp searchchar

;Inverse la chaine point‚e en ds:%0
PROC invert FAR
        ARG     @src:word
        USES    ax,cx,si,di
        mov     si,[@src]
        call    getlength,si
        mov     di,si
        add     di,ax
        dec     di
@@revert:
        mov     al,[si]
        xchg    al,[di]
        mov     [si],al
        inc     si
        dec     di
        cmp     si,di
        ja      @@finishinvert
        dec     di
        cmp     si,di
        ja      @@finishinvert
        inc     di
        jmp     @@revert
@@finishinvert:
        clc
        ret
endp invert

;Compares 2 chaines de caractŠres DS:%0 et DS:%1 zerof si non equal
PROC cmpstr FAR
        ARG     @src:word,@dest:word
        USES    cx,dx,si,di
        push    ds
        pop     es
        mov     si,[@src]
        mov     di,[@dest]
        call    getlength,di
        mov     cx,ax
        call    getlength,si
        cmp     cx,ax
        jne     @@notequal
        repe    cmpsb
@@notequal:
        ret
endp cmpstr

;Compares 2 chaines de caractŠres DS:%0 et DS:%1 zerof si non equal et renvoie le nb de caractŠre egaux dans ax
PROC evalue FAR
        ARG     @src:word,@dest:word
        USES    cx,si,di,es
        push    ds
        pop     es
        mov     si,[@src]
        mov     di,[@dest]
        call    getlength ,di 
        mov     cx,ax    
        repe    cmpsb
        pushf
        jne     @@noident
        sub     ax,cx
        popf
        clc
        ret
@@noident:
        sub     ax,cx
        dec     ax
        popf
        clc
        ret
endp evalue

;Insert une chaine ds:%0 en ds:%1 a partir du caractŠre %2
PROC insert FAR
        ARG     @src:word,@dest:word,@item:word
        USES    ax,cx,si,di,es
        push    es
        pop     ds   
        mov     si,[@dest]
        call    getlength,si
        mov     cx,ax
        add     si,ax
        mov     di,si
        call    getlength,[@src]
        add     di,ax
        sub     cx,[@item]
        inc     cx
        std
        rep     movsb
        mov     si,[@src]
        mov     di,[@dest]
        add     di,[@item] 
        mov     cx,ax
        cld
        rep     movsb             
        clc
        ret
endp insert 


;Detruit %2 caractŠres a partir du caractŠre %1 de DS:%0
PROC delete FAR
        ARG     @src:word,@item:word,@size:word
        USES    ax,cx,dx,si,di,es
        push    ds
        pop     es
        mov     si,[@src]
        call    getlength,si
        mov     cx,ax
        sub     cx,[@size]
        sub     cx,[@item]
        inc     cx
        add     si,[@item]
        mov     di,si
        add     si,[@size]
        cld
        rep     movsb
        clc
        ret
endp delete
        
;Copie une chaine de ds:si en es:di
PROC copy FAR
        ARG     @src:word,@dest:word
        USES    ax,cx,si,di
        mov     si,[@src]
        mov     di,[@dest]
        call    getlength,si
        mov     cx,ax
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        ret
endp copy


;ConcatŠne le chaine ds:si avec ds:di
PROC concat FAR
        ARG     @src:word,@dest:word
        USES    ax,cx,si,di,es
        push    ds
        pop     es
        mov     si,[@src]
        call    getlength,si
        mov     cx,ax
        mov     di,[@dest]
        call    getlength,di
        add     di,ax
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        ret
endp concat


;D‚truit les d‚limiteur qui sont cons‚cutifs dans ds:%0 -> renvoie le nb d'item
PROC compressdelimiter FAR
        ARG     @src:word,@delim:word
        USES    cx,dx,si,di,es
        mov     di,[@src]
        call    getlength,di
        mov     cx,ax
        push    ds
        pop     es
        mov     ax,[@delim]
        xor     dx,dx
@@compressitems:
        repne   scasb
        inc     dx
@@againcomp:
        cmp     [di],al
        jne     @@nosup
        call    delete,di,0,1
        jmp     @@againcomp
@@nosup:
        cmp     cx,0
        jne     @@compressitems
        mov     ax,dx
        clc
        ret
endp compressdelimiter

;Met le nombre d'‚l‚ments de ds:%0 à %1
PROC setnbitems FAR
        ARG     @src:word,@size:word,@delim:word
        USES    ax,cx,di,es
        mov     di,[@src]
        cmp     [@size],0
        je      @@onlyzero
        call    getnbitems,di,[@delim]
        cmp     [@size],ax
        je      @@noadjust
        jb      @@subsome
        push    ds
        pop     es
        sub     ax,[@size]
        neg     ax
        mov     cx,ax
        call    getlength,di
        add     di,ax
        mov     ax,[@delim]
        mov     ah,'a'
        rep     stosw
        xor     al,al
        stosb
        jmp     @@noadjust
@@subsome:
        call    getpointeritem,[@src],[@size],[@delim]
        dec     ax
        mov     di,ax
@@onlyzero:
        mov     [byte ptr di],0
@@noadjust:
        clc
        ret
endp setnbitems

;Renvoie la taille ax de l'‚l‚ment %0
PROC getitemsize FAR
        ARG     @src:word,@item:word,@delim:word
        USES    cx,dx
        mov     cx,[@item]
        call    getpointeritem,[@src],cx,[@delim]
        mov     dx,ax
        inc     cx
        call    getpointeritem,[@src],cx,[@delim]
        sub     ax,dx
        dec     ax
        clc
        ret
endp getitemsize

;Renvoie en ds:%1 l'‚l‚ment %2 de ds:%0
PROC getitem FAR
        ARG     @src:word,@dest:word,@item:word,@delim:word
        USES    ax,cx,si,di,es
        push    ds
        pop     es 
        call    getpointeritem,[@src],[@item],[@delim]
        mov     si,ax
        call    getitemsize,[@src],[@item],[@delim]
        mov     di,[@dest]
        mov     cx,ax    
        cld 
        rep     movsb
        mov     al,0
        stosb
        clc
        ret
endp getitem

;renvoi un pointeur ax sur l'‚l‚ment %1 de ds:%0
PROC getpointeritem FAR
        ARG     @src:word,@item:word,@delim:word
        USES    cx,dx,di,es
        mov     di,[@src]
        cmp     [@item],0
        je      @@finishpointer
        push    ds
        pop     es  
        call    getlength,di
        mov     cx,ax 
        push    ds
        pop     es
        mov     ax,[@delim]
        xor     dx,dx
@@countnbitems:
        cmp     [@item],dx
        je      @@finishpointer
        cld
        repne   scasb
        inc     dx
        cmp     cx,0
        jne     @@countnbitems
        inc     di
@@finishpointer:
        mov     ax,di
        clc
        ret 
endp getpointeritem

;Renvoie le nombre d'‚l‚ments ax de ds:%0
PROC getnbitems FAR
        ARG     @src:word,@delim:word
        USES    cx,dx,di,es
        mov     di,[@src]
        call    getlength,di
        mov     cx,ax
        push    ds
        pop     es
        mov     ax,[@delim]
        xor     dx,dx
        cld
@@countitems:
        repne   scasb
        inc     dx
        cmp     cx,0
        jne     @@countitems
        mov     ax,dx
        clc
        ret
endp getnbitems

;renvoie la taille en octets AX de la chaine point‚e en ds:%0
PROC getlength FAR
        ARG     @src:word
        USES    cx,di,es
        push    ds
        pop     es
        mov     di,[@src]
        mov     al,0
        mov     cx,0FFFFh
        cld
        repne   scasb
        neg     cx
        dec     cx
        dec     cx
        mov     ax,cx
        clc
        ret
endp getlength

;Met la taille en octets de la chaine point‚e ds:%0 a %1     
PROC setlength FAR
        ARG     @src:word,@size:word
        USES    si
        mov     si,[@src]        
        add     si,[@size] 
        mov     [byte ptr si],0
        clc
        ret  
endp setlength

;met en majuscule la chaine ds:%0
PROC uppercase FAR
        ARG     @src:word
        USES    si,ax
        mov     si,[@src]    
@@uppercase:
        mov     al,[ds:si]
        inc     si
        cmp     al,0
        je      @@enduppercase
        cmp     al,'a'
        jb      @@uppercase
        cmp     al,'z'
        ja      @@uppercase
        sub     [byte ptr si-1],'a'-'A'
        jmp     @@uppercase
@@enduppercase:
        clc
        ret
endp uppercase

;met en majuscule la premiŠre lettre chaine ds:%0
PROC onecase FAR
        ARG     @src:word
        USES    ax
        mov     si,[@src] 
        mov     al,[ds:si]
        cmp     al,'a'
        jb      @@oneenduppercase
        cmp     al,'z'
        ja      @@oneenduppercase
        sub     [byte ptr si],'a'-'A'
@@oneenduppercase:
        clc
        ret  
endp onecase

;met en minuscule la chaine ds:%0
PROC lowercase FAR
        ARG     @src:word
        USES    si,ax
        mov     si,[@src]        
@@lowercase:
        mov     al,[ds:si]
        inc     si
        cmp     al,0
        je      @@endlowercase
        cmp     al,'A'
        jb      @@lowercase
        cmp     al,'Z'
        ja      @@lowercase
        add     [byte ptr si-1],'a'-'A'
        jmp     @@lowercase
@@endlowercase:
        clc
        ret
endp lowercase

;Inverse la casse la chaine ds:%0
PROC invertcase FAR
        ARG     @src:word
        USES    si,ax
        mov     si,[@src]
@@invertcase:
        mov     al,[ds:si]
        inc     si
        cmp     al,0
        je      @@endinvertcase
        cmp     al,'A'
        jb      @@invertcase
        cmp     al,'Z'
        jbe     @@goinvertcase
        cmp     al,'a'
        jb      @@invertcase
        cmp     al,'z'
        ja      @@invertcase 
        sub     [byte ptr si-1],'a'-'A'
        jmp     @@invertcase
@@goinvertcase:
        add     [byte ptr si-1],'a'-'A'
        jmp     @@invertcase
@@endinvertcase:
        clc
        ret
endp invertcase

