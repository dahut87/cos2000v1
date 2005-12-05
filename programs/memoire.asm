.model tiny
.486
smart
.code

org 0h

include ..\include\mem.h
include ..\include\divers.h

start:
header exe <,1,0,,,offset imports,,>

realstart:
push offset msg
call [print]

xor cx,cx
listmcb:
mov ah,4
int 49h
jc fino
inc cx

;placement mémoire
mov dx,gs
inc dx
inc dx
push edx

;parent
cmp gs:[MB.Reference],0
je next
mov dx,gs:[MB.Reference]
dec dx
dec dx
push dx
push offset MB.Names
jmp suitemn
next:
push cs
push offset none
suitemn:

;Resident
cmp gs:[MB.IsResident],true
jne notresident
push offset resident
jmp suitelistmcb
notresident:
push offset nonresident
suitelistmcb:

;taille memoire
xor edx,edx
mov dx,gs:[MB.Sizes]
shl edx,4
push 6
push edx

;nom
push gs
push offset MB.Names

push offset line
call [print]

jmp listmcb
fino:
db 0CBh
resident       db "oui",0
nonresident    db "non",0
line           db "%0P\h15%w\h24%0\h30%0P\h46%hW\l",0
msg            db "Memory manager V1.5\lNom            Taille   Res   Parent          Mem\l",0
none           db ".",0

imports:
        db "VIDEO.LIB::print",0
print   dd 0
        dw 0
        
end start
