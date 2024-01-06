
ROOT_DIR:=.
BOOT_DIR:=$(ROOT_DIR)/boot
INIT_DIR:=$(ROOT_DIR)/init
INCLUDE_DIR:=$(ROOT_DIR)/inc
BUILD_DIR:=$(ROOT_DIR)/build
TOOLS_DIR:=$(ROOT_DIR)/tools
PACKAGE=$(ROOT_DIR)/kernel.bin

PYTHON:=python

THIS:=Makefile
README:=README.md

SHELL:=/bin/sh

# 汇编代码
ASMS:=$(wildcard $(BOOT_DIR)/*.asm)
ASMS+=$(wildcard $(BOOT_DIR)/*.inc)
ASMS+=$(wildcard $(INIT_DIR)/*.asm)
ASMS+=$(wildcard $(INCLUDE_DIR)/*.asm)

# C代码
SRCS:=$(wildcard $(INIT_DIR)/*.c)

VHD=/home/lyt0628/dev/CODE/MistOS/tools/vpcvm/orange/orange.vhd
# bochs
TOOL_BOCHS:=$(TOOLS_DIR)/bochs
# 自己写的 bootloader
BOCHS_CONFIG_MSR:=$(TOOL_BOCHS)/bochsrc_msr
BOCHS_IMG_MSR:=$(TOOL_BOCHS)/msr.img


$(PACKAGE):	$(BUILD_DIR)/build.py $(ASMS) $(SRCS)
	cd $(BOOT_DIR) && make
	cd $(INCLUDE_DIR) && make
	cd $(INIT_DIR) && make
	$(PYTHON) $(BUILD_DIR)/build.py


.PHONY: clean vhd msr 

# 将系统内核写进VHD硬盘 , 现在还兼容硬盘，不可运行
vhd:	$(PACKAGE)
	vhdw -s $(PACKAGE) -d $(VHD) 

msr: $(PACKAGE) 
	dd if=$(PACKAGE) of=$(BOCHS_IMG_MSR) bs=1000000000 count=1 conv=notrunc
	bochs -f $(BOCHS_CONFIG_MSR)

dump: $(ASMS) $(SRCS)
	cd $(BOOT_DIR) && make dump
	cd $(INCLUDE_DIR) && make dump
	cd $(INIT_DIR) && make dump


clean:
	cd $(BOOT_DIR) && make clean
	cd $(INCLUDE_DIR) && make clean
	cd $(INIT_DIR) && make clean
	-rm -f *.bin *.com  \
			  *.out *.elf *.o \
				*.log


