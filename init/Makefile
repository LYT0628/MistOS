ROOT_DIR:=..
BOOT_DIR:=$(ROOT_DIR)/boot

SRCS:=$(wildcard *.c)
OBJS:=$(subst .c,.o,$(SRC))


CFLAGS=-std=c11 -I$(ROOT_DIR) -fno-pic -mcmodel=kernel \
				-fno-stack-protector -fcf-protection=none
LDFLAGS=-s

sys.bin: main.o header64.o 
	ld  -Ttext=0x100000  -o sys.elf $^
	objcopy -O  binary  sys.elf $@ 

header64.o: header64.asm 
	nasm -f elf64 $< -o $@

main.o: main.c
	gcc $(CFLAGS) -c -o $@ $^




.PHONY: clean dump 

clean:
	-rm *.o *-bin *.elf *.bin 

dump:
	objdump -d  sys.elf > dis_sys.S
	ndisasm -o 0x100000 sys.bin > dis_sys.asm