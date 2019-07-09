ASM=fasm 
CLEAN=rm -rf
OBJS= $(SRCS:.c=.o)
SRC= $(wildcard *.asm)
PROG= $(SRC:.asm=.ce)

all: $(PROG)
	sync

%.ce: %.asm
	$(ASM) $^ $@

clean:
	$(CLEAN) *.ce
