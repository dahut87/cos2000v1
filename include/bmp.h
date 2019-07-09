struc bmp_file         		
{
.bmp_filetype            db      'bm'
.bmp_filesize            dd      ?       ; taille du fichier
.bmp_reserved            dd      0       ; toujours 0
.bmp_bitmapoffset        dd      ?       ; offset de l'image
.bmp_headersize          dd      ? ; taille de l'entete en octects
.bmp_width               dd      ? ; largeur en pixels de l'image
.bmp_height              dd      ? ; hauteur en pixels de l'image
.bmp_planes              dw      1 ; nombre de plan utilisés
.bmp_bitsperpixel        dw      ? ; nombre de bits par pixels
.bmp_compression         dd      ? ; méthode de compression 
.bmp_sizeofbitmap        dd      ? ; taille de l'image en octects
.bmp_horzresolution      dd      ? ; resolution horizontale en pixels par mètre
.bmp_vertresolution      dd      ? ; resolution verticale en pixels  par mètre
.bmp_colorsused          dd      ? ; nombre de couleur dans la palette  si 0: palette entière si bitperpixel<=8
.bmp_colorsimportant     dd      ? ; nombre de couleurs importantes masques pour les modes de plus de 8 bits par pixels
.bmp_redmask             dd      ?
.bmp_greenmask           dd      ?
.bmp_bluemask            dd      ?
.bmp_alphamask           dd      ?
.bmp_colorspacetype      dd      ?
.bmp_redx                dd      ?
.bmp_redy                dd      ?
.bmp_redz                dd      ?
.bmp_greenx              dd      ?
.bmp_greeny              dd      ?
.bmp_greenz              dd      ?
.bmp_bluex               dd      ?
.bmp_bluey               dd      ?
.bmp_bluez               dd      ?
.bmp_gammared            dd      ?
.bmp_gammagreen          dd      ?
.bmp_gammeblue           dd      ?
.sizeof = $ - .bmp_filetype
}

;.bmp_compression peut prendre les valeurs suivantes: 
bmp_comp_uncomp         equ     0       ; pas de compression
bmp_comp_rle8           equ     1       ; 8-bit run length encoding
bmp_comp_rle4           equ     2       ; 4-bit tun length encoding
bmp_comp_bfe            equ     3       ; bitfields encoding
