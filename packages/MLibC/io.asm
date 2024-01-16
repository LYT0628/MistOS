global io_hlt
global io_cli
global io_sti
global io_stihlt
global io_in8
global io_in16
global io_in32
global io_out8
global io_out16
global io_out32
global write_mem8

[SECTION .text]
; ALIGN 16
[BITS 64]
io_hlt:
  hlt
  ret
io_cli:
  cli
  ret
io_sti:
  sti 
  ret 
io_stihlt:
  sti 
  hlt 
  ret 
io_in8: ; int io_in8(int port)
  mov EDX, EAX ; port
  mov EAX, 0 
  in AL, DX
  ret
io_in16:
  mov EDX, EAX ; port
  mov EAX, 0 
  in AX, DX
  ret
io_in32:
  mov EDX, EAX ; port 
  in EAX, DX
  ret
io_out8:
  mov EDX, EAX ; port
  mov EAX, ESI  ; data
  out DX, AL
  ret 
io_out16:
  mov EDX, EAX ; port
  mov EAX, ESI  ; data
  out DX, AX
  ret 
io_out32:
  mov EDX, EAX ; port
  mov EAX, ESI  ; data
  out DX, EAX
  ret 
; void write_mem8(int addr, int data)
; 向目标地址写入int大小(32位)的数据eax, esi
write_mem8:
  mov [EAX], ESI 
  ret