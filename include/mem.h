struc regs
seip dd 0
seax dd 0
sebx dd 0
secx dd 0
sedx dd 0
sesi dd 0
sedi dd 0
sebp  dd 0
sesp  dd 0
scs  dw 0
sds  dw 0
ses  dw 0
sfs  dw 0
sgs  dw 0
sss  dw 0
seflags dd 0
ends regs

struc tuple   ;vecteur d'interruption
off dw 0   ;adresse
seg dw 0   ;segment
ends tuple

union vector
data tuple <>
content dd 0
ends

struc ints      ;bloc interruption
number db 0    ;numero de l'interruption
activated db 0     ;activé ou non
locked db 0    ;verrouillée
launchedlow dd 0
launchedhigh dd 0
calledlow dd 0
calledhigh dd 0
vector1 vector ?
vector2 vector ?
vector3 vector ?
vector4 vector ?
vector5 vector ?
vector6 vector ?
vector7 vector ?
vector8 vector ?
ends ints
 
struc mb	                    ;Bloc de mémoire
check 	        db "NH"         ;signature du bloc de mémoire
isnotlast 	db 0             ;flag indiquant le dernier bloc
isresident	db 0             ;flag indiquant que le bloc est resident
reference	dw 0             ;pointeur vers le bloc parent
sizes		dw 0             ;taille du bloc en paragraphe de 16 octet
names		db 24 dup (0)    ;nom du bloc
ends mb	

struc exe	                    ;Executable COS
checks 	         db "CE"         ;signature de l'exe
major            db 1            ;N° version
checksum         dd 0            ;Checksum de l'exe
compressed       db 0            ;a 1 si compressé par RLE
exports          dw 0            ;importation de fonctions
imports          dw 0            ;exportation de fonctions
sections         dw 0            ;sections des blocs mémoire
starting         dw 15
ends exe	

struc descriptor
limit_low   dw 0
base_low    dw 0
base_middle db 0
dpltype     db 0
limit_high  db 0
base_high   db 0
ends descriptor


free        equ 0                 ;Reference quand libre



macro   exporting
	 label exports
endm

macro   importing
	 label imports
endm

macro   noimporting
	 label imports
	 dd 0
endm

macro   noexporting
	 label imports
	 dd 0
endm

macro   ende
	 dd 0
endm

macro   endi
	 dd 0
endm

macro   use    lib:req,fonction:req
	 db "&lib&::&fonction&",0
label &fonction& dword
         dd 0
endm

macro   declare    fonction:req
	 db "&fonction&",0
         dw offset fonction
endm

macro   heading    versmaj:req,versmin:req,start:req
header exe <"CE",offset &versmaj&,offset &versmin&,0,offset exports,offset imports,0,offset &start&>
	 db "&fonction&",0
         dw offset fonction
endif
endm
