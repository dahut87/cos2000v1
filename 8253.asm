.model tiny
.486
smart
.code
org 0100h
start:
jmp tsr
db '8253'
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

