.model tiny
.486
smart
.code

org 0100h

start:
mov si,offset essai
call whatis0


	mov	si,offset pop1
	mov	di,offset pop2
	call	checksyntax0
ret

essai db '#',0
pop1 db 'essai 0FFh',0
pop2 db 'ESSAI 012H',0
        include str0.asm



end start
