[bits 16]		        ;16 bits
[org 0x0100]			;Point d'entré en 0100h
section .text			;Segment de code				

start:
	mov	ah,0x0D		
	mov	si,msg
	int	0x47		;Afficher le texte (Showstring0)
	xor	ax,ax
	int	0x16		;Attendre l'appuie sur une touche
	retf		 	;retour far

msg db 'Hello World',0

