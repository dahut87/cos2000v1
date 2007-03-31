.model tiny			;model tiny (.com)
.486				;Pour processeur 80486
Smart				;Optimisations
.code				;Segment de code

org 0h			    ;Point d'entré en 0h

checks 	         db "CE"           ;signature de l'exe
major            db 1              ;N° version
checksum         dd 0              ;Checksum de l'exe
compressed       db 0              ;a 1 si compressé par RLE
exports          dw 0              ;importation de fonctions
imports          dw imported       ;exportation de fonctions
sections         dw 0              ;sections des blocs mémoire
starting         dw realstart

imported:
db "VIDEO.LIB::print",0
print dd 0

start:
    push   msg
    call   far [cs:print]		;Afficher le texte (Showstring0)
	xor	   ax,ax
    int	   16h		        ;Attendre l'appuie sur une touche
	db	   0CBH             ;retour far

msg db 'Hello World !!',0

end start

