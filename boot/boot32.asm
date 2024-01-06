;; 进入这里就不需要考虑启动盘末尾标识的问题了，可以使用多个section。
%include	"pm.inc"
%include 	"boot.inc"


PM4		        EQU	0x20000	; 四级页表1个
PM3		        EQU	0x21000	; 三级页表1个
PM2		        EQU	0x22000	; 二级页表1个
PM1		        EQU	0x23000	; 一级页表 512 个
PM3_IDENTITY  EQU 0x33000 ; 恒等映射的三级页表
PM2_IDENTITY  EQU 0x34000 ; 恒等映射的二级页表
; 页表结束在 0x35000的位置

[SECTION .boot32 vstart=0x10000]
[BITS 32]
  mov ax, SELECTOR_DATA
  mov ds, ax 
  mov es, ax 

  lgdt [GDTR] ;为64位模式准备新的段描述符

  call setupPaging   


; 使能PAE 
  mov eax, cr4
  bts eax, 5 
  mov cr4, eax

; 设置cr3指向四级页表
  mov eax, PM4
  mov cr3, eax


; 使能 64位模式
; msr EFER
  mov  ecx, 0xC000_0080
  rdmsr
  bts eax, 0x8 ; 使能64位模式 
  bts eax, 0x0 ; 使能 syscall
  wrmsr 

; 使能分页
  mov eax, cr0 
  bts eax, 31
  mov cr0, eax 

  mov AX, SELECTOR_DATA
  mov DS, AX 
  mov SS, AX 
  mov ES, AX 
  mov FS, AX 
  mov GS, AX 

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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDT 需要重新设置， 64位模式下段描述符只有 L, P, DPL, S, TYPE 有作用, 因为粒度得重新设置，所以GDT必须重新分配
;                              段基址,       段界限     , 属性
GDT:	   Descriptor       0,                	 0, 						0           	 ; 空描述符
DESC_CODE64: Descriptor   0, 				           0xFF_FF_FF_FF, 			DA_L | DA_CR | DA_G ; 内核代码段，可读，长模式，存在，特权级0
DESC_DATA: Descriptor     0,     		           0xFF_FF_FF_FF,   	 	DA_DRW | DA_G ; 内核数据段
; GDT 结束

GDT_LEN		equ	$ - GDT	; GDT长度
GDTR		  dw	GDT_LEN - 1	; GDT界限
		      dd	GDT		; GDT基地址

; GDT 选择子
SELECTOR_SYSTEM		  EQU	DESC_CODE64	- GDT
SELECTOR_DATA       EQU DESC_DATA - GDT
; END of [SECTION .gdt]
;-------------------------------------------------------------------
