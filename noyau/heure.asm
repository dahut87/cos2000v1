.model tiny
.486
smart
.code

org 0h

start:

jmp tsr
offsets dd 0
db 'HOURS'
tsr:
 pushf
 db  2eh,0ffh,1eh
 dw  offsets
        cli
        pusha
        push ds es        
        push cs
        push cs
        pop ds
        pop es
        mov ah,22h
        mov di,offset infos
        int 47h
        mov bl,[infos+1]
        xor  bh,bh
        sub bl,8
        mov di,bx
        shl di,1
        mov dx,71h
        xor eax,eax
        mov     cx,0B800h
        mov     es,cx
        mov     cl,4
        mov     bp,8
show:
        dec dx
        mov al,cl
        out dx,al
        inc dx
        in al,dx
        call showbcd
        cmp cl,0
        je finic
        mov byte ptr es:[di],':'
        add di,2
        sub cl,2
       jmp show 
finic:
        pop es ds       
        popa     
        sti
       iret


;==============================Affiche le nombre nb hexa en EDX==============
Showbcd:
        push    ax bx cx edx
        mov     edx,eax
        mov     cx,bp
        sub     cx,32
        neg     cx
        shl     edx,cl
        mov     ax,bp
        shr     ax,2
bcdaize:
        rol     edx,4
        mov     bx,dx
        and     bx,0fh
        add     bl,'0'
        mov     es:[di],bl
        add     di,2
        dec     al
        jnz     bcdaize
        pop     edx cx bx ax
        ret
infos db 40 dup (0)

end start
