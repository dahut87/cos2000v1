					< COS2000 the new operating system >


I. Présentation

	COS2000, par définition, est système d'exploitation. Celui-ci prend la direction des opérations à partir
 du moment où le  PC est mis sous tension (Après le BIOS). Il gère tous les périphériques rattachés au PC et 
offre aux  programmeurs les moyens de développer des applications compatibles en fournissant des APIs 
(Application Programming Interface). COS2000 est basé sur un concept particulier qui est d'offrir aux 
programmeurs un maximum de fonctions intégrées pour faciliter le travail des programmeurs et réduire la 
taille des programmes.

II. Comment l'installer ?

	Pour installer COS2000 :

		- Insérez une disquette 1.44 Mo vierge ou inutile dans votre lecteur.
		- Lancez le programme SETUP.COM situé dans le dossier de COS2000.
		- Si celui-ci ne détecte pas d'erreur, COS2000 est installé !

	Pour lancer COS2000 :

		- Insérez la disquette où COS2000 est installé.
		- Veillez que dans le BIOS vous puissiez démarrer à partir de A:.
		- Redémarrer votre ordinateur et vous serez sur COS2000.

	Il est possible de télécharger une version plus récente de COS2000 à :

		https://github.com/dahut87/cos2000v1
    
III. Mode d'emploi

	Le COS MENU LOADER est le premier logiciel qui est lancé au démarrage. A partir de celui-ci, vous pouvez 
visionner tout les fichiers présents sur votre disquette et éventuellement les exécuter s'ils possèdent 
l'extension EXE . Pour cela, il suffit de sélectionner avec la ligne en surbrillance le programme à exécuter 
en utilisant les flèches de direction. Pour exécuter le programmer, pressez la touche "Entrée".

	A partir du COS MENU LOADER on peut lancer un interpréteur de commandes . Celui-ci s'appelle PROMPT.EXE.
Une fois dans l'interpréteur de commande, vous pouvez tout aussi bien lancer des logiciels en saisissant leurs
noms après "COS>".

En plus des logiciels, l'interpréteur de commandes peut exécuter 6 commandes :

	EXIT			Quitte l'interpréteur
	VERSION		Donne la version de COS2000
	CLS			Efface l'écran
	REBOOT		Redémarre le PC
	COMMAND		Donne la liste des commandes disponibles
	MODE [mode]		Permet de changer de mode vidéo. [mode] doit être un entier compris entre 1 et 9. les 
				modes au delà de 4 sont des modes graphiques à texte émulé. Il est déconseillé de les 
				utiliser car il est parfois impossible de revenir aux modes texte.

Les possibilités de COS2000 sont aujourd'hui très limitées car il est en cours de développement.
