ROOT_DIR:=..
BOOT_DIR:=$(ROOT_DIR)/boot
INCLUDE_DIR:=$(ROOT_DIR)/inc

SRCS:=$(wildcard *.c)
OBJS:=$(subst .c,.o,$(SRC))

CFLAGS=-std=c11 -I$(INCLUDE_DIR) \
				-fno-pic -mcmodel=kernel \
				-fno-stack-protector -fcf-protection=none \
				-nostdinc -fno-builtin
LDFLAGS=-s

# $(LIB_DIR)/io.o
sys.bin: main.o header64.o $(INCLUDE_DIR)/io.o  $(INCLUDE_DIR)/vga.o
	ld  -Ttext=0x50000  -o sys.elf $^
	objcopy -O binary  sys.elf $@ 

header64.o: header64.asm 
	nasm -f elf64 $< -o $@

# main.o: main.c
# gcc $(CFLAGS) -c -o $@ $^

.depend: $(SRCS)
	@rm -f .depend
	@$(foreach src, $(SRCS), \
			gcc - I$(CFLAGS) -MM $(src) >> .depend; \
	)
include .depend


.PHONY: clean dump 

clean:
	-rm *.o *-bin *.elf *.bin 
	-rm dis_*.asm dis_*.S 

dump:  sys.bin
	objdump -d  sys.elf > dis_sys.S
	ndisasm -o 0x50000 sys.bin > dis_sys.asm