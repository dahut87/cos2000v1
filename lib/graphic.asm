model tiny,stdcall
p586
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\graphic.h"

org 0h

header exe <"CE",1,0,0,offset exports,offset imports,,>

exporting
declare hline
declare line
declare polyfill
ende

importing
use VIDEO,showpixel
endi

PROC hline FAR
        ARG     @x1:word,@x2:word,@y:word,@color:word
        USES    cx,dx
        mov     cx,[@x1]
        mov     dx,[@x2]
        cmp     cx,dx
        jbe     @@boucle
        xchg    cx,dx
@@boucle:
        call    [cs:showpixel],cx,[@y],[@color]
        inc     cx
        cmp     cx,dx
        jbe     @@boucle
        ret
endp hline

; affiche un pixel en %0 %1 couleur %2
PROC line FAR
        ARG     @x1:word,@y1:word,@x2:word,@y2:word,@color:word
        USES    ax,bx,cx,dx,si,di
        LOCAL   @@deltax:word,@@deltay:word
        mov     ax,[@x2]
        sub     ax,[@x1]
        call    absolute
        mov     [@@deltax],ax
        mov     cx,ax
        mov     ax,[@y2]
        sub     ax,[@y1]
        call    absolute
        mov     dx,ax
        mov     [@@deltay],ax
        mov     ax,-1
        mov     bx,-1
        mov     si,[@x1]
        mov     di,[@y1]
        cmp     si,[@x2]
        jg      @@x1greater
        mov     ax,1
@@x1greater:
        cmp     di,[@y2]
        jg      @@y1greater
        mov     bx,1
@@y1greater:
        cmp     cx,dx
        jl      @@deltaxgreater
        mov     dx,[@@deltax]
        sar     dx,1
        xor     cx,cx
@@boucle1:
        add     si,ax
        add     dx,[@@deltay]
        cmp     dx,[@@deltax]
        jl      @@above1
        sub     dx,[@@deltax]
        add     di,bx
@@above1:
        call    [cs:showpixel],si,di,[@color]
        inc     cx
        cmp     cx,[@@deltax]
        jl      @@boucle1
        jmp     @@endofline
@@deltaxgreater:
        mov     dx,[@@deltay]
        sar     dx,1
        xor     cx,cx
@@boucle2:
        add     di,bx
        add     dx,[@@deltax]
        cmp     dx,[@@deltay]
        jle     @@above2
        sub     dx,[@@deltay]
        add     si,ax
@@above2:
        call    [cs:showpixel],si,di,[@color]
        inc     cx
        cmp     cx,[@@deltay]
        jl      @@boucle2
@@endofline:
        ret
endp line

;renvoie la valeur absolue de AX
PROC absolute  NEAR
          cmp     ax,0
          jg      @@noabs
          neg     ax
@@noabs:
          ret
endp absolute 

ymax equ 200

; initialise un segment 2
PROC polyfill FAR
         ARG     @pointer:word,@nbfaces:word,@color:word;
         LOCAL   @@startx:word:200,@@endx:word:200,@@pas:dword,@@miny:word,@@maxy:word
         USES    eax,ebx,ecx,edx,si,di,es
         mov     di,bp
         sub     di,2
         mov     ax,16000
         mov     cx,(200+200)*2
         push    ss
         pop     es
         std
         rep     stosw
         mov     si,[@pointer]
         mov     di,[@pointer]
         add     di,size vertex2d
         mov     [@@miny],ymax
         mov     [@@maxy],0
         mov     cx,[@nbfaces]
         dec     cx
@@boucle:
         push    si di cx
         mov     ax,[(vertex2d di).py]
         cmp     ax,[(vertex2d si).py]
         je      @@noexchange
         jge     @@nothingtodo
         xchg    si,di
@@nothingtodo:
         xor     eax,eax
         mov     ax,[(vertex2d si).px]
         cwde
         sal     eax,8
         mov     ebx,eax
         xor     eax,eax
         mov     ax,[(vertex2d di).px]
         sub     ax,[(vertex2d si).px]
         cwde
         sal     eax,8
         xor     ecx,ecx
         mov     cx,[(vertex2d di).py]
         sub     cx,[(vertex2d si).py]
         cdq
         idiv     ecx
         mov     [@@pas],eax
         add     ebx,eax
         mov     dx,[(vertex2d si).py]
         inc     dx
         cmp     dx,[@@miny]
         jge     @@notinf
         mov     [@@miny],dx
@@notinf:
         mov     ax,[(vertex2d di).py]
         cmp     ax,[@@maxy]
         jle     @@boucle2
         mov     [@@maxy],ax
@@boucle2:
         cmp     dx,0
         jl      @@notgood
         cmp     dx,ymax
         jge     @@notgood
         mov     si,dx
         shl     si,1
         neg     si
         cmp     [word ptr bp+si-2],16000
         jne     @@notgoodforinf
         mov     eax,ebx
         sar     eax,8
         mov     [bp+si-2],ax
@@notgoodforinf:
         mov     eax,ebx
         sar     eax,8
         mov     [bp+si-200*2-2],ax
@@notgood:
         add     ebx,[@@pas]
         inc     dx
         cmp     dx,[(vertex2d di).py]
         jle     @@boucle2
@@noexchange:
         pop     cx di si
         add     si,size vertex2d
         add     di,size vertex2d
         dec     cx
         js      @@finished
         jnz     @@boucle
         mov     di,[@pointer]
         mov     cx,0FFFFh
         jmp     @@boucle
@@finished:
         cmp     [word ptr @@miny],0
         jae     @@noadj
         mov     [@@miny],0
@@noadj:
         cmp     [word ptr @@maxy],ymax
         jb     @@noadj2
         mov    [@@maxy],ymax-1
@@noadj2:
         mov    cx,[@@miny]
@@drawboucle:
         mov    si,cx
         shl    si,1
         neg    si
         mov    ax,[bp+si-2]
         mov    bx,[bp+si-200*2-2]
         cmp    bx,16000
         jnz    @@noinfatall
         mov    ax,bx
@@noinfatall:
         call   hline,ax,bx,cx,[@color]
         inc    cx
         cmp    cx,[@@maxy]
         jna    @@drawboucle
         ret
endp polyfill        
 
