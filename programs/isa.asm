use16
align 1

include "..\include\mem.h"
include "..\include\divers.h"

org 0h

start:
header exe 1

realstart:
retf

PNP_ADR_PORT        equ 0x279
PNP_WRITE_PORT      equ	0xA79
;MIN and MAX READ_ADDR must have the bottom two bits set
MIN_READ_ADDR	    equ	0x203
MAX_READ_ADDR	    equ	0x3FF
;READ_ADDR_STEP must be a multiple of 4
READ_ADDR_STEP	    equ	8

;bits
CONFIG_WAIT_FOR_KEY equ	0x02
CONFIG_RESET_CSN    equ	0x04
IDENT_LEN           equ	9

;renvoie le timer en ax
ctc:
    cli
    mov     dx,043h
    mov     al,0
    out     dx,al
    mov     dx,40h
    in      al,dx
    mov     ah,al
    in      al,dx
    sti
    ret
    
;attend pendant ax microsecondes
usleep:
