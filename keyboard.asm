.model tiny
.486
smart
.code
org 0100h

start:
mov al,0D0h
call keybcmd
in al,60h
ret
 

;============= PPI port A (Programmable Peripheral interface) ================
;8048 (old XT) 8042 (old AT) 8741 8742 (with PS2 mouse)
; R/W
;Port 60h : Scancode & keyboarddata
overrun  equ 000h ;Error too many keys pressed
BATend   equ 0AAh ;End of the test BAT (basic test assurance)
MF2code  equ 0ABh ;Code send by MF2 keyboard
MF2code2 equ 041h ;Code send by MF2 keyboard
echo     equ 0EEh ;Send by echo command
Ack      equ 0FAh ;Send by every comman exept EEh et FEh (Aknoledge)
BATerror equ 0FCh ;BAT failed
Resend   equ 0FEh ;Resend data please
Error    equ 0FFh ;Error of keyboard

;Port 60h : command data
led    equ 0EDh ;set the led like you want
echo   equ 0EEh ;Echo byte for diagnostic
Set    equ 0F0h ;Choose the Set of scancode
Id     equ 0F2h ;Identify the keyboard
rate   equ 0F3h ;Set the specified typematic rate
enable equ 0F4h ;clear buffer and scan
reset  equ 0F5h ;Reset and no scan
reset2 equ 0F6h ;Reset and scan

;============= PPI port A (Programmable Peripheral interface) ================
;8048 (old XT) 8042 (old AT) 8741 8742 (with PS2 mouse)
; R/W
;Port 61h

;==================== Data and control keyboard registers ===================
;8042 (old AT) 8741 8742 (with PS2 mouse)
; R/W
;Port 64h



;Envoie la commande AL aux clavier et si besoin est la donn‚e DL
Keybcmd:
push ax
xchg al,ah
xor cx,cx
clearbuffer:
in al,64h
test al,02h
loopnz clearbuffer
jnz errorkb
xchg al,ah
out 64h,al
clearbuffer2:
in al,64h
test al,02h
loopnz clearbuffer2
jnz errorkb  
cmp dl,0
je endkeyb
mov al,dl
out 60h,al
endkeyb:
clc
pop ax
ret
errorkb:
stc
pop ax
ret





end start
