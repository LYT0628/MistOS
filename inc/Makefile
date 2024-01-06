ROOT_DIR=.

io.o: io.asm io.h  
	nasm -f elf64 io.asm 

.PHONY: clean dump

clean: 
	-rm *.o 
	-rm dis_*.asm dis_*.S *.bin  

dump: io.o 
	objcopy -O binary io.o io.bin
	ndisasm -o 0x50000 io.bin > dis_io.asm
	objdump -d  io.o > dis_io.S