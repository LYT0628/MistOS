###############################################################################
# 1. 子Makefile， 维护住自己内部指令的依赖关系，其它Makefile只要依赖于原始文件(asm文件)即可 
##############################################################################

everything: boot16.bin boot32.bin 
	@echo $@

boot16.bin: boot16.asm 
	nasm -o $@ $^

boot32.bin: boot32.asm
	nasm -o $@ $^



.PHONY: clean dump everything

clean:
	-rm -f *.bin *.o
	-rm -f dis_*.asm

dump: boot16.bin boot32.bin 
	ndisasm -o 0x7c00 boot16.bin > dis_boot16.asm
	ndisasm -o 0x10000 boot32.bin > dis_boot32.asm