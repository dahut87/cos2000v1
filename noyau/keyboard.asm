.model tiny
.486
smart
.code

org 0100h

start:

jmp tsr
offsets dd 0
db 'KEYBOARD'
tsr:
 pushf
 db  2eh,0ffh,1eh
 dw  offsets
        cli
        mov cs:feax,eax
        in al,60h
        cmp cs:isstate,1
        jne nostate
        cmp al,57
        jne endof
        mov cs:isstate,0
        jmp endof
        nostate:
        cmp al,87
        je F11
        cmp al,88
        je F12
        endof:
        mov eax,cs:feax
        sti
        iret
        isstate db 0
        infos db 40 dup (0)

F11:
     push ax di es
     push cs
     pop es
     mov di,offset infos
     mov ah,34
     int 47h
     mov al,cs:[di+7]
     inc al
     cmp al,9
     jbe notabove
     mov al,0
notabove:
     mov ah,0
     int 47h
     pop es di ax
     jmp endof


f12:
     mov cs:isstate,1
     pop word ptr cs:fip
     pop word ptr cs:fcs
     pop dword ptr cs:ffl
     mov cs:fesp,esp
     push ds es
     pusha
     push word ptr cs:fip
     push gs
     push fs
     push ss
     push es
     push ds
     push word ptr cs:fcs
     push dword ptr cs:fesp
     push ebp
     push edi
     push esi
     push edx
     push ecx
     push ebx
     push eax
     push dword ptr cs:ffl
     push cs
     push cs
     pop es
     pop ds
     mov ah,26
     int 47h  
     mov ah,2
     int 47h
     mov ah,21
     mov cl,4
     int 47h
     mov ah,13
     mov si,offset reg
     int 47h
     mov ah,6
     int 47h
     mov ah,21
     mov cl,7
     int 47h
     mov ah,13
     mov si,offset fla
     int 47h
     pop edx
     mov cx,32
     mov ah,11
     int 47h
     mov ah,5
     int 47h
     mov ah,10
     int 47h
     mov si,offset regs
     mov bx,8+7
     mov ah,21
     mov cl,6
     int 47h
showallREG:
     mov ah,6
     int 47h
     cmp bx,8
     jb nodr
     pop edx
     mov cx,32
     jmp popo
     nodr:
     mov ah,21
     mov cl,1
     int 47h
     xor edx,edx
     pop dx
     mov cx,16
     popo:
     mov ah,13
     int 47h
     mov ah,10
     int 47h
     mov ah,5
     int 47h
     push si
     mov si,offset gr
     mov ah,13
     int 47h
     mov ah,8
     int 47h
     mov si,offset dr
     mov ah,13
     int 47h
     pop si
     add si,5
     dec bx
     jnz showallreg
     mov ah,34
     mov di,offset infos
     int 47h
     mov ah,25
     mov bl,cs:infos
     xor bh,bh
     dec bl
     int 47h
     mov si,offset app
     mov ah,13
     int 47h
     mov ah,32
     mov bl,cs:infos
     xor bh,bh
     mov di,ax
     dec di
     mov cl,116
     int 47h
     pop es ds     
     sti
     waitt:
     cmp cs:isstate,0
     jne waitt
     mov ah,27
     int 47h
     popa
     pop es ds
     push dword ptr cs:ffl
     push word ptr cs:fcs
     push word ptr cs:fip  
     jmp endof

reg db ' State of registers',0
fla db 'Eflags:',0 
regs db 'EAX:',0
     db 'EBX:',0
     db 'ECX:',0
     db 'EDX:',0
     db 'ESI:',0
     db 'EDI:',0
     db 'EBP:',0
     db 'ESP:',0
     db ' CS:',0
     db ' DS:',0
     db ' ES:',0
     db ' FS:',0
     db ' GS:',0
     db ' SS:',0
     db ' IP:',0
gr db '(',0
dr db ')',0
app db 'Press space to quit...',0
ffl dd 0
fcs dw 0
fip dw 0
fesp dd 0
feax dd 0
end start
