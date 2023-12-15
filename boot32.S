.text
.code32
start32:
  ; mov $0x3f8, %dx # location of serial port 
  ; mov $'P', %al # content 
  ; out %al, %dx # send content to serial port

  ; hlt # rest cpu

  ; set selector of kernel data segment for cpu to get
  mov $0x10, %ax
  mov %ax, %ds

  lgdt gdtr ; load new global descriptor table.  


  ; initialize pm_3
  mov $0x32000, %edi ; beginning address of pml_2  
  mov $0x33000 + 3, %eax  ; firset value of pm_2. adding 3 for special control-bits
1:
  stosl ; copy content of memory from eax to edi, postfix 'l' for 32-bits operators. every time copy 32-bits, and auto imcrease 32-bits
  add $0x1000, %eax ; point to next pml_1 
  add $4, %edi ; 32-bits was added by stosl,and we needto add 32-bits for reach 64-bits. point to next item of pml_1

  cmp $(0x32000 +31 * 8), %edi ; we fill (32 *8) items, limit by index of pml_2
  jle 1b

  ;initialize pml_1
  mov $0x33000, %edi
  mov $0x0 +3, %eax 
2:
  stosl
  add $0x1000, %eax 
  add $4, %edi

  cmp $(0x33000 + 32 * 512 * 8 - 8), %edi
  jle 2b


; set new global descriptor table. the difference noly reset no need bit to zero, and enable long mode
gdt:
	.quad 0x0000000000000000 # reserved
	.quad 0x00209a0000000000 # kernel code segment
	.quad 0x0000920000000000 # kernel data segment
gdt_end:

gdtr:
	.word gdt_end - gdt # 16bit. length of global descriptor table.
	.word gdt		# noew is protection mode, base address starts from 0x0


; initialize pml_4 for kernel segment
.org 0x10000 ;set address point to offset(setted by -Ttext oprtion, and now is 0x20000) + 0x10000\
  .quad 0x0000000000053003 ; for identity mapping pml_3
  .fill 511, 8, 0 ; repeat, size(bytes), value. 511*8*8 zeros
  .quad 0x0000000000031003 ;16*4. quad declare a 64-bits.

; initialize pml_3
.org 0x11000 
  .fill 510, 8, 0
  .quad 0x 0000000000032003
  .fill 1, 8, 0 

; initialize pml_2
.org 0x12000 
  .fill 510, 2, 0

; initialize 32 pml_1s 
.org 0x13000 
  .fill 512 * 32, 8, 0 ; 32 pml_1 for 64MB starting from 0


; for identity mapping
.org 0x33000 ;pml_3
  .quad 0x0000000000054003
  .fill 511, 8, 0

.org 0x34000
  .quad 0x0000000000033003
  .fill 511, 8, 0