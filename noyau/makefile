ASM=fasm
CLEAN=rm -rf
LISTING=listing

all: disque.sys video.sys systeme.sys
	sync

systeme.sys: systeme.asm
	$(ASM) $^ $@ -s systeme.fas
	$(LISTING) systeme.fas systeme.txt

disque.sys: disque.asm
	$(ASM) $^ $@

video.sys: video.asm
	$(ASM) $^ $@

clean:
	$(CLEAN) *.sys
	$(CLEAN) *.fas
	$(CLEAN) *.txt
