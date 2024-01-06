global io_hlt

[SECTION .text]
; ALIGN 16
[BITS 64]
io_hlt:
  mov ax, 0xFF
  hlt
  rep
