.model tiny
.486
smart
.code

org 0100h

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
push ds es
pusha
mov ax,40h
mov es,ax
mov ax,0B800h
mov ds,ax
mov word ptr dx,es:[8]

in al,dx
mov di,158
decompose:
mov cl,al
and cl,1
cmp cl,1
je un
mov byte ptr ds:[di],'0'
jmp errr
un:
mov byte ptr ds:[di],'1'
errr:
shr al,1
dec di
dec di    
cmp di,142
jne decompose

inc dx
in al,dx
mov di,318
decompose2:
mov cl,al
and cl,1
cmp cl,1
je un2
mov byte ptr ds:[di],'0'
jmp errr2
un2:
mov byte ptr ds:[di],'1'
errr2:
cmp di,314
jb errrr
mov byte ptr ds:[di],'X'
errrr:
shr al,1
dec di
dec di    
cmp di,302
jne decompose2
popa
pop es ds









        pop es bx ax
        sti
        iret
        compteur dw 0
        fig db 'Ä\³/'      
end start
