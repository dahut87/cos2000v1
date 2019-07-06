;Adresses de port du controleur IRQ
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
 SLAVEFIRSTVECTOR  = 070h         ;electroniques

;OCW3 codes registres
 IRR  =   002h   ;Interrupt Request Register
 ISR  =   003h   ;In Service Register
;OCW3 et modes
 OCW3         =   008h   ;OCW3
 POLLING      =   004h   ;Polling bit


ISR = 0Bh ; Pas d'operation, pas de Poll, lire ISR  OCW3
IRR = 0Ah ; Pas d'operation, pas de Poll, lire IRR

;Autorise une interruption electronique
;Entree : %1 - Numero de l'interruption (0-15) à autoriser 0-7 = MASTERPIC , 8-15 = SLAVEPIC
proc enableirq, irq
        mov     ax,[irq]
        mov     dx,MASTERPIC+IRQMASK
        cmp     al,7
        jbe     .master
        mov     dx,SLAVEPIC+IRQMASK
.master:
        mov    cl,al
        and    cl,7
        mov    al,1
        shl    al,cl
        not    al
        mov    ah,al
        in     al,dx
        and    al,ah
        out    dx,al
        retf
endp

;Desactive une interruption ‚lectronique
;Entr‚e : %0 - Num‚ro de l'interruption (0-15) … desactiver 0-7 = MASTERPIC , 8-15 = SLAVEPIC
proc disableirq, irq
        mov     ax,[irq]
        mov     dx,MASTERPIC+IRQMASK
        cmp     al,7
        jbe     .master
        mov     dx,SLAVEPIC+IRQMASK
.master:
        mov    cl,al
        and    cl,7
        mov    al,1
        shl    al,cl
        not    al
        mov    ah,al
        in     al,dx
        or     al,ah
        out    dx,al
        retf
endp


;Signale "End Of Interrupt" de l'interruption %0
proc seteoi, irq
       mov     ax,[irq]
       cmp     al,7
       jbe     .master
       mov     al,EOI
       out     SLAVEPIC,al
.master:
       mov     al,EOI
       out     MASTERPIC,al
       retf
endp


;Lit les masques d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
proc readimr, controleurx
       mov     bx,[controleur]
       mov     dx,MASTERPIC+ IRQMASK
       cmp     bl,0
       jne     .master
       mov     dx,SLAVEPIC+ IRQMASK
.master:
       xor     ah,ah
       in      al,dx
       pop     dx
       retf
endp

;Lit le registre d'‚tat d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
proc readisr, controleur
       mov     bx,[controleur]
       mov     dx,MASTERPIC
       cmp     bh,0
       jne     .master
       mov     dx,SLAVEPIC
.master:
       mov     al,ISR
       out     dx,al
       xor     ah,ah
       in      al,dx
       retf
endp


;Lit le registre d'‚tat d'un contr“leur IRQ dans al, 0 master ou slave 1 ds bh
proc readirr, controleur
       mov     bx,[controleur]
       mov     dx,MASTERPIC
       cmp     bh,0
       jne     .master
       mov     dx,SLAVEPIC
.master:
       mov     al,IRR
       out     dx,al
       xor     ah,ah
       in      al,dx
       retf
endp

;carry si enable et pas carry si pas enable
proc isenableirq, irq
        mov     ax,[irq]
        mov     dx,MASTERPIC+IRQMASK
        cmp     al,7
        jbe     .master
        mov     dx,SLAVEPIC+IRQMASK
.master:
        mov    cl,al
        and    cx,7        
        in     al,dx
        neg    al
        bt     ax,cx
        retf
endp


;carry si enable et pas carry si pas enable
proc isinserviceirq, irq
        mov     ax,[irq]
        mov     dx,MASTERPIC
        cmp     al,7
        jbe     .master
        mov     dx,SLAVEPIC
.master:
        mov    cl,al
        mov    al,ISR
        out    dx,al
        and    cx,7        
        in     al,dx
        neg    al
        bt     ax,cx
        retf
endp


;carry si enable et pas carry si pas enable
proc isrequestirq, irq
        mov     ax,[irq]
        mov     dx,MASTERPIC
        cmp     al,7
        jbe     .master
        mov     dx,SLAVEPIC
.master:
        mov    cl,al
        mov    al,IRR
        out    dx,al
        and    cx,7        
        in     al,dx
        neg    al
        bt     ax,cx
        retf
endp


proc installirqhandler
       push    fs
       stdcall    mbcreate,interruptionbloc,256*ints.sizeof
       mov     es,ax
       mov     ax,0x0000
       mov     ds,ax
       xor     si,si
.searchdummypointer:
       mov     fs,[si+vector.data.seg] 
       mov     bx,[si+vector.data.off]
       cmp     byte [fs:bx],0xCF ;iret
       je      .founded
       add     si,vector.sizeof
       cmp     si,256*4
       jb      .searchdummypointer
       xor     edx,edx
       jmp     .suite
.founded:
       mov     edx,[si+vector.content]
.suite:
       xor     cx,cx
       xor     si,si
       xor     di,di
       cli
.copy:
       mov     [es:di+ints.number],cl
       mov     [es:di+ints.locked],0
       mov     [es:di+ints.vector1.content],0
       mov     [es:di+ints.vector3.content],0
       mov     [es:di+ints.vector4.content],0
       mov     [es:di+ints.vector5.content],0
       mov     [es:di+ints.vector6.content],0
       mov     [es:di+ints.vector7.content],0
       mov     [es:di+ints.vector8.content],0
       mov     [es:di+ints.launchedlow],0
       mov     [es:di+ints.launchedhigh],0
       mov     [es:di+ints.calledlow],0
       mov     [es:di+ints.calledhigh],0
       mov     eax,[si+vector.ints.content]
       cmp     eax,edx
       je      .notarealvector
       mov     [es:di+ints.vector1.content],eax
       mov     [es:di+ints.activated],1
       jmp     .copynext
.notarealvector:
       mov     [es:di+ints.vector1.content],0
       mov     [es:di+ints.activated],0
.copynext:
       mov     bx,cx
       shl     bx,3
       sub     bx,cx
       add     bx,coupling
       mov     [si+vector.data.seg],cs
       mov     [si+vector.data.off],bx
       add     si,vector.sizeof
       add     di,ints.sizeof
       inc     cl
       cmp     cl,0
       jne     .copy
.end:
       pop     fs
       sti
       retf
endp


interruptionbloc db '/interrupts',0


proc savecontext, pointer
pushfd
push eax
push ebx
push ecx
push edx
push esi
push edi
push  ds
push  es
push  fs
push  gs
push  ss
mov   si,[pointer]
mov   ds,[ss:bp+4]
mov   eax,ebp
mov   ax,word [ss:bp]
push  eax
push  word [ss:bp+4]
xor   eax,eax
mov   ax,word [ss:bp+2]
push  eax  
mov   ax,bp
add   ax,4
push  eax 
pop   [si+regs.sesp]
pop   [si+regs.seip]
pop   [si+regs.scs]
pop   [si+regs.sebp]
pop   [si+regs.sss]
pop   [si+regs.sgs]
pop   [si+regs.sfs]
pop   [si+regs.ses]
pop   [si+regs.sds]
pop   [si+regs.sedi]
pop   [si+regs.sesi]
pop   [si+regs.sedx]
pop   [si+regs.secx]
pop   [si+regs.sebx]
pop   [si+regs.seax]
pop   [si+regs.seflags]
retf
endp

proc restorecontextg, pointer
mov     si,[pointer]
pushd [cs:si+regs.sesi]
pushd [cs:si+regs.seflags]
mov eax,[cs:si+regs.seax]
mov ebx,[cs:si+regs.sebx]
mov ecx,[cs:si+regs.secx]
mov edx,[cs:si+regs.sedx]
mov edi,[cs:si+regs.sedi]
mov ebp,[cs:si+regs.sebp]
mov es,[cs:si+regs.ses]
mov fs,[cs:si+regs.sfs]
mov gs,[cs:si+regs.sgs]
mov ds,[cs:si+regs.sds]
popfd
pop esi
pop [cs:dummy]
db 0xCA,0x02,0x00 ;retf 2
endp



coupling:
repeat 256 
push %+256
push offset irqhandlers
ret
end repeat

interrupt dw 0
dummy dw 0
calling_reg regs
function_reg regs

irqhandlers:
cli
pop     [cs:interrupt]
stdcall    savecontext,offset calling_reg
stdcall    irqhandler,[cs:interrupt]
stdcall    restorecontextg,offset calling_reg
sti
iret

proc    irqhandler, int
push    cs
pop     ds
stdcall    mbfindsb,offset interruptionbloc,cs
jc      .end
mov     es,ax
mov     ax,[int] 
sub     ax,256
mov     cx,ints.sizeof
mul     cx
mov     si,ax
add     [es:si+ints.calledlow],1
adc     [es:si+ints.calledhigh],0
cmp     [es:si+ints.activated],1
jne     .end
add     [es:si+ints.launchedlow],1
adc     [es:si+ints.launchedhigh],0
lea     si,[es:si+ints.vector1]
mov     cl,8
.launchall:
cmp     [es:si+vector.content],0
je      .end
push    word [cs:calling_reg.seflags]
push    cs
push    offset .back
push    [es:si+vector.data.seg]
push    [es:si+vector.data.off]
stdcall    savecontext,offset function_reg
stdcall    restorecontextg,offset calling_reg
db 0xCB
.back:
cli
stdcall    savecontext,offset calling_reg
stdcall    restorecontextg,offset function_reg
.next:
add     si,vector.sizeof
dec     cl
jnz     .launchall
.end:
ret
endp







