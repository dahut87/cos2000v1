.model tiny
.486
smart
.code
org 0h
start:
jmp tsr
db 'PIC8259A'
Tsr:
cli
cmp ax,1234h
jne nomore
mov ax,4321h
jmp itsok
nomore:
push bx
mov bl,ah
xor bh,bh
shl bx,1
mov bx,cs:[bx].tables
mov cs:current,bx
pop bx
call cs:current
itsok:
jnc noerror
push bp
mov bp,sp
or byte ptr [bp+6],1b
pop bp
mov ax,cs
shl eax,16
mov ax,cs:current
jmp endofint
noerror:
push bp
mov bp,sp
and byte ptr [bp+6],0FEh
pop bp
endofint:
sti
iret
current dw 0
tables  dw enableirq
        dw disableirq
        dw readmaskirq
        dw readirr
        dw readisr
        dw installhandler
        dw replacehandler
        dw getint
        dw setint
        dw seteoi

;Adresses de port du contr“leur IRQ
 MASTERPIC      =    020h          ;Adresse de base du PIC maŒtre 
 SLAVEPIC       =    0A0h          ;Adresse de base du PIC esclave 
 IRQMASK        =    001h          ;Offset sur port de masquage 

;Commandes IRQ OCW2
 DISABLEROTATION =    000h          ;Desactiver la rotation de priorités en mode EOI automatique 
 EOI             =    020h          ;End of Interrupt non sp‚cifi‚ 
 COMMANDEOI	 =    060h          ;Commande EOI particulière
 ENABLEROTATION  =    080h          ;Activer la rotation de priorités en mode EOI automatique
 ROTATIONNOSPEC	 =    0A0h          ;Rotation des priorités en mode EOI automatique
 SETPRIORITY     =    0C0h          ;Definir la priorité
 ROTATIONSPEC    =    0E0h          ;Rotation des priorités en mode EOI spécifié

;Position des vecteurs d'interruptions
 MASTERFIRSTVECTOR = 008h         ;Vecteurs logiciels des interruptions 
 SLAVEFIRSTVECTOR  = 070h         ;‚lectroniques      

;OCW3 codes registres
 IRR  =   002h   ;Interrupt Request Register
 ISR  =   003h   ;In Service Register
;OCW3 et modes   
 OCW3         =   008h   ;OCW3
 POLLING      =   004h   ;Polling bit


ISR = 0Bh ; Pas d'op‚ration, pas de Poll, lire ISR  OCW3
IRR = 0Ah ; Pas d'op‚ration, pas de Poll, lire IRR    


;Autorise une interruption ‚lectronique
;Entr‚e : AL - Num‚ro de l'interruption (0-15) … autoriser 0-7 = MASTERPIC , 8-15 = SLAVEPIC        
EnableIRQ:
push ax cx dx
mov dx,MASTERPIC+IRQMASK        
cmp al,7
jbe master
mov dx,SLAVEPIC+IRQMASK        
master:
mov cl,al
and cl,7
mov al,1
shl al,cl
not al
mov ah,al
in al,dx
and al,ah
out dx,al
pop dx cx ax
ret

;Desactive une interruption ‚lectronique
;Entr‚e : AL - Num‚ro de l'interruption (0-15) … desactiver 0-7 = MASTERPIC , 8-15 = SLAVEPIC        
DisableIRQ:
push ax cx dx
mov dx,MASTERPIC+IRQMASK        
cmp al,7
jbe master2
mov dx,SLAVEPIC+IRQMASK        
master2:
mov cl,al
and cl,7
mov al,1
shl al,cl
mov ah,al
in al,dx
or al,ah
out dx,al
pop dx cx ax
ret

;Signale "End Of Interrupt" de l'interruption al
SetEOI:
push ax dx
cmp al,7
jbe master3
mov al,EOI
out SLAVEPIC,al
master3: 
mov al,EOI
out MASTERPIC,al        
pop dx ax
ret
                     
;Lit les masques d'un contr“leur IRQ dans al, 0 master ou slave 1 ds bh
ReadmaskIrq:
push dx
mov dx,MASTERPIC+ IRQMASK
cmp bh,0
jne Master5
mov dx,SLAVEPIC+ IRQMASK
master5:
in al,dx
pop dx
ret

;Lit le registre d'‚tat d'un contr“leur IRQ dans al, 0 master ou slave 1 ds bh
ReadISR:
push dx
mov dx,MASTERPIC
cmp bh,0
jne Master6
mov dx,SLAVEPIC
master6:
mov al,isr
out dx,al
in al,dx
pop dx
ret

;Lit le registre d'‚tat d'un contr“leur IRQ dans al, 0 master ou slave 1 ds bh
ReadIRR:
push dx
mov dx,MASTERPIC
cmp bh,0
jne Master7
mov dx,SLAVEPIC
master7:
mov al,irr
out dx,al
in al,dx
pop dx
ret

;remplace le handler pointer par ds:si en bx:100h interruption ax
replacehandler:
push ax bx cx si di ds es
mov es,bx
mov di,0100h
mov ah,4
int 48h
jc  reph
mov bx,ax
call getint
mov es:[102h],si
mov es:[104h],ds
call setint
reph:
pop es ds di si cx bx ax
ret
      
;install le handler pointer par ds:si en bx:100h interruption ax
installhandler:
push bx cx di es
mov es,bx
mov di,100h
mov ah,4
int 48h
jc inh
mov bx,ax
call setint
inh:
pop es di cx bx
ret    

;met es:di le handle de l'int al
setint:
push ax bx ds
call disableirq
cli
xor ah,ah
mov bx,ax
shl bx,2
xor ax,ax
mov ds,ax
mov ds:[bx],di
mov ds:[bx+2],es
pop ds bx ax
sti
call enableirq
ret

;met ds:si le handle de l'int al
getint:
push ax bx es
xor ah,ah
mov bx,ax
shl bx,2
xor ax,ax
mov es,ax
mov si,es:[bx]
mov ds,es:[bx+2]
pop es bx ax
ret 


end start

