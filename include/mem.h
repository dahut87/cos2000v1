MB	struc                    ;Bloc de mémoire
Check 	         dw 'NH'         ;signature du bloc de mémoire
IsNotLast 	db 0             ;flag indiquant le dernier bloc
IsResident	db 0             ;flag indiquant que le bloc est resident
Reference	dw 0             ;pointeur vers le bloc parent
Sizes		dw 0             ;taille du bloc en paragraphe de 16 octet
Names		db 24 dup (0)    ;nom du bloc
MB	ends

exe	struc                    ;Executable COS
Checks 	         db "CE"         ;signature de l'exe
major            db 1            ;N° version majeur
minor            db 0            ;N° version mineur
checksum         dd 0            ;Checksum de l'exe
compressed       db 0            ;a 1 si compressé par RLE
import           dw 0            ;importation de fonctions
export           dw 0            ;exportation de fonctions
blocs          dw 0              ;sections des blocs mémoire
exe	ends


Free        equ 0                 ;Reference quand libre
memorystart equ 1000h             ;premier bloc de la mémoire
