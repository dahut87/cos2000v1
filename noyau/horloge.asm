.model tiny
.486
smart
.code

org 0h

start:

jmp tsr
offsets dd 0
db 'TIMER'
tsr:
 pushf
 db  2eh,0ffh,1eh
 dw  offsets
        cli
        push ax bx es
        mov bx,cs:compteur
        inc bx
        and bx,11b
        mov cs:compteur,bx
        mov bx,cs:[offset fig+bx]
        mov ax,0B800h
        mov es,ax
        mov es:[0],bl						
        pop es bx ax
        sti
       iret
compteur dw 0
fig db 'Ä\³/'      
end start
