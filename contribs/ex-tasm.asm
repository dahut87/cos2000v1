.model tiny			;model tiny (.com)
.486				;Pour processeur 80486
Smart				;Optimisations
.code				;Segment de code

org 0100h			;Point d'entré en 0100h

start:
	mov	ah,0Dh		
	mov	si,offset msg
	int	47h		;Afficher le texte (Showstring0)
	xor	ax,ax
	int	16h		;Attendre l'appuie sur une touche
	db	0CBH            ;retour far

msg db 'Hello World',0

end start

