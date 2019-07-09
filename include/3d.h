struc vertex3d tx,ty,tz
{
.tx dd ?
.ty dd ?
.tz dd ?
.sizeof = $ - .tx
}

struc mat 
{
.p1 dd ?
.p2 dd ?
.p3 dd ?
.p4 dd ?
.p5 dd ?
.p6 dd ?
.p7 dd ?
.p8 dd ?
.p9 dd ?
.p10 dd ?
.p11 dd ?
.p12 dd ?
.p13 dd ?
.p14 dd ?
.p15 dd ?
.p16 dd ?
.sizeof = $ - .p1
}

main   equ 4D4Dh
edit   equ 3D3Dh
object equ 4000h
mesh   equ 4100h
vertex equ 4110h
face   equ 4120h
locale equ 4160h

