struc cpu
{	
.vendor          db 13 dup(0)     ;Chaine 0 du fabriquant
.names           db 32 dup(0)
.stepping        db 0
.models           db 0
.family          db 0
.types            db 0
.emodels          db 0
.efamily         db 0
.mmx             db 0
.mmx2             db 0
.sse             db 0
.sse2            db 0
.sse3            db 0
.fpu             db 0
.now3d           db 0
.now3d2          db 0
.htt             db 0
.apic            db 0
.sizeof = $ - .vendor
}
