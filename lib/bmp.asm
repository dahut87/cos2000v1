use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"
include "..\include\bmp.h"

org 0h

header exe 1,exports,imports,0,0
         
exporting 
declare showbmp
declare loadbmppalet
ende

importing
use VIDEO,showpixel
endi
         
;==========SHOWBMP=========
;Affiche le BMP pointée par DS:%0 en %1, %2
;<- DS:%0 BMP, %1 coordonnées X, %2 coordonnées Y
;->
;==========================
proc showbmp uses ax bx cx dx si di, pointer:word, x:word, y:word
	mov     si,[pointer]
	virtual at si
	.bmp_file bmp_file
	end virtual
	cmp	word [.bmp_file.bmp_filetype],"MB"
	jne     .errorshowing
	mov     edi,[.bmp_file.bmp_bitmapoffset]
    add   di,400h
	add     di,si
       	xor 	ebx,ebx
        mov     ecx,[.bmp_file.bmp_height]
       	mov 	edx,[.bmp_file.bmp_width]
        ;and     dx,11111100b
       	cmp     edx,[.bmp_file.bmp_width]
       	;jae     .noadjust
       	;add     dx,4
.noadjust:
        sub     edx,[.bmp_file.bmp_width]
.bouclette:
	push 	bx cx
	add 	bx,[x]
	add 	cx,[y]
    invoke    showpixel,bx,cx,word [di]
	pop 	cx bx
	inc 	bx
	inc     di
	cmp 	ebx,[.bmp_file.bmp_width]
	jb 	  .bouclette
	xor 	bx,bx
	;add     di,dx
	dec 	cx
	cmp 	cx,0
	jne 	.bouclette
	clc
	ret  
.errorshowing:
        stc
       	ret
endp 


;==========LOADBMPPALET=========
;Charge la palette du BMP pointée par DS:%0
;-> DS:%0 BMP
;<-
;===============================
proc loadbmppalet uses ax bx cx dx si, pointer:word
        mov     si,[pointer]
	mov 	bx,0400h+36h-4
	mov 	cx,100h
	mov 	dx, 3c8h
.paletteload:
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
	jnz 	.paletteload
	ret
endp 


