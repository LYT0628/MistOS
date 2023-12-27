


[SECTION boot16  vstart=7c00h]
ALIGN 16
LB_BOOT16:

  mov ax, cs
  mov ds, ax
  mov es, ax 

  call print_boot_msg
  jmp $ 
 

print_boot_msg:
  mov ax, boot_msg
  mov bp, ax 
  mov cx, 16
  mov ax, 01301H
  mov bx, 000cH
  mov dl, 0
  int 10H
  ret 

boot_msg:  DB "Hello, MistXS!  "

times 510 - ($ - $$) DB 0
DW 0xAA55