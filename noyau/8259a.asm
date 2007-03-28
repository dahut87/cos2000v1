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
PROC readimr FAR
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
endp readimr

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

;carry si enable et pas carry si pas enable
PROC isenableirq FAR
        ARG     @irq:word
        USES    ax,cx,dx
        mov     ax,[@irq]
        mov     dx,MASTERPIC+IRQMASK
        cmp     al,7
        jbe     @@master
        mov     dx,SLAVEPIC+IRQMASK
@@master:
        mov    cl,al
        and    cx,7        
        in     al,dx
        neg    al
        bt     ax,cx
        ret
endp isenableirq


;carry si enable et pas carry si pas enable
PROC isinserviceirq FAR
        ARG     @irq:word
        USES    ax,cx,dx
        mov     ax,[@irq]
        mov     dx,MASTERPIC
        cmp     al,7
        jbe     @@master
        mov     dx,SLAVEPIC
@@master:
        mov    cl,al
        mov    al,ISR
        out    dx,al
        and    cx,7        
        in     al,dx
        neg    al
        bt     ax,cx
        ret
endp isinserviceirq


;carry si enable et pas carry si pas enable
PROC isrequestirq FAR
        ARG     @irq:word
        USES    ax,cx,dx
        mov     ax,[@irq]
        mov     dx,MASTERPIC
        cmp     al,7
        jbe     @@master
        mov     dx,SLAVEPIC
@@master:
        mov    cl,al
        mov    al,IRR
        out    dx,al
        and    cx,7        
        in     al,dx
        neg    al
        bt     ax,cx
        ret
endp isrequestirq


PROC installirqhandler FAR
       USES    eax,bx,cx,edx,si,di,ds,es
       push    fs
       call    mbcreate,offset interruptionbloc,256*size ints
       mov     es,ax
       mov     ax,0x0000
       mov     ds,ax
       xor     si,si
@@searchdummypointer:
       mov     fs,[(vector si).data.seg] 
       mov     bx,[(vector si).data.off]
       cmp     [byte ptr fs:bx],0xCF ;iret
       je      @@founded
       add     si,size vector
       cmp     si,256*4
       jb      @@searchdummypointer
       xor     edx,edx
       jmp     @@suite
@@founded:
       mov     edx,[(vector si).content]
@@suite:
       xor     cx,cx
       xor     si,si
       xor     di,di
       cli
@@copy:
       mov     [es:(ints di).number],cl
       mov     [es:(ints di).locked],0
       mov     [es:(ints di).vector1.content],0
       mov     [es:(ints di).vector3.content],0
       mov     [es:(ints di).vector4.content],0
       mov     [es:(ints di).vector5.content],0
       mov     [es:(ints di).vector6.content],0
       mov     [es:(ints di).vector7.content],0
       mov     [es:(ints di).vector8.content],0
       mov     [es:(ints di).launchedlow],0
       mov     [es:(ints di).launchedhigh],0
       mov     [es:(ints di).calledlow],0
       mov     [es:(ints di).calledhigh],0
       mov     eax,[(vector si).content]
       cmp     eax,edx
       je      @@notarealvector
       mov     [es:(ints di).vector1.content],eax
       mov     [es:(ints di).activated],1
       jmp     @@copynext
@@notarealvector:
       mov     [es:(ints di).vector1.content],0
       mov     [es:(ints di).activated],0
@@copynext:
       mov     bx,cx
       shl     bx,3
       sub     bx,cx
       add     bx,offset coupling
       mov     [(vector si).data.seg],cs
       mov     [(vector si).data.off],bx
       add     si,size vector
       add     di,size ints
       inc     cl
       cmp     cl,0
       jne     @@copy
@@end:
       pop     fs
       sti
       ret
endp installirqhandler


interruptionbloc db '/interrupts',0


PROC savecontext FAR
ARG     @pointer:word
USES    eax,si,ds
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
mov   si,[@pointer]
mov   ds,[ss:bp+4]
mov   eax,ebp
mov   ax,[word ptr ss:bp]
push  eax
push  [word ptr ss:bp+4]
xor   eax,eax
mov   ax,[word ptr ss:bp+2]
push  eax  
mov   ax,bp
add   ax,4
push  eax 
pop   [(regs si).sesp]
pop   [(regs si).seip]
pop   [(regs si).scs]
pop   [(regs si).sebp]
pop   [(regs si).sss]
pop   [(regs si).sgs]
pop   [(regs si).sfs]
pop   [(regs si).ses]
pop   [(regs si).sds]
pop   [(regs si).sedi]
pop   [(regs si).sesi]
pop   [(regs si).sedx]
pop   [(regs si).secx]
pop   [(regs si).sebx]
pop   [(regs si).seax]
pop   [(regs si).seflags]
ret
endp savecontext

PROC restorecontextg FAR
ARG     @pointer:word
mov     si,[@pointer]
pushd [cs:(regs si).sesi]
pushd [cs:(regs si).seflags]
mov eax,[cs:(regs si).seax]
mov ebx,[cs:(regs si).sebx]
mov ecx,[cs:(regs si).secx]
mov edx,[cs:(regs si).sedx]
mov edi,[cs:(regs si).sedi]
mov ebp,[cs:(regs si).sebp]
mov es,[cs:(regs si).ses]
mov fs,[cs:(regs si).sfs]
mov gs,[cs:(regs si).sgs]
mov ds,[cs:(regs si).sds]
popfd
pop esi
pop [cs:dummy]
db 0xCA,0x02,0x00 ;retf 2
endp restorecontextg



coupling:
counter = 0
REPEAT 256 
push counter+256
push offset irqhandlers
ret
counter = counter + 1 
ENDM

interrupt dw 0
dummy dw 0
calling_reg regs <>
function_reg regs <>

irqhandlers:
cli
pop     [cs:interrupt]
call    savecontext,offset calling_reg
call    irqhandler,[cs:interrupt]
call    restorecontextg,offset calling_reg
sti
iret

PROC    irqhandler NEAR
ARG     @int:word
push    cs
pop     ds
call    mbfindsb,offset interruptionbloc,cs
jc      @@end
mov     es,ax
mov     ax,[@int] 
sub     ax,256
mov     cx,size ints
mul     cx
mov     si,ax
add     [es:(ints si).calledlow],1
adc     [es:(ints si).calledhigh],0
cmp     [es:(ints si).activated],1
jne     @@end
add     [es:(ints si).launchedlow],1
adc     [es:(ints si).launchedhigh],0
lea     si,[es:(ints si).vector1]
mov     cl,8
@@launchall:
cmp     [es:(vector si).content],0
je      @@end
push    [word ptr cs:calling_reg.seflags]
push    cs
push    offset @@back
push    [es:(vector si).data.seg]
push    [es:(vector si).data.off]
call    savecontext,offset function_reg
call    restorecontextg,offset calling_reg
db 0xCB
@@back:
cli
call    savecontext,offset calling_reg
call    restorecontextg,offset function_reg
@@next:
add     si,size vector
dec     cl
jnz     @@launchall
@@end:
ret
endp irqhandler







