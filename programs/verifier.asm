.model tiny
.386c
.code
org 0h
             
                
include ..\include\mem.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
          mov      ah,28h
          int      47h
          push     offset msg
          call     [print]
          mov      bp,1000h
          xor      di,di
          xor      cx,cx
          xor      edx,edx
VerifAll:
          mov      ah,1
          int      16h
          jz       nokey
          cmp      al,' '
          je       enend
nokey:
          mov      dx,di
          push     edx
          mov      dx,cx
          inc      dx
          push     edx
          mov      ax,cx
          inc      ax
          mov      si,100
          mul      si
          mov      si,2880
          div      si
          mov      dx,ax
          push     edx
          push     offset msg2
          call     [print]
          call     gauge
          mov      ah,2
          int      48h
          jc       errors
          je       noprob
          inc      di
noprob:
          inc      cx
          cmp      cx,2880
          jnz      verifall
 enend:
          cmp      di,0
          je       noatall
          push     offset error2
          call     [print]
          jmp      someof
noatall:
          push     offset noerror
          call     [print]
someof:
          mov      ah,0
          int      16h
          mov      ah,29h
          int      47H
          retf
errors:
          push     offset error
          call     [print]
          mov      ah,0
          int      16h
          mov      ah,29h
          int      47H
          retf



error db '\g10,10Erreur avec le lecteur de disquette !',0
error2 db '\g10,10Le disque est defectueux, appuyez sur une touche pour quitter',0
noerror db '\g10,10Pas de secteurs defectueux, appuyez sur une touche pour continuer',0
msg db '\m02\e\c07\g29,00- Test de surface du disque -\g02,49<Pressez espace pour quitter>',0
msg2 db '\g10,20%u %%\g10,16%u cluster testes.    \h34%u cluster defectueux.    ',0

gauge:
             push     ax dx
             mov      ax,cx
             mul      sizeof
             div      max
             xor      edx,edx
             mov      dx,sizeof
             sub      dx,ax
             push     dx
             push     'Û'
             mov      dx,ax
             push     dx
             push     'Û'
             push     offset gauges
             call     [print]
             pop      dx ax
             retn

max      dw 2879
sizeof   dw 50

gauges db '\g10,18\c05%cM\c07%cM',0

imports:
        db "VIDEO.LIB::print",0
print   dd 0
        dw 0
        
End Start
