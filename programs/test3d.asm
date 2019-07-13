use16
align 1

include "..\include\mem.h"
include "..\include\fat.h"
include "..\include\divers.h"
include "..\include\3d.h"

org 0h

start:
header exe 1

alldata:
camera vertex3d 320.0,240.0,70.0

zoom dd 5.0
rot1 dd 0.1
rot2 dd -0.1

vertexnbp dw 15
dd 0.0,0.0,0.0
dd 20.0,0.0,0.0
dd 24.0,0.0,0.0
dd 20.0,-2.0,0.0
dd 20.0,2.0,0.0
dd 0.0,0.0,0.0
dd 0.0,20.0,0.0
dd 0.0,24.0,0.0
dd -2.0,20.0,0.0
dd 2.0,20.0,0.0
dd 0.0,0.0,0.0
dd 0.0,0.0,20.0
dd 0.0,0.0,24.0
dd -2.0,-2.0,20.0
dd 2.0,2.0,20.0

facenbp dw 6
dw 0,1,1
dw 2,4,3
dw 5,6,6
dw 7,9,8
dw 10,11,11
dw 12,14,13

vertexnbp2 dw 15
dd 0.0,0.0,0.0
dd 20.0,0.0,0.0
dd 24.0,0.0,0.0
dd 20.0,-2.0,0.0
dd 20.0,2.0,0.0
dd 0.0,0.0,0.0
dd 0.0,20.0,0.0
dd 0.0,24.0,0.0
dd -2.0,20.0,0.0
dd 2.0,20.0,0.0
dd 0.0,0.0,0.0
dd 0.0,0.0,20.0
dd 0.0,0.0,24.0
dd -2.0,-2.0,20.0
dd 2.0,2.0,20.0


mat1 mat 
mat2 mat 
mat3 mat 
matrixp mat

mode db 0

objectp:
vertexp equ objectp+15
facep   equ vertexp+20000
screen  equ facep+20000

realstart:
    invoke      savestate
    invoke      setvideomode,10
    invoke      clearscreen
    invoke      mballoc,65535
    mov       es,ax
    mov       si, alldata
    mov       di,si
    mov       ecx,( realstart- alldata)
    shr       ecx,2
    inc       ecx
    cld
    rep       movsd
    invoke      projfile, filename
    jc        errorloading
    invoke      mbfind, filename
    jc        errorloading
    push      es
    pop       ds
    mov       es,ax  
    invoke      load3ds,es,0, objectp, vertexp, matrixp, facep
    invoke      transform, vertexnbp, matrixp
    invoke      identity, mat1
    jmp       show
rool:
    mov       ah,1
    int       16h
    jz        rool
    xor       ax,ax
    int       16h
    cmp       ax,011Bh
    je        endee
    cmp       ax,3B00h
    jne       notmode
    inc       [mode]
    cmp       [mode],3
    jb        notmodify
    mov       [mode],0
    jmp       notmodify
notmode:
    cmp       ax,4800h
    jne       notup
    invoke      rotationx, mat1,[rot2]
    jmp       show
notup:
    cmp       ax,5000h
    jne       notdown
    invoke      rotationx, mat1,[rot1]
    jmp       show
notdown:
    cmp       ax,4B00h
    jne       notleft
    invoke      rotationy, mat1,[rot1]
    jmp       show
notleft:
    cmp       ax,4D00h
    jne       notright
    invoke      rotationy, mat1,[rot2]
    jmp       show
notright:
    cmp       ax,4900h
    jne       notupup
    invoke      rotationz, mat1,[rot1]
    jmp       show
notupup:
    cmp       ax,5100h
    jne       notdowndown
    invoke      rotationz, mat1,[rot2]
    jmp       show
notdowndown:
    cmp       ax,4A2Dh
    jne       notminus
    fld       [camera.tz]
    fsub      [zoom]
    fstp      [camera.tz]
    jmp       show
notminus:
    cmp       ax,4E2Bh
    jne       notmaxus
    fld       [camera.tz]
    fadd      [zoom]
    fstp      [camera.tz]
    jmp       show
notmaxus:
    invoke      identity, mat1
    jmp       rool
show:
    invoke      transform, vertexp, mat1
    invoke      transform, vertexnbp, mat1
notmodify:
    invoke      clearscreen
    invoke      print, objectp
    invoke      draw3d_line,3, facenbp, vertexnbp, screen, camera,3
    invoke      draw3d_line,3, facenbp, vertexnbp2, screen, camera,3
    cmp       [mode],0
    jne       line
    invoke      draw3d_point, vertexp, screen, camera,4
    jmp       retrace
line:
    cmp       [mode],1
    jne       hidden
    invoke      draw3d_line,3, facep, vertexp, screen, camera,4
    jmp       retrace
hidden:
    invoke      draw3d_hidden,3, facep, vertexp, screen, camera,4
retrace:
    invoke      waitretrace
    invoke      waitretrace
    jmp       rool
endee:
    invoke      restorestate
    retf

errorloading:
    push      cs
    pop       ds
    invoke      print, errorload
    invoke      bioswaitkey
    jmp       endee

errorload db '\c02Erreur au chargement du fichier 3D\l<Appuyez sur une touche>\c07',0

filename find "SPHERE.3DS"


importing
use 3D.LIB,draw3d_point
use 3D.LIB,draw3d_line
use 3D.LIB,draw3d_hidden
use 3D.LIB,draw3d_hidden_fill
use 3D.LIB,load3ds
use 3D.LIB,translate
use 3D.LIB,translatex
use 3D.LIB,translatey
use 3D.LIB,translatez
use 3D.LIB,scale
use 3D.LIB,rescale
use 3D.LIB,copy
use 3D.LIB,fill
use 3D.LIB,identity
use 3D.LIB,rotationx
use 3D.LIB,rotationy
use 3D.LIB,rotationz
use 3D.LIB,rotation
use 3D.LIB,project
use 3D.LIB,transform
use 3D.LIB,multiply
use VIDEO,savestate
use VIDEO,clearscreen
use VIDEO,setvideomode
use VIDEO,restorestate
use VIDEO,waitretrace
use SYSTEME,bioswaitkey
use SYSTEME,mbfind
use SYSTEME,mballoc
use VIDEO.LIB,print
use DISQUE,projfile
endi
