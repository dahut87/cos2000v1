model tiny,stdcall
p586
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\graphic.h"
include "..\include\3d.h"

org 0h

header exe <"CE",1,0,0,offset exports,offset imports,,>

exporting
declare draw3d_point
declare draw3d_line
declare draw3d_hidden
declare draw3d_hidden_fill
declare load3ds
declare translate
declare translatex
declare translatey
declare translatez
declare scale
declare rescale
declare copy
declare fill
declare identity
declare rotationx
declare rotationy
declare rotationz
declare rotation
declare project
declare transform
declare multiply
ende

importing
use GRAPHIC.LIB,line
use GRAPHIC.LIB,polyfill
use VIDEO,showpixel
endi

;affiche liste vertex %0
PROC draw3d_point FAR
        ARG     @vertex3d:word,@vertex2d:word,@camera:word,@color:word
        USES    cx,si
        mov     si,[@vertex2d]
        call    project,si,[@vertex3d],[@camera]
        mov     cx,[si]
        inc     si
        inc     si
@@draw:
        call    [cs:showpixel],[(vertex2d si).px],[(vertex2d si).py],[@color]
        add     si,4
        dec     cx
        jnz     @@draw
        ret
endp draw3d_point 
        
;affiche liste vertex %0
PROC draw3d_line FAR
        ARG     @type:word,@faces:word,@vertex3d:word,@vertex2d:word,@camera:word,@color:word
        USES    ax,bx,cx,dx,si,di
        mov     di,[@faces]
        mov     si,[@vertex2d]
        call    project,si,[@vertex3d],[@camera]
        mov     cx,[di]
        inc     si
        inc     si
        inc     di
        inc     di
@@draw:
        mov     ax,[@type]
        dec     al
        mov     dx,di
@@drawset:
        mov     bx,[di]
        shl     bx,2
        push    [@color]
        push    [(vertex2d bx+si).py]
        push    [(vertex2d bx+si).px]
        add     di,2
        mov     bx,[di]
        shl     bx,2
        push    [(vertex2d bx+si).py]
        push    [(vertex2d bx+si).px]
        call    [cs:line]
        dec     al
        jnz     @@drawset
        push    di
        mov     di,dx
        mov     bx,[di]
        pop     di
        shl     bx,2
        push    [@color]
        push    [(vertex2d bx+si).py]
        push    [(vertex2d bx+si).px]
        mov     bx,[di]
        shl     bx,2
        push    [word ptr bx+si+2]
        push    [word ptr bx+si]
        call    [cs:line]
        add     di,2
        dec     cx
        jnz     @@draw
        ret
endp draw3d_line 

;affiche liste vertex %0
PROC draw3d_hidden FAR
        ARG     @type:word,@faces:word,@vertex3d:word,@vertex2d:word,@camera:word,@color:word
        LOCAL   @@a1:word,@@a2:word,@@b1:word
        USES    ax,bx,cx,dx,si,di
        mov     di,[@faces]
        mov     si,[@vertex2d]
        call    project,si,[@vertex3d],[@camera]
        mov     cx,[di]
        inc     si
        inc     si
        inc     di
        inc     di
@@draw:
        push    cx
        mov     si,[@vertex2d]
        inc     si
        inc     si
        mov     bx,[di+2]
        shl     bx,2
        mov     cx,[(vertex2d bx+si).px]
        mov     dx,[(vertex2d bx+si).py]
        mov     bx,[di]
        shl     bx,2
        mov     ax,[(vertex2d bx+si).px]
        sub     ax,cx
        mov     [@@a1],ax
        mov     ax,[(vertex2d bx+si).py]
        sub     ax,dx
        mov     [@@b1],ax
        mov     bx,[di+4]
        shl     bx,2
        mov     ax,[(vertex2d bx+si).px]
        sub     ax,cx
        mov     [@@a2],ax
        mov     ax,[(vertex2d bx+si).py]
        sub     ax,dx
        xor     edx,edx
        imul    [@@a1]
        and     eax,0FFFFh
        rol     eax,16
        add     eax,edx
        rol     eax,16
        mov     ecx,eax
        mov     ax,[@@b1]
        imul    [@@a2]
        and     eax,0FFFFh
        rol     eax,16
        add     eax,edx
        rol     eax,16
        sub     ecx,eax
        pop     cx
        jge     @@nohidden
        mov    ax,[@type]
        shl    ax,1
        add    di,ax
        dec    cx
        jnz    @@draw
        jmp    @@endof
@@nohidden:
        mov     ax,[@type]
        dec     al
        mov     dx,di
@@drawset:
        mov     bx,[di]
        shl     bx,2
        push    [@color]
        push    [(vertex2d bx+si).py]
        push    [(vertex2d bx+si).px]
        add     di,2
        mov     bx,[di]
        shl     bx,2
        push    [(vertex2d bx+si).py]
        push    [(vertex2d bx+si).px]
        call    [cs:line]
        dec     al
        jnz     @@drawset
        push    di
        mov     di,dx
        mov     bx,[di]
        pop     di
        shl     bx,2
        push    [@color]
        push    [(vertex2d bx+si).py]
        push    [(vertex2d bx+si).px]
        mov     bx,[di]
        shl     bx,2
        push    [word ptr bx+si+2]
        push    [word ptr bx+si]
        call    [cs:line]
        add     di,2
        dec     cx
        jnz     @@draw
@@endof:
        ret
endp draw3d_hidden 

;creer table pour face caché %0
PROC draw3d_hidden_fill FAR
        ARG     @type:word,@faces:word,@vertex3d:word,@vertex2d:word,@camera:word,@color:word
        USES    eax,bx,ecx,edx,si,di
        LOCAL   @@a1:word,@@a2:word,@@b1:word
        mov     di,[@faces]
        call    project,[@vertex2d],[@vertex3d],[@camera]
        mov     cx,[di]
        inc     di
        inc     di
@@calculvect:
        push    cx
        mov     si,[@vertex2d]
        inc     si
        inc     si
        mov     bx,[di+2]
        shl     bx,2
        mov     cx,[(vertex2d bx+si).px]   
        mov     dx,[(vertex2d bx+si).py] 
        mov     bx,[di]
        shl     bx,2
        mov     ax,[(vertex2d bx+si).px] 
        sub     ax,cx
        mov     [@@a1],ax
        mov     ax,[(vertex2d bx+si).py] 
        sub     ax,dx
        mov     [@@b1],ax
        mov     bx,[di+4]
        shl     bx,2
        mov     ax,[(vertex2d bx+si).px] 
        sub     ax,cx
        mov     [@@a2],ax
        mov     ax,[(vertex2d bx+si).py] 
        sub     ax,dx
        xor     edx,edx
        imul    [@@a1]
        rol     eax,16
        add     eax,edx
        rol     eax,16
        mov     ecx,eax
        mov     ax,[@@b1]
        imul    [@@a2]
        rol     eax,16
        add     eax,edx
        rol     eax,16
        sub     ecx,eax
        pop     cx
        jl      @@hidden
        mov     ax,[@type]
        mov     si,[@vertex3d]
        inc     si
        inc     si
        fld     [cs:zero]
@@calcz:
        mov     bx,[di]
        mov     dx,bx
        shl     dx,2
        shl     bx,3
        add     bx,dx
        fadd    [(vertex3d bx+si).tz]
        add     di,2
        dec     al
        jnz     @@calcz
@@hidden:
        mov    ax,[@type]
        shl    ax,1
        add    di,ax
@@enofvalue:
        dec    cx
        jnz    @@calculvect
        ret
endp draw3d_hidden_fill 


;charge un fichier 3ds logé en %0 renvoie error
;sauvegarde en :
;- %1 le nom de l'objet
;- %2 les vertex 3D de l'objet
;- %3 la matrice de transformation de l'objet
;- %4 les faces de l'objet
;- %5 le type de face de l'objet
;1 non 3ds
;2 non 3 et >
PROC load3ds FAR
        ARG     @seg:word,@add:word,@objectname:word,@vertex:word,@matrix:word,@face:word
        USES    eax,bx,cx,si,di,ds,es,fs
        push    ds
        pop     fs
        mov     si,[@add]
        mov     ds,[@seg]
        cmp     [word ptr si],main
        jne     @@error1
        cmp     [word ptr si+28],3
        jb      @@error2
@@reading:
        mov     ax,[si]
        mov     bx,[si+2]
        cmp     ax,main
        je      @@enter
        cmp     ax,edit
        je      @@enter
        cmp     ax,mesh
        je      @@enter
        cmp     ax,object
        je      @@readobject
        cmp     ax,vertex
        je      @@readvertex
        cmp     ax,locale
        je      @@readmatrix
        cmp     ax,face
        je      @@readfaces
@@next:
        add     si,bx
        jmp     @@reading        
@@enter:
        add     si,6
        jmp     @@reading       
@@readobject:
        add     si,6
        mov     di,si
        mov     al,0
        mov     es,[@seg]
        mov     cx,12
        cld
        repne   scasb
        mov     cx,di
        sub     cx,si
        mov     di,[@objectname]
        push    fs
        pop     es
        cld
        rep     movsb
        jmp     @@reading        
@@readvertex:
        add     si,6
        mov     ax,[si]
        mov     di,[@vertex]
        mov     [fs:di],ax
        inc     si
        inc     si
        mov     cx,ax
        shl     ax,1
        add     cx,ax
        add     di,2
        cld
        push    fs
        pop     es
        cld
        rep     movsd
        jmp     @@reading
@@readmatrix:
        add     si,6
        mov     di,[@matrix]
        mov     eax,[si]
        mov     [fs:(mat di).p1],eax
        mov     eax,[si+4*1]
        mov     [fs:(mat di).p5],eax
        mov     eax,[si+4*2]
        mov     [fs:(mat di).p9],eax
        mov     eax,[si+4*3]
        mov     [fs:(mat di).p2],eax
        mov     eax,[si+4*4]
        mov     [fs:(mat di).p6],eax
        mov     eax,[si+4*5]
        mov     [fs:(mat di).p10],eax
        mov     eax,[si+4*6]
        mov     [fs:(mat di).p3],eax
        mov     eax,[si+4*7]
        mov     [fs:(mat di).p7],eax
        mov     eax,[si+4*8]
        mov     [fs:(mat di).p11],eax
        mov     eax,[si+4*9]
        mov     [fs:(mat di).p4],eax
        mov     eax,[si+4*10]
        mov     [fs:(mat di).p8],eax
        mov     eax,[si+4*11]
        mov     [fs:(mat di).p12],eax
        mov     eax,[cs:un]
        mov     [fs:(mat di).p16],eax
        mov     eax,0
        mov     [fs:(mat di).p13],eax
        mov     [fs:(mat di).p14],eax
        mov     [fs:(mat di).p15],eax
        add     si,12*4
        jmp     @@reading        
@@readfaces:
        add     si,6
        mov     ax,[si]
        mov     di,[@face]
        mov     [fs:di],ax
        inc     si
        inc     si
        add     di,2
        push    fs
        pop     es
        cld
@@readall:
        mov     cx,3
        rep     movsw
        inc     si
        inc     si
        dec     ax
        jnz     @@readall
        ;;jmp     @@reading
@@error1:
@@error2:
        ret
endp load3ds  

un dd 1.0
zero dd 0.0

;initialise une matrice de translation pour une translation TX,TY,TZ (%1,%2,%3) dans MATRICE %0
;  mat[ 0] = 1.0
;  mat[ 5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  mat[ 3] = vecteur->x
;  mat[ 7] = vecteur->y
;  mat[11] = vecteur->z
PROC translate FAR
        ARG     @mat:word,@x:dword,@y:dword,@z:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     eax,[@x]
        mov     [di+3*4],eax
        mov     eax,[@y]
        mov     [di+7*4],eax
        mov     eax,[@z]
        mov     [di+11*4],eax
        ret
ENDP translate 

;initialise une matrice de translation pour une translation TX %1 dans MATRICE %0
;  mat[ 0] = 1.0
;  mat[ 5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  mat[ 3] = value
;  mat[ 7] = 1
;  mat[11] = 1
PROC translatex FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     [di+7*4],eax
        mov     [di+11*4],eax
        mov     eax,[@value]
        mov     [di+3*4],eax
        ret
ENDP translatex 


;initialise une matrice de translation pour une translation TY %1 dans MATRICE %0
;  mat[ 0] = 1.0
;  mat[ 5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  mat[ 3] = 1
;  mat[ 7] = value
;  mat[11] = 1
PROC translatey FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     [di+3*4],eax
        mov     [di+11*4],eax
        mov     eax,[@value]
        mov     [di+7*4],eax
        ret
ENDP translatey 

;initialise une matrice de translation pour une translation TZ %1 dans MATRICE %0
;  mat[ 0] = 1.0
;  mat[ 5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  mat[ 3] = 1
;  mat[ 7] = 1
;  mat[11] = value
PROC translatez FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     [di+3*4],eax
        mov     [di+7*4],eax
        mov     eax,[@value]
        mov     [di+11*4],eax
        ret
ENDP translatez 

;initialise une matrice d'echelle %0 de facteur (x,y,z) %1-%3
;  mat[ 0] = factorx
;  mat[ 5] = factory
;  mat[10] = factorz
;  mat[15] = 1.0
;  reste a 0
PROC scale FAR
        ARG     @mat:word,@x:dword,@y:dword,@z:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        mov     eax,[@x]
        mov     [di+0*4],eax
        mov     eax,[@y]
        mov     [di+5*4],eax
        mov     eax,[@z]
        mov     [di+10*4],eax
        mov     eax,[cs:un]
        mov     [di+15*4],eax
        ret
ENDP scale 

;initialise une matrice d'echelle %0 de facteur value %1
;  mat[ 0] = factor
;  mat[ 5] = factor
;  mat[10] = factor
;  mat[15] = 1.0
;  reste a 0
PROC rescale FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        mov     eax,[@value]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     eax,[cs:un]
        mov     [di+15*4],eax
        ret
ENDP rescale 

;copy une matrice %0 en %1
;mat2=mat1
PROC copy FAR
        ARG     @mat1:word,@mat2:word
        USES    ecx,si,di,es
        mov     si,[@mat1]
        mov     di,[@mat2]
        mov     ecx,16
        push    ds
        pop     es
        cld
        rep     stosd
        ret
ENDP copy 

;initialise une matrice %0 avec la valeur %1
;mat[i]=value
PROC fill FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     eax,[@value]
        mov     ecx,16
        push    ds
        pop     es
        cld
        rep     stosd
        ret
ENDP fill 

;initialise une matrice d'identité %0
;  mat[0] = 1.0
;  mat[5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  reste a 0
PROC identity FAR
        ARG     @mat:word
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        ret
ENDP identity 


;initialise une matrice de rotation %0 autour de X de %1 degrees
;  mat[ 5] =  cos(angle)
;  mat[ 6] = -sin(angle)
;  mat[ 9] =  sin(angle)
;  mat[10] =  cos(angle)
;  mat[ 0] = 1.0
;  mat[15] = 1.0
;  reste a 0
PROC rotationx FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        fld     [@value]
        fsincos
;mat[ 5] =  cos(angle);
        fst     [dword ptr di+5*4]
;mat[ 10] =  cos(angle);
        fstp    [dword ptr di+10*4]
;mat[ 9] =  sin(angle);
        fst     [dword ptr di+9*4]
;mat[ 6] =  -sin(angle);
        fchs
        fstp    [dword ptr di+6*4]
;mat[ 0] = 1.0
;mat[15] = 1.0
         mov    eax,[cs:un]
         mov    [di+0*4],eax
         mov    [di+15*4],eax
         ret
endp rotationx 

;initialise une matrice de rotation BX autour de Y de %0 degrees
;  mat[ 0] =  cos(angle)
;  mat[ 8] = -sin(angle)
;  mat[ 2] =  sin(angle)
;  mat[10] =  cos(angle)
;  mat[ 5] = 1.0
;  mat[15] = 1.0
;  reste a 0
PROC rotationy FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        fld     [@value]
        fsincos
;mat[ 0] =  cos(angle)
        fst     [dword ptr di+0*4]
;mat[ 10] =  cos(angle)
        fstp    [dword ptr di+10*4]
;mat[ 2] =  sin(angle)
        fst     [dword ptr di+2*4]
        fchs
;mat[ 8] =  -sin(angle)
        fstp    [dword ptr di+8*4]
;mat[ 5] = 1.0
;mat[15] = 1.0
        mov     eax,[cs:un]
        mov     [di+5*4],eax
        mov     [di+15*4],eax
        ret
endp rotationy 

;initialise une matrice de rotation %0 autour de Z de %1 degrees
;  mat[ 0] =  cos(angle)
;  mat[ 1] = -sin(angle)
;  mat[ 4] =  sin(angle)
;  mat[ 5] =  cos(angle)
;  mat[10] = 1.0
;  mat[15] = 1.0
;  reste a 0
PROC rotationz FAR
        ARG     @mat:word,@value:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
        fld     [@value]
        fsincos
;mat[ 0] =  cos(angle)
        fst     [dword ptr di+0*4]
;mat[ 5] =  cos(angle)
        fstp    [dword ptr di+5*4]
;mat[ 4] =  sin(angle)
        fst     [dword ptr di+4*4]
        fchs
;mat[ 1] =  -sin(angle)
        fstp    [dword ptr di+1*4]
;mat[10] = 1.0
;mat[15] = 1.0
        mov     eax,[cs:un]
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        ret
endp rotationz 

;initialise une matrice de rotation %0 autour de X,Y,Z de %0-%3 degrees
;  mat[ 0] =  cos(angleY)*cos(angleZ)
;  mat[ 1] =  cos(angleY)*sin(angleZ)
;  mat[ 2] =  -sin(angleY)
;  mat[ 4] =  sin(angleX)*sin(angleY)*cos(angleZ)+cos(angleX)*-sin(angleZ)
;  mat[ 5] =  sin(angleX)*sin(angleY)*sin(angleZ)+cos(angleX)*cos(angleZ)
;  mat[ 6] =  sin(angleX)*cos(angleY)
;  mat[ 8] =  cos(angleX)*sin(angleY)*cos(angleZ)+sin(angleX)*sin(angleZ)
;  mat[ 9] =  cos(angleX)*sin(angleY)*sin(angleZ)-sin(angleX)*cos(angleZ)
;  mat[ 10] = cos(angleX)*cos(angleY)
;  mat[3] = 0.0
;  mat[7] = 0.0
;  mat[11] = 0.0
;  mat[12] = 0.0
;  mat[13] = 0.0
;  mat[14] = 0.0
;  mat[15] = 1.0
;  reste a 0
PROC rotation FAR
        ARG     @mat:word,@anglex:dword,@angley:dword,@anglez:dword
        USES    eax,ecx,di,es
        mov     di,[@mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[@mat]
;st(1) sin(angleZ)
;st(2) cos(angleZ)
;st(3) sin(angleY)
;st(4) cos(angleY)
;st(5) sin(angleX)
;st(6) cos(angleX)
        fld     [@anglex]
        fsincos
        fld     [@angley]
        fsincos
        fld     [@anglez]
        fsincos
;Cos(angleY)*Cos(angleZ)
        fld     st(3)
        fmul    st(0),st(2)
;mat[0]
        fstp    [dword ptr di+0*4]
;Cos(angleY)*Sin(angleZ)
        fld     st(3)
        fmul    st(0),st(1)
;mat[1]
        fstp    [dword ptr di+1*4]
;-Sin(angley)
        fld     st(2)
        fchs
;mat[2]
        fstp    [dword ptr di+2*4]
        mov     eax,[cs:un]
        mov     [di+15*4],eax
        ret
endp rotation 


factor dd 128.0

;Transforme la liste de vertex 3D pointé par %0 en vertex 2D dans %1 en utilisant %2 comme origine pour %3 valeurs
;    vertex2d[i].px=int((vertex3d[i].tx*factor)/(vertex3d[i].tz+origin.Z)+origin.X)
;    vertex2d[i].py=int((vertex3d[i].ty*factor)/(vertex3d[i].tz+origin.Z)+origin.Y)
PROC project FAR
        ARG     @vertex2d:word,@vertex3d:word,@origin:word
        USES    cx,bx,si,di
        mov     si,[@vertex3d]
        mov     bx,[@vertex2d]
        mov     di,[@origin]
        mov     cx,[si]
        mov     [bx],cx
        inc     si
        inc     si
        inc     bx
        inc     bx
@@boucle:
;(vertex3d[i].z+origZ)
        fld     [(vertex3d si).tz]
        fadd    [(vertex3d di).tz]
;(vertex3d[i].tx*factor)
        fld     [(vertex3d si).tx]
        fmul    [cs:factor]
;(vertex3d[i].tx*factor)/(vertex3d[i].tz+origZ)
        fdiv    st,st(1)
;(vertex3d[i].tx*factor)/(vertex3d[i].tz+origZ)+origX
        fadd    [(vertex3d di).tx]
;vertex2d[i].tx=int((vertex3d[i].tx*factor)/(vertex3d[i].tz+origZ)+origX)
        fistp   [(vertex2d bx).px] 
;(vertex3d[i].z+origZ)
;(vertex3d[i].ty*factor)
        fld     [(vertex3d si).ty]
        fmul    [cs:factor]
;(vertex3d[i].ty*factor)/(vertex3d[i].tz+origZ)
        fdivrp  st(1)
;(vertex3d[i].ty*factor)/(vertex3d[i].tz+origZ)+origY
        fadd    [(vertex3d di).ty]
;vertex2d[i].ty=int((vertex3d[i].ty*factor)/(vertex3d[i].tz+origZ)+origY)
        fistp   [(vertex2d bx).py]
        add     si,size vertex3d
        add     bx,size vertex2d
        dec     cx
        jnz     @@boucle
        ret
endp project 


;transforme les points %0 avec la matrice %1

; vertex3d_2 = mat * vertex3d

;  w                = mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty + mat[14]*vertex3d[i].tz + mat[15]
;  vertex3d_2[i].tx = mat[ 0]*vertex3d[i].tx + mat[ 1]*vertex3d[i].ty + mat[ 2]*vertex3d[i].tz + mat[ 3]
;  vertex3d_2[i].ty = mat[ 4]*vertex3d[i].tx + mat[ 5]*vertex3d[i].ty + mat[ 6]*vertex3d[i].tz + mat[ 7]
;  vertex3d_2[i].tz = mat[ 8]*vertex3d[i].tx + mat[ 9]*vertex3d[i].ty + mat[10]*vertex3d[i].tz + mat[11]
PROC transform FAR
        ARG     @vertex3d:word,@mat:word
        USES    cx,si,di
        mov     si,[@vertex3d]
        mov     cx,[si]
        inc     si
        inc     si
        mov     di,[@mat]
@@boucle:
;Calcul du facteur echelle
;mat[12]*vertex3d[i].tx
        fld     [(vertex3d si).tx]
        fmul    [dword ptr di+12*4]
;mat[13]*vertex3d[i].ty
        fld     [(vertex3d si).ty]
        fmul    [dword ptr di+13*4]
;mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty
        faddp    st(1)
;mat[14]*vertex3d.tz
        fld      [(vertex3d si).tz]
        fmul     [dword ptr di+14*4]
;mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty + mat[14]*vertex3d[i].tz
        faddp    st(1)
;mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty + mat[14]*vertex3d[i].tz + mat[15]
        fadd     [dword ptr di+15*4]
;w=0.0 ??
        ftst
;-> AX
        fstsw    ax

;vertex3d.tx vertex3d.ty et vertex3d.tz
        fld      [(vertex3d si).tx]
        fmul     [dword ptr di+0*4]
        fld      [(vertex3d si).ty]
        fmul     [dword ptr di+1*4]
        faddp    st(1)
        fld      [(vertex3d si).tz]
        fmul     [dword ptr di+2*4]
        faddp    st(1)
        fadd     [dword ptr di+3*4]

        fld      [(vertex3d si).tx]
        fmul     [dword ptr di+4*4]
        fld      [(vertex3d si).ty]
        fmul     [dword ptr di+5*4]
        faddp    st(1)
        fld      [(vertex3d si).tz]
        fmul     [dword ptr di+6*4]
        faddp    st(1)
        fadd     [dword ptr di+7*4]

        fld      [(vertex3d si).tx]
        fmul     [dword ptr di+8*4]
        fld      [(vertex3d si).ty]
        fmul     [dword ptr di+9*4]
        faddp    st(1)
        fld      [(vertex3d si).tz]
        fmul     [dword ptr di+10*4]
        faddp    st(1)
        fadd     [dword ptr di+11*4]

;w=0.0
        sahf
        jz       @@divby0
;vertex3d.tx=vertex3d[i].tz/w
        fdiv     st,st(3)
        fstp     [(vertex3d si).tz]
;vertex3d.ty=vertex3d[i].ty/w
        fdiv     st,st(2)
        fstp     [(vertex3d si).ty]
;vertex3d.tz=vertex3d[i].tx/w
        fdivrp   st(1),st
        fstp     [(vertex3d si).tx]
;No div by 0
        jmp      @@nodiv
@@divby0:
        fstp     [(vertex3d si).tz]
        fstp     [(vertex3d si).ty]
        fstp     [(vertex3d si).tx]
        ffree
@@nodiv:
        add      si,size vertex3d
        dec      cx
        jnz      @@boucle
        ret
endp transform 

;Multiplie la matrice de transformation %0 par celle en %1 et met les resultat en %2

; mat = p1 * p2

;  mat[ 0] = (p1[ 0]*p2[ 0])+(p1[ 1]*p2[ 4])+(p1[ 2]*p2[ 8])+(p1[ 3]*p2[12]);
;  mat[ 4] = (p1[ 4]*p2[ 0])+(p1[ 5]*p2[ 4])+(p1[ 6]*p2[ 8])+(p1[ 7]*p2[12]);
;  mat[ 8] = (p1[ 8]*p2[ 0])+(p1[ 9]*p2[ 4])+(p1[10]*p2[ 8])+(p1[11]*p2[12]);
;  mat[12] = (p1[12]*p2[ 0])+(p1[13]*p2[ 4])+(p1[14]*p2[ 8])+(p1[15]*p2[12]);
;  mat[ 1] = (p1[ 0]*p2[ 1])+(p1[ 1]*p2[ 5])+(p1[ 2]*p2[ 9])+(p1[ 3]*p2[13]);
;  mat[ 5] = (p1[ 4]*p2[ 1])+(p1[ 5]*p2[ 5])+(p1[ 6]*p2[ 9])+(p1[ 7]*p2[13]);
;  mat[ 9] = (p1[ 8]*p2[ 1])+(p1[ 9]*p2[ 5])+(p1[10]*p2[ 9])+(p1[11]*p2[13]);
;  mat[13] = (p1[12]*p2[ 1])+(p1[13]*p2[ 5])+(p1[14]*p2[ 9])+(p1[15]*p2[13]);
;  mat[ 2] = (p1[ 0]*p2[ 2])+(p1[ 1]*p2[ 6])+(p1[ 2]*p2[10])+(p1[ 3]*p2[14]);
;  mat[ 6] = (p1[ 4]*p2[ 2])+(p1[ 5]*p2[ 6])+(p1[ 6]*p2[10])+(p1[ 7]*p2[14]);
;  mat[10] = (p1[ 8]*p2[ 2])+(p1[ 9]*p2[ 6])+(p1[10]*p2[10])+(p1[11]*p2[14]);
;  mat[14] = (p1[12]*p2[ 2])+(p1[13]*p2[ 6])+(p1[14]*p2[10])+(p1[15]*p2[14]);
;  mat[ 3] = (p1[ 0]*p2[ 3])+(p1[ 1]*p2[ 7])+(p1[ 2]*p2[11])+(p1[ 3]*p2[15]);
;  mat[ 7] = (p1[ 4]*p2[ 3])+(p1[ 5]*p2[ 7])+(p1[ 6]*p2[11])+(p1[ 7]*p2[15]);
;  mat[11] = (p1[ 8]*p2[ 3])+(p1[ 9]*p2[ 7])+(p1[10]*p2[11])+(p1[11]*p2[15]);
;  mat[15] = (p1[12]*p2[ 3])+(p1[13]*p2[ 7])+(p1[14]*p2[11])+(p1[15]*p2[15]);

PROC multiply FAR
        ARG     @p1:word,@p2:word,@mat:word
        USES    bx,si,di
        mov     si,[@p1]
        mov     di,[@p2]
        mov     bx,[@mat]
;0,0
;p1[ 0]*p2[ 0]
        fld     [dword ptr si+0*4]
        fmul    [dword ptr di+0*4]
;p1[ 1]*p2[ 4]
        fld     [dword ptr si+1*4]
        fmul    [dword ptr di+4*4]
;(p1[ 0]*p2[ 0])+(p1[ 1]*p2[ 4])
        faddp   st(1)
;p1[ 2]*p2[ 8]
        fld     [dword ptr si+2*4]
        fmul    [dword ptr di+8*4]
;(p1[ 0]*p2[ 0])+(p1[ 1]*p2[ 4])+(p1[ 2]*p2[ 8])
        faddp   st(1)
;p1[ 3]*p2[12]
        fld     [dword ptr si+3*4]
        fmul    [dword ptr di+12*4]
;(p1[ 0]*p2[ 0])+(p1[ 1]*p2[ 4])+(p1[ 2]*p2[ 8])+(p1[ 3]*p2[12])
        faddp   st(1)
        fstp    [dword ptr bx+0*4]
;mat[ 0]

;1,0
        fld     [dword ptr si+0*4]
        fmul    [dword ptr di+1*4]
        fld     [dword ptr si+1*4]
        fmul    [dword ptr di+5*4]
        faddp   st(1)
        fld     [dword ptr si+2*4]
        fmul    [dword ptr di+9*4]
        faddp   st(1)
        fld     [dword ptr si+3*4]
        fmul    [dword ptr di+13*4]
        faddp   st(1)
        fstp    [dword ptr bx+1*4]
;2,0
        fld     [dword ptr si+0*4]
        fmul    [dword ptr di+2*4]
        fld     [dword ptr si+1*4]
        fmul    [dword ptr di+6*4]
        faddp   st(1)
        fld     [dword ptr si+2*4]
        fmul    [dword ptr di+10*4]
        faddp   st(1)
        fld     [dword ptr si+3*4]
        fmul    [dword ptr di+14*4]
        faddp   st(1)
        fstp    [dword ptr bx+2*4]
;3,0
        fld     [dword ptr si+0*4]
        fmul    [dword ptr di+3*4]
        fld     [dword ptr si+1*4]
        fmul    [dword ptr di+7*4]
        faddp   st(1)
        fld     [dword ptr si+2*4]
        fmul    [dword ptr di+11*4]
        faddp   st(1)
        fld     [dword ptr si+3*4]
        fmul    [dword ptr di+15*4]
        faddp   st(1)
        fstp    [dword ptr bx+3*4]
;0,1
        fld     [dword ptr si+4*4]
        fmul    [dword ptr di+0*4]
        fld     [dword ptr si+5*4]
        fmul    [dword ptr di+4*4]
        faddp   st(1)
        fld     [dword ptr si+6*4]
        fmul    [dword ptr di+8*4]
        faddp   st(1)
        fld     [dword ptr si+7*4]
        fmul    [dword ptr di+12*4]
        faddp   st(1)
        fstp    [dword ptr bx+4*4]
;1,1
        fld     [dword ptr si+4*4]
        fmul    [dword ptr di+1*4]
        fld     [dword ptr si+5*4]
        fmul    [dword ptr di+5*4]
        faddp   st(1)
        fld     [dword ptr si+6*4]
        fmul    [dword ptr di+9*4]
        faddp   st(1)
        fld     [dword ptr si+7*4]
        fmul    [dword ptr di+13*4]
        faddp   st(1)
        fstp    [dword ptr bx+5*4]
;2,1
        fld     [dword ptr si+4*4]
        fmul    [dword ptr di+2*4]
        fld     [dword ptr si+5*4]
        fmul    [dword ptr di+6*4]
        faddp   st(1)
        fld     [dword ptr si+6*4]
        fmul    [dword ptr di+10*4]
        faddp   st(1)
        fld     [dword ptr si+7*4]
        fmul    [dword ptr di+14*4]
        faddp   st(1)
        fstp    [dword ptr bx+6*4]
;3,1
        fld     [dword ptr si+4*4]
        fmul    [dword ptr di+3*4]
        fld     [dword ptr si+5*4]
        fmul    [dword ptr di+7*4]
        faddp   st(1)
        fld     [dword ptr si+6*4]
        fmul    [dword ptr di+11*4]
        faddp   st(1)
        fld     [dword ptr si+7*4]
        fmul    [dword ptr di+15*4]
        faddp   st(1)
        fstp    [dword ptr bx+7*4]
;0,2
        fld     [dword ptr si+8*4]
        fmul    [dword ptr di+0*4]
        fld     [dword ptr si+9*4]
        fmul    [dword ptr di+4*4]
        faddp   st(1)
        fld     [dword ptr si+10*4]
        fmul    [dword ptr di+8*4]
        faddp   st(1)
        fld     [dword ptr si+11*4]
        fmul    [dword ptr di+12*4]
        faddp   st(1)
        fstp    [dword ptr bx+8*4]
;1,2
        fld     [dword ptr si+8*4]
        fmul    [dword ptr di+1*4]
        fld     [dword ptr si+9*4]
        fmul    [dword ptr di+5*4]
        faddp   st(1)
        fld     [dword ptr si+10*4]
        fmul    [dword ptr di+9*4]
        faddp   st(1)
        fld     [dword ptr si+11*4]
        fmul    [dword ptr di+13*4]
        faddp   st(1)
        fstp    [dword ptr bx+9*4]
;2,2
        fld     [dword ptr si+8*4]
        fmul    [dword ptr di+2*4]
        fld     [dword ptr si+9*4]
        fmul    [dword ptr di+6*4]
        faddp   st(1)
        fld     [dword ptr si+10*4]
        fmul    [dword ptr di+10*4]
        faddp   st(1)
        fld     [dword ptr si+11*4]
        fmul    [dword ptr di+14*4]
        faddp   st(1)
        fstp    [dword ptr bx+10*4]
;3,2
        fld     [dword ptr si+8*4]
        fmul    [dword ptr di+3*4]
        fld     [dword ptr si+9*4]
        fmul    [dword ptr di+7*4]
        faddp   st(1)
        fld     [dword ptr si+10*4]
        fmul    [dword ptr di+11*4]
        faddp   st(1)
        fld     [dword ptr si+11*4]
        fmul    [dword ptr di+15*4]
        faddp   st(1)
        fstp    [dword ptr bx+11*4]
;0,3
        fld     [dword ptr si+12*4]
        fmul    [dword ptr di+0*4]
        fld     [dword ptr si+13*4]
        fmul    [dword ptr di+4*4]
        faddp   st(1)
        fld     [dword ptr si+14*4]
        fmul    [dword ptr di+8*4]
        faddp   st(1)
        fld     [dword ptr si+15*4]
        fmul    [dword ptr di+12*4]
        faddp   st(1)
        fstp    [dword ptr bx+12*4]
;1,3
        fld     [dword ptr si+12*4]
        fmul    [dword ptr di+1*4]
        fld     [dword ptr si+13*4]
        fmul    [dword ptr di+5*4]
        faddp   st(1)
        fld     [dword ptr si+14*4]
        fmul    [dword ptr di+9*4]
        faddp   st(1)
        fld     [dword ptr si+15*4]
        fmul    [dword ptr di+13*4]
        faddp   st(1)
        fstp    [dword ptr bx+13*4]
;2,3
        fld     [dword ptr si+12*4]
        fmul    [dword ptr di+2*4]
        fld     [dword ptr si+13*4]
        fmul    [dword ptr di+6*4]
        faddp   st(1)
        fld     [dword ptr si+14*4]
        fmul    [dword ptr di+10*4]
        faddp   st(1)
        fld     [dword ptr si+15*4]
        fmul    [dword ptr di+14*4]
        faddp   st(1)
        fstp    [dword ptr bx+14*4]
;3,3
        fld     [dword ptr si+12*4]
        fmul    [dword ptr di+3*4]
        fld     [dword ptr si+13*4]
        fmul    [dword ptr di+7*4]
        faddp   st(1)
        fld     [dword ptr si+14*4]
        fmul    [dword ptr di+11*4]
        faddp   st(1)
        fld     [dword ptr si+15*4]
        fmul    [dword ptr di+15*4]
        faddp   st(1)
        fstp    [dword ptr bx+15*4]
        ret
endp multiply 
