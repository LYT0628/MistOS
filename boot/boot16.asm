
%include	"pm.inc"	; 常量, 宏
%include 	"boot.inc"



[SECTION .boot16 vstart=0x7c00]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs ; cs初始是0
	mov	ds, ax
	mov	es, ax
	mov	ss, ax



	lgdt	[GdtPtr]	; 加载 GDTR


	cli	; 关中断

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al



;软盘驱动,读取boot32内核代码;;;;;;;;;;;;;;;;;;;;;
	mov ax, BOOT32_LOGIC_ADDR
	mov es, ax 

	mov ch, 0 ; 0柱面
	mov dh, 0 ; 0磁头
	mov cl, 2 ; 扇区2

	mov ah, 0x02 ; 读盘操作
	mov al, 1 ;一个扇区
	mov bx, 0
	mov dl, 0x00 ;A驱动器
	int 0x13 ; bios中断
;boot32读取结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; 注意，跳到保护模式后不能 mov cs段寄存器了
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax
; 真正进入保护模式
	jmp	dword SelectorCode32: BOOT32_PHYSICAL_ADDR
; END of [SECTION .boot16]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDT
;                              段基址,       段界限     , 属性
LABEL_GDT:	   Descriptor       0,                	 0, 						0           	 ; 空描述符
LABEL_DESC_CODE32: Descriptor   0, 				BOOT32_LIMIT, 						DA_C + DA_32	 ; 内核代码段
LABEL_DESC_DATA: Descriptor     0,     		BOOT32_LIMIT,   	 				DA_DRW + DA_32 ; 内核数据段
; GDT 结束

GdtLen		EQU	$ - LABEL_GDT	; GDT长度
GdtPtr		DW	GdtLen - 1	; GDT界限
		      DD	LABEL_GDT		; GDT基地址

; GDT 选择子
SelectorCode32		EQU	LABEL_DESC_CODE32	- LABEL_GDT
SelectorData      EQU LABEL_DESC_DATA - LABEL_GDT
; END of [SECTION .gdt]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


times 510 - ($ - $$) DB 0
DW 0xAA55 