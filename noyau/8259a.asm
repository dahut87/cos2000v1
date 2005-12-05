.model tiny,StdCall
.486
.code
Locals
jumps

org 0h

include ..\include\mem.h
include ..\include\bmp.h

start:
header exe <,1,0,,,,offset exports,>

exports:
         db "enableirq",0
         dw enableirq
         db "disableirq",0
         dw enableirq
         db "readmaskirq",0
         dw readmaskirq
         db "readirr",0
         dw readirr
         db "readisr",0
         dw readisr
         db "installhandler",0
         dw installhandler
         db "replacehandler",0
         dw replacehandler
         db "getint",0
         dw getint
         db "setint",0
         dw setint
         db "seteoi",0
         dw seteoi
         dw 0

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
;Entr‚e : %1 - Num‚ro de l'interruption (0-15) … autoriser 0-7 = MASTERPIC , 8-15 = SLAVEPIC
EnableIRQ PROC FAR
        ARG     @irq:word
        USES    ax,cx,dx
        mov     ax,[@irq]
        mov     dx,MASTERPIC+IRQMASK
        cmp     al,7
        jbe     @@master
        mov     dx,SLAVEPIC+IRQMASK
@@master:
        mov    cl,al
        and    cl,7
        mov    al,1
        shl    al,cl
        not    al
        mov    ah,al
        in     al,dx
        and    al,ah
        out    dx,al
        ret
EnableIRQ endp

;Desactive une interruption ‚lectronique
;Entr‚e : %0 - Num‚ro de l'interruption (0-15) … desactiver 0-7 = MASTERPIC , 8-15 = SLAVEPIC
DisableIRQ PROC FAR
        ARG     @irq:word
        USES    ax,cx,dx
        mov     ax,[@irq]
        mov     dx,MASTERPIC+IRQMASK
        cmp     al,7
        jbe     @@master
        mov     dx,SLAVEPIC+IRQMASK
@@master:
        mov    cl,al
        and    cl,7
        mov    al,1
        shl    al,cl
        not    al
        mov    ah,al
        in     al,dx
        or     al,ah
        out    dx,al
        ret
DisableIRQ endp


;Signale "End Of Interrupt" de l'interruption %0
SetEOI PROC FAR
       ARG     @irq:word
       USES    ax,dx
       mov     ax,[@irq]
       cmp     al,7
       jbe     @@master
       mov     al,EOI
       out     SLAVEPIC,al
@@master:
       mov     al,EOI
       out     MASTERPIC,al
       ret
DisableIRQ endp


;Lit les masques d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
ReadmaskIrq PROC FAR
       ARG     @controleur:word
       USES    bx,dx
       mov     bx,[@controleur]
       mov     dx,MASTERPIC+ IRQMASK
       cmp     bl,0
       jne     @@master
       mov     dx,SLAVEPIC+ IRQMASK
@@master:
       xor     ah,ah
       in      al,dx
       pop     dx
       ret
ReadmaskIrq endp

;Lit le registre d'‚tat d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
ReadISR PROC FAR
       ARG     @controleur:word
       USES    bx,dx
       mov     bx,[@controleur]
       mov     dx,MASTERPIC
       cmp     bh,0
       jne     @@master
       mov     dx,SLAVEPIC
@@master:
       mov     al,isr
       out     dx,al
       xor     ah,ah
       in      al,dx
       ret
ReadISR endp


;Lit le registre d'‚tat d'un contr“leur IRQ dans al, 0 master ou slave 1 ds bh
ReadIRR PROC FAR
       ARG     @controleur:word
       USES    bx,dx
       mov     bx,[@controleur]
       mov     dx,MASTERPIC
       cmp     bh,0
       jne     @@master
       mov     dx,SLAVEPIC
@@master:
       mov     al,irr
       out     dx,al
       xor     ah,ah
       in      al,dx
       ret
ReadIRR endp

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

