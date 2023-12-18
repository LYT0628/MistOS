kernel.bin: boot16.asm
	nasm -o $@ $<


.PRONY: clean bochs


clean:
	rm -f *.bin kernel *.out *.log

bochs: kernel.bin
	bochs -f bochsrc
