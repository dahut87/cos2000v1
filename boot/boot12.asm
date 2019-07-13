use16
align 1

include "..\include\mem.h"
include "..\include\fat.h"
include "..\include\divers.h"

org 7C00h

jmp Boot

bootsec bootinfo  "COS2000A","COS2000    ","FAT12   "

Boot_Message		db "Cos2000",0
Entre_Message       db "Search",0
Loading_Message		db "Load",0
System_File		    db "As",0,"y",0,"s",0,"t",0,"e",0,0x0F,0,0x38,"m",0,"e",0,".",0,"s",0,"y",0,"s",0,0,0,0,0,0xFF,0xFF
Is_Ok			    db " [  OK ]",0x0A,0x0D,0
Is_Failed		    db " [ERROR]",0x0A,0x0D,0
The_Dot			    db '.',0

Boot_Error:
    mov	    si,Is_Failed
    call	ShowString
    xor     ax,ax
    int	    0x16
    int	    0x19

Boot_Ok:
	mov	    si,Is_Ok
	call	ShowString
	ret

Boot:
    push	cs
    push	cs
    pop	es
    pop	ds
	mov	[bootsec.bootdrive],dl
    cli        
    mov	ax,0x9000
    mov	ss,ax
    mov	sp,0xFFFF
    sti
    mov si,Boot_Message
    call ShowString	
    xor	ax,ax
    int	0x13
    jc	Boot_Error
	mov	cx,[bootsec.reservedsectors]
    add	cx,[bootsec.hiddensectorsh]
    adc	cx,[bootsec.hiddensectorsl]
    mov	bx,[bootsec.sectorsperfat]
    mov di,bufferfat
    push bx
    push cx
readfat:
    call    ReadSector
    jc  Boot_Error
	inc cx
	add di,[bootsec.sectorsize]
	dec bx
	jnz readfat          
    pop cx
    pop bx
    xor	ax,ax
    mov	al,[bootsec.fatsperdrive]
    mul	bx
    add	cx,ax
    mov	ax,32
    mul	word [bootsec.directorysize]
    div	word [bootsec.sectorsize]
    add	ax,cx
    sub	ax,2
    mov	word [bootsec.reservedfornt],ax
    xor	dx,dx
	call	Boot_Ok
    mov si,Loading_Message
    call ShowString	
Find_System:
    mov	di,buffer
    call	ReadSector
    jc	Near Boot_Error
    xor	bx,bx
Next_Root_Entrie:
    cmp	byte [di],0
    je	near Boot_Error
    push	di
    push	cx
    mov	si,System_File
    mov	cx,32
    rep	cmpsb
    pop	cx
    pop	di
    je	System_Found
    add	di,32
    add	bx,32
    inc	dx
    cmp	dx,[bootsec.directorysize]
    ja	near Boot_Error
    cmp	bx,[bootsec.sectorsize]
    jb	Next_Root_Entrie
    inc	cx
    jmp	Find_System
System_Found:
    call Boot_Ok
    mov si,Entre_Message
    call ShowString	
    mov	cx,[di+26+32]
    mov	ax,0x8000
    mov	es,ax
    push	es
    mov	di,0x0
    push	0x10
	mov	si,The_Dot
Resume_Loading:
    cmp	cx,0x0FF0
    jae	Finish_Loading
    push	cx
    add	cx,word [bootsec.reservedfornt]
    call	ReadSector
    pop	cx
    jc  near Boot_Error
	call    ShowString
    add	    di,[bootsec.sectorsize]
    call	NextFatGroup
    jc	near Boot_Error
    jmp	Resume_Loading
Finish_Loading:
	call	Boot_Ok
    retf

;====================READSECTOR=======================
;Lit le secteur logique LBA CX et le met en es:di
;-> CX (limité à 65536 secteurs, soit 32 Mo avec secteur 512 octets)
;<- Flag Carry si erreur
;=====================================================
ReadSector:
	pusha
	mov ax,cx
	xor	dx,dx
	div	word [bootsec.sectorspertrack]
	inc	dl
	mov	bl,dl
	xor	dx,dx
	div word [bootsec.headsperdrive]
	mov dh, [bootsec.bootdrive]
	xchg    dl,dh
	mov	cx,ax
	xchg	cl,ch
	shl	cl,6
	or	cl, bl
	mov	bx,di
	mov	si, 4
	mov	al, 1
Read_Again:
  	mov	ah, 2
  	int	0x13
  	jnc	Read_Done
  	dec	si
  	jnz	Read_Again
Read_Done:
  	popa
	ret

;===================NEXTFATGROUP======================
;Renvoie en CX le groupe qui succède dans la FAT le groupe CX
;-> CX
;<-
;=====================================================
NextFatGroup:
	push	bx
	push	dx
	push	di
	mov	    ax,cx
	mov	    bx,ax
	and	    bx,0000000000000001b
	shr	    ax,1
	mov	    cx,3
	mul	    cx
	mov	    di,bufferfat
	add	    di,ax
	cmp	    bx,0
	jnz	    Even_Group
Odd_Group:
	mov	    dx,[di]
	and	    dx,0x0FFF
	mov	    cx,dx
	jmp	    Next_Group_Found
Even_Group:
	mov	    dx,[di+1]
	and	    dx,0xFFF0
	shr	    dx,4
	mov	    cx,dx
Next_Group_Found:
	pop	    di
	pop	    dx
	pop	    bx
	ret

;======================SHOWSTR========================
;Affiche la chaine de caractère pointé par ds:si à l'écran
;-> DS, SI
;<- Flag Carry si erreur
;=====================================================
ShowString:
	    pusha
Next_Char:
        lodsb
        or	al,al
        jz	End_Show
        mov	ah,0x0E
        mov	bx,0x07
        int	0x10
        jmp	Next_Char
End_Show:
	    popa
        ret

rb 7C00h+512-2-$
db 055h,0AAh

endof:

buffer:      
rb 7C00h+512+2048-$
bufferfat:
rb 7C00h+512+4096-$
