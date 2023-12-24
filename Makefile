TOOLS = ./tool 
BOCHS = $(TOOLS)/bochs/bochs-2.3

kernel.bin: boot.asm
	nasm -o $@ $<


.PRONY: clean write bochs dump


clean:
	rm -f *.bin kernel *.out *.log *.elf *.o 

write: kernel.bin
	dd if=kernel.bin of=a.img bs=512 count=1 conv=notrunc

bochs: kernel.bin
	bochs -f bochsrc

dump: kernel.bin
	ndisasm -o 0x7c00 kernel.bin > diskernel.asm 
