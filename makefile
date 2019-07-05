all:	boot/boot12.bin lib/3d.lib noyau/systeme.sys commande.ce
	sync

install:
	(sudo apt-get install yasm qemu fusefat cgdb)

clean:
	make -C final clean
	make -C lib clean
	make -C noyau clean
	make -C programs clean
	sync

backup: clean
	(tar cf - . | gzip -f - > ../backup.tar.gz)
		
copy: 
	make -C final

test: all copy qemu

view:
	(hexdump  -C ./final/cos2000.img|head -c10000)

debug-boot: all copy qemu-debug
	(sleep 2;cgdb -x ./debug/boot.txt)

debug-loader: all copy qemu-debug
	(sleep 2;cgdb -x ./debug/loader.txt)

debug-system: all copy qemu-debug
	(sleep 2;cgdb -x ./debug/system.txt)

qemu-debug:
	(qemu-system-i386 -m 1G -fda ./final/cos2000.img -s -S &)

qemu:
	(qemu-system-i386 -m 1G -fda ./final/cos2000.img -s)    
	
noyau/systeme.sys:
	make -C noyau
	
boot/boot12.bin:
	make -C boot

lib/3d.lib:
	make -C lib
