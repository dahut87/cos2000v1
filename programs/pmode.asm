.model tiny
.486p
smart
.code

org 0h

start:
mov eax,cr0
or al,1
mov cr0,eax

db 0CBh

end start
