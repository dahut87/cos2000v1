					< COS2000 the new operating system >


I. Pr�sentation

	COS2000, par d�finition, est syst�me d'exploitation. Celui-ci prend la direction des op�rations � partir
 du moment o� le  PC est mis sous tension (Apr�s le BIOS). Il g�re tous les p�riph�riques rattach�s au PC et 
offre aux  programmeurs les moyens de d�velopper des applications compatibles en fournissant des APIs 
(Application Programming Interface). COS2000 est bas� sur un concept particulier qui est d'offrir aux 
programmeurs un maximum de fonctions int�gr�es pour faciliter le travail des programmeurs et r�duire la 
taille des programmes.

II. Comment l'installer ?

	Pour installer COS2000 :

		- Ins�rez une disquette 1.44 Mo vierge ou inutile dans votre lecteur.
		- Lancez le programme SETUP.COM situ� dans le dossier de COS2000.
		- Si celui-ci ne d�tecte pas d'erreur, COS2000 est install� !

	Pour lancer COS2000 :

		- Ins�rez la disquette o� COS2000 est install�.
		- Veillez que dans le BIOS vous puissiez d�marrer � partir de A:.
		- Red�marrer votre ordinateur et vous serez sur COS2000.

	Il est possible de t�l�charger une version plus r�cente de COS2000 � :

		https://github.com/dahut87/cos2000v1
    
III. Mode d'emploi

	Le COS MENU LOADER est le premier logiciel qui est lanc� au d�marrage. A partir de celui-ci, vous pouvez 
visionner tout les fichiers pr�sents sur votre disquette et �ventuellement les ex�cuter s'ils poss�dent 
l'extension EXE . Pour cela, il suffit de s�lectionner avec la ligne en surbrillance le programme � ex�cuter 
en utilisant les fl�ches de direction. Pour ex�cuter le programmer, pressez la touche "Entr�e".

	A partir du COS MENU LOADER on peut lancer un interpr�teur de commandes . Celui-ci s'appelle PROMPT.EXE.
Une fois dans l'interpr�teur de commande, vous pouvez tout aussi bien lancer des logiciels en saisissant leurs
noms apr�s "COS>".

En plus des logiciels, l'interpr�teur de commandes peut ex�cuter 6 commandes :

	EXIT			Quitte l'interpr�teur
	VERSION		Donne la version de COS2000
	CLS			Efface l'�cran
	REBOOT		Red�marre le PC
	COMMAND		Donne la liste des commandes disponibles
	MODE [mode]		Permet de changer de mode vid�o. [mode] doit �tre un entier compris entre 1 et 9. les 
				modes au del� de 4 sont des modes graphiques � texte �mul�. Il est d�conseill� de les 
				utiliser car il est parfois impossible de revenir aux modes texte.

Les possibilit�s de COS2000 sont aujourd'hui tr�s limit�es car il est en cours de d�veloppement.
