use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

header exe 1,exports,0,0,0


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
proc checksyntax uses ax bx cx dx si di ds es, src:word,dest:word,delim:word
        local   temp[256]:WORD
        push    ss
        pop     es
        lea     si,[temp]
        mov     di,[dest]
        stdcall    copy,[src],si
        call    xch 
        stdcall    compressdelimiter,si,[delim]
        stdcall    getnbitems,si,[delim]
        mov     bx,ax
        call    xch 
        stdcall    getnbitems,di,[delim]
        cmp     bx,ax
        jne     .notequalatall
        xor     cx,cx
.itemer:
        call    xch 
        stdcall    whatisitem,si,cx,[delim]
        mov     dx,ax
        stdcall    xch 
        stdcall    whatisitem,di,cx,[delim]
        cmp     ax,dx
        jne     .prob
        cmp     al,6
        jb      .equal
        stdcall    cmpitems
        je      .equal
.prob:
        cmp     dl,4
        ja      .nonumber
        cmp     dl,8
        je      .equal
        ;cmp     al,4
        ;jne     .notequalatall
        cmp     dh,ah
        ja      .notequalatall
        jmp     .equal
.nonumber:
        cmp     al,7
        jne     .nostr
        cmp     ah,0
        jne     .notequalatall
        jmp     .equal
.nostr:
        cmp     al,6
        jne     .noname
        cmp     dl,6
        jne     .noname
        cmp     ah,0
        jne     .notequalatall
        jmp     .equal
.noname:
        cmp     al,8
        je      .equal
        jmp     .notequalatall
.equal:
        inc     cx
        cmp     cx,bx
        jne     .itemer
        cld
.ackno: 
        retf
.notequalatall:
        stc
        jmp     .ackno
xch:
        push    es
        push    ds
        pop     es
        pop     ds
        ret
endp


;Compare les ‚l‚ments cx de deux chaine ds:si et es:di
proc cmpitems uses ax cx si di es, src:word,dest:word,item:word,delim:word
        push    ds
        pop     es 
        stdcall    getpointeritem,[src],[item],[delim]
        mov     si,ax
        stdcall    getitemsize,[src],[item],[delim]
        mov     di,[dest]
        mov     cx,ax    
        cld 
        rep     cmpsb
        clc
        retf
endp

                                
;Renvoie l'‚l‚ment cx de ds:si dans edx si nb et dans es:di si str ou name
proc gettypeditem uses bx cx si di, src:word,item:word,delim:word
        mov     si,[src]
        mov     cx,[item]
        stdcall    getpointeritem,si,cx,[delim]
        mov     di,ax
        inc     cx
        stdcall    getpointeritem,si,cx,[delim]
        mov     si,ax
        dec     si
        mov     cl,0
        xchg    cl,[ds:si]
        stdcall    gettyped,di
        xchg    cl,[ds:si]
        clc
        retf
endp 


;Renvoie eax si nb et dans ds:eax si str ou name
proc gettyped uses si, src:word
        mov     si,[src]
        xor     eax,eax
        stdcall    whatis,si
        cmp     al,1
        je      .bin
        cmp     al,2
        je      .oct
        cmp     al,3
        je      .dec
        cmp     al,4
        je      .hex
        cmp     al,5
        je      .pointer
        mov     ax,si
        jmp     .endofgettypeditem
.bin:
        stdcall    strtoint,si,2
        jmp     .endofgettypeditem
.oct:
        stdcall    strtoint,si,8
        jmp     .endofgettypeditem
.dec:
        stdcall    strtoint,si,10
        jmp     .endofgettypeditem
.hex:
        stdcall    strtoint,si,16
        jmp     .endofgettypeditem
.pointer:
        stdcall    strtoadress,si
.endofgettypeditem:
        clc
        retf   
endp

;Renvoie dans ax le type de la str0 point‚e par ds:%0 ‚l‚ment %1 delim %3
proc whatisitem uses bx cx si di, src:word,item:word,delim:word
        mov     si,[src]
        mov     cx,[item]
        stdcall    getpointeritem,si,cx,[delim]
        mov     di,ax
        inc     cx
        stdcall    getpointeritem,si,cx,[delim]
        mov     si,ax
        dec     si
        mov     cl,0
        xchg    cl,[ds:si]
        stdcall    whatis,di
        xchg    cl,[ds:si]
        clc
        retf
endp 

;Renvoie dans ax le type de la str0 point‚e par ds:%0
;High          Low
;0 variable    4 hex
;1 byte        3 dec
;2 word        2 oct
;3 3 octets    1 bin
;4 dword       5 adresse
;5 5 octets    6 name
;6 ...         7 str
proc whatis uses bx cx edx si, src:word
        mov     si,[src]
        xor     cx,cx
        mov     cl,2 
        stdcall    strisbase,si,cx
        jnc     .finbase
        mov     cl,8
        stdcall    strisbase,si,cx
        jnc     .finbase
        mov     cl,10
        stdcall    strisbase,si,cx
        jnc     .finbase
        mov     cl,16
        stdcall    strisbase,si,cx
        jc      .testadress
.finbase:
        mov     bx,cx
        xor     ch,ch
        mov     al,[cs:bx+ basenn-2]
        push    eax
        stdcall    strtoint,si,cx
        mov     edx,eax
        pop     eax 
        cmp     edx,0000FFFFh
        ja      .bits32
        cmp     dx,00FFh
        ja      .bits16
        mov     ah,1
        jmp     .endofwhat
.bits16:
        mov     ah,2
        jmp     .endofwhat
.bits32:
        mov     ah,4
        jmp     .endofwhat
.testadress:
        stdcall    strisadress,si
        jc      .testname
        mov     ax,0005h
        jmp     .endofwhat
.testname:
        stdcall    strisname
        jc      .testnumber
        xor     ah,ah
        cmp     byte [si],'&'
        je      .okname
        stdcall    getlength,si
        mov     ah,al
.okname:
	    mov     al,06h
	    jmp     .endofwhat
.testnumber:
        cmp     byte [si],'#'
        jne     .testvarstr
        xor     ah,ah
	    mov     al,08h
        jmp     .endofwhat
.testvarstr:    
        xor     ah,ah   
        cmp     byte [si],'?'
        je      .okvarstr
        stdcall    getlength,si
        mov     ah,al
.okvarstr:
	    mov     al,07h
.endofwhat:
        clc
        retf
endp 



;Renvoie non carry si la str ds:si point‚e peut ˆtre une adresse
proc strtoadress 
        ;push
        stc
        ;pop
        retf
endp 
        

;Renvoie en es:di le pointeur str0 ds:si
proc strisadress
        ;push
        stc
        ;pop
        retf
endp 

;Renvoie non carry si la str ds:%0 point‚e peut ˆtre un nom de fichier
proc strisname uses ax si di, src:word
        mov     si,[src] 
.isname:
        mov     al,[si]
        inc     si
        cmp     al,0
        je      .itsok
        mov     di, non
.verify:
        mov     ah,[cs:di]
        inc     di
        cmp     ah,0FFh
        je      .isname
        cmp     ah,al
        jne     .verify
        stc
        jmp     .itsdead
.itsok:
        clc
.itsdead:        
        retf
endp 

non db '/<>|"?*:\',01,0FFh
base   db '0123456789ABCDEF'
basen  db 'b     o d     h'            
basenn db 1,0,0,0,0,0,2,0,3,0,0,0,0,0,4

;Renvoie non carry si le texte point‚ par %0 est de la base %1
proc strisbase uses ax cx si di es, src:word,base:word
        push    cs
        pop     es
        mov     si,[src] 
.isstrbase:
        mov     al,[si]         
        cmp     al,0
        je      .okbase
        mov     cx,[base] 
        xor     ch,ch
        mov     di,cx
        cmp     al,[es:di-2+ basen]
        je      .verifbase
        xor     ch,ch
        inc     cl
        lea     di,[base]
        cld
        repne   scasb
        cmp     cx,0
        je      .nobase
        inc     si
        jmp     .isstrbase
.okbase:
        clc
.endbase:
        retf
.verifbase:
        cmp     byte [si+1],0
        je      .okbase  
.nobase:
        stc
        jmp     .endbase  
endp 


;Converti un str %0 de base %1 en int dans eax
proc strtoint uses ebx ecx edx si edi es, src:word,base:word
        push    cs
        pop     es
        mov     si,[src]
.gotos:         
        cmp     byte [si+1], 0
        je      .oklo
        inc     si
        jmp     .gotos
.oklo:
        mov     edi,1
        xor     ebx,ebx
.baseto:                        
        cmp     [src],si
        ja      .endbaseto
        mov     al,[si]
        xor     ecx,ecx
        mov     cl,byte [base]
        inc     cl
        push    di
        lea     di, [base]
        cld
        repne   scasb
        pop     di
        jne     .noop
        sub     cl,byte [base]
        neg     cl
        mov     eax,edi
        mul     ecx
        add     ebx,eax
        mov     eax,edi
        mov     cl,byte [base]
        mul     ecx
        mov     edi,eax
.noop:
        dec     si
        jmp     .baseto
.endbaseto:
        mov     eax,ebx
        clc
        retf  
endp 


;Renvoie en ds:%1 la partie de %2 caractŠres a partir de la gauche de ds:%0
proc left uses ax cx si di es, src:word,dest:word,nb:word
        push    ds
        pop     es 
        mov     si,[src] 
        mov     di,[dest] 
        mov     cx,[nb]
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        retf
endp 

;Renvoie en ds:%1 la partie de %2 caractŠres a partir de la droite de ds:%0
proc right uses ax cx si di es, src:word,dest:word,nb:word
        push    ds
        pop     es  
        mov     si,[src] 
        mov     di,[dest]
        stdcall    getlength,si
        add     si,ax
        sub     si,[nb]
        mov     cx,[nb]
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        retf
endp 

;Renvoie en ds:%1 la partie de %3 caractŠres a partir de la position %2 de ds:%0
proc middle uses ax cx si di es, src:word,dest:word,item:word,nb:word
        push    ds
        pop     es   
        mov     si,[src]   
        mov     di,[dest]
        mov     cx,[nb]   
        add     si,[item] 
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        retf
endp 

;Rempli de %3 caractŠres %2 a partir de la position %1 de ds:%0
proc fill uses ax cx si di es, src:word,item:word,char:word,nb:word
        push    ds
        pop     es
        mov     di,[src]
        add     di,[item]
        mov     ax,[char]
        mov     cx,[nb]
        cld
        rep     stosb
        clc
        retf
endp 

;Remplace tout les caractŠres %1 de ds:%0 par des caractŠres %2
proc replaceallchar uses ax cx dx di es, src:word,char1:word,char2:word
        mov     di,[src]
        stdcall    getlength,di
        mov     cx,ax
        mov     ax,[char1]
        mov     dx,[char2]
        push    ds
        pop     es
.findandchange:
        repne   scasb
        cmp     cx,0
        je      .endofchange
        mov     [es:di-1],dl
        jmp     .findandchange
.endofchange:
        clc
        retf
endp 

;Recherche un caractŠre dl dans la chaŒne ds:%0
proc searchchar uses cx di es, src:word,char:word
        mov     di,[src]
        stdcall    getlength,di
        mov     cx,ax
        push    ds
        pop     es
        mov     ax,[char]
        repne   scasb
        mov     ax,di
        dec     ax
        clc
        retf
endp 

;Inverse la chaine point‚e en ds:%0
proc invert uses ax cx si di, src:word
        mov     si,[src]
        stdcall    getlength,si
        mov     di,si
        add     di,ax
        dec     di
.revert:
        mov     al,[si]
        xchg    al,[di]
        mov     [si],al
        inc     si
        dec     di
        cmp     si,di
        ja      .finishinvert
        dec     di
        cmp     si,di
        ja      .finishinvert
        inc     di
        jmp     .revert
.finishinvert:
        clc
        retf
endp 

;Compares 2 chaines de caractŠres DS:%0 et DS:%1 zerof si non equal
proc cmpstr uses cx dx si di, src:word,dest:word
        push    ds
        pop     es
        mov     si,[src]
        mov     di,[dest]
        stdcall    getlength,di
        mov     cx,ax
        stdcall    getlength,si
        cmp     cx,ax
        jne     .notequal
        repe    cmpsb
.notequal:
        retf
endp 

;Compares 2 chaines de caractŠres DS:%0 et DS:%1 zerof si non equal et renvoie le nb de caractŠre egaux dans ax
proc evalue uses cx si di es, src:word,dest:word
        push    ds
        pop     es
        mov     si,[src]
        mov     di,[dest]
        stdcall    getlength ,di 
        mov     cx,ax    
        repe    cmpsb
        pushf
        jne     .noident
        sub     ax,cx
        popf
        clc
        retf
.noident:
        sub     ax,cx
        dec     ax
        popf
        clc
        retf
endp 

;Insert une chaine ds:%0 en ds:%1 a partir du caractŠre %2
proc insert uses ax cx si di es, src:word,dest:word,item:word
        push    es
        pop     ds   
        mov     si,[dest]
        stdcall    getlength,si
        mov     cx,ax
        add     si,ax
        mov     di,si
        stdcall    getlength,[src]
        add     di,ax
        sub     cx,[item]
        inc     cx
        std
        rep     movsb
        mov     si,[src]
        mov     di,[dest]
        add     di,[item] 
        mov     cx,ax
        cld
        rep     movsb             
        clc
        retf
endp 


;Detruit %2 caractŠres a partir du caractŠre %1 de DS:%0
proc delete uses ax cx dx si di es, src:word,item:word,size:word
        push    ds
        pop     es
        mov     si,[src]
        stdcall    getlength,si
        mov     cx,ax
        sub     cx,[size]
        sub     cx,[item]
        inc     cx
        add     si,[item]
        mov     di,si
        add     si,[size]
        cld
        rep     movsb
        clc
        retf
endp 
        
;Copie une chaine de ds:si en es:di
proc copy uses ax cx si di, src:word,dest:word
        mov     si,[src]
        mov     di,[dest]
        stdcall    getlength,si
        mov     cx,ax
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        retf
endp 


;ConcatŠne le chaine ds:si avec ds:di
proc concat uses ax cx si di es, src:word,dest:word
        push    ds
        pop     es
        mov     si,[src]
        stdcall    getlength,si
        mov     cx,ax
        mov     di,[dest]
        stdcall    getlength,di
        add     di,ax
        cld
        rep     movsb
        mov     al,0
        stosb
        clc
        retf
endp 


;D‚truit les d‚limiteur qui sont cons‚cutifs dans ds:%0 -> renvoie le nb d'item
proc compressdelimiter uses cx dx si di es, src:word,delim:word
        mov     di,[src]
        stdcall    getlength,di
        mov     cx,ax
        push    ds
        pop     es
        mov     ax,[delim]
        xor     dx,dx
.compressitems:
        repne   scasb
        inc     dx
.againcomp:
        cmp     [di],al
        jne     .nosup
        stdcall    delete,di,0,1
        jmp     .againcomp
.nosup:
        cmp     cx,0
        jne     .compressitems
        mov     ax,dx
        clc
        retf
endp 

;Met le nombre d'‚l‚ments de ds:%0 à %1
proc setnbitems uses ax cx di es, src:word,size:word,delim:word
        mov     di,[src]
        cmp     [size],0
        je      .onlyzero
        stdcall    getnbitems,di,[delim]
        cmp     [size],ax
        je      .noadjust
        jb      .subsome
        push    ds
        pop     es
        sub     ax,[size]
        neg     ax
        mov     cx,ax
        stdcall    getlength,di
        add     di,ax
        mov     ax,[delim]
        mov     ah,'a'
        rep     stosw
        xor     al,al
        stosb
        jmp     .noadjust
.subsome:
        stdcall    getpointeritem,[src],[size],[delim]
        dec     ax
        mov     di,ax
.onlyzero:
        mov     byte [di],0
.noadjust:
        clc
        retf
endp 

;Renvoie la taille ax de l'‚l‚ment %0
proc getitemsize uses cx dx, src:word,item:word,delim:word
        mov     cx,[item]
        stdcall    getpointeritem,[src],cx,[delim]
        mov     dx,ax
        inc     cx
        stdcall    getpointeritem,[src],cx,[delim]
        sub     ax,dx
        dec     ax
        clc
        retf
endp 

;Renvoie en ds:%1 l'‚l‚ment %2 de ds:%0
proc getitem uses ax cx si di es, src:word,dest:word,item:word,delim:word
        push    ds
        pop     es 
        stdcall    getpointeritem,[src],[item],[delim]
        mov     si,ax
        stdcall    getitemsize,[src],[item],[delim]
        mov     di,[dest]
        mov     cx,ax    
        cld 
        rep     movsb
        mov     al,0
        stosb
        clc
        retf
endp 

;renvoi un pointeur ax sur l'‚l‚ment %1 de ds:%0
proc getpointeritem uses cx dx di es, src:word,item:word,delim:word
        mov     di,[src]
        cmp     [item],0
        je      .finishpointer
        push    ds
        pop     es  
        stdcall    getlength,di
        mov     cx,ax 
        push    ds
        pop     es
        mov     ax,[delim]
        xor     dx,dx
.countnbitems:
        cmp     [item],dx
        je      .finishpointer
        cld
        repne   scasb
        inc     dx
        cmp     cx,0
        jne     .countnbitems
        inc     di
.finishpointer:
        mov     ax,di
        clc
        retf 
endp 

;Renvoie le nombre d'‚l‚ments ax de ds:%0
proc getnbitems uses cx dx di es, src:word,delim:word
        mov     di,[src]
        stdcall    getlength,di
        mov     cx,ax
        push    ds
        pop     es
        mov     ax,[delim]
        xor     dx,dx
        cld
.countitems:
        repne   scasb
        inc     dx
        cmp     cx,0
        jne     .countitems
        mov     ax,dx
        clc
        retf
endp 

;renvoie la taille en octets AX de la chaine point‚e en ds:%0
proc getlength uses cx di es, src:word
        push    ds
        pop     es
        mov     di,[src]
        mov     al,0
        mov     cx,0FFFFh
        cld
        repne   scasb
        neg     cx
        dec     cx
        dec     cx
        mov     ax,cx
        clc
        retf
endp 

;Met la taille en octets de la chaine point‚e ds:%0 a %1     
proc setlength uses si, src:word,size:word
        mov     si,[src]        
        add     si,[size] 
        mov     byte [si],0
        clc
        retf  
endp 

;met en majuscule la chaine ds:%0
proc uppercase uses ax si, src:word
        mov     si,[src]    
.uppercase:
        mov     al,[ds:si]
        inc     si
        cmp     al,0
        je      .enduppercase
        cmp     al,'a'
        jb      .uppercase
        cmp     al,'z'
        ja      .uppercase
        sub     byte [si-1],'a'-'A'
        jmp     .uppercase
.enduppercase:
        clc
        retf
endp 

;met en majuscule la premiŠre lettre chaine ds:%0
proc onecase uses ax si, src:word
        mov     si,[src] 
        mov     al,[ds:si]
        cmp     al,'a'
        jb      .oneenduppercase
        cmp     al,'z'
        ja      .oneenduppercase
        sub     byte [si],'a'-'A'
.oneenduppercase:
        clc
        retf  
endp 

;met en minuscule la chaine ds:%0
proc lowercase uses ax si, src:word
        mov     si,[src]        
.lowercase:
        mov     al,[ds:si]
        inc     si
        cmp     al,0
        je      .endlowercase
        cmp     al,'A'
        jb      .lowercase
        cmp     al,'Z'
        ja      .lowercase
        add     byte [si-1],'a'-'A'
        jmp     .lowercase
.endlowercase:
        clc
        retf
endp 

;Inverse la casse la chaine ds:%0
proc invertcase uses ax si, src:word
        mov     si,[src]
.invertcase:
        mov     al,[ds:si]
        inc     si
        cmp     al,0
        je      .endinvertcase
        cmp     al,'A'
        jb      .invertcase
        cmp     al,'Z'
        jbe     .goinvertcase
        cmp     al,'a'
        jb      .invertcase
        cmp     al,'z'
        ja      .invertcase 
        sub     byte [si-1],'a'-'A'
        jmp     .invertcase
.goinvertcase:
        add     byte [si-1],'a'-'A'
        jmp     .invertcase
.endinvertcase:
        clc
        retf
endp 

