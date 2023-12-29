;; 进入这里就不需要考虑启动盘末尾标识的问题了，可以使用多个section。
%include	"pm.inc"
%include 	"boot.inc"


[SECTION .boot32 vstart=0x10000]
[BITS 32]
  ; 为64 位模式准备e新的 段描述符
  mov ax, SelectorData
  mov ds, ax 

  lgdt [GdtPtr]

  jmp $



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDT 需要重新设置， 64位模式下段描述符只有 L, P, DPL, S, TYPE 有作用
;                              段基址,       段界限     , 属性
LABEL_GDT:	   Descriptor       0,                	 0, 						0           	 ; 空描述符
LABEL_DESC_CODE32: Descriptor   0, 				           0, 						DA_L + DA_CR ; 内核代码段，可读，长模式，存在，特权级0
LABEL_DESC_DATA: Descriptor     0,     		           0,   	 				DA_DRW  ; 内核数据段
; GDT 结束

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		      dd	LABEL_GDT		; GDT基地址

; GDT 选择子
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorData      EQU LABEL_DESC_DATA - LABEL_GDT
; END of [SECTION .gdt]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; 为boot32 留下 64KB 空间
org 0x10000
  times 511 * 8 DB 0x0 ; 511个，64位(8个byte) 的 0
  DQ 0x1