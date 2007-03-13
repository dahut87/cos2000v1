.model tiny
.486
smart
locals
.code
org 0h

include ..\include\mem.h
include ..\include\bmp.h

start:
header exe <,1,0,,,,offset exports,>

exports:
         db "showbmp",0
         dw showbmp
         db "loadbmppalet",0
         dw loadbmppalet
         dw 0
         
         
;==========SHOWBMP=========
;Affiche le BMP pointée par DS:%0 en %1, %2
;<- DS:%0 BMP, %1 coordonnées X, %2 coordonnées Y
;->
;==========================
showbmp PROC FAR
        ARG     pointer:word, x:word, y:word=taille
        push    bp
        mov     bp,sp
	push 	ax bx cx dx si di
	mov     si,[pointer]
	cmp	word ptr [si+BMP_file.BMP_FileType],"MB"
	jne     @@errorshowing
	mov     edi,[si+BMP_BitMapOffset]
	add     di,si
        mov     ah,8
       	xor 	ebx,ebx
        mov     ecx,[si+offset BMP_File.BMP_height]
       	mov 	edx,[si+offset BMP_File.BMP_width]
        and     dx,11111100b
       	cmp     edx,[si+offset BMP_File.BMP_width]
       	jae     @@noadjust
       	add     dx,4
@@noadjust:
        sub     dx,[si+offset BMP_File.BMP_width]
@@bouclette:
	mov 	al,[di]	
	push 	bx cx
	add 	bx,[x]
	add 	cx,[y]
        int     47h
	pop 	cx bx
	inc 	bx
	inc     di
	cmp 	ebx,[si+offset BMP_File.BMP_width]
	jb 	@@bouclette
	xor 	bx,bx
	add     di,dx
	dec 	cx
	cmp 	cx,0
	jne 	@@bouclette
	clc
	pop 	di si dx cx bx ax
	pop     bp
	retf    taille
	
@@errorshowing:
        stc
        pop     di si cx bx ax
       	pop     bp
       	retf    taille
        
showbmp ENDP


;==========LOADBMPPALET=========
;Charge la palette du BMP pointée par DS:%0
;-> DS:%0 BMP
;<-
;===============================
loadbmppalet PROC FAR
        ARG     pointer:word=taille
        push    bp
        mov     bp,sp
        push    ax bx cx dx si
        mov     si,[pointer]
	mov 	bx,0400h+36h-4
	mov 	cx,100h
	mov 	dx, 3c8h
paletteload:
	mov 	al, cl
	dec 	al
	out 	dx, al
	inc 	dx
	mov 	al,[bx+si+2]
	shr 	al,2
	out 	dx, al
	mov 	al,[bx+si+1]
	shr 	al,2
	out 	dx, al
	mov 	al,[bx+si]
	shr 	al,2
	out 	dx, al
	sub 	bx,4
	dec 	dx
	dec 	cl
	jnz 	paletteload
       	pop 	si dx cx bx ax
	pop     bp
	retf    taille
loadbmppalet ENDP

end start
