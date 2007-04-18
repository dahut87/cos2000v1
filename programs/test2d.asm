model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\fat.h"
include "..\include\divers.h"
include "..\include\3d.h"

org 0h

start:
header exe <"CE",1,0,0,,offset imports,,offset realstart>

realstart:
    call      [cs:randomize]
    call      [cs:savestate]
    call      [cs:setvideomode],10
    call      [cs:clearscreen]
    mov       cx,65535
show:
    call      [cs:random]
    and       ax,1111b
    push      ax
    call      [cs:random]
    push      ax
    call      [cs:random]
    push      ax
    call      [cs:random]
    push      ax
    call      [cs:random]
    push      ax
    call      [cs:line]
    dec       cx
    jnz       show
    call      [cs:bioswaitkey]
    call      [cs:restorestate]
    retf

importing
use VIDEO.LIB,print
use VIDEO,savestate
use VIDEO,clearscreen
use VIDEO,setvideomode
use VIDEO,restorestate
use VIDEO,waitretrace
use GRAPHIC,line     ;@x1:word,@y1:word,@x2:word,@y2:word,@color:word
use GRAPHIC,polyfill ;@pointer:word,@nbfaces:word,@color:word;
use SYSTEME,bioswaitkey
use MATH.LIB,randomize
use MATH.LIB,random
endi
