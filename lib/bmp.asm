model tiny,stdcall
p586N
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\divers.h"
include "..\include\bmp.h"

org 0h

start:
header exe <"CE",1,0,0,offset exports,offset imports,,>
         
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
PROC showbmp  FAR
        ARG     @pointer:word, @x:word, @y:word
	USES 	ax,bx,cx,dx,si,di
	mov     si,[@pointer]
	cmp	[word ptr (bmp_file si).bmp_filetype],"MB"
	jne     @@errorshowing
	mov     edi,[(bmp_file si).bmp_bitmapoffset]
	add     di,si
       	xor 	ebx,ebx
        mov     ecx,[(bmp_file si).bmp_height]
       	mov 	edx,[(bmp_file si).bmp_width]
        and     dx,11111100b
       	cmp     edx,[(bmp_file si).bmp_width]
       	jae     @@noadjust
       	add     dx,4
@@noadjust:
        sub     edx,[(bmp_file si).bmp_width]
@@bouclette:
	push 	bx cx
	add 	bx,[@x]
	add 	cx,[@y]
    call    [showpixel],bx,cx,[word ptr di]
	pop 	cx bx
	inc 	bx
	inc     di
	cmp 	ebx,[(bmp_file si).bmp_width]
	jb 	  @@bouclette
	xor 	bx,bx
	add     di,dx
	dec 	cx
	cmp 	cx,0
	jne 	@@bouclette
	clc
	ret  
@@errorshowing:
        stc
       	ret
ENDP showbmp


;==========LOADBMPPALET=========
;Charge la palette du BMP pointée par DS:%0
;-> DS:%0 BMP
;<-
;===============================
PROC loadbmppalet FAR
        ARG     @pointer:word
        USES    ax,bx,cx,dx,si
        mov     si,[@pointer]
	mov 	bx,0400h+36h-4
	mov 	cx,100h
	mov 	dx, 3c8h
@@paletteload:
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
	jnz 	@@paletteload
	ret
ENDP loadbmppalet 


