boots segment
.386
org 7C00h
;org 100h
assume cs:boots,ds:boots

start:
jmp boot

bootdb  db     'COS2000A'                ;Fabricant + n°série Formatage
sizec   dw      512                      ;octet/secteur
        db      1                        ;secteur/cluster
reserv  dw      1                        ;secteur reserv‚
nbfat   db      2                        ;nb de copie de la FAT
nbfit   dw      224                      ;taille rep racine
allclu  dw      2880                     ;nb secteur du volume si < 32 még
        db      0F0h                     ;Descripteur de média
fatsize dw      9                        ;secteur/FAT
nbtrack dw      18                       ;secteur/piste       
head    dw      2                        ;nb de tˆteb de lecture/écriture
hidden  dd      0                        ;nombre de secteur cach‚s
        dd      0                        ;si nbsecteur = 0 nbsect                                       ; the number of sectors
bootdrv db      0                        ;Lecteur de d‚marrage
bootsig db      0                        ;NA
        db      29h                      ;boot signature 29h
bootsig2 dd     01020304h                ;no de serie
pope    db      'COS2000    '            ;nom de volume
        db      'FAT12   '               ;FAT
specialboot:

errorloading  db ' Erreur !!',0dh,0ah,0
okloading db 'Recherche noyau',0Dh,0ah,'   - system.sys',0
syst db ' Ok',0dh,0ah,'Chargement',0
dot db '.',0
Sys db 'SYSTEME SYS'

errorboot:
        mov  si,offset errorloading
        call showstr
        mov  ah,0
        int  16h
        int  19h
boot:
        mov  Bootdrv,dl
        cli        
        mov  ax,09000h
        mov  ss,ax
        mov  sp,0FFFFh
	  sti

boot2:
        push cs
        push cs
        pop  es
        pop  ds
        xor  ax,ax
        int  13h
        jc   errorboot
        mov  si,offset okloading
        call showstr
        mov  cx,Reserv  
	add  cx,word ptr [offset Hidden]
        adc  cx,word ptr [offset Hidden+2]
	push cx
	mov bx,fatsize 
	mov di,offset bufferfat
readfat:
	call readsector
	inc cx
	add di,sizec
	dec	bx
	jnz readfat
	pop	cx
        xor  ax,ax
        mov  al,NbFat
        mov  bx,FatSize
        mul  bx
        add  cx,ax
	  mov  ax,32                 
	  mul  nbfit   
	  div  sizec
	  add  ax,cx
	  sub  ax,2
        mov  word ptr [offset bootsig],ax 
        xor  dx,dx 
CheckRoot:
	mov  di,offset buffer
	  call readsector
	  jc   errorboot
	  xor  bx,bx
findnext:
        cmp  byte ptr [di],0
        je   errorboot
	cmp  byte ptr [di],0E5h
	je no
        cmp  byte ptr [di],041h
	je no
	mov  si,offset dot
        call showstr
	push di cx
	mov si,offset sys
	mov  cx,11
        rep  cmpsb
        pop  cx di
	 je   oksystem
no:
        add  di,32
	  add  bx,32
        inc  dx
        cmp  dx,nbfit
	  ja   errorboot
        cmp  bx,sizec
	  jb   findnext
        inc  cx
        jmp  Checkroot
oksystem:
	  mov  si,offset syst
        call showstr
	  mov  cx,[di+26]
	  mov  ax,0900h
	  mov  es,ax
	  push es
	  mov  di,100h
	  push di
	  mov  si,offset dot
	  xor	 ax,ax
fatagain:
	  cmp  cx,0FF0h
        jae  finishload
	  push cx
	  add  cx,word ptr [offset bootsig]
        call readsector
        pop  cx
	  jc   errorboot
        inc	 ax
	  call showstr
        add  di,sizec
        call getfat
        jnc  fatagain
finishload:
	  db 0CBh

;=============READSECTOR (Fonction 01H)===============
;Lit le secteur CX et le met en es:di
;-> AH=1
;<- Flag Carry si erreur
;=====================================================
ReadSector:
	push 	ax bx cx dx si
	mov	ax,cx
	xor   dx,dx
	div   nbtrack 
	inc   dl
	mov 	bl,dl           
	xor 	dx,dx                   
	div 	head    
	mov 	dh, 0
	xchg 	dl,dh          
	mov 	cx,ax              
	xchg 	cl,ch             
	shl 	cl,6                
	or 	cl, bl       
	mov 	bx,di                           
	mov 	SI, 4
	mov 	AL, 1
TryAgain:
  	mov 	AH, 2
  	int 	13h
  	jnc 	Done
  	dec 	SI
  	jnz 	TryAgain
Done:
  	pop 	si dx cx bx ax
ret

getfat:
	push  ax bx dx di
	mov   di,offset bufferfat
	mov	ax,cx
	mov	bx,ax
	and   bx,0000000000000001b
	shr   ax,1
	mov   cx,3
	mul   cx
	add   di,ax
	cmp   bx,0h
	jnz   evenfat
oddfat:
	mov	dx,[di]
      and   dx,0FFFh
    	mov   cx,dx
      jmp   endfat
evenfat:
      mov   dx,[di+1]
      and   dx,0FFF0h
      shr   dx,4
      mov   cx,dx
endfat:
	pop di dx bx ax
	ret

showstr:
        push ax bx si
again:
        lodsb
        or al,al
        jz fin
        mov ah,0Eh
        mov bx,07h
        int 10h
        jmp again
        fin:
        pop si bx ax
        ret

Buffer equ $
BufferFat equ $+2048

boots ends
end start

