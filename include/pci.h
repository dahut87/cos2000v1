struc pcidata
vendor		dw 0	;vendor ID (read-only), FFFFh returned if requested device non-existent
device		dw 0	;device ID (read-only)
command		dw 0	;command register
status		dw 0	;status register
revision 	db 0	;revision ID
interface	db 0	;programming interface
subclass	db 0	;sub-class
class	        db 0	;class code
cache		db 0	;cache line size
timer		db 0	;latency timer
typed		db 0	;header type
			;bits 6-0: header format
			;00h other
			;01h PCI-to-PCI bridge
			;02h PCI-to-CardBus bridge
			;bit 7: multi-function device
result		db 0	;Built-In Self-Test result
ends pcidata

struc pciinf
version_major   db 0
version_minor   db 0
types           db 0
maxbus          db 0
ends pciinf

multifunction equ 80h
othercard     equ 00h
pci2pcibridge equ 01h
pci2pcicard   equ 02h

config1addr	equ 0CF8h
config1data	equ 0CFCh
