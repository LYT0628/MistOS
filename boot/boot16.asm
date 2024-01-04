
%include	"pm.inc"	; 常量, 宏
%include 	"boot.inc"

[SECTION boot16 vstart=7c00h]
[BITS	16]
SEG_BOOT16:
	mov	AX, CS ; cs初始是0
	mov	DS, AX
	mov	ES, AX
	mov	SS, AX

	; 读入内核代码
	call printBootMsg
	call readBoot32
	call readHeader64
	call switch2GraphMode

	cli	;关中断

	lgdt	[GDTR]	;加载 GDTR

	;打开地址线A20
	in	AL, 92h
	or	AL, 00000010b
	out	92h, AL

;------------------------------------------------------------------------------
; 注意，跳到保护模式后不能 mov cs段寄存器了
	mov	EAX, cr0
	or	EAX, 1
	mov	cr0, EAX
; 真正进入保护模式
	jmp	dword SELECTOR_BOOT32: BOOT32_PHYSICAL_ADDR
; END of [SECTION boot16]
;-------------------------------------------

;------------------------------------------------
;软盘驱动,读取boot32内核代码
;-----------------------------------------------------
readBoot32:
	mov AX, BOOT32_LOGIC_ADDR ; 加载到 0x10000 的位置
	mov ES, AX  

	mov CH, 0 ;0柱面
	mov DH, 0 ;0磁头
	mov CL, 2 ;扇区2

loop_read_boot32:
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
	jbe loop_read_boot32;

	mov CL, 1 ;重置扇区 
	add DH, 1 ; 读取下一个磁头

	cmp DH, 2; 柱面的磁头是否读完了
	jb loop_read_boot32

	mov DH, 0 ;重置磁头
	add CH, 1 ;读取下一个柱面

	cmp CH, 1 ; 一共读取1个柱面
	jb loop_read_boot32

	ret 
;boot32读取结束---------------------------------------------
;------------------------------------------------
;软盘驱动,读取header64内核代码
;-----------------------------------------------------
readHeader64:
	mov AX, HEADER64_LOGIC_ADDR ; 加载到 0x020000 的位置
	mov ES, AX  

	mov CH, 0 ;0柱面
	mov DH, 0 ;0磁头
	mov CL, 4 ;扇区4

loop_read_header64:
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
	jbe loop_read_header64;

	mov CL, 1 ;重置扇区 
	add DH, 1 ; 读取下一个磁头

	cmp DH, 2; 柱面的磁头是否读完了
	jb loop_read_header64

	mov DH, 0 ;重置磁头
	add CH, 1 ;读取下一个柱面

	cmp CH, 1 ; 一共读取1个柱面
	jb loop_read_header64

	ret 
;header64读取结束---------------------------------------------
;-------------------------------------------------------------
switch2GraphMode:
  mov AL, 0x13 ;VGA显卡320x320真彩色
  mov AH, 0x00 
  int 10
	mov byte [VMODES], 8 
	mov word [SCRNX], 320
	mov word [SCRNY], 200
	mov DWORD [VRAM_GRAPH], 0x000a_0000

	mov AH, 0x02
	int 0x16
	mov [LEDS], AL

  ret 
;End of Switch2GraphMode----------------------------------------------------------
;--------------------------------------------------------------
printBootMsg:
  mov ax, boot_msg
  mov bp, ax 
  mov cx, 16
  mov ax, 01301H
  mov bx, 000cH
  mov dl, 0
  int 10H
  ret 

boot_msg:
  DB "Hello, MistOS!  "
;End of printBootMsg----------------------------------------------------------
;----------------------------------------------------------------------------------------------
; GDT
;----------------------------------------------------------------------------------------------
;                              段基址,       段界限     , 属性
GDT:	   Descriptor       0,                	 0, 						0           	 ; 空描述符
DESC_CODE32: Descriptor   0, 				BOOT32_LIMIT, 						DA_C + DA_32	 ; 内核代码段
DESC_DATA: Descriptor     0,     		BOOT32_LIMIT,   	 				DA_DRW + DA_32 ; 内核数据段
; GDT 结束

GDT_LEN		EQU	$ - GDT	; GDT长度
GDTR			DW	GDT_LEN - 1	; GDT界限
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