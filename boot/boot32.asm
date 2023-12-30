;; 进入这里就不需要考虑启动盘末尾标识的问题了，可以使用多个section。
%include	"pm.inc"
%include 	"boot.inc"


[SECTION .boot32 vstart=0x10000]
[BITS 32]
  ; 为64 位模式准备e新的 段描述符
  mov ax, SelectorData
  mov ds, ax 

  lgdt [GdtPtr]


;;;;;;;;;;;;;;;;;;;;;;;;为二级页表赋值
  mov edi, 0x22000, 
  mov eax, 0x23000 | PA_P | PA_RW 

.pm2_init:
  mov [edi], eax
  add eax, 0x1000
  add edi, 8 ; 每次移动64位，一个表项


  cmp edi, 0x22000 + 31 * 8
  jbe .pm2_init
; 二级页表初始化结束
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;初始化一级页表
  mov edi, 0x23000, 
  mov eax, 0x0 | PA_P | PA_RW 

.pm1_init:
  mov [edi], eax
  add eax, 0x1000
  add edi, 8 ; 每次移动64位，一个表项

  cmp edi, 0x23000 + 512* 32 * 8 -8 
  jbe .pm1_init
; 一级页表初始化结束
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; 使能PAE
  mov eax, cr4
  or eax, 1_0000b 
  mov cr4, eax 

; 设置cr3指向四级页表(根页表)
  mov eax, 0x20000
  mov cr3, eax

; 使能 64位模式
;;; msr EFER
  mov  ecx, 0xC000_0080
  rdmsr
  or eax, 1000_0000b ; 使能64位模式 
  or eax, 0000_0001b ; 使能 syscall
  wrmsr 

; 开启分页
  mov eax, cr0
  bts eax, 31
  mov cr0, eax 


  jmp SelectorCode64: 0x100000



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDT 需要重新设置， 64位模式下段描述符只有 L, P, DPL, S, TYPE 有作用
;                              段基址,       段界限     , 属性
LABEL_GDT:	   Descriptor       0,                	 0, 						0           	 ; 空描述符
LABEL_DESC_CODE64: Descriptor   0, 				           0, 						DA_L + DA_CR ; 内核代码段，可读，长模式，存在，特权级0
LABEL_DESC_DATA: Descriptor     0,     		           0,   	 				DA_DRW  ; 内核数据段
; GDT 结束

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		      dd	LABEL_GDT		; GDT基地址

; GDT 选择子
SelectorCode64		equ	LABEL_DESC_CODE64	- LABEL_GDT
SelectorData      EQU LABEL_DESC_DATA - LABEL_GDT
; END of [SECTION .gdt]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; pm_4
; 为boot32 留下 64KB 空间;
; 因为我们将 虚拟地址 0xFFFF_FFFF_8000_0000 起的位置分配给内核
; 所以前九位 1_1111_1111b 表示其在四级页表的索引，为 511， 即最后一个页表项
; 现在要考虑把多少个扇区读进来了
;这样搞内核映像也太大了,能不能在程序中动态创建页表
org 0x10000 ; 此时位置= 0x10000(文件起始) + 0x10000(ORG 指令指定) = 0x20000
  DQ 0x43000 | PA_P | PA_RW ; 恒等映射的三级页表，放在一级页表之后，本文件偏移33000e的位置，即43000 
  times 510 * 8 DB 0x0 ; 511个，64位(8个byte) 的 0 
  DQ 0x21000  | PA_P | PA_RW ; 存在的，可读写的页面, 每个页表大小为 0x1000(4KB), 所以三级页表的起始项地址位 0x20000+0x1000

; pm_3 0x21000
  times 510 * 8 DB 0x0 
  DQ 0x22000 | PA_P |PA_RW
  DQ 0x0 

; pm_2 0x22000
  times 512 * 8 DB 0x0 

;pm_1 0x23000
  times 512*32 DB 0x0 
; 一级页表结束在本文件0x33000的位置， 总共占408个扇区

;pm_3 恒等映射 0x34000
  DQ 0x44000 | PA_P | PA_RW ; 指向恒等映射一级页表
  times 511 * 8 DB 0x0

;pm_2 恒等映射 0x44000
  DQ 0x23000 | PA_P | PA_RW ; 复用原本的一级页表， 指向一级页表的起始位置，指向0x0的位置
  times 511 * 8 DB 0x0 
; 恒等映射二级页表结束在本文件0x45000的位置， 总共占424个扇区