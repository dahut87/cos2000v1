MB	struc
Check 	         dw 'NH'
IsNotLast 	db 0
IsResident	db 0
Reference	dw 0
Sizes		dw 0
Names		db 24 dup (0)
MB	ends

Free  equ 0
memorystart equ 1000h
