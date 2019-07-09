ASM=fasm 
CLEAN=rm -rf
OBJS= $(SRCS:.c=.o)
SRC= $(wildcard *.asm)
LIB= $(SRC:.asm=.lib)

all: $(LIB)
	sync

%.lib: %.asm
	$(ASM) $^ $@

clean:
	$(CLEAN) *.lib
