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
        pusha
        in al,60h
        cmp cs:isstate,1
        jne nostate
        cmp al,57
        jne nof12
        mov cs:isstate,0
        jmp noF12
        nostate:
        cmp al,87
        jne NoF11
        push es
        push cs
        pop es
        mov di,offset infos
        mov ah,34
        int 47h
        mov al,cs:infos+7
        inc al
        and ax,111b
        int 47h
        pop es
        nof11:
        cmp al,88
        jne NoF12 
        mov ah,26
        int 47h
        call showstate
        mov cs:isstate,1
        sti
        waitt:
        cmp cs:isstate,0
        jne waitt
        mov ah,27
        int 47h 
        noF12:
        popa
        sti
        iret
        isstate db 0
        infos db 10 dup (0)

 showstate:
     push ds es       
     push ss
     push gs
     push fs
     push es
     push ds
     push cs  
     pushad
     pushfd

     push cs
     push cs
     pop es
     pop ds
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
     mov bx,8+6
     mov ah,21
     mov cl,6
     int 47h
showallREG:
     mov ah,6
     int 47h
     cmp bx,7
     jb nodr
     pop edx
     jmp popo
     nodr:
     mov ah,21
     mov cl,1
     int 47h
     xor edx,edx
     pop dx
     popo:
     mov ah,13
     int 47h
     mov ah,10
     mov cx,32
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
     ret

reg db 'State of registers',0
fla db 'Flags:',0 
regs db 'EDI:',0
     db 'ESI:',0
     db 'EBP:',0
     db 'ESP:',0
     db 'EBX:',0
     db 'EDX:',0
     db 'ECX:',0
     db 'EAX:',0
     db ' CS:',0
     db ' DS:',0
     db ' ES:',0
     db ' FS:',0
     db ' GS:',0
     db ' SS:',0
gr db '(',0
dr db ')',0
app db 'Press space to quit...',0

end start
