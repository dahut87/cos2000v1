use16
align 1

include "..\include\mem.h"
include "..\include\fat.h"
include "..\include\divers.h"
include "..\include\3d.h"

org 0h

header exe 1,0,imports,0,realstart

realstart:
    invoke      randomize
    invoke      savestate
    invoke      setvideomode,10
    invoke      clearscreen
    mov       cx,65535
show:
    invoke      random
    and       ax,1111b
    push      ax
    invoke      random
    push      ax
    invoke      random
    push      ax
    invoke      random
    push      ax
    invoke      random
    push      ax
    invoke      line
    dec       cx
    jnz       show
    invoke      bioswaitkey
    invoke      restorestate
    ret

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
