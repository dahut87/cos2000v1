Free  equ 0
True 	equ 1
False equ 0

DPT struc    
StepRate&HeadUnload db 0DFh ;Vitesse de progression & mont‚e de la tˆte
DMAFlag&HeadLoad    db 002h ;Etat Dma et temps de descente de la tˆte
DelayMotorOff       db 025h ;Temps avant extinction moteur
BytePerSector       db 002h ;Taille des secteurs
SectorPerTracks     db 000h ;Nombre de secteur par piste
InterSectGapLength  db 01Bh ;Taille du GAP3 en lecture/‚criture
DataLength          db 0FFh ;Longueur du transfert de donn‚es
InterSectGapLengthF db 054h ;Taille du GAP3 en formatage
FormatByte          db 0F6h ;Octet de formatage
HeadSettlingTime    db 000h ;Temps de repos des tˆtes
DelayMotorNormSpeed db 008h ;Temps de mont‚e en vitesse du moteur
DPT ends  

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

BootSector Struc
jumper			db 0,0,0
Vendor  	      db     'COS2000A'                ;Fabricant + n°série Formatage
SectorSize        dw      512                      ;octet/secteur
SectorsPerCluster db      1                        ;secteur/cluster
ReservedSectors   dw      1                        ;secteur reserv‚
FatsPerDrive      db      2                        ;nb de copie de la FAT
DirectorySize     dw      224                      ;taille rep racine
SectorsPerDrive   dw      2880                     ;nb secteur du volume si < 32 még
MédiaDescriptor   db      0F0h                     ;Descripteur de média
SectorsPerFat     dw      9                        ;secteur/FAT
SectorsPerTrack   dw      18                       ;secteur/piste       
HeadsPerDrive     dw      2                        ;nb de tˆteb de lecture/écriture
HiddenSectorsH    dw      0                        ;nombre de secteur cach‚s
HiddenSectorsL	dw	  0				   ;
SectorPerDisk2    dd      0                        ;Nombre secteur du volume si > 32 Mo+20h                                        ; the number of sectors
BootDrive 	      db      0                        ;Lecteur de d‚marrage
ReservedForNT     db      0                        ;NA
BootSign 	      db      29h                      ;boot signature 29h
SerialNumber      dd      01020304h                ;no de serie
DriveName         db      'COS2000    '            ;nom de volume
TypeOffAt         db      'FAT16   '               ;FAT
bootcode          db 453 dup (0)
BootSector ends
