all: cos2000.img

cos2000.img:
	(dd if=/dev/zero of=cos2000.img count=2880 bs=512)
	(mkfs.msdos -F 12 -n "COS2000" cos2000.img)
	(fusefat cos2000.img ./mnt -o rw+)
	(cp ../noyau/systeme.sys ./mnt/)
	(cp ../noyau/systeme.ini ./mnt/)
	(cp ../programs/*.ce ./mnt/)
	(cp ../programs/*.lib ./mnt/)
	(cp ../programs/*.rip ./mnt/)
	(cp ../lib/*.lib ./mnt/)
	(cp ../system/system.sys ./mnt/;sync)
	(fusermount ./mnt -u)
	(dd if=../boot/boot12.bin of=cos2000.img seek=0 count=1 conv=notrunc;sync)

clean:
	rm -f *.img
