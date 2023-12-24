TOOLS = ./tool 
BOCHS = $(TOOLS)/bochs/bochs-2.3

# kernel.bin: boot.asm
kernel.com: boot.asm 
	nasm -o $@ $<


.PRONY: clean write bochs dump mount


clean:
	rm -f *.bin kernel *.out *.log *.elf *.o  *.com

write: kernel.com
	dd if=kernel.bin of=a.img bs=512 count=1 conv=notrunc

bochs: kernel.com
	bochs -f bochsrc

dump: kernel.com
	ndisasm -o 0x7c00 kernel.bin > diskernel.asm 

mount: kernel.com 
	sh mount.sh 