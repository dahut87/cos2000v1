model tiny,stdcall
p486
locals
jumps
codeseg
option procalign:byte

include "..\include\mem.h"
include "..\include\fat.h"
include "..\include\divers.h"

org 7C00h

jmp boot

bootsec bootinfo <"COS2000A",512,1,1,2,224,2880,0F0h,9,18,2,0,0,0,0,0,29h,01020304h,"COS2000    ","FAT12   ">

errorloading  db " [Erreur]",0dh,0ah,0
okloading     db "Recherche noyau ",0Dh,0ah,"  -"
sys           db "SYSTEME SYS",0
syst          db " [  Ok  ]",0dh,0ah,"Chargement ",0
dot           db ".",0



errorboot:
        mov      si,offset errorloading
        call     showstr
        mov      ah,0
        int      16h
        int      19h

boot:
        mov      [bootsec.bootdrive],dl
        cli        
        mov      ax,09000h
        mov      ss,ax
        mov      sp,0FFFFh
        sti
boot2:
        push     cs
        push     cs
        pop      es
        pop      ds
        xor      ax,ax
        mov      dl,[bootsec.bootdrive]
        int      13h
        jc       errorboot
        mov      si,offset okloading
        call     showstr
        mov      cx,[bootsec.reservedsectors]
	add      cx,[bootsec.hiddensectorsh]
        adc      cx,[bootsec.hiddensectorsl]
	push     cx
	mov      bx,[bootsec.sectorsperfat]
	mov      di,offset bufferfat
readfat:
	call     readsector
        jc       errorboot
	inc      cx
	add      di,[bootsec.sectorsize]
	dec      bx
	jnz      readfat
	pop	 cx
        xor      ax,ax
        mov      al,[bootsec.fatsperdrive]
        mov      bx,[bootsec.sectorsperfat]
        mul      bx
        add      cx,ax
        mov      ax,32
        mul      [bootsec.directorysize]
        div      [bootsec.sectorsize]
        add      ax,cx
        sub      ax,2
        mov      [word ptr bootsec.reservedfornt],ax
        xor      dx,dx
checkroot:
	mov      di,offset buffer
        call     readsector
        jc       errorboot
        xor      bx,bx
findnext:
        cmp      [byte ptr di],0
        je       errorboot
	cmp      [byte ptr di],0E5h
	je       no
        cmp      [byte ptr di],041h
	je       no
	mov      si,offset dot
        call     showstr
	push     di cx
	mov      si,offset sys
	mov      cx,11
        rep      cmpsb
        pop      cx di
        je       oksystem
no:
        add      di,32
        add      bx,32
        inc      dx
        cmp      dx,[bootsec.directorysize]
        ja       errorboot
        cmp      bx,[bootsec.sectorsize]
        jb       findnext
        inc      cx
        jmp      checkroot
oksystem:
        mov      si,offset syst
        call     showstr
        mov      cx,[di+26]
        mov      ax,0900h
        mov      es,ax
        push     es
        mov      di,0000h
        push     0010h
        mov      si,offset dot
        xor	 ax,ax
fatagain:
        cmp      cx,0FF0h
        jae      finishload
        push     cx
        add      cx,[word ptr bootsec.reservedfornt]
        call     readsector
        pop      cx
        jc       errorboot
        inc	 ax
        call     showstr
        add      di,[bootsec.sectorsize]
        call     getfat
        jnc      fatagain
finishload:
	retf

;=============READSECTOR (Fonction 01H)===============
;Lit le secteur CX et le met en es:di
;-> AH=1
;<- Flag Carry si erreur
;=====================================================
readsector:
	push 	ax bx cx dx si
	mov	ax,cx
	xor     dx,dx
	div     [bootsec.sectorspertrack]
	inc     dl
	mov 	bl,dl
	xor 	dx,dx
	div 	[bootsec.headsperdrive]
	xchg 	dl,dh
	mov 	cx,ax
	xchg 	cl,ch
	shl 	cl,6
	or 	cl, bl
	mov 	bx,di                           
	mov 	si, 4
	mov 	al, 1
tryagain:
  	mov 	ah, 2
        mov     dl,[bootsec.bootdrive]  	
  	int 	13h
  	jnc 	done
  	dec 	si
  	jnz 	tryagain
done:
  	pop 	si dx cx bx ax
        ret


getfat:
	push    ax bx dx di
	mov     di,offset bufferfat
	mov	ax,cx
	mov	bx,ax
	and     bx,0000000000000001b
	shr     ax,1
	mov     cx,3
	mul     cx
	add     di,ax
	cmp     bx,0h
	jnz     evenfat
oddfat:
	mov	dx,[di]
        and     dx,0FFFh
    	mov     cx,dx
        jmp     endfat
evenfat:
        mov     dx,[di+1]
        and     dx,0FFF0h
        shr     dx,4
        mov     cx,dx
endfat:
	pop     di dx bx ax
	ret
	

showstr:
        push    ax bx si
again:
        lodsb
        or      al,al
        jz      fin
        mov     ah,0Eh
        mov     bx,07h
        int     10h
        jmp     again
fin:
        pop     si bx ax
        ret
        
        
db 055h,0AAh

endof:

buffer      equ offset endof+2048
bufferfat   equ offset endof+4096

