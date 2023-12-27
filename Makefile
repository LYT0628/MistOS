# make 
# make dump
# make dos
# make fd

# floppy  boot and bochs
# SRC:=boot.asm 
ROOT_DIR:=.
SRC:=hello.asm 
SRC1:=boot.asm 
SRC2:=hello2.asm 
SRC3:=hello2.asm 


BIN:=$(subst .asm,.bin,$(SRC))
COM:=$(subst .asm,.com,$(SRC1))

##########Boot img#################################
# Dos boot 
DOS_LOAD_ADDR:=0x100
MOUNT_POINT:=/mnt/floppy
#  hard disk boot and vpc
VHD=/home/lyt0628/dev/CODE/MistOS/tools/vpcvm/orange/orange.vhd
# floppy  boot and bochs
FLOPPY=a.img 
#################  TOOLS   #####################
TOOLS_DIR:=$(ROOT_DIR)/tools
# bochs
TOOL_BOCHS:=$(TOOLS_DIR)/bochs
BHCHS_CONFIG_DOS:=$(TOOL_BOCHS)/bochsrc_dos
BOCHS_CONFIG_MSR:=$(TOOL_BOCHS)/bochsrc_msr 
BOCHS_IMG_MSR:=$(TOOL_BOCHS)/msr.img
BOCHS_IMG_DOS_PM:=$(TOOL_BOCHS)/pm.img
BOCHS_IMG_DOS:=$(TOOL_BOCHS)/freedos.img
# vpc
TOOL_VPC:=$(TOOLS_DIR)/vpcvm/
VPCVM_ORANGE_DIR:=$(TOOL_VPC)/orange
VHD_ORANGE:=$(VPCVM_ORANGE_DIR)/orange.vhd 


# boot.bin/boot.com
$(BIN): $(SRC)
	nasm -o $@ $<

$(COM): $(SRC1)
	nasm -o $@ $<

.PHONY: clean fd bochs dump mount

dump: $(BIN)
	ndisasm -o $(DOS_LOAD_ADDR) $(BIN) > disasm.asm 

clean:
	rm -f *.bin *.com  \
			  *.out *.elf *.o \
				*.log 

msr: $(BIN) 
	dd if=$(BIN) of=$(BOCHS_IMG_MSR) bs=512 count=1 conv=notrunc
	bochs -f $(BOCHS_CONFIG_MSR)

dos:$(COM) mount
	bochs -f $(BHCHS_CONFIG_DOS)

mount: $(COM)
	-sudo mkdir $(MOUNT_POINT)/
	sudo mount -o loop $(BOCHS_IMG_DOS_PM) $(MOUNT_POINT)/
	sudo cp $(COM) $(MOUNT_POINT)/ -v 
	sudo umount $(MOUNT_POINT)/

hd:	$(BIN)
	vhdw -s $(BIN) -d $(VHD) 