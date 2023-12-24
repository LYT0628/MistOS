SRC:=boot.asm 
BIN:=$(subst .asm,.com,$(SRC))
LOAD_ADDR:=0x100

# kernel.bin: boot.asm
$(BIN): $(SRC)
	nasm -o $@ $<


.PHONY: clean write bochs dump mount


clean:
	rm -f *.bin kernel.com *.out *.log *.elf *.o  *.com

write: kernel.com
	dd if=$(BIN) of=a.img bs=512 count=1 conv=notrunc

bochs: kernel.com
	bochs -f bochsrc

dump: kernel.com
	ndisasm -o $(LOAD_ADDR) $(BIN) > disasm.asm 

mount: $(BIN)
	mount -o loop pm.img /mnt/floppy/
	cp $(BIN) /mnt/floppy/ -v 
	umount /mnt/floppy