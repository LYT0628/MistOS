kernel.bin: boot16.asm
	nasm -o $@ $<


.PRONY 