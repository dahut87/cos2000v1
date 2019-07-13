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
proc enableirq uses ax cx dx, irq:word
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
        ret
endp

;Desactive une interruption ‚lectronique
;Entr‚e : %0 - Num‚ro de l'interruption (0-15) … desactiver 0-7 = MASTERPIC , 8-15 = SLAVEPIC
proc disableirq uses ax cx dx, irq:word
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
        ret
endp


;Signale "End Of Interrupt" de l'interruption %0
proc seteoi uses ax dx, irq:word
       mov     ax,[irq]
       cmp     al,7
       jbe     .master
       mov     al,EOI
       out     SLAVEPIC,al
.master:
       mov     al,EOI
       out     MASTERPIC,al
       ret
endp


;Lit les masques d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
proc readimr uses bx dx, controleur:word
       mov     bx,[controleur]
       mov     dx,MASTERPIC+ IRQMASK
       cmp     bl,0
       jne     .master
       mov     dx,SLAVEPIC+ IRQMASK
.master:
       xor     ah,ah
       in      al,dx
       pop     dx
       ret
endp

;Lit le registre d'‚tat d'un contr“leur IRQ dans ax, 0 master ou slave 1 ds %1
proc readisr uses bx dx, controleur:word
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
       ret
endp


;Lit le registre d'‚tat d'un contr“leur IRQ dans al, 0 master ou slave 1 ds bh
proc readirr uses bx dx, controleur:word
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
       ret
endp

;carry si enable et pas carry si pas enable
proc isenableirq uses ax cx dx, irq:word
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
        ret
endp


;carry si enable et pas carry si pas enable
proc isinserviceirq uses ax cx dx, irq:word
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
        ret
endp


;carry si enable et pas carry si pas enable
proc isrequestirq uses ax cx dx, irq:word
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
        ret
endp


proc installirqhandler uses eax bx cx edx si di ds es
       push    fs
	virtual at 0
	.intsori ints
	end virtual
       stdcall    mbcreate,interruptionbloc,256*.intsori.sizeof
       mov     es,ax
       mov     ax,0x0000
       mov     ds,ax
       xor     si,si
.searchdummypointer:
	virtual at si
	.vector vector
	end virtual
	virtual at 0
	.vectorori vector
	end virtual
       mov     fs,[.vector.data.seg] 
       mov     bx,[.vector.data.off]
       cmp     byte [fs:bx],0xCF ;iret
       je      .founded
       add     si,.vectorori.sizeof
       cmp     si,256*4
       jb      .searchdummypointer
       xor     edx,edx
       jmp     .suite
.founded:
       mov     edx,[.vector.content]
.suite:
       xor     cx,cx
       xor     si,si
       xor     di,di
       cli
.copy:
	virtual at di
	.ints ints
	end virtual
       mov     [es:.ints.number],cl
       mov     [es:.ints.locked],0
       mov     [es:.ints.vector1.content],0
       mov     [es:.ints.vector3.content],0
       mov     [es:.ints.vector4.content],0
       mov     [es:.ints.vector5.content],0
       mov     [es:.ints.vector6.content],0
       mov     [es:.ints.vector7.content],0
       mov     [es:.ints.vector8.content],0
       mov     [es:.ints.launchedlow],0
       mov     [es:.ints.launchedhigh],0
       mov     [es:.ints.calledlow],0
       mov     [es:.ints.calledhigh],0
       mov     eax,[.vector.content]
       cmp     eax,edx
       je      .notarealvector
       mov     [es:.ints.vector1.content],eax
       mov     [es:.ints.activated],1
       jmp     .copynext
.notarealvector:
       mov     [es:.ints.vector1.content],0
       mov     [es:.ints.activated],0
.copynext:
       mov     bx,cx
       shl     bx,3
       sub     bx,cx
       add     bx,coupling
       mov     [.vector.data.seg],cs
       mov     [.vector.data.off],bx
       add     si,.vectorori.sizeof
       add     di,.intsori.sizeof
       inc     cl
       cmp     cl,0
       jne     .copy
.end:
       pop     fs
       sti
       ret
endp


interruptionbloc db '/interrupts',0


proc savecontext uses eax si ds, pointer:word
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
virtual at si
.regs regs
end virtual
pop   [.regs.sesp]
pop   [.regs.seip]
pop   [.regs.scs]
pop   [.regs.sebp]
pop   [.regs.sss]
pop   [.regs.sgs]
pop   [.regs.sfs]
pop   [.regs.ses]
pop   [.regs.sds]
pop   [.regs.sedi]
pop   [.regs.sesi]
pop   [.regs.sedx]
pop   [.regs.secx]
pop   [.regs.sebx]
pop   [.regs.seax]
pop   [.regs.seflags]
ret
endp

proc restorecontextg, pointer:word
mov     si,[pointer]
virtual at si
.regs regs
end virtual
pushd [cs:.regs.sesi]
pushd [cs:.regs.seflags]
mov eax,[cs:.regs.seax]
mov ebx,[cs:.regs.sebx]
mov ecx,[cs:.regs.secx]
mov edx,[cs:.regs.sedx]
mov edi,[cs:.regs.sedi]
mov ebp,[cs:.regs.sebp]
mov es,[cs:.regs.ses]
mov fs,[cs:.regs.sfs]
mov gs,[cs:.regs.sgs]
mov ds,[cs:.regs.sds]
popfd
pop esi
pop [cs:dummy]
db 0xCA,0x02,0x00 ;ret 2
endp



coupling:
repeat 256 
push %+256
push irqhandlers
ret
end repeat

interrupt dw 0
dummy dw 0
calling_reg regs
function_reg regs

irqhandlers:
cli
pop     [cs:interrupt]
stdcall    savecontext,calling_reg
stdcall    irqhandler,[cs:interrupt]
stdcall    restorecontextg,calling_reg
sti
iret

proc    irqhandler, int:word
push    cs
pop     ds
stdcall    mbfindsb,interruptionbloc,cs
jc      .end
mov     es,ax
mov     ax,[int] 
sub     ax,256
virtual at 0
.intsorig ints
end virtual
mov     cx,.intsorig.sizeof
mul     cx
mov     si,ax
virtual at si
.ints ints
end virtual
add     [es:.ints.calledlow],1
adc     [es:.ints.calledhigh],0
cmp     [es:.ints.activated],1
jne     .end
add     [es:.ints.launchedlow],1
adc     [es:.ints.launchedhigh],0
lea     si,[es:.ints.vector1]
mov     cl,8
.launchall:
virtual at si
.vector vector
end virtual
virtual at 0
.vectorori vector
end virtual
cmp     [es:.vector.content],0
je      .end
push    word [cs:calling_reg.seflags]
push    cs
push    .back
push    [es:.vector.data.seg]
push    [es:.vector.data.off]
stdcall    savecontext,function_reg
stdcall    restorecontextg,calling_reg
db 0xCB
.back:
cli
stdcall    savecontext,calling_reg
stdcall    restorecontextg,function_reg
.next:
add     si,.vectorori.sizeof
dec     cl
jnz     .launchall
.end:
ret
endp



