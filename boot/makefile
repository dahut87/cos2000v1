ASM=fasm
CLEAN=rm -rf

all: boot12.bin
	sync

boot12.bin: boot12.asm
	$(ASM) $<

clean:
	$(CLEAN) *.bin
