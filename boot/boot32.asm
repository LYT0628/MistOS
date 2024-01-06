;; 进入这里就不需要考虑启动盘末尾标识的问题了，可以使用多个section。
%include	"pm.inc"
%include 	"boot.inc"


PageDirBase		equ	0x200000	; 页目录开始地址: 2M
PageTblBase		equ	0x201000	; 页表开始地址: 2M+4K

PM4		        EQU	0x20000	; 四级页表1个
PM3		        EQU	0x21000	; 三级页表1个
PM2		        EQU	0x22000	; 二级页表1个
PM1		        EQU	0x23000	; 一级页表 512 个
PM3_IDENTITY  EQU 0x33000 ; 恒等映射的三级页表
PM2_IDENTITY  EQU 0x34000 ; 恒等映射的二级页表
; 我使用page指令，发现 0x0 的线性地址映射到 0x34000 的物理页， 说明 pm4-> pm3-> pm2 ,pm3被认为是物理页
; 即只有两级页表 
[SECTION .boot32 vstart=0x10000]
[BITS 32]
  mov ax, SELECTOR_DATA
  mov ds, ax 
  mov es, ax 

  ; call readHeader64 ; 读入内核代码段

  lgdt [GDTR] ;为64位模式准备新的段描述符

  call setupPaging   
  ; call SetupPagingTmp ; 没办法了, 现在暂时先使用2级分页吧, 现在bohcs默认用二级分页，等找到办法开启4级分页再切换回来


; 使能PAE 2
  mov eax, cr4
  bts eax, 5 
  mov cr4, eax

; 设置cr3指向四级页表(根页表) 3
  mov eax, PM4
  mov cr3, eax


; 使能 64位模式
; msr EFER
  mov  ecx, 0xC000_0080
  rdmsr
  bts eax, 0x8 ; 使能64位模式 
  bts eax, 0x0 ; 使能 syscall
  wrmsr 

; 使能分页..默认就是启动分页的 ？
  mov eax, cr0 
  bts eax, 31
  mov cr0, eax 


  ; jmp SELECTOR_SYSTEM: 0x0100000
  jmp SELECTOR_SYSTEM: HEADER64_PHYSICAL_ADDR
; 别忘记粒度了，4KB的粒度，段长空间才是4GB


;启动设置页表--------------------------------------------------------------------------
setupPaging:
	mov	AX, SELECTOR_DATA ; stosd 指令 EAX -> ES:EDI, edi 会自动增加
	mov	ES, AX  
  

; 初始化4级页表 -----------------------------------------------------
  mov	EDI, PM4  ; 目的地址 EDI  
  mov	EAX, PM3_IDENTITY | PG_P | PG_RWW ; 指向恒等映射的三级页表
  stosd
  xor EAX, EAX ; 高32位填充0
  stosd 

	mov	ECX, 510  ; 填充510个空项
pm4_init:
	stosd ; EAX -> ES:EDI
  stosd ; 高32位也填充0
  loop	pm4_init


; 第 512 项指向，pm3
  mov EAX, PM3 | PG_P | PG_RWW
  stosd
  xor EAX, EAX ; 高32位填充0
  stosd 
; 4级页表初始化结束--------------------------------------------------


  ; 初始化3级页表
  ; 填充510个空项
  mov EDI, PM3 
	mov	ECX, 510  
  xor EAX, EAX
pm3_init:
	stosd ; EAX -> ES:EDI
  stosd 
	loop	pm3_init

  ; 第 511 项指向pm2
  mov EAX, PM2 | PG_P | PG_RWW
  stosd
  xor EAX, EAX ; 高32位填充0
  stosd 

  ; 第512 项填充 0 
  stosd
  stosd 
; 三级页表初始化结束---------------------------------------------

  ; 初始化2级页表
  mov EDI, PM2 
	mov	ECX, 512
  mov EDX, PM1 | PG_P | PG_RWW ; 一级页表首地址
pm2_init:
  mov EAX, EDX
	stosd ; EAX -> ES:EDI
  add EDX, 0x1000 ; 指向下一个一级页表项
  xor EAX, EAX ; 高32位填充0
  stosd 
	loop	pm2_init
; 二级页表初始化结束

  ; 初始化1级页表
  mov EDI, PM1 ; 
	mov	ECX, 32 * 512  ; 先做好前 32 个一级页表， 现在还不知道物理空间到底有多大 
  mov EDX, 0 | PG_P | PG_RWW ; 指向整个物理地址
pm1_init:
  mov EAX, EDX
	stosd ; EAX -> ES:EDI
  add EDX, 0x1000 ; 指向下一个一级页表项
  xor EAX, EAX ; 高32位填充0
  stosd 
  loop	pm1_init
  
  ; 初始化恒等映射三级页表
  mov	EDI, PM3_IDENTITY  ; 目的地址 EDI
  ; 指向恒等映射的二级页表
  mov	EAX, PM2_IDENTITY | PG_P | PG_RWW
  stosd
  xor EAX, EAX ; 高32位填充0
  stosd 
  ; add EAX, 0x1000 ;  每个表项4K大小 

; 填充511个空项
	mov	ECX, 511
pm3_identity_init:
	stosd ; EAX -> ES:EDI
  stosd 
	loop	pm3_identity_init


  ; 初始化恒等映射二级页表
  mov	EDI, PM2_IDENTITY  ; 目的地址 EDI
  ; 复用内核映射的第一个一级页表
  mov	EAX, PM1 | PG_P | PG_RWW
  stosd
  xor EAX, EAX ; 高32位填充0
  stosd 
  add EAX, 0x1000 ;  每个表项4K大小 

; 填充511个空项
	mov	ECX, 511
pm2_identity_init:
	stosd ; EAX -> ES:EDI
  stosd 

	loop	pm2_identity_init

	ret
;-------------------------------------

; 启动分页机制 --------------------------------------------------------------
SetupPagingTmp:
	; 为简化处理, 所有线性地址对应相等的物理地址.

	; 首先初始化页目录
	mov	ax, SELECTOR_PAGE_DIR	; 此段首地址为 PageDirBase
	mov	es, ax
	mov	ecx, 1024		; 共 1K 个表项
	xor	edi, edi 
	xor	eax, eax
	mov	eax, PageTblBase | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表 (1K 个, 4M 内存空间)
	mov	ax, SELECTOR_PAGE_TBL	; 此段首地址为 PageTblBase
	mov	es, ax
	mov	ecx, 1024 * 1024	; 共 1M 个页表项, 也即有 1M 个页
	xor	edi, edi
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2

	mov	eax, PageDirBase
	mov	cr3, eax
	
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	
	jmp	short .3
.3:
	nop

	ret
; 分页机制启动完毕 ----------------------------------------------------------

;-----------------------------------------
;COMMON: jmp $
;--------------------------------------------
; print:
;   mov ax, 0
;   mov ss, 0
;   ret 
; --------------------------------------------



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDT 需要重新设置， 64位模式下段描述符只有 L, P, DPL, S, TYPE 有作用
;                              段基址,       段界限     , 属性
GDT:	   Descriptor       0,                	 0, 						0           	 ; 空描述符
DESC_CODE64: Descriptor   0, 				           0xFF_FF_FF_FF, 			DA_L | DA_CR | DA_G ; 内核代码段，可读，长模式，存在，特权级0
DESC_DATA: Descriptor     0,     		           0xFF_FF_FF_FF,   	 	DA_DRW | DA_G ; 内核数据段
DESC_PAGE_DIR: Descriptor PageDirBase, 4095, DA_DRW                   ; 二级页
DESC_PAGE_TBL: Descriptor PageTblBase, 1023, DA_DRW | DA_G   ; 一级页
; GDT 结束

GDT_LEN		equ	$ - GDT	; GDT长度
GDTR		  dw	GDT_LEN - 1	; GDT界限
		      dd	GDT		; GDT基地址

; GDT 选择子
SELECTOR_SYSTEM		  EQU	DESC_CODE64	- GDT
SELECTOR_DATA       EQU DESC_DATA - GDT
SELECTOR_PAGE_DIR		equ	DESC_PAGE_DIR	- GDT
SELECTOR_PAGE_TBL		equ	DESC_PAGE_TBL	- GDT
; END of [SECTION .gdt]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ; pm_4
; ; 为boot32 留下 64KB 空间;
; ; 因为我们将 虚拟地址 0xFFFF_FFFF_8000_0000 起的位置分配给内核
; ; 所以前九位 1_1111_1111b 表示其在四级页表的索引，为 511， 即最后一个页表项
; ; 现在要考虑把多少个扇区读进来了
; ;这样搞内核映像也太大了,能不能在程序中动态创建页表
; org 0x10000 ; 此时位置= 0x10000(文件起始) + 0x10000(ORG 指令指定) = 0x20000
;   DQ 0x33000 | PA_P | PA_RW ; 恒等映射的三级页表，放在一级页表之后，本文件偏移33000e的位置，即43000 
;   times 510 * 8 DB 0x0 ; 511个，64位(8个byte) 的 0 
;   DQ 0x21000  | PA_P | PA_RW ; 存在的，可读写的页面, 每个页表大小为 0x1000(4KB), 所以三级页表的起始项地址位 0x20000+0x1000

; ; pm_3 0x21000
;   times 510 * 8 DB 0x0 
;   DQ 0x22000 | PA_P |PA_RW
;   DQ 0x0 

; ; pm_2 0x22000
;   times 512 * 8 DB 0x0 

; ;pm_1 0x23000
;   times 512*32 DB 0x0 
; ; 一级页表结束在本文件0x33000的位置， 总共占408个扇区

; ;pm_3 恒等映射 0x33000
;   DQ 0x44000 | PA_P | PA_RW ; 指向恒等映射一级页表
;   times 511 * 8 DB 0x0

; ;pm_2 恒等映射 0x34000
;   DQ 0x23000 | PA_P | PA_RW ; 复用原本的一级页表， 指向一级页表的起始位置，指向0x0的位置
;   times 511 * 8 DB 0x0 
; ; 恒等映射二级页表结束在本文件0x45000的位置， 总共占424个扇区