![logo](https://github.com/dahut87/cos2000v1/raw/master/graphisme/logo.png)
## Documentation d'origine (importée)

COS 2000
Compatible Operating System

 

	Pr�sentation
	Comment l�installer
	Mode d�emploi
	Faire un programme pour COS
	Liste des APIs
	En cas de probl�me
	
	mailto:nicolas@palon.fr


Pr�sentation

	COS2000, par d�finition, est syst�me d'exploitation. Celui-ci prend la direction des op�rations � partir du moment o� le  PC est mis sous tension (Apr�s le BIOS). Il g�re tous les p�riph�riques rattach�s au PC et offre aux  programmeurs les moyens de d�velopper des applications compatibles en fournissant des APIs (Application Programming Interface). COS2000 est bas� sur un concept particulier qui est d'offrir aux programmeurs un maximum de fonctions int�gr�es pour faciliter le travail des programmeurs et r�duire la taille des programmes.

Comment l'installer ?

	Pour installer COS2000 :

	Sous dos/windows

		  Ins�rez une disquette 1.44 Mo vierge ou inutile dans votre lecteur.
		  Lancez le programme SETUP.COM situ� dans le dossier de COS2000.
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

	EFFAC
	Efface l'�cran.

	REDEM
	Red�marre le PC.

	CMDS
	Donne la liste des commandes disponibles.

	MODE [mode]
Permet de changer de mode vid�o. [mode] doit �tre un entier compris entre 1 et 9. les modes au del� de 4 sont des modes graphiques � texte �mul�. Il est d�conseill� de les utiliser car il est parfois impossible de revenir aux modes texte.

	LIRE
	Permet de lire un support disquette 1.44 Mo au format FAT12.

	CH
	Change le dossier actuel vers celui sp�cifi�.

	VOIR
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
	int	47h			;Afficher le texte point� par DS:SI (Showstring0)
	xor	ax,ax
	int	16h			;Attendre l�appuie sur une touche
	db	0CBH ;retour far

msg db �Hello World�,0
end start

	Avec nasm

[bits 16]				;16 bits
[org 0x0100]				;Point d�entr� en 0100h
section .text				;Segment de code				

start:
	mov	ah,0x0D		
	mov	si,msg
	int	0x47			;Afficher le texte point� par DS:SI (Showstring0)
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
          	08h	getfreespace
          	09h 	searchfile
         	0Ah	getname
          	0Bh	getserial
          	0Ch	changedir
          	0Dh 	readcluster
         	0Eh	writecluster
	0Fh	getdir

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
	25h	clearscr
	26h	savedac
	27h	restoredac
	28h	savestate
	29h	restorestate
	30h	enablescroll
         	31h	disablescroll
	32h	showdate
	33h	showtime
	34h	showname
	35h	showattr
	36h	showsize

Pour l�instant je n�ai pas fait de guide d�taill� de l�utilisation des fonctions de COS� A venir

Les possibilit�s de COS2000 sont aujourd'hui tr�s limit�es car il est en cours de d�veloppement.

En cas de probl�mes

	Si des bugs surviennent ou si COS2000 ne veut pas s'installer, veuillez s'il vous pla�t m'envoyer un E Mail � :

		mailto:nicolas@palon.fr

COS2000 n'exploite pas les disques durs, il est donc impossible qu'il alt�re de quelque mani�re que ce soit vos donn�es !!!!!!!!!!!!!
