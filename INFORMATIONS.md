![logo](https://github.com/dahut87/cos2000v1/raw/master/graphisme/logo.png)
## Documentation d'origine (importée)

COS 2000
Compatible Operating System

 

	Pr�sentation
	Comment l�installer
	Mode d�emploi
	Faire un programme pour COS
	Liste des APIs
	D�tail des APIs
	En cas de probl�me
	
	mailto:nicolas@palon.fr


Pr�sentation

	COS2000, par d�finition, est syst�me d'exploitation. Celui-ci prend la direction des op�rations � partir du moment o� le  PC est mis sous tension (Apr�s le BIOS). Il g�re tous les p�riph�riques rattach�s au PC et offre aux  programmeurs les moyens de d�velopper des applications compatibles en fournissant des APIs (Application Programming Interface). COS2000 est bas� sur un concept particulier qui est d'offrir aux programmeurs un maximum de fonctions int�gr�es pour faciliter le travail des programmeurs et r�duire la taille des programmes.

Comment l'installer ?

	Pour installer COS2000 :

	Sous dos/windows 9x

		  Ins�rez une disquette 1.44 Mo vierge ou inutile dans votre lecteur.
		  Lancez le programme SETUP.COM situ� dans le dossier de COS2000.
- Si celui ci ne d�tecte pas d'erreur, COS2000 est install� !


	Sous windows NT/Xp

		  Ins�rez une disquette 1.44 Mo vierge ou inutile dans votre lecteur.
		  Lancez le programme SETUP.EXE situ� dans le dossier de COS2000.
- Si celui ci ne d�tecte pas d'erreur, COS2000 est install� !


	Sous Linux

		  Ins�rez une disquette 1.44 Mo vierge ou inutile dans votre lecteur.
		  Lancez le programme SETUP.SH situ� dans le dossier de COS2000.
- Si celui ci ne d�tecte pas d'erreur, COS2000 est install� !

	Pour lancer COS2000 :

		  Ins�rez la disquette o� COS2000 est install�.
		  Veillez que dans le BIOS vous puissiez d�marrer � partir de A:.
		  Red�marrer votre ordinateur et vous serez sur COS2000. 



Mode d'emploi

	L�interpr�teur de commande COS est le premier logiciel qui est lanc� au d�marrage. A partir de celui-ci vous pouvez ex�cuter quelques commandes ou logiciels. 

En plus des logiciels, l'interpr�teur de commandes peut ex�cuter 6 commandes :

	QUIT
	Quitte l'interpr�teur.

	VERS
	Donne la version de COS2000.

	CLEAR
	Efface l'�cran.

	REBOOT
	Red�marre le PC.

	CMDS
	Donne la liste des commandes disponibles.

	MODE [mode]
Permet de changer de mode vid�o. [mode] doit �tre un entier compris entre 1 et 9. les modes au del� de 4 sont des modes graphiques � texte �mul�. Il est d�conseill� de les utiliser car il est parfois impossible de revenir aux modes texte.

	DISK
	Permet de lire un support disquette 1.44 Mo au format FAT12.

	CD
	Change le dossier actuel vers celui sp�cifi�.

	DIR
	Permet de lister le contenu du dossier actuel.

	MEM
	Permet de lister le contenu du dossier actuel.


Faire un programme pour COS

	Toute contribution � COS 2000 en terme de programme est la bienvenue, un r�pertoire � contribs � contiendra les programmes des diff�rents contributeurs. Aucune modification a ceux-ci ne sera faire sans l�accord explicite de l�auteur. Pour une contribution �crivez moi a l�adresse mailto:nicolas@palon.fr.

Pour l�instant il n�y a aucun formatage particulier du code � respecter pour faire un programme pour COS 2000. Il faut pour l�instant seulement un point d�entr�e en 0100h comme un .COM de dos, 64 Ko sont donc disponible au programme, la pile utilis� est celle du syst�me d�exploitation, c�est donc le seul segment qui ne sera pas initialis� comme les autres.


 
	





Pour clore le programme il suffit de faire un retour far.
Exemple avec un Hello Word.
	
	Avec tasm

.model tiny			;model tiny (.com)
.486					;Pour processeur 80486
Smart				;Optimisations
.code				;Segment de code

org 0100h				;Point d�entr� en 0100h

start:
	mov	ah,0Dh		
	mov	si,offset msg
	int	47h			;Afficher le texte (Showstring0)
	xor	ax,ax
	int	16h			;Attendre l�appuie sur une touche
	db	0CBH ;retour far

msg db �Hello World�,0

end start

	Avec nasm

[bits 16]				;16 bits
[org 0x0100]			;Point d�entr� en 0100h
section .text			;Segment de code				

start:
	mov	ah,0x0D		
	mov	si,msg
	int	0x47			;Afficher le texte (Showstring0)
	xor	ax,ax
	int	0x16			;Attendre l�appuie sur une touche
	retf		 		;retour far

msg db �Hello World�,0

	
	Comme vous pouvez le constater l�appel des APIs de Cos se r�alise par le biais d�interruptions logiciels dont voici la liste.

Liste des APIs

disque.sys : Gestionnaires FAT12 et Disquette
Interruption 48h (Disquette uniquement)

00h 	readsector
          	01h	writesector
          	02h	verifysector 
          	03h	initdrive
          	04h	loadfile
          	05h 	compressrle
         	06h	decompressrle
          	07h	findfirstfile
          	08h	findnextfile
          	09h	getfreespace
          	0Ah 	searchfile
         	0Bh	getname
          	0Ch	getserial
          	0Dh	changedir
          	0Eh 	readcluster
         	0Fh	writecluster
	10h	getdir
11h	projfile
11h	execfile

port.sys : Gestionnaires port parall�le
Interruption 0Dh (LPT1) ou 0Fh (LPT2)

00h 	getlptin
          	01h	getlptout
          	02h	getlptinout
         	03h	setlptin
         	04h	setlptout
         	05h 	setlptinout
         	06h	getlpt
	07h	getfirstlpt
	08h	setemettor
	09h	setreceptor
	0Ah	settimeout
	0Bh	gettimeout
	0Ch	receivelpt
	0Dh	sendlpt
	0Eh	receivelptblock
	0Fh	sendlptblock
	10h	receivecommand
	11h	sendcommand

souris.sys : Gestionnaires souris
Interruption 74h (PS/2)

00h	cmdmouse
          	01h	cmdmouse2
         	02h	detectmouse
         	03h	getmouse
         	04h 	getmousescreen
         	05h	configmouse

8259a.sys : Gestionnaires contr�leur d'interruption programmable
Interruption 50h (Ma�tre et esclave)

00h 	enableirq
          	01h	disableirq
          	02h	readmaskirq
         	03h	readirr
         	04h	readisr
         	05h 	installhandler
         	06h	replacehandler
	07h	getint
	08h	setint
	09h	seteoi

video.sys : Gestionnaires de la carte vid�o
Interruption 47h (VGA)

00h 	setvideomode
          	01h	getvideomode
          	02h	cleartext
         	03h	changefont
         	04h	loadfont
         	05h 	space
         	06h	line
	07h	showchar
	08h	showint
	09h	showsigned
	0Ah	showhex
	0Bh	showbin
	0Ch	showstring
	0Dh	showstring0
	0Eh	showcharat
	0Fh	showintat
	10h	showsignedat
	11h	showhexat
	12h	showbinat
	13h	showstringat
	14h	showstring0at
	15h	setcolor
	16h	getcolor
	17h	scrolldown
	18h	getxy
	19h	setxy
	1Ah	savescreen
	1Bh 	restorescreen
	1Ch	page2to1
	1Dh	page1to2
	1Eh	xchgPages
	1Fh	savepage1
	20h	changelineattr
	21h	waitretrace
	22h	getinfos
	23h	loadbmp
	24h	showbmp
	25h	viewbmp
	26h	savedac
	27h	restoredac
	28h	savestate
	29h	restorestate
	2Ah	enablescroll
         	2Bh	disablescroll
	2Ch	showdate
	2Dh	showtime
	2Eh	showname
	2Fh	showattr
	30h	showsize
	31h	getchar

mcb.sys : Gestionnaires de m�moire vive
Interruption 49h (MB)

00h 	mbinit
01h 	mbfree
02h	mbcreate
03h	mbresident
04h	mbget
05h	mbfind
06h	mbchown
07h	mballoc
08h	mbclean
09h	mbfindsb


Les possibilit�s de COS2000 sont aujourd'hui tr�s limit�es car il est en cours de d�veloppement.


D�tail des APIs

- Interruption 48h

Readsector


Lit le secteur CX et le met en ES:DI. Met le flag carry � 1 si erreur.


	
Param�tres
d�entr�e	AH=0
CX
ES
DI
	
Donn�es en sortie	Flag Carry

Writesector


Ecrit le secteur CX avec les donn�es point�s par DS:SI. Met le flag carry � 1 si erreur.

	
Param�tres
d�entr�e	AH=1
CX
DS
SI
	
Donn�es en sortie	Flag Carry

Verifysector


V�rifie si le secteur CX n�est pas d�fectueux. Met le flag carry � 1 si erreur et flag equal � 0 si secteur d�fectueux.

	
Param�tres
d�entr�e	AH=2
CX
	
Donn�es en sortie	Flag Carry
Flag Equal

Initdrive


Fonction initialisant le pilote et le mat�riel afin d�utiliser ult�rieurement les fonctions de disque.sys. Met le flag carry � 1 si erreur.

	
Param�tres
d�entr�e	AH=3

	
Donn�es en sortie	Flag Carry

Loadfile


Charge le fichier dont le nom est point� par DS:SI en m�moire dans ES:DI et renvoie le nombre d�octets lu en ECX. Met le flag carry � 1 si erreur.

	
Param�tres
d�entr�e	AH=4
DS
SI
ES
DI
	
Donn�es en sortie	ECX
Flag Carry
          	
Compressrle


Compresse le contenu de la m�moire point� par DS:SI (selon une m�thode RLE)  et dont la taille est sp�cifi� par CX. Le r�sultat sera mis en ES:DI ainsi que la nouvelle taille m�moire (octets) en BP.	
Param�tres
d�entr�e	AH=5
DS
SI
ES
DI
CX
	
Donn�es en sortie	
          
Decompressrle


D�compresse le contenu de la m�moire point� par DS:SI (selon une m�thode RLE)  et dont la taille est sp�cifi� par CX. Le r�sultat sera mis en ES:DI ainsi que la nouvelle taille m�moire (octets) en BP.	
Param�tres
d�entr�e	AH=6
DS
SI
ES
DI
CX
	
Donn�es en sortie	
          
Findfirstfile


Renvoie en ES:DI la premi�re entr�e du r�pertoire courant (format BRUT). Met le flag carry � 1 si erreur. Cette fonction pr�pare aussi l�usage de la fonction findnextfile.

Format d�une entr�e de r�pertoire :

Entries Struc
FileName 	db 8 dup (0)
FilExt  	db 3 dup (0)
FileAttr	db 0
FileReserved 	db 0
FileTimeCreaMs  db 0 ;(*10 ms)
FileTimeCrea	dw 0
FileDateCrea	dw 0
FileDateAcc	dw 0
FileNotused	dw 0
FileTime	dw 0
FileDate	dw 0
FileGroup	dw 0
FileSize	dd 0
Entries Ends
	
Param�tres
d�entr�e	AH=7
ES
DI
	
Donn�es en sortie	Flag Carry
          	
Findnextfile


Renvoie en ES:DI l�entr�e suivante du r�pertoire courant (format BRUT). Met le flag carry � 1 si erreur.	
Param�tres
d�entr�e	AH=8
ES
DI
	
Donn�es en sortie	Flag Carry

Getfreespace


Renvoie en EDX l'espace disque libre du volume en octets. Met le flag carry � 1 si erreur.	
Param�tres
d�entr�e	AH=9
	
Donn�es en sortie	EDX
Flag Carry
          	
Searchfile


Renvois dans ES:DI l�entr�e de r�pertoire du fichier point� par DS:SI. Met le flag equal a 0 si pas existant. Met le flag carry � un si erreur.	
Param�tres
d�entr�e	AH=10
DS
SI
ES
DI

	
Donn�es en sortie	Flag Equal
Flag Carry


Getname


Renvois dans ES:DI le nom du support courant.	
Param�tres
d�entr�e	AH=11
ES
DI

	
Donn�es en sortie	


Getserial


Renvois le num�ro de s�rie du support courant en EDX.	
Param�tres
d�entr�e	AH=11
	
Donn�es en sortie	EDX

Changedir


Change le r�pertoire courant a celui dont le nom est point� par DS:SI. Met le flag carry � un si erreur.	
Param�tres
d�entr�e	AH=13
DS
SI
	
Donn�es en sortie	Flag Carry

Readcluster


Lit le cluster (groupe) CX et le met en ES:DI. Met le flag carry � 1 si erreur.	
Param�tres
d�entr�e	AH=14
ES
DI
	
Donn�es en sortie	Flag Carry

Writecluster


Ecrit le cluster (groupe) CX avec les donn�es point�s par DS:SI. Met le flag carry � 1 si erreur.
	
Param�tres
d�entr�e	AH=15
ES
DI
	
Donn�es en sortie	Flag Carry

Getdir


Renvoie en ES:DI sous forme de cha�ne a z�ro terminal le nom du r�pertoire courant.	
Param�tres
d�entr�e	AH=16
ES
DI
	
Donn�es en sortie	

Projfile


Charge le fichier dont le nom est point� par DS:SI dans un bloc m�moire. Renvoie en ECX le nombre d�octets lus et en ES l�adresse du bloc de m�moire. Met le flag carry � 1 si erreur.
	
Param�tres
d�entr�e	AH=17
DS
SI
	
Donn�es en sortie	ECX
ES
Flag Carry

Execfile


Ex�cute le fichier dont le nom est point� par DS:SI. Met le flag carry � 1 si erreur.
	
Param�tres
d�entr�e	AH=18
DS
SI
	
Donn�es en sortie	Flag Carry

- Interruption 47h

Setvideomode


Fixe le mode vid�o courant a dont le num�ro est AL. Met le flag carry � 1 si erreur.

MODES :
0 -> 40x25x16 couleurs en texte
1 -> 80x25x16 couleurs en texte
2 -> 80x50x16 couleurs en texte
3 -> 100x50x16 couleurs en texte
4 -> 100x60x16 couleurs en texte
5 -> 320x200x256 couleurs en graphique
6 -> 320x400x256 couleurs en graphique
7 -> 320x480x256 couleurs en graphique
8 -> 360x480x256 couleurs en graphique
9 -> 400x600x256 couleurs en graphique

Les modes sont g�n�ralement utilisable avec une carte VGA 256ko, mais la plupart surexploitent le contr�leur vid�o donc ne fonctionne pas toujours. L�utilisation des fonctions caract�res est disponible en mode graphique par l�usage de polices �mul�s mais beaucoup de bugs sont encore pr�sent.

	
Param�tres
d�entr�e	AH=0
AL
	
Donn�es en sortie	Flag Carry

Getvideomode


Retourne le mode vid�o courant a dans AL.
	
Param�tres
d�entr�e	AH=1

	
Donn�es en sortie	AL

Getvideomode


Efface l��cran en mode graphique ou texte.
	
Param�tres
d�entr�e	AH=2

	
Donn�es en sortie	

Setfont


Active la police de num�ro CL parmi les 8 disponibles.
	
Param�tres
d�entr�e	AH=3
CL
	
Donn�es en sortie	

Getfont (PAS ENCORE IMPLEMENTE)


R�cup�re en CL le N� de police actif.
	
Param�tres
d�entr�e	AH
CL
	
Donn�es en sortie	


Loadfont


Charge une police point�e par DS:SI dans la carte vid�o sous le n� de police BL. La taille en hauteur de la police (en pixel) doit �tre renseign� dans CL Met le flag carry � 1 si erreur.
	
Param�tres
d�entr�e	AH=4
DS
SI
CL
	
Donn�es en sortie	Flag Carry

Showspace


Affiche un espace � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=5

	
Donn�es en sortie	

Showline


Affiche un retour a la ligne � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=6

	
Donn�es en sortie	

Showchar


Affiche un caract�re dont le code ASCII est contenu dans DL � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=7
DL
	
Donn�es en sortie	


Showint


Affiche le nombre entier contenu dans EDX � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=8
EDX
	
Donn�es en sortie	

Showsigned


Affiche le nombre entier sign� contenu dans EDX � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=9
EDX
	
Donn�es en sortie	

Showhex


Affiche le nombre hexad�cimal contenu dans EDX et de taille CX bits � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=10
EDX
CX
	
Donn�es en sortie	

ShowBin


Affiche le nombre binaire contenu dans EDX et de taille CX bits � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=11
EDX
CX
	
Donn�es en sortie	

ShowString


Affiche la cha�ne de caract�re (type fixe) point�e par DS:SI � l��cran apr�s le curseur.

Cha�ne de type fixe :

Chaine db 24,�c un chaine de type fixe�
	
Param�tres
d�entr�e	AH=12
DS
SI
	
Donn�es en sortie	

ShowString0


Affiche la cha�ne de caract�re (type z�ro terminal) point�e par DS:SI � l��cran apr�s le curseur.

Cha�ne de type z�ro terminal:

Chaine db �c un chaine de type z�ro terminal�,0
	
Param�tres
d�entr�e	AH=13
DS
SI
	
Donn�es en sortie	

Showchartat


R�alise la m�me fonction que la fonction showchar en sp�cifiant les coordonn�es BL (y), BH (x) ou tout devra �tre affich�.
	
Param�tres
d�entr�e	AH=14
DL
BL BH
	
Donn�es en sortie	

Showintat


R�alise la m�me fonction que la fonction showint en sp�cifiant les coordonn�es BL (y), BH (x) ou tout devra �tre affich�.
	
Param�tres
d�entr�e	AH=15
EDX
BL BH
	
Donn�es en sortie	

Showsignedat


R�alise la m�me fonction que la fonction showsigned en sp�cifiant les coordonn�es BL (y), BH (x) ou tout devra �tre affich�.
	
Param�tres
d�entr�e	AH=16
EDX
BL BH
	
Donn�es en sortie	

Showhexat


R�alise la m�me fonction que la fonction showhex en sp�cifiant les coordonn�es BL (y), BH (x) ou tout devra �tre affich�.
	
Param�tres
d�entr�e	AH=17
EDX
CX
BL BH
	
Donn�es en sortie	

Showbinat


R�alise la m�me fonction que la fonction showbin en sp�cifiant les coordonn�es BL (y), BH (x) ou tout devra �tre affich�.
	
Param�tres
d�entr�e	AH=18
EDX
CX
BL BH
	
Donn�es en sortie	

Showstringat


R�alise la m�me fonction que la fonction showstring en sp�cifiant les coordonn�es BL (y), BH (x) ou tout devra �tre affich�.
	
Param�tres
d�entr�e	AH=19
DS
SI
BL BH
	
Donn�es en sortie	

Showstring0at


R�alise la m�me fonction que la fonction showstring0 en sp�cifiant les coordonn�es BL (y), BH (x) ou tout devra �tre affich�.
	
Param�tres
d�entr�e	AH=20
DS
SI
BL BH
	
Donn�es en sortie	

Setcolor


Change la couleur courante (attributs) pour les op�rations textes a celle sp�cifi� dans CL
	
Param�tres
d�entr�e	AH=21
CL
	
Donn�es en sortie	

Setcolor


R�cup�re dans CL la couleur courante (attributs) pour les op�rations textes. 
	
Param�tres
d�entr�e	AH=22

	
Donn�es en sortie	CL

Setstyle (PAS ENCORE IMPLEMENTE)


Change le style (transparent ou non) courant pour les op�rations graphique a celui sp�cifi� dans CL
	
Param�tres
d�entr�e	AH
CL
	
Donn�es en sortie	

Getstyle (PAS ENCORE IMPLEMENTE)


R�cup�re dans CL le style courant (transparent ou non) pour les op�rations graphique.
	
Param�tres
d�entr�e	AH

	
Donn�es en sortie	CL

Scrolldown


D�file l��cran texte ou graphique de CX caract�res vers le haut.
	
Param�tres
d�entr�e	AH=23
CX
	
Donn�es en sortie	

Getxy


Renvoie en BH les coordonn�es x du curseur texte et en BL les coordonn�es y du curseur texte.
	
Param�tres
d�entr�e	AH=24

	
Donn�es en sortie	BH BL

Setxy


Fixe les coordonn�es x du curseur texte a BH et les coordonn�es y du curseur texte a L.
	
Param�tres
d�entr�e	AH=25
BH BL
	
Donn�es en sortie	

SaveScreen


Sauvegarde le contenu de l��cran dans un bloc m�moire appel� /vgascreen li� a l�application appelante.	
Param�tres
d�entr�e	AH=26

	
Donn�es en sortie	

RestoreScreen


Restaure le contenu de l��cran pr�c�demment sauvegard� dans un bloc m�moire.	
Param�tres
d�entr�e	AH=27

	
Donn�es en sortie	

Page1to2


Copie le contenu de la page vid�o n�1 dans la page vid�o n�2. Ne fonctionne qu�en mode texte.	
Param�tres
d�entr�e	AH=28
	
Donn�es en sortie	

Page2to1


Copie le contenu de la page vid�o n�2 dans la page vid�o n�1. Ne fonctionne qu�en mode texte.	
Param�tres
d�entr�e	AH=29
	
Donn�es en sortie	

Xchgpage


Echange le contenu de la page vid�o n�2 dans la page vid�o n�1. Ne fonctionne qu�en mode texte.	
Param�tres
d�entr�e	AH=30
	
Donn�es en sortie	

Savepage1


Sauvegarde le contenu de l��cran dans un bloc m�moire appel� /vgapage1 li� a l�application appelante.	
Param�tres
d�entr�e	AH=31
	
Donn�es en sortie	

Changelineattr (VA ETRE SUPPRIMER)


Modifie la couleur de la ligne N�DI a l��cran a celle contenue dans AL.	
Param�tres
d�entr�e	AH=32
AL
DI
	
Donn�es en sortie	

Waitretrace


Synchronisation avec la retrace verticale.	
Param�tres
d�entr�e	AH=33

	
Donn�es en sortie	

Getvgainfos


Renvoie un bloc de donn�e en ES:DI contenant l'�tat de la carte graphique.

lines 	db 0
columns 	db 0
x           db 0
y 		db 0
xy		dw 0
colors 	db 7
mode 		db 0FFh
pagesize 	dw 0
pages       db 0
font		db 0
graphic 	db 0
xg		dw 0
yg		dw 0
style		dw 0
nbpage    	db 0
pagesshowed db 0
plane       db 0
xyg		dw 0
linesize    dw 0
adress     	dw 0
base 		dw 0
scrolling       db 1	
Param�tres
d�entr�e	AH=34
ES
SI
	
Donn�es en sortie	

Loadbmppalet


Charge la palette (DAC) du BMP point�e par DS:SI.	
Param�tres
d�entr�e	AH=35
DS
SI
	
Donn�es en sortie	

Showbmp


Affiche le BMP point�e par DS:SI en X:BX, Y:CX.	
Param�tres
d�entr�e	AH=36
DS
SI
BX
CX
	
Donn�es en sortie	

Viewbmp


Affiche le BMP point�e par DS:SI en X:BX, Y:CX avec la pr�paration de la palette.	
Param�tres
d�entr�e	AH=3
DS
SI
BX
CX
	
Donn�es en sortie	

Savedac


Sauvegarde le contenu de la palette (DAC) dans un bloc m�moire appel� /vgadac li� a l�application appelante.	
Param�tres
d�entr�e	AH=38

	
Donn�es en sortie	

Savedac


Restaure le contenu de la palette (DAC) pr�c�demment sauvegard� dans un bloc m�moire.	
Param�tres
d�entr�e	AH=39

	
Donn�es en sortie	

Savestate


Sauvegarde l�etat complet de la carte graphique dans un bloc m�moire appel� /vga li� a l�application appelante. FONCTIONNE PEUT ETRE EN MODE GRAPHIQUE.	
Param�tres
d�entr�e	AH=40

	
Donn�es en sortie	

Restorestate


Restaure l�etat complet de la carte graphique pr�c�demment sauvegard� dans un bloc m�moire. FONCTIONNE PEUT ETRE EN MODE GRAPHIQUE.	
Param�tres
d�entr�e	AH=41

	
Donn�es en sortie	

EnableScroll


Active le d�filement automatique de l��cran lors de d�passements.	
Param�tres
d�entr�e	AH=42

	
Donn�es en sortie	

DisableScroll



Desactive le d�filement automatique de l��cran lors de d�passements.	
Param�tres
d�entr�e	AH=43

	
Donn�es en sortie	

Showdate


Affiche la date contenue dans DX � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=44
DX
	
Donn�es en sortie	

Showtime


Affiche l�heure contenue dans � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=45
DX

	
Donn�es en sortie	

Showname


Affiche le nom de fichier point� par DS:SI � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=46
DS
SI
	
Donn�es en sortie	

Showattr


Affiche les attributs fichiers contenus dans DL � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=47
DL
	
Donn�es en sortie	

Showsize


Affiche le la taille en octets (et multiples) contenue dans EDX � l��cran apr�s le curseur.
	
Param�tres
d�entr�e	AH=48
EDX
	
Donn�es en sortie	

Getchar


Renvoie le caract�re situ� sous le curseur dans DL.
	
Param�tres
d�entr�e	AH=49

	
Donn�es en sortie	DL

Setxyg (PAS ENCORE IMPLEMENTE)


Change les coordonn�es du curseur graphique a X:BX,Y:CX.	
Param�tres
d�entr�e	AH
BX CX
	
Donn�es en sortie	

Getxyg (PAS ENCORE IMPLEMENTE NI ECRIT)


R�cup�re les coordonn�es du curseur graphique a X:BX,Y:CX.	
Param�tres
d�entr�e	AH

	
Donn�es en sortie	BX CX

Showpixel (PAS ENCORE IMPLEMENTE)


Affiche un pixel de couleur AL en X:BX,Y:CX.	
Param�tres
d�entr�e	AH
BX CX
AL
	
Donn�es en sortie	

Getpixel (PAS ENCORE IMPLEMENTE)


R�cup�re la couleur du pixel en X:BX,Y:CX dans AL.	
Param�tres
d�entr�e	AH
BX CX

	
Donn�es en sortie	AL

- Interruption 49h

Mbinit


Initialise les blocs de m�moire pour une utilisation futur des fonction MBs (inutile car le syst�me le r�alise au boot). Met le flag carry � 1 si erreur.
	
Param�tres
d�entr�e	AH=0

	
Donn�es en sortie	Flag Carry

Mbfree


Lib�re le bloc de m�moire GS ainsi que tout les sous blocs de m�moire li� (fils). Un bloc de m�moire consid�r� r�sident ou un sous bloc r�sident ne sera pas lib�r�. Met le flag carry � 1 si erreur.
	
Param�tres
d�entr�e	AH=1
GS
	
Donn�es en sortie	Flag Carry

Mbcreate


Cr�e un bloc de CX caract�res (octets) et de nom DS :SI. Retourne en GS le bloc de m�moire allou� et met le flag carry � 1 en cas d�erreur.	
Param�tres
d�entr�e	AH=2
DS
SI
	
Donn�es en sortie	GS
Flag Carry

Mbresident


Met le bloc GS en situation de bloc m�moire r�sident (non lib�rable).
	
Param�tres
d�entr�e	AH=3
GS
	
Donn�es en sortie	

Mbget


Renvoie en GS l�adresse du bloc m�moire situ� en CX �me position. Met le flag carry � 1 si introuvable.
	
Param�tres
d�entr�e	AH=4

	
Donn�es en sortie	GS
Flag Carry

Mbfind


Renvoie en GS le bloc de m�moire dont le nom correspond a la cha�ne de caract�re situ� en DS:SI. Met le flag carry � 1 si introuvable.
	
Param�tres
d�entr�e	AH=5
DS
SI
	
Donn�es en sortie	GS
Flag Carry

Mbchown


Change le proprietaire (p�re) du bloc de m�moire GS a celui precis� par DX.
	
Param�tres
d�entr�e	AH=6
GS
DX
	
Donn�es en sortie	Flag Carry

Mballoc


Alloue un bloc de CX caract�res (octets) pour le processus (programme) qui le demande. Retourne en GS le bloc de m�moire allou� et met le flag carry � 1 en cas d�erreur.	
Param�tres
d�entr�e	AH=7
CX
	
Donn�es en sortie	GS
Flag Carry

Mbclean


Nettoie un peu la m�moire pour fonctionner des blocs de m�moire libre contigu�. G�n�ralement inutile car g�r� par le systeme.	
Param�tres
d�entr�e	AH=8

	
Donn�es en sortie	Flag Carry

Mbfindsb


Renvoie en GS le sous bloc de m�moire dont le nom correspond a la cha�ne de caract�re situ� en DS:SI et dont le propri�taire est DX. Met le flag carry � 1 si introuvable.
	
Param�tres
d�entr�e	AH=9
DS
SI
DX
	
Donn�es en sortie	Flag Carry

- Interruption 74h

Cmdmouse


Envoie une commande AL � la souris via contr�leur clavier	
Param�tres
d�entr�e	AH=0
AL
	
Donn�es en sortie	

Cmdmouse2


Envoie une commande type 2 AL � la souris via contr�leur clavier	
Param�tres
d�entr�e	AH=1
AL
	
Donn�es en sortie	

Detectmouse


D�tecte et initialise une souris de type PS/2. Met le flag carry � 1 si introuvable.
	
Param�tres
d�entr�e	AH=2
AL
	
Donn�es en sortie	Flag Carry

Getmouse


Envoie en BX,CX les coordonn�es virtuelles de la souris (respectivement X et Y) ainsi qu�en DL l��tat des boutons.
	
Param�tres
d�entr�e	AH=3

	
Donn�es en sortie	BX
CX
DL

Getmousescreen


Envoie en BX,CX les coordonn�es �cran de la souris (respectivement X et Y) ainsi qu�en DL l��tat des boutons.
	
Param�tres
d�entr�e	AH=4

	
Donn�es en sortie	BX
CX
DL

Configmouse


Configure la v�locit� de la souris dans CL et dans AH, AL les sph�res X et Y. 	
Param�tres
d�entr�e	AH=5
AH AL
CL
	
Donn�es en sortie	



A suivre pour les autres ressources�. (et avec exemples !)

En cas de probl�mes

	Si des bugs surviennent ou si COS2000 ne veut pas s'installer, veuillez s'il vous pla�t m'envoyer un E Mail � :

		mailto:nicolas@palon.fr

COS2000 n'exploite pas les disques durs, il est donc improbable qu'il alt�re vos donn�es !
