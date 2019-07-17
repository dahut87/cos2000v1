use16
align 1

include "..\include\mem.h"
include "..\include\graphic.h"
include "..\include\3d.h"

org 0h

header exe 1,exports,imports,0,0

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
proc draw3d_point uses cx si, vertex3d:word,vertex2d:word,camera:word,color:word
        mov     si,[vertex2d]
        stdcall    project,si,[vertex3d],[camera]
        mov     cx,[si]
        inc     si
        inc     si
.draw:
	virtual at si
		.vertex2d vertex2d
	end virtual
        invoke    showpixel,[.vertex2d.px],[.vertex2d.py],[color]
        add     si,4
        dec     cx
        jnz     .draw
        ret
endp 
        
;affiche liste vertex %0
proc draw3d_line uses ax bx cx dx si di, type:word,faces:word,vertex3d:word,vertex2d:word,camera:word,color:word
        mov     di,[faces]
        mov     si,[vertex2d]
        stdcall    project,si,[vertex3d],[camera]
        mov     cx,[di]
        inc     si
        inc     si
        inc     di
        inc     di
.draw:
        mov     ax,[type]
        dec     al
        mov     dx,di
.drawset:
        mov     bx,[di]
        shl     bx,2
        push    [color]
	virtual at bx+si
	    .vertex2d vertex2d
	end virtual
        push    [.vertex2d.py]
        push    [.vertex2d.px]
        add     di,2
        mov     bx,[di]
        shl     bx,2
        push    [.vertex2d.py]
        push    [.vertex2d.px]
        invoke    line
        dec     al
        jnz     .drawset
        push    di
        mov     di,dx
        mov     bx,[di]
        pop     di
        shl     bx,2
        push    [color]
        push    [.vertex2d.py]
        push    [.vertex2d.px]
        mov     bx,[di]
        shl     bx,2
        push    word [bx+si+2]
        push    word [bx+si]
        invoke   line
        add     di,2
        dec     cx
        jnz     .draw
        ret
endp 

;affiche liste vertex %0
proc draw3d_hidden uses ax bx cx dx si di, type:word,faces:word,vertex3d:word,vertex2d:word,camera:word,color:word
        local   a1:WORD,a2:WORD,b1:WORD
        mov     di,[faces]
        mov     si,[vertex2d]
        stdcall    project,si,[vertex3d],[camera]
        mov     cx,[di]
        inc     si
        inc     si
        inc     di
        inc     di
.draw:
        push    cx
        mov     si,[vertex2d]
        inc     si
        inc     si
        mov     bx,[di+2]
        shl     bx,2
	virtual at bx+si
	    .vertex2d vertex2d
	end virtual
        mov     cx,[.vertex2d.px]
        mov     dx,[.vertex2d.py]
        mov     bx,[di]
        shl     bx,2
        mov     ax,[.vertex2d.px]
        sub     ax,cx
        mov     [a1],ax
        mov     ax,[.vertex2d.py]
        sub     ax,dx
        mov     [b1],ax
        mov     bx,[di+4]
        shl     bx,2
        mov     ax,[.vertex2d.px]
        sub     ax,cx
        mov     [a2],ax
        mov     ax,[.vertex2d.py]
        sub     ax,dx
        xor     edx,edx
        imul    [a1]
        and     eax,0FFFFh
        rol     eax,16
        add     eax,edx
        rol     eax,16
        mov     ecx,eax
        mov     ax,[b1]
        imul    [a2]
        and     eax,0FFFFh
        rol     eax,16
        add     eax,edx
        rol     eax,16
        sub     ecx,eax
        pop     cx
        jge     .nohidden
        mov    ax,[type]
        shl    ax,1
        add    di,ax
        dec    cx
        jnz    .draw
        jmp    .endof
.nohidden:
        mov     ax,[type]
        dec     al
        mov     dx,di
.drawset:
        mov     bx,[di]
        shl     bx,2
        push    [color]
        push    [.vertex2d.py]
        push    [.vertex2d.px]
        add     di,2
        mov     bx,[di]
        shl     bx,2
        push    [.vertex2d.py]
        push    [.vertex2d.px]
        invoke  line
        dec     al
        jnz     .drawset
        push    di
        mov     di,dx
        mov     bx,[di]
        pop     di
        shl     bx,2
        push    [color]
        push    [.vertex2d.py]
        push    [.vertex2d.px]
        mov     bx,[di]
        shl     bx,2
        push    word [bx+si+2]
        push    word [bx+si]
        invoke  line
        add     di,2
        dec     cx
        jnz     .draw
.endof:
        ret
endp 

;creer table pour face caché %0
proc draw3d_hidden_fill uses eax bx ecx edx si di, type:word,faces:word,vertex3d:word,vertex2d:word,camera:word,color:word
        local   a1:WORD,a2:WORD,b1:WORD
        mov     di,[faces]
        stdcall    project,[vertex2d],[vertex3d],[camera]
        mov     cx,[di]
        inc     di
        inc     di
.calculvect:
        push    cx
        mov     si,[vertex2d]
        inc     si
        inc     si
        mov     bx,[di+2]
        shl     bx,2
	virtual at bx+si
	    .vertex2d vertex2d
	end virtual
        mov     cx,[.vertex2d.px]   
        mov     dx,[.vertex2d.py] 
        mov     bx,[di]
        shl     bx,2
        mov     ax,[.vertex2d.px] 
        sub     ax,cx
        mov     [a1],ax
        mov     ax,[.vertex2d.py] 
        sub     ax,dx
        mov     [b1],ax
        mov     bx,[di+4]
        shl     bx,2
        mov     ax,[.vertex2d.px] 
        sub     ax,cx
        mov     [a2],ax
        mov     ax,[.vertex2d.py] 
        sub     ax,dx
        xor     edx,edx
        imul    [a1]
        rol     eax,16
        add     eax,edx
        rol     eax,16
        mov     ecx,eax
        mov     ax,[b1]
        imul    [a2]
        rol     eax,16
        add     eax,edx
        rol     eax,16
        sub     ecx,eax
        pop     cx
        jl      .hidden
        mov     ax,[type]
        mov     si,[vertex3d]
        inc     si
        inc     si
        fld     [cs:zero]
.calcz:
        mov     bx,[di]
        mov     dx,bx
        shl     dx,2
        shl     bx,3
        add     bx,dx
	virtual at bx+si
	    .vertex3d vertex3d
	end virtual
        fadd    [.vertex3d.tz]
        add     di,2
        dec     al
        jnz     .calcz
.hidden:
        mov    ax,[type]
        shl    ax,1
        add    di,ax
.enofvalue:
        dec    cx
        jnz    .calculvect
        ret
endp


;charge un fichier 3ds logé en %0 renvoie error
;sauvegarde en :
;- %1 le nom de l'objet
;- %2 les vertex 3D de l'objet
;- %3 la matrice de transformation de l'objet
;- %4 les faces de l'objet
;- %5 le type de face de l'objet
;1 non 3ds
;2 non 3 et >
proc load3ds uses eax bx cx si di ds es fs, seg:word,addt:word,objectname:word,vertex:word,matrix:word,face:word
        push    ds
        pop     fs
        mov     si,[addt]
        mov     ds,[seg]
        cmp     word [si],main
        jne     .error1
        cmp     word [si+28],3
        jb      .error2
.reading:
        mov     ax,[si]
        mov     bx,[si+2]
        cmp     ax,main
        je      .enter
        cmp     ax,edit
        je      .enter
        cmp     ax,mesh
        je      .enter
        cmp     ax,object
        je      .readobject
        cmp     ax,vertex
        je      .readvertex
        cmp     ax,locale
        je      .readmatrix
        cmp     ax,face
        je      .readfaces
.next:
	add si,bx
        jmp     .reading        
.enter:
        add     si,6
        jmp     .reading       
.readobject:
        add     si,6
        mov     di,si
        mov     al,0
        mov     es,[seg]
        mov     cx,12
        cld
        repne   scasb
        mov     cx,di
        sub     cx,si
        mov     di,[objectname]
        push    fs
        pop     es
        cld
        rep     movsb
        jmp     .reading        
.readvertex:
        add     si,6
        mov     ax,[si]
        mov     di,[vertex]
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
        jmp     .reading
.readmatrix:
        add     si,6
        mov     di,[matrix]
        mov     eax,[si]
	virtual at di
	.mat mat
	end virtual
        mov     [fs:.mat.p1],eax
        mov     eax,[si+4*1]
        mov     [fs:.mat.p5],eax
        mov     eax,[si+4*2]
        mov     [fs:.mat.p9],eax
        mov     eax,[si+4*3]
        mov     [fs:.mat.p2],eax
        mov     eax,[si+4*4]
        mov     [fs:.mat.p6],eax
        mov     eax,[si+4*5]
        mov     [fs:.mat.p10],eax
        mov     eax,[si+4*6]
        mov     [fs:.mat.p3],eax
        mov     eax,[si+4*7]
        mov     [fs:.mat.p7],eax
        mov     eax,[si+4*8]
        mov     [fs:.mat.p11],eax
        mov     eax,[si+4*9]
        mov     [fs:.mat.p4],eax
        mov     eax,[si+4*10]
        mov     [fs:.mat.p8],eax
        mov     eax,[si+4*11]
        mov     [fs:.mat.p12],eax
        mov     eax,[cs:un]
        mov     [fs:.mat.p16],eax
        mov     eax,0
        mov     [fs:.mat.p13],eax
        mov     [fs:.mat.p14],eax
        mov     [fs:.mat.p15],eax
        add     si,12*4
        jmp     .reading        
.readfaces:
        add     si,6
        mov     ax,[si]
        mov     di,[face]
        mov     [fs:di],ax
        inc     si
        inc     si
        add     di,2
        push    fs
        pop     es
        cld
.readall:
        mov     cx,3
        rep     movsw
        inc     si
        inc     si
        dec     ax
        jnz     .readall
        ;;jmp     .reading
.error1:
.error2:
        ret
endp

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
proc translate uses eax ecx di es, mat:word,x:dword,y:dword,z:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     eax,[x]
        mov     [di+3*4],eax
        mov     eax,[y]
        mov     [di+7*4],eax
        mov     eax,[z]
        mov     [di+11*4],eax
        ret
endp 

;initialise une matrice de translation pour une translation TX %1 dans MATRICE %0
;  mat[ 0] = 1.0
;  mat[ 5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  mat[ 3] = value
;  mat[ 7] = 1
;  mat[11] = 1
proc translatex uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     [di+7*4],eax
        mov     [di+11*4],eax
        mov     eax,[value]
        mov     [di+3*4],eax
        ret
endp


;initialise une matrice de translation pour une translation TY %1 dans MATRICE %0
;  mat[ 0] = 1.0
;  mat[ 5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  mat[ 3] = 1
;  mat[ 7] = value
;  mat[11] = 1
proc translatey uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     [di+3*4],eax
        mov     [di+11*4],eax
        mov     eax,[value]
        mov     [di+7*4],eax
        ret
endp 

;initialise une matrice de translation pour une translation TZ %1 dans MATRICE %0
;  mat[ 0] = 1.0
;  mat[ 5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  mat[ 3] = 1
;  mat[ 7] = 1
;  mat[11] = value
proc translatez uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        mov     [di+3*4],eax
        mov     [di+7*4],eax
        mov     eax,[value]
        mov     [di+11*4],eax
        ret
endp 

;initialise une matrice d'echelle %0 de facteur (x,y,z) %1-%3
;  mat[ 0] = factorx
;  mat[ 5] = factory
;  mat[10] = factorz
;  mat[15] = 1.0
;  reste a 0
proc scale uses eax ecx di es, mat:word,x:dword,y:dword,z:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        mov     eax,[x]
        mov     [di+0*4],eax
        mov     eax,[y]
        mov     [di+5*4],eax
        mov     eax,[z]
        mov     [di+10*4],eax
        mov     eax,[cs:un]
        mov     [di+15*4],eax
        ret
endp

;initialise une matrice d'echelle %0 de facteur value %1
;  mat[ 0] = factor
;  mat[ 5] = factor
;  mat[10] = factor
;  mat[15] = 1.0
;  reste a 0
proc rescale uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        mov     eax,[value]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     eax,[cs:un]
        mov     [di+15*4],eax
        ret
endp 

;copy une matrice %0 en %1
;mat2=mat1
proc copy uses ecx si di es, mat1:word,mat2:word
        mov     si,[mat1]
        mov     di,[mat2]
        mov     ecx,16
        push    ds
        pop     es
        cld
        rep     stosd
        ret
endp 

;initialise une matrice %0 avec la valeur %1
;mat[i]=value
proc fill uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     eax,[value]
        mov     ecx,16
        push    ds
        pop     es
        cld
        rep     stosd
        ret
endp

;initialise une matrice d'identité %0
;  mat[0] = 1.0
;  mat[5] = 1.0
;  mat[10] = 1.0
;  mat[15] = 1.0
;  reste a 0
proc identity uses eax ecx di es, mat:word
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        mov     eax,[cs:un]
        mov     [di+0*4],eax
        mov     [di+5*4],eax
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        ret
endp


;initialise une matrice de rotation %0 autour de X de %1 degrees
;  mat[ 5] =  cos(angle)
;  mat[ 6] = -sin(angle)
;  mat[ 9] =  sin(angle)
;  mat[10] =  cos(angle)
;  mat[ 0] = 1.0
;  mat[15] = 1.0
;  reste a 0
proc rotationx uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        fld     [value]
        fsincos
;mat[ 5] =  cos(angle);
        fst     dword [di+5*4]
;mat[ 10] =  cos(angle);
        fstp    dword [di+10*4]
;mat[ 9] =  sin(angle);
        fst     dword [di+9*4]
;mat[ 6] =  -sin(angle);
        fchs
        fstp    dword [di+6*4]
;mat[ 0] = 1.0
;mat[15] = 1.0
         mov    eax,[cs:un]
         mov    [di+0*4],eax
         mov    [di+15*4],eax
         ret
endp

;initialise une matrice de rotation BX autour de Y de %0 degrees
;  mat[ 0] =  cos(angle)
;  mat[ 8] = -sin(angle)
;  mat[ 2] =  sin(angle)
;  mat[10] =  cos(angle)
;  mat[ 5] = 1.0
;  mat[15] = 1.0
;  reste a 0
proc rotationy uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        fld     [value]
        fsincos
;mat[ 0] =  cos(angle)
        fst     dword [di+0*4]
;mat[ 10] =  cos(angle)
        fstp    dword [di+10*4]
;mat[ 2] =  sin(angle)
        fst     dword [di+2*4]
        fchs
;mat[ 8] =  -sin(angle)
        fstp    dword [ di+8*4]
;mat[ 5] = 1.0
;mat[15] = 1.0
        mov     eax,[cs:un]
        mov     [di+5*4],eax
        mov     [di+15*4],eax
        ret
endp

;initialise une matrice de rotation %0 autour de Z de %1 degrees
;  mat[ 0] =  cos(angle)
;  mat[ 1] = -sin(angle)
;  mat[ 4] =  sin(angle)
;  mat[ 5] =  cos(angle)
;  mat[10] = 1.0
;  mat[15] = 1.0
;  reste a 0
proc rotationz uses eax ecx di es, mat:word,value:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
        fld     [value]
        fsincos
;mat[ 0] =  cos(angle)
        fst     dword [ di+0*4]
;mat[ 5] =  cos(angle)
        fstp    dword [ di+5*4]
;mat[ 4] =  sin(angle)
        fst     dword [ di+4*4]
        fchs
;mat[ 1] =  -sin(angle)
        fstp    dword [ di+1*4]
;mat[10] = 1.0
;mat[15] = 1.0
        mov     eax,[cs:un]
        mov     [di+10*4],eax
        mov     [di+15*4],eax
        ret
endp

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
proc rotation uses eax ecx di es, mat:word,anglex:dword,angley:dword,anglez:dword
        mov     di,[mat]
        mov     ecx,16
        mov     eax,0
        push    ds
        pop     es
        cld
        rep     stosd
        mov     di,[mat]
;st1 sin(angleZ)
;st2 cos(angleZ)
;st3 sin(angleY)
;st4 cos(angleY)
;st5 sin(angleX)
;st6 cos(angleX)
        fld     [anglex]
        fsincos
        fld     [angley]
        fsincos
        fld     [anglez]
        fsincos
;Cos(angleY)*Cos(angleZ)
        fld     st3
        fmul    st0,st2
;mat[0]
        fstp    dword [ di+0*4]
;Cos(angleY)*Sin(angleZ)
        fld     st3
        fmul    st0,st1
;mat[1]
        fstp    dword [ di+1*4]
;-Sin(angley)
        fld     st2
        fchs
;mat[2]
        fstp    dword [ di+2*4]
        mov     eax,[cs:un]
        mov     [di+15*4],eax
        ret
endp


factor dd 128.0

;Transforme la liste de vertex 3D pointé par %0 en vertex 2D dans %1 en utilisant %2 comme origine pour %3 valeurs
;    vertex2d[i].px=int((vertex3d[i].tx*factor)/(vertex3d[i].tz+origin.Z)+origin.X)
;    vertex2d[i].py=int((vertex3d[i].ty*factor)/(vertex3d[i].tz+origin.Z)+origin.Y)
proc project uses bx cx si di, vertex2d:word,vertex3d:word,origin:word
        mov     si,[vertex3d]
        mov     bx,[vertex2d]
        mov     di,[origin]
        mov     cx,[si]
        mov     [bx],cx
        inc     si
        inc     si
        inc     bx
        inc     bx
.boucle:
	virtual at 0
		.vertex3d vertex3d
	end virtual
	virtual at 0
		.vertex2d vertex2d
	end virtual
	virtual at si
		.vertex3dsrc vertex3d
	end virtual
	virtual at di
		.vertex3ddst vertex3d
	end virtual
	virtual at bx
		.vertex2dsrc vertex2d
	end virtual
;(vertex3d[i].z+origZ)
        fld     [.vertex3dsrc.tz]
        fadd    [.vertex3ddst.tz]
;(vertex3d[i].tx*factor)
        fld     [.vertex3dsrc.tx]
        fmul    [cs:factor]
;(vertex3d[i].tx*factor)/(vertex3d[i].tz+origZ)
        fdiv    st,st1
;(vertex3d[i].tx*factor)/(vertex3d[i].tz+origZ)+origX
        fadd    [.vertex3ddst.tx]
;vertex2d[i].tx=int((vertex3d[i].tx*factor)/(vertex3d[i].tz+origZ)+origX)
        fistp   [.vertex2dsrc.px] 
;(vertex3d[i].z+origZ)
;(vertex3d[i].ty*factor)
        fld     [.vertex3dsrc.ty]
        fmul    [cs:factor]
;(vertex3d[i].ty*factor)/(vertex3d[i].tz+origZ)
        ;fdivrp  st1
;(vertex3d[i].ty*factor)/(vertex3d[i].tz+origZ)+origY
        fadd    [.vertex3ddst.ty]
;vertex2d[i].ty=int((vertex3d[i].ty*factor)/(vertex3d[i].tz+origZ)+origY)
        fistp   [.vertex2dsrc.py]
        add     si,.vertex3d.sizeof
        add     bx,.vertex2d.sizeof
        dec     cx
        jnz     .boucle
        ret
endp


;transforme les points %0 avec la matrice %1

; vertex3d_2 = mat * vertex3d

;  w                = mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty + mat[14]*vertex3d[i].tz + mat[15]
;  vertex3d_2[i].tx = mat[ 0]*vertex3d[i].tx + mat[ 1]*vertex3d[i].ty + mat[ 2]*vertex3d[i].tz + mat[ 3]
;  vertex3d_2[i].ty = mat[ 4]*vertex3d[i].tx + mat[ 5]*vertex3d[i].ty + mat[ 6]*vertex3d[i].tz + mat[ 7]
;  vertex3d_2[i].tz = mat[ 8]*vertex3d[i].tx + mat[ 9]*vertex3d[i].ty + mat[10]*vertex3d[i].tz + mat[11]
proc transform uses cx si di, vertex3d:word,mat:word
        mov     si,[vertex3d]
        mov     cx,[si]
        inc     si
        inc     si
        mov     di,[mat]
.boucle:
;Calcul du facteur echelle
;mat[12]*vertex3d[i].tx
	virtual at si
		.vertex3d vertex3d
	end virtual
        fld     [.vertex3d.tx]
        fmul    dword [ di+12*4]
;mat[13]*vertex3d[i].ty
        fld     [.vertex3d.ty]
        fmul    dword [ di+13*4]
;mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty
        ;faddp    st1
;mat[14]*vertex3d.tz
        fld      [.vertex3d.tz]
        fmul     dword [ di+14*4]
;mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty + mat[14]*vertex3d[i].tz
        ;faddp    st1
;mat[12]*vertex3d[i].tx + mat[13]*vertex3d[i].ty + mat[14]*vertex3d[i].tz + mat[15]
        fadd     dword [ di+15*4]
;w=0.0 ??
        ftst
;-> AX
        fstsw    ax

;vertex3d.tx vertex3d.ty et vertex3d.tz
        fld      [.vertex3d.tx]
        fmul     dword [ di+0*4]
        fld      [.vertex3d.ty]
        fmul     dword [ di+1*4]
        ;faddp    st1
        fld      [.vertex3d.tz]
        fmul     dword [ di+2*4]
        ;faddp    st1
        fadd     dword [ di+3*4]

        fld      [.vertex3d.tx]
        fmul     dword [ di+4*4]
        fld      [.vertex3d.ty]
        fmul     dword [ di+5*4]
        ;faddp    st1
        fld      [.vertex3d.tz]
        fmul     dword [ di+6*4]
        ;faddp    st1
        fadd     dword [ di+7*4]

        fld      [.vertex3d.tx]
        fmul     dword [ di+8*4]
        fld      [.vertex3d.ty]
        fmul     dword [ di+9*4]
        ;faddp    st1
        fld      [.vertex3d.tz]
        fmul     dword [ di+10*4]
        ;faddp    st1
        fadd     dword [ di+11*4]

;w=0.0
        sahf
        jz       .divby0
;vertex3d.tx=vertex3d[i].tz/w
        fdiv     st,st3
        fstp     [.vertex3d.tz]
;vertex3d.ty=vertex3d[i].ty/w
        fdiv     st,st2
        fstp     [.vertex3d.ty]
;vertex3d.tz=vertex3d[i].tx/w
        fdivrp   st1,st
        fstp     [.vertex3d.tx]
;No div by 0
        jmp      .nodiv
.divby0:
        fstp     [.vertex3d.tz]
        fstp     [.vertex3d.ty]
        fstp     [.vertex3d.tx]
        ;ffree
.nodiv:
	virtual at 0
	.vertex3dori vertex3d
	end virtual
        add      si,.vertex3dori.sizeof
        dec      cx
        jnz      .boucle
        ret
endp

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

proc multiply uses bx si di, p1:word,p2:word,mat:word
        mov     si,[p1]
        mov     di,[p2]
        mov     bx,[mat]
;0,0
;p1[ 0]*p2[ 0]
        fld     dword [ si+0*4]
        fmul    dword [ di+0*4]
;p1[ 1]*p2[ 4]
        fld     dword [ si+1*4]
        fmul    dword [ di+4*4]
;(p1[ 0]*p2[ 0])+(p1[ 1]*p2[ 4])
        ;;faddp   st1
;p1[ 2]*p2[ 8]
        fld     dword [ si+2*4]
        fmul    dword [ di+8*4]
;(p1[ 0]*p2[ 0])+(p1[ 1]*p2[ 4])+(p1[ 2]*p2[ 8])
        ;;faddp   st1
;p1[ 3]*p2[12]
        fld     dword [ si+3*4]
        fmul    dword [ di+12*4]
;(p1[ 0]*p2[ 0])+(p1[ 1]*p2[ 4])+(p1[ 2]*p2[ 8])+(p1[ 3]*p2[12])
        ;;faddp   st1
        fstp    dword [ bx+0*4]
;mat[ 0]

;1,0
        fld     dword [ si+0*4]
        fmul    dword [ di+1*4]
        fld     dword [ si+1*4]
        fmul    dword [ di+5*4]
        ;faddp   st1
        fld     dword [ si+2*4]
        fmul    dword [ di+9*4]
        ;faddp   st1
        fld     dword [ si+3*4]
        fmul    dword [ di+13*4]
        ;faddp   st1
        fstp    dword [ bx+1*4]
;2,0
        fld     dword [ si+0*4]
        fmul    dword [ di+2*4]
        fld     dword [ si+1*4]
        fmul    dword [ di+6*4]
        ;faddp   st1
        fld     dword [ si+2*4]
        fmul    dword [ di+10*4]
        ;faddp   st1
        fld     dword [ si+3*4]
        fmul    dword [ di+14*4]
        ;faddp   st1
        fstp    dword [ bx+2*4]
;3,0
        fld     dword [ si+0*4]
        fmul    dword [ di+3*4]
        fld     dword [ si+1*4]
        fmul    dword [ di+7*4]
        ;faddp   st1
        fld     dword [ si+2*4]
        fmul    dword [ di+11*4]
        ;faddp   st1
        fld     dword [ si+3*4]
        fmul    dword [ di+15*4]
        ;faddp   st1
        fstp    dword [ bx+3*4]
;0,1
        fld     dword [ si+4*4]
        fmul    dword [ di+0*4]
        fld     dword [ si+5*4]
        fmul    dword [ di+4*4]
        ;faddp   st1
        fld     dword [ si+6*4]
        fmul    dword [ di+8*4]
        ;faddp   st1
        fld     dword [ si+7*4]
        fmul    dword [ di+12*4]
        ;faddp   st1
        fstp    dword [ bx+4*4]
;1,1
        fld     dword [ si+4*4]
        fmul    dword [ di+1*4]
        fld     dword [ si+5*4]
        fmul    dword [ di+5*4]
        ;faddp   st1
        fld     dword [ si+6*4]
        fmul    dword [ di+9*4]
        ;faddp   st1
        fld     dword [ si+7*4]
        fmul    dword [ di+13*4]
        ;faddp   st1
        fstp    dword [ bx+5*4]
;2,1
        fld     dword [ si+4*4]
        fmul    dword [ di+2*4]
        fld     dword [ si+5*4]
        fmul    dword [ di+6*4]
        ;faddp   st1
        fld     dword [ si+6*4]
        fmul    dword [ di+10*4]
        ;faddp   st1
        fld     dword [ si+7*4]
        fmul    dword [ di+14*4]
        ;faddp   st1
        fstp    dword [ bx+6*4]
;3,1
        fld     dword [ si+4*4]
        fmul    dword [ di+3*4]
        fld     dword [ si+5*4]
        fmul    dword [ di+7*4]
        ;faddp   st1
        fld     dword [ si+6*4]
        fmul    dword [ di+11*4]
        ;faddp   st1
        fld     dword [ si+7*4]
        fmul    dword [ di+15*4]
        ;faddp   st1
        fstp    dword [ bx+7*4]
;0,2
        fld     dword [ si+8*4]
        fmul    dword [ di+0*4]
        fld     dword [ si+9*4]
        fmul    dword [ di+4*4]
        ;faddp   st1
        fld     dword [ si+10*4]
        fmul    dword [ di+8*4]
        ;faddp   st1
        fld     dword [ si+11*4]
        fmul    dword [ di+12*4]
        ;faddp   st1
        fstp    dword [ bx+8*4]
;1,2
        fld     dword [ si+8*4]
        fmul    dword [ di+1*4]
        fld     dword [ si+9*4]
        fmul    dword [ di+5*4]
        ;faddp   st1
        fld     dword [ si+10*4]
        fmul    dword [ di+9*4]
        ;faddp   st1
        fld     dword [ si+11*4]
        fmul    dword [ di+13*4]
        ;faddp   st1
        fstp    dword [ bx+9*4]
;2,2
        fld     dword [ si+8*4]
        fmul    dword [ di+2*4]
        fld     dword [ si+9*4]
        fmul    dword [ di+6*4]
        ;faddp   st1
        fld     dword [ si+10*4]
        fmul    dword [ di+10*4]
        ;faddp   st1
        fld     dword [ si+11*4]
        fmul    dword [ di+14*4]
        ;faddp   st1
        fstp    dword [ bx+10*4]
;3,2
        fld     dword [ si+8*4]
        fmul    dword [ di+3*4]
        fld     dword [ si+9*4]
        fmul    dword [ di+7*4]
        ;faddp   st1
        fld     dword [ si+10*4]
        fmul    dword [ di+11*4]
        ;faddp   st1
        fld     dword [ si+11*4]
        fmul    dword [ di+15*4]
        ;faddp   st1
        fstp    dword [ bx+11*4]
;0,3
        fld     dword [ si+12*4]
        fmul    dword [ di+0*4]
        fld     dword [ si+13*4]
        fmul    dword [ di+4*4]
        ;faddp   st1
        fld     dword [ si+14*4]
        fmul    dword [ di+8*4]
        ;faddp   st1
        fld     dword [ si+15*4]
        fmul    dword [ di+12*4]
        ;faddp   st1
        fstp    dword [ bx+12*4]
;1,3
        fld     dword [ si+12*4]
        fmul    dword [ di+1*4]
        fld     dword [ si+13*4]
        fmul    dword [ di+5*4]
        ;faddp   st1
        fld     dword [ si+14*4]
        fmul    dword [ di+9*4]
        ;faddp   st1
        fld     dword [ si+15*4]
        fmul    dword [ di+13*4]
        ;faddp   st1
        fstp    dword [ bx+13*4]
;2,3
        fld     dword [ si+12*4]
        fmul    dword [ di+2*4]
        fld     dword [ si+13*4]
        fmul    dword [ di+6*4]
        ;faddp   st1
        fld     dword [ si+14*4]
        fmul    dword [ di+10*4]
        ;faddp   st1
        fld     dword [ si+15*4]
        fmul    dword [ di+14*4]
        ;faddp   st1
        fstp    dword [ bx+14*4]
;3,3
        fld     dword [ si+12*4]
        fmul    dword [ di+3*4]
        fld     dword [ si+13*4]
        fmul    dword [ di+7*4]
        ;faddp   st1
        fld     dword [ si+14*4]
        fmul    dword [ di+11*4]
        ;faddp   st1
        fld     dword [ si+15*4]
        fmul    dword [ di+15*4]
        ;faddp   st1
        fstp    dword [ bx+15*4]
        ret
endp
