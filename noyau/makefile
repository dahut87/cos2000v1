ASM=fasm
CLEAN=rm -rf

all: disque.sys video.sys systeme.sys
	sync

systeme.sys: systeme.asm
	$(ASM) $^ $@

disque.sys: disque.asm
	$(ASM) $^ $@

video.sys: video.asm
	$(ASM) $^ $@

clean:
	$(CLEAN) *.sys
