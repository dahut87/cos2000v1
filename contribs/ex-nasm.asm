[bits 16]		        ;16 bits
[org 0x0]			;Point d'entré en 0h
section .text			;Segment de code				

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
endofimport dd 0

realstart:
    push   msg
    call   far [cs:print]		;Afficher le texte (Showstring0)
	xor	   ax,ax
    int	   0x16		        ;Attendre l'appuie sur une touche
	retf		 	        ;retour far

msg db 'Hello World !!',0

