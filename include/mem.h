struc regs
{
.seip dd 0
.seax dd 0
.sebx dd 0
.secx dd 0
.sedx dd 0
.sesi dd 0
.sedi dd 0
.sebp  dd 0
.sesp  dd 0
.scs  dw 0
.sds  dw 0
.ses  dw 0
.sfs  dw 0
.sgs  dw 0
.sss  dw 0
;.seflags dd 0
;.sst0 dt 0
;;sst1 dt 0
;.sst2 dt 0
;.sst3 dt 0
;.sst4 dt 0
;.sst5 dt 0
;.sst6 dt 0
;.sst7 dt 0
}

struc tuple
{
.off dw 0   ;adresse
.seg dw 0   ;segment
}

;union vector
;{
;.data tuple 0,0
;.content dd 0
;}

struc ints ;bloc interruption
{ 
.number db 0    ;numero de l'interruption
.activated db 0     ;activé ou non
.locked db 0    ;verrouillée
.launchedlow dd 0
.launchedhigh dd 0
.calledlow dd 0
.calledhigh dd 0
.vector1 vector ?
.vector2 vector ?
.vector3 vector ?
.vector4 vector ?
.vector5 vector ?
.vector6 vector ?
.vector7 vector ?
.vector8 vector ?
}
 
struc mb	                    ;Bloc de mémoire
{
.check 	        db "NH"         ;signature du bloc de mémoire.
.isnotlast 	db 0             ;flag indiquant le dernier bloc
.isresident	db 0             ;flag indiquant que le bloc est resident
.reference	dw 0             ;pointeur vers le bloc parent
.sizes		dw 0             ;taille du bloc en paragraphe de 16 octet
.names		db 24 dup (0)    ;nom du bloc
}

struc exe	                    ;Executable COS
{
.checks 	         db "CE"         ;signature de l'exe
.major            db 1            ;N° version
.checksum         dd 0            ;Checksum de l'exe
.compressed       db 0            ;a 1 si compressé par RLE
.exports          dw 0            ;importation de fonctions
.imports          dw 0            ;exportation de fonctions
.sections         dw 0            ;sections des blocs mémoire
.starting         dw 15
}

struc descriptor
{
.limit_low   dw 0
.base_low    dw 0
.base_middle db 0
.dpltype     db 0
.limit_high  db 0
.base_high   db 0
}

free        equ 0                 ;Reference quand libre

macro   exporting
{
	 exports:
}

macro   importing
{
	 imports:
}

macro   noimporting
{
	 imports:
	 dd 0
}

macro   noexporting
{
	 imports:
	 dd 0
}

macro   ende
{
	 dd 0
}

macro   endi
{
	 dd 0
}

macro   use    lib*,fonction*
{
	 db "&lib&::&fonction&",0
fonction:
	   dd 0
         dd 0
 }

macro   declare    fonction*
{
	 db "&fonction&",0
       dw fonction
}

macro   heading    versmaj*,versmin*,start*
{
header exe "CE",versmaj,versmin,0,exports,imports,0,start
}
