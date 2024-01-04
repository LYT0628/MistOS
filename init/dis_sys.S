
sys.elf：     文件格式 elf64-x86-64


Disassembly of section .text:

0000000000100000 <main>:
  100000:	55                   	push   %rbp
  100001:	48 89 e5             	mov    %rsp,%rbp
  100004:	f4                   	hlt    
  100005:	f3 b8 00 00 00 00    	repz mov $0x0,%eax
  10000b:	5d                   	pop    %rbp
  10000c:	c3                   	ret    
