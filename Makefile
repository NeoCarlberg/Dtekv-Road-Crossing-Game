# Makefile from the DTEK-V lab 3 template (see COPYING).
# Changed by Neo Carlberg: added OPT (make OPT=-O0) for the performance analysis,
# and clean only removes *.elf.txt so it no longer deletes readme.txt.

SRC_DIR ?= ./src
OBJ_DIR ?= ./
SOURCES ?= $(shell find $(SRC_DIR) -name '*.c' -or -name '*.S')
OBJECTS ?= $(addsuffix .o, $(basename $(notdir $(SOURCES))))
LINKER ?= ./dtekv-script.lds

TOOLCHAIN ?= riscv32-unknown-elf-
OPT ?= -O3
CFLAGS ?= -Wall -nostdlib -O3 -mabi=ilp32 -march=rv32imzicsr -fno-builtin -Iinclude


build: clean main.bin

main.elf: 
	$(TOOLCHAIN)gcc -c $(CFLAGS) $(SOURCES)
	$(TOOLCHAIN)ld -o $@ -T $(LINKER) $(filter-out boot.o, $(OBJECTS)) softfloat.a

main.bin: main.elf
	$(TOOLCHAIN)objcopy --output-target binary $< $@
	$(TOOLCHAIN)objdump -D $< > $<.txt

clean:
	rm -f *.o *.elf *.bin *.elf.txt

TOOL_DIR ?= ./tools
run: main.bin
	make -C $(TOOL_DIR) "FILE_TO_RUN=$(CURDIR)/$<"
