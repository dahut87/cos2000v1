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
PROC enableirq FAR
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
endp enableirq

;Desactive une interruption ‚lectronique
;Entr‚e : %0 - Num‚ro de l'interruption (0-15) … desactiver 0-7 = MASTERPIC , 8-15 = SLAVEPIC
PROC disableirq FAR
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
endp disableirq


;Signale "End Of Interrupt" de l'interruption %0
PROC seteoi FAR
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
endp seteoi


;Lit les masques d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
PROC readmaskirq FAR
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
endp readmaskirq

;Lit le registre d'‚tat d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
PROC readisr FAR
       ARG     @controleur:word
       USES    bx,dx
       mov     bx,[@controleur]
       mov     dx,MASTERPIC
       cmp     bh,0
       jne     @@master
       mov     dx,SLAVEPIC
@@master:
       mov     al,ISR
       out     dx,al
       xor     ah,ah
       in      al,dx
       ret
endp readisr


;Lit le registre d'‚tat d'un contr“leur IRQ dans al, 0 master ou slave 1 ds bh
PROC readirr FAR
       ARG     @controleur:word
       USES    bx,dx
       mov     bx,[@controleur]
       mov     dx,MASTERPIC
       cmp     bh,0
       jne     @@master
       mov     dx,SLAVEPIC
@@master:
       mov     al,IRR
       out     dx,al
       xor     ah,ah
       in      al,dx
       ret
endp readirr