;Librairie qui prend en charge le format de STR ASCIIZ
;# nombre   9
;@ str      8
;& file     7

;Renvoie carry si la syntaxe de ds:si n'est pas respect‚ par rapport a es:di
CheckSyntax0:
        push    ax bx dx bp si di ds es
        push    es di
        push    cs
        pop     es
        mov     di,offset temp2
        call    copy0
        mov     si,di
        push    cs
        pop     ds
        pop     di es
        call    getdelimiter0
        mov     bp,dx
        mov     dl,' '
        call    setdelimiter0
        call    compressdelimiter0
        call    uppercase0
        call    getnbitems0
        ;call    xch 
        ;mov     ax,cx
        ;call    getnbitem0
        ;call    xch
        ;cmp     ax,cx
        ;call    xch
        ;jne     notequalatall
        mov     bx,cx
        xor     cx,cx
itemer:
        call    whatisitem0
        mov     dx,ax
        call    xch
        call    whatisitem0
        call    xch
        cmp     ax,dx
        jne     prob
        cmp     al,6
        jb      equal
        call    cmpitems0
        je      equal
prob:
        cmp     dl,4
        ja      nosize
        cmp     al,8
        je      equal
        cmp     al,4
        jne     notequalatall
        cmp     dh,ah
        ja      notequalatall
        jmp     equal
nosize:
        cmp     al,7
        jne     noname
        cmp     ah,0
        jne     notequalatall
        jmp     equal
noname:
        cmp     al,8
        je      equal
        jmp     notequalatall
equal:
        inc     cx
        cmp     cx,bx
        jne     itemer
        cld
ackno:
        mov     dx,bp
        call    setdelimiter0
        pop     es ds di si bp dx bx ax
        ret
notequalatall:
        stc
        jmp     ackno
xch:
        push    ds
        push    es
        pop     ds
        pop     es
        xchg    si,di
        ret

temp2 db 256 dup (0)

;Compare les ‚l‚ments cx de deux chaine ds:si et es:di
Cmpitems0:
        push    cx dx si di
        push    cx di
        call    getpointeritem0
        mov     si,di
        xor     cx,cx
        inc     cx
        call    getpointeritem0
        mov     dx,di 
        sub     dx,si
        dec     cx
        pop     di cx
        push    ds si
        push    es
        pop     ds
        mov     si,di
        call    getpointeritem0
        pop     si ds
        mov     cx,dx
        rep     cmpsb
        pop     di si dx cx
        ret


                                
;Renvoie l'‚l‚ment cx de ds:si dans edx si nb et dans es:di si str ou name
gettypeditem0:
        push    bx cx si
        call    getpointeritem0
        mov     si,di 
        xor     cx,cx
        inc     cl
        call    getpointeritem0
        mov     bx,di
        dec     bx
        mov     cl,0
        xchg    cl,ds:[bx]
        call    gettyped0
        xchg    cl,ds:[bx]
        pop     si cx bx
        ret

;Renvoie ds:si dans edx si nb et dans es:di si str ou name
gettyped0:
        push    ax
        call    whatis0
        cmp     al,5
        jb      number
        cmp     al,6
        je      pointer
        push    ds
        pop     es
        call    getpointeritem0
        jmp     endofGettypeditem0
number:
        mov     edx,cs:lastnumber              
        jmp     endofgettypeditem0
pointer:
        call    str0toadress
endofgettypeditem0:
        pop      ax
        ret     

;Renvoie dans ax le type de la str0 point‚e par ds:si ‚l‚ment cx
whatisitem0:
        push    bx cx si di
        call    getpointeritem0
        mov     si,di 
        xor     cx,cx
        inc     cl
        call    getpointeritem0
        mov     bx,di
        dec     bx
        mov     cl,0
        xchg    cl,ds:[bx]
        call    whatis0
        xchg    cl,ds:[bx]
        pop     di si cx bx
        ret

;Renvoie dans ax le type de la str0 point‚e par ds:si
;High          Low
;0 variable    4 hex
;1 byte        3 dec
;2 word        2 oct
;3 3 octets    1 bin
;4 dword       5 adresse
;5 5 octets    6 name
;6 ...         7 str
whatis0:
        push    bx cx edx
        mov     cl,2
        call    str0isbase
        jnc      finbase
        mov     cl,8
        call    str0isbase
        jnc      finbase
        mov     cl,10
        call    str0isbase
        jnc      finbase
        mov     cl,16
        call    str0isbase
        jc     testadress
finbase:
        mov     bx,cx
        xor     ch,ch
        mov     al,cs:[bx+offset basenn-2]
        call    str0toint
        mov     cs:Lastnumber,edx
        cmp     edx,0000FFFFh
        ja      bits32
        cmp     dx,00FFh
        ja      bits16
        mov     ah,1
        jmp     endofwhat
bits16:
        mov     ah,2
        jmp     endofwhat
bits32:
        mov     ah,3
        jmp     endofwhat
testadress:
        call    str0isadress
        jc      testname
        mov     ax,0005h
        jmp     endofwhat
testname:
        call    str0isname
        jc      testvarstr
        mov     al,07h
        call    getlength0
        cmp     byte ptr [si],'&'
        jne     real
        mov     cl,0
real:
        mov     ah,cl
        jmp     endofwhat
testvarstr:       
        cmp     byte ptr [si],'@'
        jne     testnumber
        mov     al,08h
        call    getlength0
        mov     ah,cl
        jmp     endofwhat 
testnumber:
        cmp     byte ptr [si],'#'
        jne     isstr
        call    getlength0
        cmp     cl,1
        ja      isstr
        mov     ax,0009h
        jmp     endofwhat
isstr:
        mov     al,06h
        call    getlength0
        dec     cl
        mov     ah,cl
endofwhat:
        pop     edx cx bx 
        ret

Lastnumber dd 0

;Renvoie non carry si la str ds:si point‚e peut ˆtre une adresse
str0isadress:
        ;push
        stc
        ;pop
        ret

;Renvoie en es:di le pointeur str0 ds:si
Str0toAdress:
        ;push
        stc
        ;pop
        ret

;Renvoie non carry si la str ds:si point‚e peut ˆtre un nom de fichier
str0isname:
        push    ax si di
isname:
        mov     al,[si]
        inc     si
        cmp     al,0
        je      itsok
        mov     di,offset non
verify:
        mov     ah,[di]
        inc     di
        cmp     ah,0FFh
        je      isname
        cmp     ah,al
        jne     verify
        stc
        jmp     itsdead
itsok:
        clc
itsdead:        
        pop    di si ax
        ret

non db '/<>|@#',01,0FFh

;Renvoie non carry si le texte point‚ par si est de la base cl
str0isbase:
        push    ax cx si di es
        push    cs
        pop     es
        mov     ah,cl
isstrbase:
        mov     al,[si]         
        cmp     al,0
        je      okbase
        mov     cl,ah 
        xor     ch,ch
        mov     di,cx
        cmp     al,es:[di-2+offset basen]
        je      verifbase
        xor     ch,ch
        inc     cl
        mov     di,offset base
        cld
        repne   scasb
        cmp     cx,0
        je      nobase
        inc     si
        jmp     isstrbase
okbase:
        clc
endbase:
        pop     es di si cx ax
        ret
verifbase:
        cmp     byte ptr [si+1],0
        je      okbase  
nobase:
        stc
        jmp     endbase  

temp dw 0

;Converti un str de base cl en int dans edx
str0toint:
        push    eax bx ecx si edi ebp es
        push    cs
        pop     es
        mov     ah,cl
        mov     cs:temp,si 
gotos:         
        cmp     byte ptr [si+1], 0
        je      oklo
        inc     si
        jmp     gotos
oklo:
        mov     edi,1
        xor     ebp,ebp
        mov     bl,cl
baseto:                        
        cmp     si,cs:temp
        jb      endbaseto
        mov     al,[si]
        xor     ecx,ecx
        mov     cl,bl
        inc     cl
        push    di
        mov     di,offset base
        cld
        repne   scasb
        pop     di
        jne     noop
        sub     cl,bl
        neg     cl
        mov     eax,edi
        mul     ecx
        add     ebp,eax
        mov     eax,edi
        mov     cl,bl
        mul     ecx
        mov     edi,eax
noop:
        dec     si
        jmp     baseto
endbaseto:
        mov     edx,ebp
        pop     es ebp edi si ecx bx eax
ret  
base   db '0123456789ABCDEF'
basen  db 'B     O D     H'            
basenn db 1,0,0,0,0,0,2,0,3,0,0,0,0,0,4

;Renvoie en es:di la partie de cx caractŠres a partir de la gauche de ds:si
Left0:
        push    ax cx si di
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si cx ax
        ret

;Renvoie en es:di la partie de cx caractŠres a partir de la droite de ds:si
Right0:
        push    ax cx dx si di
        mov     dx,cx
        call    getlength0
        add     si,cx
        sub     si,dx
        mov     cx,dx
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si dx cx ax
        ret

;Renvoie en es:di la partie de cx caractŠres a partir de la position bx de ds:si
middle0:
        push    ax cx si di
        add     si,bx
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si cx ax
        ret

;Rempli de cx caractŠres dl a partir de la position bx de ds:si
Fill0:
        push    ax bx cx si di es
        push    ds
        pop     es
        add     si,bx
        mov     al,dl
        mov     di,si
        cld
        rep     stosb
        pop     es di si cx bx ax
        ret

;Remplace tout les caractŠres al de ds:si par des caractŠres dl
ReplaceAllchar0:
        push    ax cx di es
        call    GetLength0
        push    ds
        pop     es
        mov     di,si
findandchange:
        repne   scasb
        cmp     cx,0
        je      endofchange
        mov     es:[di-1],dl
        jmp     findandchange
endofchange:
        pop     es di cx ax
        ret


;Recherche un caractŠre dl dans la chaŒne ds:si
SearchChar0:
        push    ax cx di es
        call    GetLength0
        push    ds
        pop     es
        mov     di,si
        mov     al,dl
        repne   scasb
        pop     es di cx ax
        ret

;Inverse la chaine point‚e en ds:si
invert0:
        push    ax cx si di es
        call    GetLength0
        push    ds
        pop     es
        mov     di,si
        add     di,cx
        dec     di
revert:
        mov     al,[si]
        xchg    al,es:[di]
        mov     [si],al
        inc     si
        dec     di
        cmp     si,di
        je      finishinvert
        dec     di
        cmp     si,di
        je      finishinvert
        inc     di
        jmp     revert
finishinvert:
        pop     es di si cx ax
        ret

;Compares 2 chaines de caractŠres DS:SI et ES:DI zerof si non equal
cmpstr0:
        push    cx dx si di
        call    GetLength0
        mov     dx,cx
        push    ds si
        push    es
        pop     ds
        mov     si,di
        call    GetLength0       
        pop     si ds
        cmp     cx,dx
        jne     NotEqual
        repe    cmpsb
NotEqual:
        pop     di si dx cx
        ret

;Compares 2 chaines de caractŠres DS:SI et ES:DI zerof si non equal et renvoie le nb de caractŠre egaux dans dx
evalue0:
        push    cx si di
        push    ds si
        push    es
        pop     ds
        mov     si,di
        call    GetLength0       
        pop     si ds
        mov     dx,cx
        repe    cmpsb
        pushf
        sub     dx,cx
        popf
        pop     di si cx
        ret


;Insert une chaine ds:si en es:di a partir du caractŠre cx
insert0:
        push    cx di si
        add     di,cx
        call    getlength0
        push    si di ds
        push    es
        pop     ds
        mov     si,di
        add     di,cx
        call    copy20
        pop     ds di si
        cld
        inc     di
        rep     movsb
        pop     si di cx
        ret

;Detruit CX caractŠres a partir du caractŠre BX de DS:SI
delete0:
        push    cx dx si di es
        push    ds
        pop     es
        mov     dx,cx
        call    getlength0
        sub     cx,dx
        sub     cx,bx
        inc     cx
        add     si,bx
        mov     di,si
        add     si,dx
        cld
        rep     movsb
        pop     es di si dx cx
        ret
        
;Copie une chaine de ds:si en es:di
Copy0:
        push    ax cx si di
        call    GetLength0
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si cx ax
        ret

;Copie une chaine de ds:si en es:di
Copy20:
        push    ax cx si di
        call    GetLength0
        cld
        add     si,cx
        add     di,cx
        inc     cx
        std
        rep     movsb
        pop     di si cx ax
        ret

;ConcatŠne le chaine ds:si avec es:di
Concat0:
        push    ax cx dx si di
        call    GetLength0
        mov     dx,cx
        xchg    si,di
        push    ds
        push    es
        pop     ds
        call    GetLength0
        pop     ds
        xchg    si,di
        add     di,cx
        mov     cx,dx
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si dx cx ax
        ret

;Met DL comme d‚limiteur par d‚faut 
SetDelimiter0:
        mov     cs:delim,dl
        ret

;Renvoie le d‚limiteur par d‚faut dans dl
GetDelimiter0:
        mov     dl,cs:delim
        ret
delim db 0

;D‚truit les d‚limiteur qui sont cons‚cutifs dans ds:si
CompressDelimiter0:
        push    ax dx si di es
        call    Getlength0
        push    ds
        pop     es
        mov     di,si
        mov     al,cs:delim
        xor     dx,dx
Compressitems:
        repne   scasb
        inc     dx
againcomp:
        cmp     [di],al
        jne     nosup
        mov     si,di
        mov     bx,0
        push    cx
        mov     cx,1
        call    delete0
        pop     cx
        jmp     againcomp
nosup:
        cmp     cx,0
        jne     compressitems
        mov     cx,dx
        pop     es di si dx ax
        ret

;Met le nombre d'‚l‚ments … cx
Setnbitems0:
        push    ax cx dx di es
        mov     dx,cx
        call    Getnbitems0
        cmp     cx,dx
        je      noadjust
        ja      subsome
        push    ds
        pop     es
        mov     di,si
        sub     cx,dx
        neg     cx
        push    cx
        call    getlength0
        add     di,cx
        pop     cx
        mov     al,cs:delim
        mov     ah,'a'
        rep     stosw
        mov     al,0
        stosb
        jmp     noadjust
subsome:
        mov     cx,dx
        call    GetPointeritem0
        dec     di
        mov     byte ptr [di],0
noadjust:
        pop     es di dx cx 
        ret

;Renvoie la taille dx de l'‚l‚ment cx
Getitemsize:
        push    cx di
        call    getpointeritem0
        mov     dx,di
        inc     cx
        call    getpointeritem0
        sub     dx,di
        neg     dx 
        dec     dx
        pop     di cx
        ret

;Renvoie en es:di l'‚l‚ment cx de ds:si
Getitem0:
        push    si di cx ax
        push    di
        call    getPointeritem0
        call    getitemsize    
        mov     si,di
        pop     di
        mov     cx,dx    
        rep     movsb
        mov     al,0
        stosb
        pop     ax cx di si
        ret

;renvoi un pointeur di sur l'‚l‚ment cx de ds:si
GetPointeritem0:
        push    ax bx cx dx es
        mov     bx,cx
        call    Getlength0
        push    ds
        pop     es
        mov     di,si
        mov     al,cs:delim
        xor     dx,dx
Countnbitems:
        cmp     bx,dx
        je      finishpointer
        repne   scasb
        inc     dx
        cmp     cx,0
        jne     countnbitems
        inc     di
finishpointer:
        pop     es dx cx bx ax
        ret 

;Renvoie le nombre d'‚l‚ments cx de ds:si
GetNbitems0:
        push    ax dx di es
        call    Getlength0
        push    ds
        pop     es
        mov     di,si
        mov     al,cs:delim
        xor     dx,dx
Countitems:
        repne   scasb
        inc     dx
        cmp     cx,0
        jne     countitems
        mov     cx,dx
        pop     es di dx ax
        ret

;renvoie la taille en octets CX de la chaine point‚e en ds:si
GetLength0:
        push    ax di es
        push    ds
        pop     es
        mov     di,si
        mov     al,0
        mov     cx,0FFFFh
        cld
        repne   scasb
        neg     cx
        dec     cx
        dec     cx
        pop     es di ax
        ret

;Met la taille en octets de la chaine point‚e ds:si a CX 
SetLength0:                                   
        push    bx
        mov     bx,cx
        mov     byte ptr [si+bx],0
        pop     bx
        ret  

;met en majuscule la chaine ds:si
UpperCase0: 
        push    si ax
UpperCase:
        mov     al,ds:[si]
        inc     si
        cmp     al,0
        je      EndUpperCase
        cmp     al,'a'
        jb      UpperCase
        cmp     al,'z'
        ja      UpperCase
        sub     byte ptr [si-1],'a'-'A'
        jmp     UpperCase
EndUpperCase:
        clc
        pop ax si
        ret

;met en majuscule la premiŠre lettre chaine ds:si
OneCase0:
        push    ax
OneUpperCase:
        mov     al,ds:[si]
        cmp     al,'a'
        jb      OneEndUpperCase
        cmp     al,'z'
        ja      OneEndUpperCase
        sub     byte ptr [si],'a'-'A'
OneEndUpperCase:
        clc
        pop ax 
        ret  

;met en minuscule la chaine ds:si
LowerCase0: 
        push    si ax
LowerCase:
        mov     al,ds:[si]
        inc     si
        cmp     al,0
        je      EndLowerCase
        cmp     al,'A'
        jb      LowerCase
        cmp     al,'Z'
        ja      LowerCase
        add     byte ptr [si-1],'a'-'A'
        jmp     LowerCase
EndLowerCase:
        clc
        pop ax si
        ret

;Inverse la casse la chaine ds:si
InvertCase0:
        push    si ax
InvertCase:
        mov     al,ds:[si]
        inc     si
        cmp     al,0
        je      EndInvertCase
        cmp     al,'A'
        jb      InvertCase
        cmp     al,'Z'
        jbe     GoInvertCase
        cmp     al,'a'
        jb      InvertCase
        cmp     al,'z'
        ja      InvertCase 
        sub     byte ptr [si-1],'a'-'A'
        jmp     InvertCase
GoInvertCase:
        add     byte ptr [si-1],'a'-'A'
        jmp     InvertCase
EndInvertCase:
        clc
        pop ax si
        ret

                    
