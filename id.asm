.model tiny
.386c
.code
org 0100h

      colores equ 7


logoY        equ     064h
logo2X       equ     0A0h
logo2Y       equ     064h
ecartlogo2   equ     13Eh
logocoordsize  equ    0B40h
logo2coordsize equ   26Ch 
zoomout equ 43h


                
start:
                xor eax,eax
                xor ebx,ebx
                xor ecx,ecx
                xor edx,edx
                xor esi,esi
                xor edi,edi
                mov     ax,13h
                int     10h                 
                                               
		mov	dx,3C8h
		mov	al,7
                out     dx,al                   
		inc	dx
                xor     al,al                   
                out     dx,al                   
                out     dx,al                  
                out     dx,al                  
                mov     si,offset logo2text       
                call    showstr
		mov	ax,0A000h
		mov	ds,ax
		push	ds
		push	es
                push    cs
                mov     di,logo2coord
                mov     cx,logo2coordsize
                xor     si,si                   
                xor     dx,dx                   
                xor     bx,bx                   

loopcoord2:
                lodsb                           
                or      al,al                 
                jz      nothingcoord2             
		mov	ax,dx
		sub	ax,5Ah
                stosw                        
		mov	ax,bx
		sub	ax,14h
                stosw                           
                inc     cs:nblogo2
nothingcoord2:
		add	dx,3
                cmp     dx,0BAh
                jne     short loc_3             
                xor     dx,dx               
		add	si,102h
		add	bx,4
loc_3:
                loop    loopcoord2             

		pop	ds
                call zerocurs
                mov si,offset data6
                call showstr             
                                               
		pop	es
		pop	ds
                mov     cx,logocoordsize 
                xor     si,si                  
                xor     dx,dx                 
                xor     bx,bx                  

loopcoord:
                lodsb                       
                or      al,al                
                jz      nothingcoord          
		mov	ax,dx
		sub	ax,32h
                stosw                          
		mov	ax,bx
                shl     ax,1                   
		sub	ax,1Eh
                stosw                          
                inc     cs:nblogo
nothingcoord:
		inc	dx
		inc	dx
		cmp	dx,60h
                jne     short loc_6            
                xor     dx,dx                  
                add     si,110h 
		inc	bx
loc_6:
                loop    loopcoord              

		push	ds
		pop	es
                push    cs
                pop     ds
masterloop:
                inc    logox                            ;++++
		inc	data_10
		mov	bl,data_10
                xor     bh,bh                  
		mov	al,data_1[bx]
                cbw                            
		mov	data_11,ax
                add     bl,zoomout                 
		mov	al,data_1[bx]
                cbw                             
		mov	data_12,ax
                mov     cx,nblogo2
		push	cx
		push	cx
                mov     si,logo2coord

showlogo2:
                lodsw                 
		mov	data_7,ax
                lodsw                          
		mov	data_8,ax
                mov     data_9,0FFCEh 
		push	cx
		push	si
		mov	si,offset data_8
		push	si
		mov	di,offset data_9
		call	sub_1
		mov	si,offset data_7
		call	sub_1
		pop	di
		call	sub_1
		pop	si
                mov     ax,100h
                imul    data_7                 
		mov	bx,data_9
                add     bx,140h
                idiv    bx                    
                add     ax,logo2X
		mov	bp,ax
		mov	ax,100h
                imul    data_8                
		mov	bx,data_9
		add	bx,140h
                idiv    bx                      
                add     ax,logo2Y 
		mov	bx,140h
                imul    bx                      
		add	ax,bp
		mov	di,ax
		push	si
                sub     si,logo2coord
                shr     si,1                   
                mov     ds:data_16e[si],di
		pop	si
		mov	bx,data_9
		mov	cl,4
                shr     bx,cl                  
		pop	cx
		mov	al,17h
		sub	al,bl
		mov	ah,al
                stosw                           
                add     di,ecartlogo2
                stosw                           
                loop   showlogo2               

		pop	si
                shl     si,1                   
                shl     si,1                    
                add     si,logo2coord
                mov     cx,nblogo

showlogo:
		push	cx
                lodsw                           
                imul    data_12                 
		mov	di,ax
                lodsw                           
                imul    data_11                
		sub	di,ax
		mov	cl,7
                sar     di,cl                  
                add     di,logoX
		mov	bx,di
		sub	si,4
                lodsw                          
                imul    data_11                 
		mov	di,ax
                lodsw                          
                imul    data_12                 
		add	di,ax
                sar     di,cl                   
                add     di,logoy
                mov     ax,140h
                imul    di                      
		add	ax,bx
		mov	di,ax
		pop	cx
		mov	ax,cx
                shl     ax,1                  
                mov     bx,data_17e
		add	bx,ax
		mov	[bx],di
                mov     al,28h                 
                stosb                         
                loop    showlogo              

                mov     dx,3DAh

synchro:
                in      al,dx                  
                test    al,8
                jnz     synchro                  
synchroagain:
                in      al,dx                   
                test    al,8
                jz      synchroagain                 
                mov     si,data_16e 
		pop	cx
                add     cx,nblogo
                add     cx,14h 

showlogo2effect:
                lodsw                           
		mov	di,ax
                xor     ax,ax                 
                stosw                          
                add     di,ecartlogo2
                stosw                          
                loop    showlogo2effect             

                in      al,60h                 
		cmp	al,1
                je      endofprog            
                jmp     masterloop
endofprog:
		mov	ax,3
                int     10h                     
                int 20h                               
                ret                    


sub_1		proc	near
		mov	ax,[si]
                imul    data_12                 
		mov	bp,ax
		mov	ax,[di]
                imul    data_11                
		sub	bp,ax
		mov	cl,7
                sar     bp,cl                   
		push	bp
		mov	ax,[si]
                imul    data_11                
		mov	bp,ax
		mov	ax,[di]
                imul    data_12                 
		add	bp,ax
                sar     bp,cl                  
		mov	[di],bp
		pop	ax
		mov	[si],ax
		retn
sub_1           endp    

showcrlf:
  push ax bx
  mov ax, 0E0Dh
  xor bx, bx
  int 10h
  mov al, 0Ah
  int 10h
  pop bx ax
ret

zerocurs:
push ax bx dx
mov ah,02h
mov bh,0
mov dx,0
int 10h
pop dx bx ax
ret       

showstr:
        push ax bx si
again:
        lodsb
        or al,al
        jz fin
        cmp al,0Dh
        jne noret
        call showcrlf
        jmp again
noret:
        mov ah,0Eh
        mov bx,colores
        int 10h
        jmp again
        fin:
        pop si bx ax
        ret
logoX        dw     0A0h             ;++++


data_1          db      0                     
		db	 03h, 06h, 09h, 0Ch, 10h, 13h
		db	 16h, 19h, 1Ch, 1Fh
		db	'"%(+.1369<?ADGILNQSUXZ\^`bdfhjkm'
		db	'opqstuvxyzz{|}}~~~'
		db	7 dup (7Fh)
		db	'~~~}}|{zzyxvutsqpomkjhfdb`^\ZXUS'
		db	'QNLIGDA?<9631.+(%"'
		db	 1Fh, 1Ch, 19h, 16h, 13h, 10h
		db	 0Ch, 09h, 06h, 03h, 00h,0FDh
		db	0FAh,0F7h,0F4h,0F0h,0EDh,0EAh
		db	0E7h,0E4h,0E1h,0DEh,0DBh,0D8h
		db	0D5h,0D2h,0CFh,0CDh,0CAh,0C7h
		db	0C4h,0C1h,0BFh,0BCh,0B9h,0B7h
		db	0B4h,0B2h,0AFh,0ADh,0ABh,0A8h
		db	0A6h,0A4h,0A2h,0A0h, 9Eh, 9Ch
		db	 9Ah, 98h, 96h, 95h, 93h, 91h
		db	 90h, 8Fh, 8Dh, 8Ch, 8Bh, 8Ah
		db	 88h, 87h, 86h, 86h, 85h, 84h
		db	 83h, 83h, 82h, 82h, 82h, 81h
		db	 81h, 81h, 81h, 81h, 81h, 81h
		db	 82h, 82h, 82h, 83h, 83h, 84h
		db	 85h, 86h, 86h, 87h, 88h, 8Ah
		db	 8Bh, 8Ch, 8Dh, 8Fh, 90h, 91h
		db	 93h, 95h, 96h, 98h, 9Ah, 9Ch
		db	 9Eh,0A0h,0A2h,0A4h,0A6h,0A8h
		db	0ABh,0ADh,0AFh,0B2h,0B4h,0B7h
		db	0B9h,0BCh,0BFh,0C1h,0C4h,0C7h
		db	0CAh,0CDh,0CFh,0D2h,0D5h,0D8h
		db	0DBh,0DEh,0E1h,0E4h,0E7h,0EAh
		db	0EDh,0F0h,0F4h,0F7h,0FAh,0FDh
logo2text          db      'Cos 2000' ,0
data6           db      'Speedy', 0dh,0dh 
data61          db      'System' ,0dh,0Dh
data62          db      'Inside' ,0
data_7		dw	0
data_8		dw	0
data_9		dw	0
data_10		db	0
data_11		dw	0
data_12		dw	0
nblogo2         dw      0
nblogo          dw      0
data_15       =  $                        ;*
data_16       =  $+9C4h                 ;*
data_17       =  $+0B2Ch                   ;*
logo2coord       =  offset data_15                        ;*
data_16e       =  offset data_16                    ;*
data_17e       =  offset data_17                    ;*

end     start
