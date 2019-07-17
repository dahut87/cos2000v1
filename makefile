all:	boot/boot12.bin lib/3d.lib noyau/systeme.sys programs/commande.ce
	sync

install:
	(sudo apt-get install fasm qemu fusefat gdb)

clean:
	make -C final clean
	make -C boot clean
	make -C lib clean
	make -C noyau clean
	make -C programs clean
	sync

backup: clean
	(tar cf - . | gzip -f - > ../backup.tar.gz)
		
copy: 
	make -C final

test: all copy qemu

retest: clean test

view: final/cos2000.img
	(hexdump  -C ./final/cos2000.img|head -c10000)

view2: boot/boot12.bin
	(objdump -D -b binary -mi386 -Maddr16,data16 ./boot/boot12.bin)

debug: debug-system

redebug: clean debug

debug-boot: all copy qemu-debug
	(sleep 2;gdb -ix ./debug/gdb_init_real_mode.txt -x ./debug/boot.txt)

debug-system: all copy qemu-debug
	(sleep 2;gdb -ix ./debug/gdb_init_real_mode.txt -x ./debug/system.txt)

qemu-debug:
	(killall qemu-system-i386;qemu-system-i386 -m 1G -fda ./final/cos2000.img -s -S &)

qemu:
	(killall qemu-system-i386;qemu-system-i386 -m 1G -fda ./final/cos2000.img -s)    
	
noyau/systeme.sys:
	make -C noyau
	
boot/boot12.bin:
	make -C boot

lib/3d.lib:
	make -C lib

programs/commande.ce:
	make -C programs

