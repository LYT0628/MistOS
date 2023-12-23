kernel.bin: boot16.asm
	nasm -o $@ $<


.PRONY: clean write bochs


clean:
	rm -f *.bin kernel *.out *.log

write: kernel.bin
	dd if=kernel.bin of=a.img bs=512 count=1 count=1

bochs: kernel.bin
	bochs -f bochsrc


