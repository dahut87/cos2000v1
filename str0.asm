;Librairie qui prend en charge le format de STR ASCIIZ
.model tiny
.486
smart
.code

org 0100h

start:
mov di,offset set
mov si,offset set
mov bx,7
mov cx,5
call delete0
ret

set db 'Essai de string',0
set2 db 'epais',0 
tre db 30 dup (0)

;Renvoie en es:di la partie de cx caractäres a partir de la gauche de ds:si
Left0:
        push    ax cx si di
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si cx ax
        ret

;Renvoie en es:di la partie de cx caractäres a partir de la droite de ds:si
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

;Renvoie en es:di la partie de cx caractäres a partir de la position bx de ds:si
middle0:
        push    ax cx si di
        add     si,bx
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si cx ax
        ret

;Rempli de cx caractäres dl a partir de la position bx de ds:si
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

;Recherche un caractäre dl dans la chaåne ds:si
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

;Compares 2 chaines de caractäres DS:SI et ES:DI zerof si non equal
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

;Detruit CX caractäres a partir du caractäre BX de DS:SI
delete0:
        push    cx dx si di es
        push    ds
        pop     es
        mov     dx,cx
        call    getlength0
        sub     cx,dx
        neg     cx
        mov     di,si
        add     si,bx
        cld
        rep     movsb
        pop     es di si dx cx
        ret
        
;Copie une chaine de ds:si en es:di
Copy:
        push    ax cx si di
        call    GetLength0
        cld
        rep     movsb
        mov     al,0
        stosb
        pop     di si cx ax
        ret

;Concatäne le chaine ds:si avec es:di
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

;renvoie la taille en octets CX de la chaine pointÇe en ds:si
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

;Met la taille en octets de la chaine pointÇe ds:si a CX 
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

;met en majuscule la premiäre lettre chaine ds:si
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



end start 
