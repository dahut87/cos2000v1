.model tiny
.486
smart
.code

org 0100h

start:
mov si,offset message
mov ah,13
int 47h
mov ah,2
int 74h
db 0CBh

message db 'Activation de la souris',0
end start
