BMP_File         		struc
BMP_FileType            db      'BM'
BMP_FileSize            dd      ?       ; taille du fichier
BMP_Reserved            dd      0       ; toujours 0
BMP_BitMapOffset        dd      ?       ; offset de l'image
BMP_HeaderSize          dd      ? ; taille de l'entete en octects
BMP_Width               dd      ? ; largeur en pixels de l'image
BMP_Height              dd      ? ; hauteur en pixels de l'image
BMP_Planes              dw      1 ; nombre de plan utilis�s
BMP_BitsPerPixel        dw      ? ; nombre de bits par pixels
BMP_Compression         dd      ? ; m�thode de compression 
BMP_SizeOfBitMap        dd      ? ; taille de l'image en octects
BMP_HorzResolution      dd      ? ; resolution horizontale en pixels par m�tre
BMP_VertResolution      dd      ? ; resolution verticale en pixels  par m�tre
BMP_ColorsUsed          dd      ? ; nombre de couleur dans la palette  si 0: palette enti�re si BitPerPixel<=8
BMP_ColorsImportant     dd      ? ; nombre de couleurs importantes masques pour les modes de plus de 8 bits par pixels
BMP_RedMask             dd      ?
BMP_GreenMask           dd      ?
BMP_BlueMask            dd      ?
BMP_AlphaMask           dd      ?
BMP_ColorSpaceType      dd      ?
BMP_RedX                dd      ?
BMP_RedY                dd      ?
BMP_RedZ                dd      ?
BMP_GreenX              dd      ?
BMP_GreenY              dd      ?
BMP_GreenZ              dd      ?
BMP_BlueX               dd      ?
BMP_BlueY               dd      ?
BMP_BlueZ               dd      ?
BMP_GammaRed            dd      ?
BMP_GammaGreen          dd      ?
BMP_GammeBlue           dd      ?
BMP_file       		ends

;BMP_Compression peut prendre les valeurs suivantes: 
BMP_COMP_UNCOMP         equ     0       ; pas de compression
BMP_COMP_RLE8           equ     1       ; 8-bit run length encoding
BMP_COMP_RLE4           equ     2       ; 4-bit tun length encoding
BMP_COMP_BFE            equ     3       ; bitfields encoding
