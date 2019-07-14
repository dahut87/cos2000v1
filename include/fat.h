struc diskbuffer
{
.size  dw 12
.current dw 0FFFFh
.chain   dw 128 dup (0FFFFh)
.sizeof = $ - .size
}

struc dpt
{
.steprateheadunload db 0DFh ;Vitesse de progression & montee de la tete
.dmaflagheadload    db 002h ;Etat Dma et temps de descente de la tete
.delaymotoroff       db 025h ;Temps avant extinction moteur
.bytepersector       db 002h ;Taille des secteurs
.sectorpertracks     db 000h ;Nombre de secteur par piste
.intersectgaplength  db 01Bh ;Taille du GAP3 en lecture/‚criture
.datalength          db 0FFh ;Longueur du transfert de donn‚es
.intersectgaplengthf db 054h ;Taille du GAP3 en formatage
.formatbyte          db 0F6h ;Octet de formatage
.headsettlingtime    db 000h ;Temps de repos des tˆtes
.delaymotornormspeed db 008h ;Temps de mont‚e en vitesse du moteur
.sizeof = $ - .steprateheadunload
}

struc entries
{
.filename 	db 8 dup (0)
.filext  	db 3 dup (0)
.fileattr	db 0
.filereserved 	db 0
.filetimecreams  db 0 ;(*10 ms)
.filetimecrea	dw 0
.filedatecrea	dw 0
.filedateacc	dw 0
.filenotused	dw 0
.filetime	dw 0
.filedate	dw 0
.filegroup	dw 0
.filesize	dd 0
.sizeof = $ - .filename
}
virtual at 0
entries entries
end virtual

;Pour recherches
struc find files
{
.files                   db      13 dup (0) ;le fichier
.entryplace		dw	0 ;En octet
.adressdirectory		dw	0 ;En cluster
.firstsearch		db	1 ;Premiere requete ?
.result                  entries
.sizeof = $ - .files
}

struc bootinfo vendor,drivename,serialnumber
{
.vendor  	  db     'COS2000A'                ;Fabricant + n°série Formatage
.sectorsize        dw      512                      ;octet/secteur
.sectorspercluster db      1                        ;secteur/cluster
.reservedsectors   dw      1                        ;secteur reserv‚
.fatsperdrive      db      2                        ;nb de copie de la FAT
.directorysize     dw      224                      ;taille rep racine
.sectorsperdrive   dw      2880                     ;nb secteur du volume si < 32 még
.mediadescriptor   db      0F0h                     ;Descripteur de média
.sectorsperfat     dw      9                        ;secteur/FAT
.sectorspertrack   dw      18                       ;secteur/piste
.headsperdrive     dw      2                        ;nb de tˆteb de lecture/écriture
.hiddensectorsh    dw      0                        ;nombre de secteur cach‚s
.hiddensectorsl	  dw	  0				   ;
.sectorperdisk2    dd      0                        ;Nombre secteur du volume si > 32 Mo+20h                                        ; the number of sectors
.bootdrive 	  db      0                        ;Lecteur de d‚marrage
.reservedfornt     db      0                        ;NA
.bootsign 	  db      29h                      ;boot signature 29h
.serialnumber      dd      01020304h                ;no de serie
.drivename         db      'COS2000    '            ;nom de volume
.typeoffat         db      'FAT12   '               ;FAT
.sizeof = $ - .vendor 
}
