use16
align 1

include "..\include\mem.h"
include "..\include\graphic.h"

org 0h

header exe 1

exporting
declare hline
declare line
declare polyfill
ende

importing
use VIDEO,showpixel
endi

proc hline uses cx dx, x1:word,x2:word,y:word,color:word
        mov     cx,[x1]
        mov     dx,[x2]
        cmp     cx,dx
        jbe     .boucle
        xchg    cx,dx
.boucle:
        invoke  showpixel,cx,[y],[color]
        inc     cx
        cmp     cx,dx
        jbe     .boucle
        ret
endp

; affiche un pixel en %0 %1 couleur %2
proc line uses ax bx cx dx si di, x1:word,y1:word,x2:word,y2:word,color:word
        local   deltax:WORD,deltay:WORD
        mov     ax,[x2]
        sub     ax,[x1]
        call    absolute
        mov     [deltax],ax
        mov     cx,ax
        mov     ax,[y2]
        sub     ax,[y1]
        call    absolute
        mov     dx,ax
        mov     [deltay],ax
        mov     ax,-1
        mov     bx,-1
        mov     si,[x1]
        mov     di,[y1]
        cmp     si,[x2]
        jg      .x1greater
        mov     ax,1
.x1greater:
        cmp     di,[y2]
        jg      .y1greater
        mov     bx,1
.y1greater:
        cmp     cx,dx
        jl      .deltaxgreater
        mov     dx,[deltax]
        sar     dx,1
        xor     cx,cx
.boucle1:
        add     si,ax
        add     dx,[deltay]
        cmp     dx,[deltax]
        jl      .above1
        sub     dx,[deltax]
        add     di,bx
.above1:
        invoke  showpixel,si,di,[color]
        inc     cx
        cmp     cx,[deltax]
        jl      .boucle1
        jmp     .endofline
.deltaxgreater:
        mov     dx,[deltay]
        sar     dx,1
        xor     cx,cx
.boucle2:
        add     di,bx
        add     dx,[deltax]
        cmp     dx,[deltay]
        jle     .above2
        sub     dx,[deltay]
        add     si,ax
.above2:
        invoke  showpixel,si,di,[color]
        inc     cx
        cmp     cx,[deltay]
        jl      .boucle2
.endofline:
        ret
endp

;renvoie la valeur absolue de AX
proc absolute 
          cmp     ax,0
          jg      .noabs
          neg     ax
.noabs:
          ret
endp

ymax equ 200

; initialise un segment 2
proc polyfill uses eax ebx ecx edx si di es, pointer:word,nbfaces:word,color:word;
         local   startx[200]:WORD,endx[200]:WORD,pas:DWORD,miny:WORD,maxy:WORD
         mov     di,bp
         sub     di,2
         mov     ax,16000
         mov     cx,(200+200)*2
         push    ss
         pop     es
         std
         rep     stosw
         mov     si,[pointer]
         mov     di,[pointer]
         virtual at 0
		.vertex2d vertex2d
	end virtual
         add     di,.vertex2d.sizeof
         mov     [miny],ymax
         mov     [maxy],0
         mov     cx,[nbfaces]
         dec     cx
.boucle:
         push    si di cx
	 virtual at si
	 .vertex2dsrc vertex2d
	 end virtual
	 virtual at di
	 .vertex2ddst vertex2d
	 end virtual
         mov     ax,[.vertex2ddst.py]
         cmp     ax,[.vertex2dsrc.py]
         je      .noexchange
         jge     .nothingtodo
         xchg    si,di
.nothingtodo:
         xor     eax,eax
         mov     ax,[.vertex2dsrc.px]
         cwde
         sal     eax,8
         mov     ebx,eax
         xor     eax,eax
         mov     ax,[.vertex2ddst.px]
         sub     ax,[.vertex2dsrc.px]
         cwde
         sal     eax,8
         xor     ecx,ecx
         mov     cx,[.vertex2ddst.py]
         sub     cx,[.vertex2dsrc.py]
         cdq
         idiv     ecx
         mov     [pas],eax
         add     ebx,eax
         mov     dx,[.vertex2dsrc.py]
         inc     dx
         cmp     dx,[miny]
         jge     .notinf
         mov     [miny],dx
.notinf:
         mov     ax,[.vertex2ddst.py]
         cmp     ax,[maxy]
         jle     .boucle2
         mov     [maxy],ax
.boucle2:
         cmp     dx,0
         jl      .notgood
         cmp     dx,ymax
         jge     .notgood
         mov     si,dx
         shl     si,1
         neg     si
         cmp     word [bp+si-2],16000
         jne     .notgoodforinf
         mov     eax,ebx
         sar     eax,8
         mov     [bp+si-2],ax
.notgoodforinf:
         mov     eax,ebx
         sar     eax,8
         mov     [bp+si-200*2-2],ax
.notgood:
         add     ebx,[pas]
         inc     dx
         cmp     dx,[.vertex2ddst.py]
         jle     .boucle2
.noexchange:
         pop     cx di si
         add     si,.vertex2d.sizeof
         add     di,.vertex2d.sizeof
         dec     cx
         js      .finished
         jnz     .boucle
         mov     di,[pointer]
         mov     cx,0FFFFh
         jmp     .boucle
.finished:
         cmp     word [miny],0
         jae     .noadj
         mov     [miny],0
.noadj:
         cmp     word [maxy],ymax
         jb     .noadj2
         mov    [maxy],ymax-1
.noadj2:
         mov    cx,[miny]
.drawboucle:
         mov    si,cx
         shl    si,1
         neg    si
         mov    ax,[bp+si-2]
         mov    bx,[bp+si-200*2-2]
         cmp    bx,16000
         jnz    .noinfatall
         mov    ax,bx
.noinfatall:
         stdcall   hline,ax,bx,cx,[color]
         inc    cx
         cmp    cx,[maxy]
         jna    .drawboucle
         ret
endp
 
