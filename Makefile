# File Name: Makefile
# Author: Stephen Montes De Oca
# Email: deocapaul@gmail.com

.PHONY: clean

RREFCALC	= RREFCalc.c
RREFCALC_EXE	= RREFCalc

ARM_SRCS	= descaleRow.s reduceRows.s swapRows.s rref.s
ARM_OBJS	= $(ARM_SRCS:.s=.o)

MAIN_FLAGS	= -g -o
ASM_FLAGS	= -c -g
GCC_FLAGS	= -c -g -std=c11 -pedantic -Wall

# Standard Rules
.s.o:
	gcc $(ASM_FLAGS) $<

.c.o:
	gcc $(GCC_FLAGS) $<

# Main Executable
$(RREFCALC_EXE): $(ARM_OBJS)
	@echo "Compiling main executable"
	gcc $(MAIN_FLAGS) $(RREFCALC_EXE) $(RREFCALC) $(ARM_OBJS)

# Clean
clean:
	@echo "Cleaing up object files and executables..."
	rm -f $(ARM_OBJS) $(RREFCALC_EXE)
