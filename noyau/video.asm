model tiny,stdcall
p486
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\graphic.h"

org 0h

header exe <"CE",1,0,0,offset exports,,,>


exports:
         db "setvideomode",0
         dw setvideomode
         db "getvideomode",0		
         dw getvideomode
         db "clearscreen",0
         dw clearscreen
         db "setfont",0
         dw setfont
         db "loadfont",0
         dw loadfont
         db "getfont",0
         dw getfont
         db "addline",0
         dw addline
         db "showchar",0
         dw showchar
         db "showpixel",0
         dw showpixel
         db "getpixel",0
         dw getpixel
         db "setstyle",0
         dw setstyle
         db "getstyle",0
         dw getstyle
         db "enablecursor",0
         dw enablecursor
         db "disablecursor",0
         dw disablecursor
         db "setcolor",0
         dw setcolor
         db "getcolor",0
         dw getcolor
         db "scrolldown",0
         dw scrolldown
         db "getxy",0
         dw getxy
         db "setxy",0
         dw setxy
         db "savescreen",0
         dw savescreen
         db "restorescreen",0
         dw restorescreen
         db "page2to1",0
         dw page2to1
         db "page1to2",0
         dw page1to2
         ;db "xchgPages",0
         ;dw xchgpages
         db "waithretrace",0
         dw waithretrace
         db "waitretrace",0
         dw waitretrace
         db "getvgainfos",0
         dw getvgainfos
         ;db "savedac",0
         ;dw savedac
         ;db "restoredac",0
         ;dw restoredac
         ;db "savestate",0
         ;dw savestate
         ;db "restorestate",0
         ;dw restorestate
         db "enablescroll",0
         dw enablescroll
         db "disablescroll",0
         dw disablescroll
         db "getchar",0
	 dw getchar

;================================Table des modes videos (64 BYTES) ============================================
;40*25 16 couleurs
mode0        DB 67H,00H,  03H,08H,03H,00H,02H
             DB 2DH,27H,28H,90H,2BH,0A0H,0BFH,01FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,8EH,8FH,14H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,08H,00H
             DB 40,25

;80*25 16 couleurs
mode1        DB 67H,00H,  03H,00H,03H,00H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,4FH,0DH,0EH,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,1FH,96H,0B9H,0A3h,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,08H,00H
             DB 80,25

;80*50 16 couleurs
mode2        DB 63H, 00H, 03H,01H,03H,01H,02H
             DB 5FH,4FH,50H,82H,55H,81H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9CH,8EH,8FH,28H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             DB 80,50        
                             
;100*50 16 couleurs
mode3        DB 067H,00H,03H,01H,03H,01H,02H
             DB 70H,63H,64H,85H,68H,84H,0BFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,9Ch,08EH,8FH,32H,1FH,96H,0B9H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             DB 100,50        

;100*60 16 couleurs
mode4        DB 0A7H,00H,03H,01H,03H,01H,02H
             DB 70H,63H,64H,85H,68H,84H,0FFH,1FH,00H,47H,06H,07H,00H,00H,00H
             DB 00H,0E7H,8EH,0DFH,32H,1FH,0DFH,0E5H,0A3H,0FFH
             DB 00H,00H,00H,00H,00H,10H,0EH,00H,0FFH
             DB 00H,01H,02H,03H,04H,05H,14H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH
             DB 0CH,00H,0FH,00H,00H
             DB 100,60

;320*200 256 couleurs 
mode5        DB 63H, 00H,  03H,01H,0FH,00H,06H
             DB 5FH,4FH,50H,82H,54H,80H,0BFH,1FH,00H,41H,00H,00H,00H,00H,00H,00H
             DB 9CH,0EH,8FH,28H,00H,96H,0B9H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 40,25  

;320*400 256 couleurs 
mode6     DB 063H, 00H,  03H,01H,0FH,00H,06H
             DB 5FH,4FH,50H,82H,54H,80H,0BFH,1FH,00H,40H,00H,00H,00H,00H,00H,00H
             DB 9CH,8EH,8FH,28H,00H,96H,0B9H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 40,50

;320*480 256 couleurs 
mode7 	DB 0E3H, 00H,  03H,01H,0FH,00H,06H
             DB 5FH,4FH,50H,82H,54H,80H,0BH,3EH,00H,40H,00H,00H,00H,00H,00H,00H
             DB 0EAH,0ACH,0DFH,28H,00H,0E7H,06H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04h,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 40,60

;360*480 256 couleurs 
mode8 DB 0E7H, 00H,  03H,01H,0FH,00H,06H
             DB 6BH,59H,5AH,8EH,5EH,8AH,0DH,3EH,00H,40H,00H,00H,00H,00H,00H,00H
             DB 0EAH,0ACH,0DFH,2DH,00H,0E7H,06H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04h,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 45,60

;400*600 256 couleurs 
mode9 DB 0E7H, 00H,  03H,01H,0FH,00H,06H
		 DB 74h,63h,64h,97h,68h,95h,86h,0F0h,00h,60h,00h,00h,00h,00h,00h,00h
		 DB 5Bh,8Dh,57h,32h,00h,60h,80h,0E3h,0FFh
 		 DB 00H,00H,00H,00H,00H,40H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04h,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH
             DB 41H,00H,0FH,00H,00H
             DB 50,75
             
;640*480 16 couleurs
mode10        DB 0E3H
             DB 00H
             DB 03H,01H,0FH,00H,06H
             DB 5FH,4FH,50H,82H,53H,9FH,0BH,3EH,00H,40H,00H,00H,00H,00H,00H,00H,0E9H,8BH,0DFH,28H,00H,0E7H,04H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,00H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH,01H,00H,0FH,00H,00H
             DB 80,60

;800*600 16 couleurs
mode11        DB 0E7H
             DB 00H
             DB 03H,01H,0FH,00H,06H
             DB 70H,63H,64H,92H,65H,82H,70H,0F0H,00H,60H,00H,00H,00H,00H,00H,00H,5BH,8CH,57H,32H,00H,58H,70H,0E3H,0FFH
             DB 00H,00H,00H,00H,00H,00H,05H,0FH,0FFH
             DB 00H,01H,02H,03H,04H,05H,06H,07H,10H,11H,3AH,3BH,3CH,3DH,3EH,3FH,01H,00H,0FH,00H,00H
             DB 100,75


datablocksize equ 40
datablock 	  equ $
;============================================DATABLOCK=========================================================
lines 	        db 0
columns 	db 0
x               db 0
y 		db 0
xy		dw 0
colors 	        db 7
mode 		db 0FFh
pagesize 	dw 0
style           db 0
font		db 0
graphic 	db 0
reserved1	dw 0
reserved2	dw 0
reserved3	dw 0
nbpage    	db 0
color           db 0
cursor          db 0
segments        dw 0
linesize        dw 0
adress     	dw 0
base 		dw 0
scrolling       db 1

;=======================================Equivalence pour la clart� du code========================================
sequencer 	equ 03C4h
misc 		equ 03C2h
ccrt 		equ 03D4h
attribs 	equ 03C0h
graphics    	equ 03CEh
statut 		equ 03DAh

maxmode	        equ 11
planesize	equ 65000
;============================================Fonctions de l'int VIDEO===========================================


;=============ENABLESCROLLING=========
;Autorise le d�filement
;->
;<- 
;=====================================
PROC enablescroll FAR
        mov     [cs:scrolling],1
        ret
endp enablescroll

;=============DISABLESCROLLING=========
;D�sactive le d�filement
;->
;<- 
;======================================
PROC disablescroll FAR
        mov     [cs:scrolling],0
        ret
endp disablescroll

;=============ENABLECURSOR=============
;Autorise le d�filement
;->
;<-
;======================================
PROC enablecursor FAR
        USES    ax,dx
        mov     [cs:cursor],1
       	mov 	dx,ccrt
	mov 	al,0Ah
	out     dx,al
	inc     dx
	in      al,dx
	and     al,11011111b
	mov     ah,al
	dec     dx
	mov     al,0Ah
	out     dx,ax
	mov     al,[cs:x]
	xor     ah,ah
	mov     dl,[cs:y]
	xor     dh,dh
	call    setxy,ax,dx
        ret
endp enablecursor

;=============DISABLECURSOR=============
;D�sactive le d�filement
;->
;<-
;=======================================
PROC disablecursor FAR
        USES    ax,dx
        mov     [cs:cursor],0
       	mov 	dx,ccrt
	mov 	al,0Ah
	out     dx,al
	inc     dx
	in      al,dx
	or      al,00100000b
	mov     ah,al
	dec     dx
	mov     al,0Ah
	out     dx,ax
        ret
endp disablecursor
        
;==========SETSTYLE=========
;Change le style du texte a %0
;-> %0 style
;<-
;============================
PROC setstyle FAR
        ARG     @style:word
        USES    cx
        mov     ax,[@style]
	mov 	[cs:style],al
	ret
endp setstyle

;==========GETSTYLE=========
;R�cup�re le style du texte dans AX
;->
;<- AX style
;===========================
PROC getstyle FAR
	mov 	al,[cs:style]
	xor     ah,ah
	ret
endp getstyle

;=============SetVideoMode=========
;Fixe le mode vid�o courant a %0
;-> %0 mode d'�cran
;<- Carry if error
;==================================
PROC setvideomode FAR
        ARG     @mode:word
        USES    ax,cx,dx,di
        mov     ax,[@mode]
        xor     ah,ah	
        cmp     al,maxmode
	ja	@@errorsetvideomode
	cmp     [cs:mode],5h
	jb	@@nographic
	cmp	al,5h
	jae	@@nographic
	call	initfont
@@nographic:
        cmp     [cs:mode],0FFh
        jne     @@noinit
	call	initfont
@@noinit:
	mov 	[cs:mode],al
	xor 	ah,ah
	mov 	di,ax
	shl 	di,6
	add 	di,offset mode0 
	mov 	dx,misc
	mov 	al,[cs:di]
	out 	dx,al
	inc 	di              
	mov 	dx,statut
	mov 	al,[cs:di]
	out 	dx,al
	inc 	di              
	mov 	dx,sequencer
	xor 	ax,ax
@@initsequencer:
	mov 	ah,[cs:di]
	out 	dx,ax
	inc 	al
	inc 	di
	cmp 	al,4
	jbe 	@@initsequencer
	mov 	ax,0E11h
	mov 	dx,ccrt
	out 	dx,ax
	xor 	ax,ax
@@initcrt:
	mov 	ah,[cs:di]
	out 	dx,ax
	inc 	al
	inc 	di
	cmp 	al,24
	jbe 	@@initcrt
        mov     dx,graphics
	xor 	ax,ax
@@initgraphic:
	mov 	ah,[cs:di]
	out 	dx,ax
	inc 	al
	inc 	di
	cmp 	al,8
	jbe 	@@initgraphic
	mov 	dx,statut
	in 	al,dx
	mov 	dx,attribs
	xor 	ax,ax
@@initattribs:
	mov 	ah,[cs:di]
	push 	ax
	in 	ax,dx
	pop	ax
	out 	dx,al
	xchg 	ah,al
	out 	dx,al
	xchg 	ah,al
	inc 	al
	inc	di
	cmp 	al,20
	jbe	@@initattribs
	mov 	al,20h
	out 	dx,al
	mov 	al,[cs:di]
	mov 	[cs:columns],al
	mov 	ah,[cs:di+1]
	mov 	[cs:lines],ah
	mul 	ah
	mov     cl,[cs:di-5]
	and     cl,01000000b
	cmp     cl,0
	je      @@colors16
	mov     [cs:color],8
	mov     cl,4
	jmp     @@colors256
@@colors16:
        mov     [cs:color],4
        mov     cl,3
@@colors256:
  	cmp     [cs:mode],5
        setae   [cs:graphic]
        jb      @@istext
	shl     ax,cl
        mov     [cs:segments],0A000h
	jmp     @@wasgraph
@@istext:
        mov     [cs:segments],0B800h
        shl     ax,1
@@wasgraph:
	mov 	[cs:pagesize],ax
	mov	ax,planesize
	xor	dx,dx
	div	[cs:pagesize]
	mov	[cs:nbpage],al
        mov     al,[cs:di-36]
	xor 	ah,ah
        shl     ax,2
	mov     cl,[cs:graphic]
	shr     ax,cl
        mov     [cs:linesize],ax
        mov     ax,[cs:di-43]
        mov     [cs:adress],ax
	mov	[cs:base],ax
        mov     [cs:cursor],1
        mov     [cs:style],0
	ret
@@errorsetvideomode:
	ret
endp setvideomode


initfont:
	push 	ds
	call    clearscreen
	push 	cs
	pop 	ds
	call 	loadfont,offset font8x8,8,1
	call 	loadfont,offset font8x16,16,0
	pop 	ds
	ret

;=============GetVideoMode=========
;Renvoie le mode vid�o courant dans AX
;->
;<- AX
;==================================
PROC getvideomode FAR
	mov 	al,[cs:mode]
	xor     ah,ah
	ret
endp getvideomode

;=============CLEARSCREEN=========
;Efface l'ecran graphique ou texte
;->
;<-
;=================================
PROC clearscreen FAR
	USES 	eax,cx,dx,di,es
	mov 	cx,planesize
	mov	di,[cs:adress]
	shr 	cx,2
        cmp     [cs:graphic],1
	jne 	@@erasetext
	mov  	ax,0A000h
	mov 	es,ax
@@erasegraph:
	mov     ax,0F02h
        mov     dx,sequencer
	out     dx,ax
	mov     ax,0205h
        mov     dx,graphics
	out     dx,ax
	mov     ax,0003h
	out     dx,ax
	mov     ax,0FF08h
	out     dx,ax	
	mov	eax,00000000h
	cld
	rep 	stosd
	mov     ax,0005h
	cmp     [cs:color],4
	je      @@not256
	mov     ax,4005h	
@@not256:
        mov     dx,graphics
	out     dx,ax
	mov     ax,0003h
	out     dx,ax
        jmp     @@endoferase
@@erasetext:
	mov 	ax,0B800h
	mov 	es,ax
	mov 	eax,07200720h
	cld
	rep 	stosd	
@@endoferase:	
        call    setxy,0,0
	ret
endp clearscreen


;=============SetFont=========
;Active la font %0 parmi les 8
;-> %0 n� font
;<- Carry if error
;=============================
PROC setfont FAR
        ARG     @font:word
	USES 	ax,cx,dx
	mov     cx,[@font]
	xor     ch,ch
	cmp	cl,7
      	ja    	@@errorsetfont
	mov	[cs:font],cl
	mov 	ah,cl
	and 	cl,11b
	and 	ah,0100b
	shl 	ah,2
	add 	ah,cl
      	mov   	dx,sequencer
	mov 	al,3
	out 	dx,ax
        ret
@@errorsetfont:
	ret    
endp setfont

;=============GetFont=========
;R�cup�re le n� de la font active AX
;->
;<- CL n� font, Carry if error
;=============================
PROC getfont FAR
	mov	al,[cs:font]
	xor     ah,ah
endp getfont

;!!!!!!!!!!!!!!!!!!!! a remettre les anciens params de timing depuis origine
;=============LoadFont========
;Charge une police point�e par %0 dans la carte vid�o sous n�font %1, taille police dans %2
;-> %0 n�font, %1 pointeur vers Font, %2 taille police
;<- Carry if error
;=============================
PROC loadfont FAR
        ARG     @pointer:word,@size:word,@font:word
	USES 	ax,bx,cx,dx,si,di,es
	LOCAL   @poppop:dword
	mov     si,[@pointer]
	mov     cx,[@size]
	mov     bx,[@font]
	cmp	bl,7
      	ja    	@@errorloadfont
	xor	di,di
      	cli  
      	mov   	dx,sequencer
@@doseq:
	mov 	ax,[cs:di+offset reg1]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6
	jbe 	@@doseq
      	mov   	dx,graphics 
@@doseq2:
	mov 	ax,[cs:di+offset reg1]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6+6
	jbe 	@@doseq2
	sti
	mov 	ax,0A000h
	mov	es,ax
	mov 	dx,256
	mov 	al,0
	xor 	bh,bh
	cmp 	bl,4
	jb 	@@isless
	sub	bl,4
	shl 	bl,1
	inc 	bl
	jmp 	@@okmake
@@isless:
	shl 	bl,1
@@okmake:
	mov 	di,bx
	shl 	di,13
	mov 	bh,cl
	mov 	bl,cl
	sub 	bl,32
	neg 	bl
	xor 	cx,cx
	cld
@@popz:
	mov 	cl,bh
	rep 	movsb
	mov 	cl,bl
	rep 	stosb
	dec 	dx
	jnz 	@@popz
	xor 	di,di
      	mov   	dx,sequencer
@@doseqs:
	mov 	ax,[cs:di+offset reg2]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6
	jbe 	@@doseqs
	mov     dx,graphics
@@doseqs2:
	mov 	ax,[cs:di+offset reg2]
	out 	dx,ax
	inc 	di
	inc 	di
	cmp 	di,6+6
	jbe 	@@doseqs2
	ret    
@@errorloadfont:
	stc
	ret
  
reg2 	dw 0100h, 0302h, 0304h, 0300h 
     	dw 0004h, 1005h, 0E06h 
reg1 	dw 0100h, 0402h, 0704h, 0300h
     	dw 0204h, 0005h, 0406h
endp loadfont

;==========SHOWLINE===============
;remet le curseur text a la ligne avec un retour chariot
;->
;<-
;=================================
PROC addline FAR
        USES    bx,cx
	mov 	bl,[cs:y]
	xor 	bh,bh
	mov 	cl,[cs:lines]
      	sub     cl,2
	cmp 	bl,cl
      	jne     @@scro
	dec 	bl
	mov	cx,1
	cmp	[cs:graphic],0
	je	@@okscro
	mov	cx,8
@@okscro:
	call	scrolldown,cx
@@scro:
	inc 	bl
        call    setxy,0,bx
	ret
endp addline

;==========SETCOLOR=========
;Change les attributs du texte a CL
;-> %0 couleur
;<- 
;===========================
PROC setcolor FAR
        ARG     @color:word
        USES    cx
        mov     cx,[@color]
	mov 	[cs:colors],cl
	ret
endp setcolor

;==========GETCOLOR=========
;R�cup�re les attributs du texte dans AX
;->
;<- AX couleur
;===========================
PROC getcolor FAR
	mov 	al,[cs:colors]
	xor     ah,ah
	ret
endp getcolor
	
;==========SCROLLDOWN=========
;defile de %0 lines vers le bas
;-> %0 lines � d�filer vers le bas
;<-
;=============================	
PROC scrolldown FAR
        ARG     @line:word
	USES 	ax,cx,dx,si,di,ds,es
        cmp     [cs:scrolling],0
        je      @@graphp
	mov 	ax,[@line]
	mul 	[cs:linesize]
	mov 	si,ax
	mov 	cx,[cs:pagesize]
	sub 	cx,si
	mov 	di,[cs:adress]
	cld
	cmp     [cs:graphic],1
	jne 	@@textp
	mov  	ax,0A000h
	mov 	es,ax
	mov 	ds,ax
	mov     ax,0F02h
        mov     dx,sequencer
	out     dx,ax
	mov     ax,0105h
        mov     dx,graphics
	out     dx,ax
	cld
	rep 	movsb
	mov     ax,0005h
	cmp     [cs:color],4
	je      @@not256ok
	mov     ax,4005h	
@@not256ok:
        mov     dx,graphics
	out     dx,ax
	mov     ax,0003h
	out     dx,ax
        jmp     @@graphp
        
@@textp:
	mov 	ax,0B800h
	mov 	es,ax
	mov 	ds,ax
	rep 	movsb
@@graphp:
	ret
endp scrolldown 	

;==========GETXY=========
;Met les coordonn�es du curseur dans %0 au format point
;->
;<- ah coordonn�es x, al coordonn�es y
;========================
PROC getxy FAR
        ARG     @pointer:word
	USES 	bx
	mov     bx,[@pointer]
	mov 	ah,[cs:x]
	mov 	al,[cs:y]
	ret
endp getxy

;==========SETXY=========
;Change les coordonn�es du curseur a X:%0,Y:%1
;-> %0 coordonn�es x, %1 coordonn�es y
;<- 
;========================
PROC setxy FAR
        ARG     @x:word,@y:word
	USES 	ax,bx,dx,di
	mov     ax,[@y]
	mov     bx,[@x]
	mov 	[cs:x],bl
	mov 	[cs:y],al
	mov	di,[cs:adress]
	add 	di,bx
	mul 	[cs:columns]
	add 	di,ax
	shl 	di,1
	mov 	[cs:xy],di
	call    setcursor
	ret
endp setxy

;==========SHOWPIXEL=========
;Affiche un pixel de couleur AL en X:%0,Y:%1
;-> %0 coordonn�es x, %1 coordonn�es y, %2 couleur
;<- 
;============================
PROC showpixel FAR
        ARG     @x:word,@y:word,@color:word
     	USES 	ax,bx,cx,dx,si,di,es
     	mov     bx,[@x]
     	mov     cx,[@y]
     	mov     ax,[@color]
     	cmp     [cs:color],4
     	je      @@showpixel4
        mov     si,ax
	mov     ax,cx
        mov	cl,bl
        mul  	[cs:linesize]
        shr     bx,2
        add  	ax,bx
        mov     di,ax
	add     di,[cs:adress]
        and     cl,3
        mov     ah,1
        shl     ah,cl
        mov     al,2
        mov     dx,sequencer
        out     dx,ax
        mov     bx,0A000h
        mov  	es,bx
	mov	ax,si
	mov	[es:di],al	
        jmp     @@endofshow
        
@@showpixel4:
        mov     dx,ax
        mov     ax,cx
        mov     ch,dl
        mov	cl,bl
        mul  	[cs:linesize]
        shr     bx,3
        add  	ax,bx
        mov     di,ax
        add     di,[cs:adress]
        and     cl,111b
        xor     cl,111b
        mov     ah,1
        shl     ah,cl
        mov     al,8
        mov     dx,graphics           ;masque
        out     dx,ax
        mov     ax,0205h
        out     dx,ax
        mov     ax,0003h
        out     dx,ax
        mov     bx,0A000h
        mov  	es,bx
        mov	al,[es:di]
        mov	[es:di],ch	 	
@@endofshow:        	
	ret
endp showpixel

;!!!!!!!!!!!!!! gerer le mode chain 4
;==========GETPIXEL=========
;R�cup�re en ax la couleur du pixel de coordonn�es X:%0,Y:%1
;-> %0 coordonn�es x, %1 coordonn�es y
;<- AX couleur
;=========================================
PROC getpixel FAR
        ARG     @x:word,@y:word
     	USES 	ax,bx,cx,dx,di,es
     	mov     bx,[@x]
     	mov     cx,[@y]
	mov     ax,cx
        mov	cl,bl
        mul  	[cs:linesize]
        shr     bx,2
        add  	ax,bx
        mov     di,ax
	add     di,[cs:adress]
        and     cl,3
	mov	ah,cl                                      
        mov     al,4
        mov     dx,graphics
        out     dx,ax
        mov     bx,0A000h
        mov  	es,bx
	mov	al,[es:di] 	
	ret
endp getpixel

;==========GETVGAINFO=========
;Renvoie un bloc de donn�e en ES:DI sur l'�tat de la carte graphique
;<- ES:%0 pointeur
;->
;=============================================
PROC getvgainfos FAR
        ARG     @pointer:word
	USES 	cx,si,di,ds
	push 	cs
	pop 	ds
	mov 	cx,datablocksize
	mov 	si,offset datablock
	mov     di,[@pointer]
	cld
	rep 	movsb
	ret
endp getvgainfos

;==========WAITRETRACE=========
;Synchronisation avec la retrace verticale
;<-
;->
;==============================
PROC waitretrace FAR
	USES 	ax,dx
	mov 	dx,3DAh
@@waitr:
	in 	al,dx
	test 	al,8
	jz 	@@waitr
	ret
endp waitretrace
	
;==========WAITHRETRACE=========
;Synchronisation avec la retrace horizontale
;<-
;->
;===============================
PROC waithretrace FAR
	USES 	ax,dx
	mov 	dx,3DAh
@@waitr:
	in 	al,dx
	test 	al,1
	jz 	@@waitr
	ret
endp waithretrace
	
;==========GETCHAR=========
;Renvoie en AX le caract�re sur le curseur
;<-
;->
;==========================	
PROC getchar FAR
        USES    di,es
        mov	ax,0B800h
	mov	es,ax
	mov	di,[cs:xy]
	mov	al,[es:di]
	xor     ah,ah
        ret
endp getchar

;==========SHOWCHAR=========
;Ecrit le caract�re ASCII %0 attribut %1 apr�s le curseur, en le mettant � jours
;<-
;->
;===========================
PROC showchar FAR
        ARG     @char:word,@attr:word
	USES 	ax,bx,cx,dx,di,es
	mov     cl,[byte ptr @char]
	mov     ch,[byte ptr @attr]
        cmp     [@attr],0FFFFh
        jne     @@notlastattr
        mov     ch,[cs:colors]
@@notlastattr:	
	cmp	[cs:graphic],1
	jne	@@textaccess
        call    emulatechar
        jmp     @@adjusttext
@@textaccess:
	mov	ax,0B800h
	mov	es,ax
	mov	di,[cs:xy]
	mov	[es:di],cx
	add	[cs:xy],2
@@adjusttext:
        inc     [cs:x]
	mov	cl,[cs:columns]
	cmp	[cs:x],cl
	jb	@@noadjusted
        call    addline
@@noadjusted:
        call    setcursor
	ret
endp showchar

setcursor:
        push    ax cx dx
        cmp     [cs:cursor],1
        jne     notshow
	mov 	dx,ccrt
	mov 	al,0Eh
	mov 	cx,[cs:xy]
	shr     cx,1
	mov 	ah,ch
	out 	dx,ax
	mov 	ah,cl
	inc	al
	out 	dx,ax
notshow:
	pop     dx cx ax
	ret


;Ecrit le caract�re ASCII CL attribut CH apr�s le curseur graphique, en le mettant � jours en mode graphique
emulatechar:
        push    ax bx cx dx di
        mov     al,ch
	mov	di,cx
	and 	di,11111111b
	shl 	di,3
	add 	di,offset font8x8
	mov     bl,[cs:x]
	mov     cl,[cs:y]
        xor     bh,bh
        xor     ch,ch	
	shl     bx,3
	shl     cx,3
	mov 	ah,[cs:di]
	xor     dx,dx
bouclet:
        rol	ah,1
	push    ax
        jc 	colored
	shr	al,4
	cmp     [cs:style],0
	jnz     transparent
colored:
        and     ax,1111b
	call 	showpixel,bx,cx,ax
transparent:
        pop     ax
	inc 	bx
	inc     dl
	cmp 	dl,8
	jb 	bouclet
	inc 	di
	mov	ah,[cs:di]
	xor     dl,dl
	sub	bx,8
	inc 	cx
	inc     dh
	cmp 	dh,8
	jb 	bouclet
ended:
        pop     di dx cx bx ax
        ret



;sauve l'ecran dans un bloc de m�moire
savescreen:
push    ax cx dx si di bp ds es gs
mov     bp,sp
mov     dx,[ss:bp+22]
mov     ah,2
mov     cx,[cs:pagesize]
push    cs
pop     ds
mov     si,offset data3
int     49h
mov     ah,6
int     49h
push    gs
pop     es
xor     di,di
call    savescreento
pop     gs es ds bp di si dx cx ax
ret

data3 db '/vgascreen',0


;===================================sauve l'ecran rapidement en es:di================
savescreento:
        push    cx si di ds 
        mov     cx,0B800h
        mov     ds,cx
        xor     ecx,ecx
        mov     cx,[cs:pagesize]
        shr     cx,2
        xor     si,si
        cld
        rep     movsd
        pop     ds di si cx 
        ret

;===================================sauve les parametres en es:di================
saveparamto:
        push    ecx si di ds
        push    cs
        pop     ds
        xor     ecx,ecx
        mov     cx,datablocksize
        mov     si,offset datablock
        cld
        rep     movsb
        pop     ds di si ecx
        ret
        
;===================================restore les parametres depuis en ds:si================
restoreparamfrom:
        push    ecx si di es
        push    cs
        pop     es
        xor     ecx,ecx
        mov     cx,datablocksize
        mov     di,offset datablock
        cld
        rep     movsb
        pop     es di si ecx
        ret

;R�cup�re l'ecran de la carte depuis son bloc m�moire
restorescreen:
push    ax dx si bp ds gs
mov     bp,sp
mov     dx,[ss:bp+16]
push    cs
pop     ds
mov     si,offset data3
mov     ah,9
int     49h
push    gs
pop     ds
xor     si,si
call    restorescreenfrom
pop     gs ds bp si dx ax
ret

;===================================restore l'ecran rapidement de ds:si================
restorescreenfrom:
        push    ecx si di ds es
        mov     cx,0B800H
        mov     es,cx
        xor     ecx,ecx
        mov     cx,[cs:pagesize]
        shr     cx,2
        xor     di,di
        cld
        rep     movsd
        pop     es ds di si ecx
        ret



;===============================Page2to1============================
page2to1:
        push    ecx si di ds es
        mov     cx,0B800H
        mov     es,cx
        mov     ds,cx
        xor     ecx,ecx
        mov     cx,[cs:pagesize]
        shr     cx,2
        mov     si,[cs:pagesize]
        xor     di,di
        cld
        rep     movsd
        pop     es ds di si ecx
        ret

;===============================Page1to2============================
page1to2:
        push    ecx si di ds es
        mov     cx,0B800H
        mov     es,cx
        mov     ds,cx
        xor     ecx,ecx
        mov     cx,[cs:pagesize]
        shr     cx,2
        mov     di,[cs:pagesize]
        xor     si,si
        cld
        rep     movsd
        pop     ds es di si ecx
        ret

;===============================xchgPages============================
;xchgpages:
;push    ax cx dx si di bp ds es gs
;mov     bp,sp
;mov     dx,[ss:bp+22]
;mov     ah,2
;mov     cx,datablocksize
;add     cx,[cs:pagesize]
;add     cx,3*256
;push    cs
;pop     ds
;mov     si,offset data4
;int     49h
;mov     ah,6
;int     49h
;push    gs
;pop     es
;xor     di,di
;call    savescreento
;call    page2to1
;push    gs
;pop     ds
;xor     si,si
;mov     cx,0B800H
;mov     es,cx
;mov     di,[cs:pagesize]
;xor     ecx,ecx
;mov     cx,[cs:pagesize]
;shr     cx,2
;cld
;rep     movsd
;mov     ah,01h
;int     49h
;pop     gs es ds bp di si dx cx ax
;ret
;
;data4 db '/vgatemp',0


;Sauve l'�tat de la carte dans un bloc m�moire
;savestate:
;push    ax cx dx si di bp ds es gs
;mov     bp,sp
;mov     dx,[ss:bp+22]
;mov     ah,2
;mov     cx,datablocksize
;add     cx,[cs:pagesize]
;add     cx,3*256
;push    cs
;pop     ds
;mov     si,offset data
;int     49h
;mov     ah,6
;int     49h
;push    gs
;pop     es
;xor     di,di
;call    saveparamto
;add     di,datablocksize
;call    savescreento
;add     di,[cs:pagesize]
;call    savedacto
;pop     gs es ds bp di si dx cx ax
;ret

;data db '/vga',0

;R�cup�re l'�tat de la carte depuis son bloc m�moire
;restorestate:
;push    ax dx si bp ds gs
;mov     bp,sp
;mov     dx,[ss:bp+16]
;push    cs
;pop     ds
;mov     si,offset data
;mov     ah,9
;int     49h
;push    gs
;pop     ds
;mov     al,[ds:7]
;cmp     [cs:mode],al
;je      nochangemode
;mov     ah,0
;call    setvideomode
;nochangemode:
;xor     si,si
;call    restoreparamfrom
;add     si,datablocksize
;call    restorescreenfrom
;add     si,[cs:pagesize]
;call    restoredacfrom
;pop     gs ds bp si dx ax
;ret

;sauve le DAC dans un bloc de m�moire
;savedac:
;push    ax cx dx si di bp ds es gs
;mov     bp,sp
;mov     dx,[ss:bp+22]
;mov     ah,2
;mov     cx,3*256
;push    cs
;pop     ds
;mov     si,offset data2
;int     49h
;mov     ah,6
;int     49h
;push    gs
;pop     es
;xor     di,di
;call    savedacto
;pop     gs es ds bp di si dx cx ax
;ret

;data2 db '/vgadac',0

;R�cup�re le dac depuis son bloc m�moire
;restoredac:
;push    ax dx si bp ds gs
;mov     bp,sp
;mov     dx,[ss:bp+16]
;push    cs
;pop     ds
;mov     si,offset data2
;mov     ah,9
;int     49h
;push    gs
;pop     ds
;xor     si,si
;call    restoredacfrom
;pop     gs ds bp si dx ax
;ret

;sauve le DAC en es:di
;savedacto:
;push ax cx dx di
;mov dx,3C7h
;mov cx,256
;save:
;mov al,cl
;dec al
;out dx,al
;inc dx
;inc dx
;in al,dx
;mov [es:di],al
;inc di
;in al,dx
;mov [es:di],al
;inc di
;in al,dx
;mov [es:di],al
;inc di
;dec dx
;dec dx
;dec cx
;jne save
;pop di dx cx ax
;ret

;restore le DAC depuis ds:si
;restoredacfrom:
;push ax cx dx si
;xor ax,ax
;mov dx,3C8h
;mov cx,256
;save2:
;mov al,cl
;dec al
;out dx,al
;inc dx
;mov al,[ds:si]
;inc si
;out dx,al
;mov al,[ds:si]
;inc si
;out dx,al
;mov al,[ds:si]
;inc si
;out dx,al
;dec dx
;dec cx
;jne save2
;pop si dx cx ax
;ret


font8x8:
include "..\include\pol8x8.inc"
font8x16:
include "..\include\pol8x16.inc"


