Liste exhaustive des APIs supportée par cos
78 fonctions

Drive.sys : Gestionnaires FAT,FIT et partition
Interruption 48h (Disquette uniquement)
fonctions 	00h 	readsector
          	01h	writesector
          	02h	verifysector 
          	03h	loadfatway
          	04h	loadfile
          	05h 	compressrle
         	06h	decompressrle
lpt.sys : Gestionnaires port parallèle
Interruption 0Dh (LPT1) ou 0Fh (LPT2)
fonctions 	00h 	getlptin
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
mouse.sys : Gestionnaires souris
Interruption 74h (PS/2)
fonctions  	00h	cmdmouse
          	01h	cmdmouse2
         	02h	detectmouse
         	03h	getmouse
         	04h 	getmousescreen
         	05h	configmouse
pic8259a.sys : Gestionnaires contrôleur d'interruption programmable
Interruption 50h (Maître et esclave)
fonctions  	00h 	enableirq
          	01h	disableirq
          	02h	readmaskirq
         	03h	readirr
         	04h	readisr
         	05h 	installhandler
         	06h	replacehandler
	   	07h	getint
		08h	setint
		09h	seteoi
video.sys : Gestionnaires de la carte video
Interruption 47h (VGA)
fonctions 	00h 	setvideomode
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
	