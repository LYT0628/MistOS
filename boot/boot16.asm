
%include	"pm.inc"	; 常量, 宏
%include 	"boot.inc"

; BOOT32_LBA  						EQU 00002h 				;boot32在磁盘中的逻辑扇区号
; BOOT32_LOGIC_ADDR   		EQU 01000h 			;boot32在内存中的逻辑地址 
; BOOT32_PHYSICAL_ADDR   	EQU 10000h  		;boot32在内存中的物理地址
; BOOT32_LIMIT 						EQU FFFFFh     ;boot32的段界限

; HEADER64_LOGIC_ADDR     EQU 100000h    ;boot64在内存中的逻辑地址

[SECTION boot16 vstart=7c00h]
[BITS	16]
SEG_BOOT16:
	mov	AX, CS ; cs初始是0
	mov	DS, AX
	mov	ES, AX
	mov	SS, AX

	call readBoot32

	cli	;关中断

	lgdt	[GDTR]	;加载 GDTR

	;打开地址线A20
	in	AL, 92h
	or	AL, 00000010b
	out	92h, AL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 注意，跳到保护模式后不能 mov cs段寄存器了
	mov	EAX, cr0
	or	EAX, 1
	mov	cr0, EAX
; 真正进入保护模式
	jmp	dword SELECTOR_BOOT32: BOOT32_PHYSICAL_ADDR
; END of [SECTION .boot16]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------------------------
;软盘驱动,读取boot32内核代码
;-----------------------------------------------------
readBoot32:
	mov AX, BOOT32_LOGIC_ADDR ; 加载到 0x10000 的位置
	mov ES, AX  

	mov CH, 0 ;0柱面
	mov DH, 0 ;0磁头
	mov CL, 2 ;扇区2

loop_read_sector:
	mov AH, 02h ;读盘操作
	mov AL, 1 ;一个扇区
	mov BX, 0 
	mov DL, 00h ;A驱动器
	int 13h ; bios磁盘中断

	mov AX, ES  ; 读取地址后移0x0200,即512字节
	add AX, 0020h
	mov ES, AX 

	add CL, 1 ;读取下一个扇区 

	cmp CL, 18 ; 磁头的扇区是否读完了
	jbe loop_read_sector;

	mov CL, 1 ;重置扇区 
	add DH, 1 ; 读取下一个磁头

	cmp DH, 2; 柱面的磁头是否读完了
	jb loop_read_sector

	mov DH, 0 ;重置磁头
	add CH, 1 ;读取下一个柱面

	cmp CH, 3 ; 一共读取3个柱面
	jb loop_read_sector

	ret 
;boot32读取结束---------------------------------------------

;----------------------------------------------------------------------------------------------
; GDT
;----------------------------------------------------------------------------------------------
;                              段基址,       段界限     , 属性
GDT:	   Descriptor       0,                	 0, 						0           	 ; 空描述符
DESC_CODE32: Descriptor   0, 				BOOT32_LIMIT, 						DA_C + DA_32	 ; 内核代码段
DESC_DATA: Descriptor     0,     		BOOT32_LIMIT,   	 				DA_DRW + DA_32 ; 内核数据段
; GDT 结束

GDT_LEN		EQU	$ - GDT	; GDT长度
GDTR		DW	GDT_LEN - 1	; GDT界限
		    DD	GDT		; GDT基地址

; GDT 选择子
SELECTOR_BOOT32		EQU	DESC_CODE32	- GDT
SELECTOR_DATA      EQU DESC_DATA - GDT
;end of GDT
;-------------------------------------------------------------------
; END of [SECTION .gdt]
;--------------------------------------------------------------------

TIMES 510 - ($ - $$) DB 0
DW 0xAA55 