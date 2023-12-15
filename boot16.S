# AT&T 
# boot16.S  would be loaded at 0x1000

.text 
.code16 # genetate code for revironment of 16 bit
start16:
	cli  # dont response to interupt

	lgdt gdtr # load length and  address of gdt to register GDTR

	# enable protection mode, the last bit of register cr0(control register 0)
	mov %cr0, %eax
	or $0x1, %eax 
	mov %eax, %cr0 
	#  from now, protection mode is enabled.

	ljmpl $0x8, $0x20000 # 32 bit long jump(diff segment) to code segment boot32.S
											# 0x8 is selector of kernel code segment
											# 0x20000 is offset of kernel code, now base address start from 0x0000 

# symbel address is located by gcc and address of code is up to us
# global descriptor table 
gdt:
	.quad 0x0000000000000000 # reserved
	.quad 0x00c09a00000007ff # kernel code segment
	.quad 0x00c09200000007ff # kernel data segment
gdt_end:

gdtr:
	.word gdt_end - gdt # 16bit. length of global descriptor table.
	.word gdt, 0x1 # address of gdt. 0x1( in kvmtool(cs is 0x1000, and <<4 )) is the offset of boot16.S 
								# here load two word and low position is gdt, high position is 0x1

	
