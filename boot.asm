; include some macro, constant 
%include "pm.inc"

; put code into addr of 07c00H
; org 07c00H 
org 0100H
  jmp LB_BOOT16

; global descriptor table
[SECTION .gdt]
LB_GDT:          DESCRIPTOR       0,                0,            0 ; reserved
LB_DESC_CODE32:  DESCRIPTOR       0,SEC_BOOT32_LEN -1, DA_C + DA_32 ; kernel code segment
LB_DESC_VIDEO:   DESCRIPTOR 0b8000H,           0ffffH,       DA_DRW ; video segment
; END OF GDT

GDT_LEN   equ $ - LB_GDT ; Length of GDT. in nasm, we use $ - label to count offset between labels.
GDT_PRT   DW  GDT_LEN - 1 ; end address of GDT. in nasm variables is equire to label. GDT_LEN means, the addr of GDT_LEN
          DD  0           ; offset of GDT, now cs is start 0, so here is zero.    

; selector , when LT, AU is zero, Selector is index in GDT
SELECTOR_CODE32 equ LB_DESC_CODE32 - LB_GDT
SELECTOR_VIDEO  equ LB_DESC_VIDEO  - LB_GDT
; end of [SECTION .gdt]



[SECTION .boot16]
[BITS 16]
LB_BOOT16: 
; initial segment register.
  mov ax, cs
  mov ds, ax
  mov es, ax 
  mov ss, ax
  mov sp, 0100H

; set kernel segment for jump  for [SECTION .boot32] 
  xor eax, eax ; 归零
  mov ax, cs
  shl eax, 4 ; shl, 左位移

  add eax, LB_BOOT32
  mov word [LB_DESC_CODE32 + 2], ax
  shr eax, 16 
  mov byte [LB_DESC_CODE32 + 4], al 
  mov byte [LB_DESC_CODE32 + 7], ah

; set GDT
  xor eax, eax
  mov ax, ds
  shl eax, 4
  add eax, LB_GDT
  mov dword [GDT_PRT + 2], eax
; load GDT to gdtr  
  lgdt [GDT_PRT]

; close interrupt
  cli 


; enable A20 
  in al, 92H
  or al, 00000010B
  out 92H, al

; enable PE-bit
  mov eax, cr0
  or eax, 1
  mov cr0, eax 
  
; long jump to [SECTION .boot32]
  jmp dword SELECTOR_CODE32:0
; end of  boot16

[SECTION .boot32] 
[BITS	32]

LB_BOOT32:
  mov ax, SELECTOR_VIDEO
  mov gs, ax 

  mov edi, (80* 11 + 79) *2 
  mov ah, 0cH
  mov al, 'P'
  mov [gs:edi], ax
  jmp $

SEC_BOOT32_LEN equ $ - LB_BOOT32
; end of boot32
