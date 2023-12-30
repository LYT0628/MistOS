
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



;软盘驱动,读取boot32内核代码;;;;;;;;;;;;;;;;;;;;;;
;2 号扇区到 525 号扇区，我们留一点空余， 把 一直到499 号扇区(包括)，都留给boot32
	mov ax, BOOT32_LOGIC_ADDR
	mov es, ax 

	mov ch, 0 ; 0柱面
	mov dh, 0 ; 0磁头
	mov cl, 2 ; 扇区2

.readLoop:
	mov ah, 0x02 ; 读盘操作
	mov al, 1 ;一个扇区
	mov bx, 0
	mov dl, 0x00 ;A驱动器
	int 0x13 ; bios中断

	mov ax, es  ; 读取地址后移0x200,即512字节
	add ax, 0x0020
	mov es, ax 

	add cl, 1

	cmp cl, 18 ; 磁头的扇区是否读完了
	jbe .readLoop ; 没读完就继续读

	mov cl, 1 ; 重置扇区 
	add dh, 1 
	cmp dh, 2; 柱面的磁头是否读完了
	jb .readLoop ; 没读完就继续读

	mov dh, 0 ;重置磁头
	add ch, 1 
	cmp ch, 10 ; 读取10个柱面
	jb .readLoop
;boot32读取结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 64位a代码得在32位模式才可以加载


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