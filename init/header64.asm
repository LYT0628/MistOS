%include "../boot/boot.inc"
global _start

extern main 
; [SECTION .header64 vstart=0x20000] // vstart 在 elf格式编译下无法使用
[SECTION .header64 ]
[BITS 64]
_start:
loop_fin:
  mov ax, SELECTOR_DATA
  mov ds, ax 
  mov ss, ax 
  mov es, ax 
  mov fs, ax 
  mov gs, ax 
  
  push main
  ret   