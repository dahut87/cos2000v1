;****************************************************************
;								*
;  Periph‚rique : DMA                                           *
;  Plages Entr‚es-Sorties : 0000-000F                           *
;			    00C0-00DF				*				
;			    0080-0090				*
;			   (0094-009F)	      			*
;  Plages M‚moires : AUCUNES                                    *
;								*
DmaRead	equ 044h		;I/O to memory, no autoinit, increment, single mode
DmaWrite 	equ 048h		;Memory to I/O, no autoinit, increment, single mode

;Lecture des bits du registre d'‚tat (08, D0 )
STATUS_REQ3 = 80h        ;Bit actif: le canal DMA concern‚  
STATUS_REQ2 = 40h        ;re‡oit une requˆte DMA            
STATUS_REQ1 = 20h        ;Request                           
STATUS_REQ0 = 10h
STATUS_TC3  = 08h        ;Bit actif: Un transfert DMA a ‚t‚  
STATUS_TC2  = 04h        ;ex‚cut‚ depuis la derniŠre lecture  
STATUS_TC1  = 02h        ;du registre d'‚tat.                 
STATUS_TC0  = 01h        ;Terminal Count       
               
;Ecriture des bits du registre de commande (08, D0) 
COMMAND_DACKLEVEL = 80h  ;Bit 7 actif: ligne DMA Acknowledge HIGH active                              
COMMAND_DREQLEVEL = 40h  ;Bit 6 actif: ligne REQ Acknowledge LOW active                                
COMMAND_EXTWRITE  = 20h  ;Bit 5 actif: EXTENDED Write,sinon LATE Write 
COMMAND_FIXEDPRI  = 10h  ;Bit 4 actif: priorit‚ constante            
COMMAND_COMPRESS  = 08h  ;Bit 3 actif: compression 
COMMAND_INACTIVE  = 04h  ;Bit 2 actif: contr“leur d‚sactiv‚          
COMMAND_ADH0      = 02h  ;Bit 1 actif: Adress Hold pour canal 0/4 d‚sactiv‚   
COMMAND_MEM2MEM   = 01h  ;Bit 0 actif: m‚moire/m‚moire, sinon m‚moire/p‚riph‚rie   
               
;Ecriture des bits du registre de requˆte ( 09, D2 )
REQUEST_RESERVED = 0F8h	 ;R‚glage des bits r‚serv‚s =0
REQUEST_SET      = 04h	 ;D‚finir requˆte DMA 
REQUEST_CLR      = 00h	 ;Supprimer requˆte DMA 
REQUEST_MSK      = 03h	 ;Indiquer le canal dans les deux bits du bas 

;Ecriture des bits du registre de masquage de canal ( 0A, D4 ) 
CHANNEL_RESERVED = 0F8h	 ;R‚glage des bits r‚serv‚s =0 
CHANNEL_SET      = 04h	 ;Masquer/verrouiller canal DMA
CHANNEL_CLR      = 00h	 ;Lib‚rer canal DMA 
CHANNEL_MSK      = 03h	 ;Indiquer le canal dans les deux bits du bas 

;Ecriture des bits du registre de mode (0B,D6) 
MODE_DEMAND     = 00h	 ;Transf‚rer … la demande  
MODE_SINGLE     = 40h	 ;Transf‚rer valeurs uniques
MODE_BLOCK      = 80h	 ;Transf‚rer en bloc 
MODE_CASCADE    = 0C0h	 ;Transf‚rer en cascade 
MODE_DECREMENT  = 20h	 ;D‚cr‚menter 
MODE_AUTOINIT   = 10h	 ;Autoinitialisation vers la fin 
MODE_VERIFY     = 00h	 ;V‚rifier 
MODE_WRITE      = 04h	 ;Ecrire dans la m‚moire 
MODE_READ       = 08h	 ;Lire depuis la m‚moire 
MODE_INVALID    = 0Ch	 ;Incorrect 
MODE_CHANNELMSK = 03h	 ;Indiquer le canal dans les deux bits du bas 

;Ports du DMA esclave

DmaStatusS	dw 08h          ;R SLAVE Registre d'‚tat
DmaCommandS 	dw 08h          ;W SLAVE Registre de commande
DmaRequestS	dw 09h          ;W SLAVE Ex‚cuter requˆte DMA
DmachMaskS	dw 0ah          ;W SLAVE Masquer canaux
DmaModeS 	dw 0bh          ;W SLAVE Mode de transfert
DmaFlipFlopS	dw 0ch          ;W SLAVE Flipflop adr/compteur
DmaTempS   	dw 0dh          ;R SLAVE Reset du contr“leur
DmaClearS      	dw 0dh          ;R SLAVE Registre temporaire
DmaMaskClrS     dw 0eh          ;R SLAVE Lib‚rer canaux 
DmaMaskS        dw 0fh          ;R SLAVE Masquer canaux 

;Ports du DMA esclave

DmaStatusM      dw 0D0h         ;R MASTER Registre d'‚tat
DmaCommandM     dw 0D0h         ;W MASTER Registre de commande
DmaRequestM     dw 0D2h         ;W MASTER Ex‚cuter requˆte DMA
DmaMaskM        dw 0D4h         ;W MASTER Masquer canaux
DmaModeM        dw 0D6h         ;W MASTER  Mode de transfert
DmaFlipFlopM    dw 0D8h         ;W MASTER Flipflop adr/compteur
DmaTempM        dw 0DAh         ;R MASTER Reset du contr“leur
DmaClearM       dw 0DAh         ;R MASTER Registre temporaire
DmaMaskClrM     dw 0DCh         ;R MASTER Lib‚rer canaux 
DmaMaskM2       dw 0DEh         ;R MASTER Masquer canaux 

DmaAdress       db 00h          ;DMA address register 0
                db 002h         ;DMA address register 1
                db 004h         ;DMA address register 2
                db 006h         ;DMA address register 3
                db 0c0h         ;DMA address register 4
                db 0c4h         ;DMA address register 5
                db 0c8h         ;DMA address register 6
                db 0cch         ;DMA address register 7

DmaCount        db 001h         ;DMA count registers 0
                db 003h         ;DMA count registers 1
                db 005h         ;DMA count registers 2
                db 007h         ;DMA count registers 3
                db 0c2h         ;DMA count registers 4
                db 0c6h         ;DMA count registers 5
                db 0cah         ;DMA count registers 6
                db 0ceh         ;DMA count registers 7

DmaPage         db 087h         ;DMA page registers 0
                db 083h         ;DMA page registers 1
                db 081h         ;DMA page registers 2
                db 082h         ;DMA page registers 3
                db 08fh         ;DMA page registers 4
                db 08bh         ;DMA page registers 5
                db 089h         ;DMA page registers 6
                db 08ah         ;DMA page registers 7

;verouille le canal AL
DisableDma:
	push ax dx
	cmp al, 4			
	jae MasterDisableDma
	mov dx, DmaMaskS
	or al, 00000100b
	out dx, al		
	jmp EndDisableDma
MasterDisableDma:
	mov dx, DmaMaskS
	and al, 00000011b
	or al, 00000100b		
	out dx, al			
EndDisableDma:
	pop dx ax
	ret	

;déverouille le canal AL
EnableDma:
	push ax dx
	cmp al, 4			
	jae MasterDisableDma
	mov dx, DmaMaskS
	out dx, al		
	jmp EndEnableDma
MasterEnableDma:
	mov dx, DmaMaskS
	and al, 00000011b
	out dx, al			
EndEnableDma:
	pop dx ax
	ret	

;Efface le FlipFlop canal AL
ClrDmaFlipFlop:
	push ax dx
	cmp al, 4			
	jae MasterClrFlipFlopDma
	mov dx,DmaFlipFlopS
	xor ax, ax
	out dx, al		
	jmp EndClrFlipFlopDma
MasterClrFlipFlopDma:
	mov dx,DmaFlipFlopM
	xor ax, ax
	out dx, al			
EndClrFlipFlopDma:
	pop dx ax
	ret				
		
;Met le mode du canal al à ah	
SetDmaMode:
	push ax dx
	cmp al, 4			
	jae MasterSetDmaMode
	mov dx,DmaModeS
	or al, ah
	out dx, al	
	jmp EndSetDmaMode
MasterSetDmaMode:
	mov dx,DmaModeM
	and al, 00000011b
	or al, ah
	out dx, al		
EndSetDmaMode:
	pop dx ax
	ret	


;Met le page du canal al a ah
SetDmaPage:
	push ax bx dx si
	cmp al, 4			
	jae MasterSetDmaPage               
        	mov si, offset DmaPage
	xor dh, dh
        	xor bh, bh
        	mov bl, al
	mov dl, cs:[si+bx]
	xchg al, ah
	out dx, al		
	jmp EndSetDmaPage
MasterSetDmaPage:			
EndSetDmaPage:
	pop si dx bx ax
	ret				

;Met l'adresse du canal al a DS:BX	
SetDmaAdress:
  	 push ax bx cx dx si
	push ax
   	   mov ax, ds
     	   and ax, 0000111111111111b
     	  shl ax,4       	  
     	  add bx, ax
     	  mov ax, ds
   	  and ax, 1111000000000000b
   	  shr ax, 4
	mov cx,ax
 	pop ax
	push ax
	add ax,cx 	  
    	 call SetDmaPage
       	 pop ax
       	 call ClrDmaFlipFlop
        	mov si, offset DmaAdress
	xor dh, dh
	push  bx
        	xor bh, bh
        	mov bl, al
        	mov dl, byte ptr cs:[si+bx]  
	pop bx   
	 cmp al, 4			
	 jae MasterSetDmaAddress
	mov al, bh		
	out dx, al			
	mov al, bl			
	out dx, al			
	jmp EndSetDmaAddress
MasterSetDmaAddress:
	 mov al, bh			
	 out dx, al			
	call ClrDmaFlipFlop		
	mov al, bl			
	out dx, al			
EndSetDmaAddress:
	pop si dx cx bx ax
	ret		

;Spécifie au controleur DMA le nombre d'octets à transférer dans CX
SetDmaCount:
	push ax bx dx si
       	 call ClrDmaFlipFlop
       	 mov si, offset DmaCount
                  xor dh, dh
    	  xor bh, bh
   	  mov bl, al
     	  mov dl, byte ptr cs:[si+bx]
	cmp al, 4			
	jae MasterSetDmaCount     
	mov al, ch			
	out dx, al			
	mov al, cl			
	out dx, al			
	jmp EndSetDmaCount
MasterSetDmaCount:
	mov al, ch		
	out dx, al					
	call ClrDmaFlipFlop	
	mov al, cl			
	out dx, al		
EndSetDmaCount:
	pop si dx bx ax
	ret				

