SRC:=boot.asm 
BIN:=$(subst .asm,.com,$(SRC))
LOAD_ADDR:=0x100
MOUNT_POINT:=/mnt/floppy/
# kernel.bin: boot.asm
$(BIN): $(SRC)
	nasm -o $@ $<


.PHONY: clean write bochs dump mount


clean:
	rm -f *.bin kernel.com *.out *.log *.elf *.o  *.com

write: kernel.com
	dd if=$(BIN) of=a.img bs=512 count=1 conv=notrunc

bochs: 
	bochs -f bochsrc

dump: kernel.com
	ndisasm -o $(LOAD_ADDR) $(BIN) > disasm.asm 

mount: $(BIN)
	-sudo mkdir $(MOUNT_POINT)
	sudo mount -o loop pm.img $(MOUNT_POINT)
	sudo cp $(BIN) $(MOUNT_POINT) -v 
	sudo umount $(MOUNT_POINT)