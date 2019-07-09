struc point
{
.coordx db 0
.coordy db 0
}

struc vgainf
{
.lines 	        db 0
.columns 	db 0
.x               db 0
.y 		db 0
.xy		dw 0
.colors 	        db 7
.modenum 		db 0FFh
.pagesize 	dw 0
.style           db 0
.font		db 0
.graphic 	db 0
.nbpage    	db 0
.color           db 0
.cursor          db 0
.segments        dw 0
.linesize        dw 0
.adress     	dw 0
.base 		dw 0
.scrolling       db 1
.sizeof = $ - .lines
}


struc vertex2d 
{
.px dw ?
.py dw ?
}
