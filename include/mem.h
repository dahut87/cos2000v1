struc mb	                    ;Bloc de m�moire
check 	        db "NH"         ;signature du bloc de m�moire
isnotlast 	db 0             ;flag indiquant le dernier bloc
isresident	db 0             ;flag indiquant que le bloc est resident
reference	dw 0             ;pointeur vers le bloc parent
sizes		dw 0             ;taille du bloc en paragraphe de 16 octet
names		db 24 dup (0)    ;nom du bloc
ends mb	

struc exe	                    ;Executable COS
checks 	         db "CE"         ;signature de l'exe
major            db 1            ;N� version
checksum         dd 0            ;Checksum de l'exe
compressed       db 0            ;a 1 si compress� par RLE
exports          dw 0            ;importation de fonctions
imports          dw 0            ;exportation de fonctions
sections         dw 0            ;sections des blocs m�moire
starting         dw 15
ends exe	

struc descriptor
limit_low   dw 0
base_low    dw 0
base_middle db 0
dpltype     db 0
limit_high  db 0
base_high   db 0
ends descriptor


free        equ 0                 ;Reference quand libre
memorystart equ 0052h             ;premier bloc de la m�moire
