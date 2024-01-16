# 目录结构
INCLUDE_DIR:=.
# 源文件
SRCS:=$(wildcard *.c)
ARMS:=$(wildcard *.asm)

OBJS:=$(subst .c,.o,$(SRCS))
OBJS+=$(subst .asm,.o,$(ARMS))

CFLAGS=-std=c11 -I$(INCLUDE_DIR) \
				-fno-pic -mcmodel=kernel \
				-fno-stack-protector -fcf-protection=none \
				-nostdinc -fno-builtin

everything: $(OBJS)
	@echo $@

io.o: io.asm io.h
	nasm -f elf64 io.asm 

# 自动生成.c文件的依赖关系
.depend: $(SRCS)
	@rm -f .depend
	@$(foreach src, $(SRCS), \
			gcc - I$(CFLAGS) -MM $(src) >> .depend; \
	)
include .depend

.PHONY: clean dump 

clean: 
	-rm *.o 
	-rm dis_*.asm dis_*.S *.bin  

dump: $(OBJS)
	objcopy -O binary io.o io.bin
	ndisasm -o 0x50000 io.bin > dis_io.asm
	objdump -d  io.o > dis_io.S