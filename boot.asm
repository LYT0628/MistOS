%include	"pm.inc"	; 常量, 宏, 



	org	0100h
	jmp	LB_BOOT16

;
;
;
;
;
[SECTION .gdt]
; GDT
	;                                 段基址,              段界限 ,         属性
	LB_GDT:         Descriptor        0,              0,                  0         ; 空描述符
	LB_DESC_NORMAL: Descriptor        0,              0FFFFh,             DA_DRW    ; Normal 描述符
	LB_DESC_BOOT32: Descriptor        0,              SEG_BOOT32_LEN-1,   DA_C+DA_32; 非一致代码段, 32
	LB_DESC_RET_CODE16: Descriptor    0,              0FFFFh,             DA_C      ; 非一致代码段, 16
	LB_DESC_DATA:   Descriptor        0,              SEG_DATA_LEN-1,     DA_DRW    ; Data
	LB_DESC_STACK:  Descriptor        0,              TopOfStack,         DA_DRWA+DA_32; Stack, 32 位
	LB_DESC_TEST:   Descriptor        0500000h,       0ffffh,             DA_DRW
	LB_DESC_LDT:    Descriptor        0,              LDT_LEN - 1,        DA_LDT ; local desriptor table
LB_DESC_VIDEO:  Descriptor          0B8000h,        0ffffh,             DA_DRW    ; 显存首地址
; GDT 结束

GDT_LEN		equ	$ - LB_GDT	; GDT长度
GDT_PTR		dw	GDT_LEN - 1	; GDT界限
	      	dd	0		; GDT基地址

; GDT 选择子
	SELECTOR_NORMAL		equ	LB_DESC_NORMAL	- LB_GDT
	SELECTOR_BOOT32		equ	LB_DESC_BOOT32	- LB_GDT
	SELECTOR_RET_CODE16		equ	LB_DESC_RET_CODE16	- LB_GDT
	SELECTOR_DATA		equ	LB_DESC_DATA		- LB_GDT
	SELECTOR_STACK		equ	LB_DESC_STACK	- LB_GDT
	SELECtoR_TEST		equ	LB_DESC_TEST		- LB_GDT
	SELECTOR_LDT   equ LB_DESC_LDT      - LB_GDT
	SELECTOR_VIDEO		equ	LB_DESC_VIDEO	- LB_GDT
; END of [SECTION .gdt]

[SECTION .data1]	 ; 数据段
ALIGN	32
[BITS	32]
LB_DATA:
		;在数据段声明数据，分配内存，很合理吧
		SPValueInRealMode	dw	0
		; 字符串
		PMMessage:		db	"In Protect Mode now. ^-^", 0	; 在保护模式中显示
		OffsetPMMessage		equ	PMMessage - $$
		StrTest:		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
		OffsetStrTest		equ	StrTest - $$
		SEG_DATA_LEN			equ	$ - LB_DATA
; END of [SECTION .data1]


; 全局栈段
[SECTION .gs]
ALIGN	32
[BITS	32]
LB_STACK:
	times 512 db 0

TopOfStack	equ	$ - LB_STACK - 1

; END of [SECTION .gs]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; boot16段， 用于从16位实模式进入32位u保护模式
;
[SECTION .boot16]
[BITS	16]
LB_BOOT16:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

  ; 修改 cs, sp , 供返回实模式使用
	;通过hack 的方式， 直接修改 长跳转指令的 segment 域，OEAH（0） offset（1-2），seg（3-4）
	mov	[LB_GO_BACK_TO_REAL+3], ax
	mov	[SPValueInRealMode], sp

	; 初始化 16 位代码段描述符, 这边加载的其实是返回的 16 位段 LB_SEG_CODE16，不是 BOOT16
	mov	ax, cs
	movzx	eax, ax
	shl	eax, 4
	add	eax, LB_SEG_CODE16
	mov	word [LB_DESC_RET_CODE16 + 2], ax
	shr	eax, 16
	mov	byte [LB_DESC_RET_CODE16 + 4], al
	mov	byte [LB_DESC_RET_CODE16 + 7], ah

	; 初始化 32 位代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LB_SEG_CODE32
	mov	word [LB_DESC_BOOT32 + 2], ax
	shr	eax, 16
	mov	byte [LB_DESC_BOOT32 + 4], al
	mov	byte [LB_DESC_BOOT32 + 7], ah

	; 初始化数据段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LB_DATA
	mov	word [LB_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LB_DESC_DATA + 4], al
	mov	byte [LB_DESC_DATA + 7], ah

	; 初始化LDT 在 GDT 的段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LB_LDT ; 局部短描述表也是在GDT的一个段
	mov	word [LB_DESC_LDT + 2], ax
	shr	eax, 16
	mov	byte [LB_DESC_LDT + 4], al
	mov	byte [LB_DESC_LDT + 7], ah

	; 初始化LDT段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LB_CODEA ; 增加一个局部段
	mov	word [LB_LDT_DESC_CODEA + 2], ax
	shr	eax, 16
	mov	byte [LB_LDT_DESC_CODEA + 4], al
	mov	byte [LB_LDT_DESC_CODEA + 7], ah

	; 初始化堆栈段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LB_STACK
	mov	word [LB_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LB_DESC_STACK + 4], al
	mov	byte [LB_DESC_STACK + 7], ah

	; 为加载 GDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LB_GDT		; eax <- gdt 基地址
	mov	dword [GDT_PTR + 2], eax	; [GDT_PTR + 2] <- gdt 基地址


	; 加载 GDTR
	lgdt	[GDT_PTR]

	; 关中断
	cli

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SELECTOR_BOOT32:0	; 执行这一句会把 SELECTOR_BOOT32 装入 cs, 并跳转到 Code32Selector:0  处

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 因为运行在实模式， 所以也要放到SEG_BOOT16 下面
LB_REAL_ENTRY:		; 从保护模式跳回到实模式就到了这里
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	sp, [SPValueInRealMode]

	in	al, 92h		; `.
	and	al, 11111101b	;  | 关闭 A20 地址线
	out	92h, al		; /

	sti			; 开中断

	mov	ax, 4c00h	; `. 4c00h 是DOS的地址
	int	21h		; /   0x21 号中断, 当ax 位4c00h时，退出程序，回到 DOS。
; END of [SECTION .s16]


[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS	32]

LB_SEG_CODE32:
		mov	ax, SELECTOR_DATA
		mov	ds, ax			; 数据段选择子
		mov	ax, SELECtoR_TEST
		mov	es, ax			; 测试段选择子
		mov	ax, SELECTOR_VIDEO
		mov	gs, ax			; 视频段选择子

		mov	ax, SELECTOR_STACK
		mov	ss, ax			; 堆栈段选择子

		; 加载局部段描述符表在GDT的选择子, 加载到 ldtr
		mov ax, SELECTOR_LDT
		lldt ax 

		jmp SELECTOR_LDT_CODEA:0

		mov	esp, TopOfStack


		; 下面显示一个字符串
		mov	ah, 0Ch			; 0000: 黑底    1100: 红字
		xor	esi, esi
		xor	edi, edi
		mov	esi, OffsetPMMessage	; 源数据偏移
		mov	edi, (80 * 10 + 0) * 2	; 目的数据偏移。屏幕第 10 行, 第 0 列。
		cld ; clear direction ，清除 DF位， 使 lodsb 指令下， esi 向高位增长
	.1: ; 读取数据，放到显存中
		lodsb ; 从esi指向的内存中读取一个字节，放到 al。
		test	al, al ; 由 al&al 的值设置ZF，
		jz	.2 ; ZF 为0 时, 跳转 .2 ，  即没有读到值，就跳转到 .2。
		mov	[gs:edi], ax ; 把 ax(al) 读到的值放到显存中， edi是显存中的偏移
		add	edi, 2 ; 改变字符在屏幕显示的位置
		jmp	.1
	.2:	; 显示完毕， 回归实模式
		call	DispReturn
		call	TestRead
		call	TestWrite
		call	TestRead

		; 到此停止
		jmp	SELECTOR_RET_CODE16:0

; ------------------------------------------------------------------------
TestRead:
		xor	esi, esi
		mov	ecx, 8
	.loop:
		mov	al, [es:esi] ; es储存测试段， 读取测试段的 8 个字符， 显示出来
		call	DispAL
		inc	esi
		loop	.loop ; 每次循环都将 cx 的值减一， 如果 cx 为0 ，则跳出循环，也就是执行 cx 的值 次循环

		call	DispReturn

		ret
; TestRead 结束-----------------------------------------------------------


; ------------------------------------------------------------------------
TestWrite:
		push	esi
		push	edi
		xor	esi, esi
		xor	edi, edi
		mov	esi, OffsetStrTest	; 源数据偏移
		cld
	.1:
		lodsb
		test	al, al
		jz	.2
		mov	[es:edi], al
		inc	edi
		jmp	.1
	.2:

		pop	edi
		pop	esi

		ret
; TestWrite 结束----------------------------------------------------------


; ------------------------------------------------------------------------
; 显示 AL 中的数字（十六进制）
; 默认地:
;	数字已经存在 AL 中
;	edi 始终指向要显示的下一个字符的位置
; 被改变的寄存器:
;	ax, edi
; ------------------------------------------------------------------------
DispAL:
		push	ecx
		push	edx

		mov	ah, 0Ch			; 0000: 黑底    1100: 红字
		mov	dl, al
		shr	al, 4
		mov	ecx, 2 ; 循环2次
	.begin:
		and	al, 01111b
		cmp	al, 9 ;十六进制中 大于等于A的部分
		ja	.1
		add	al, '0' ; 十六进制中小于A的部分
		jmp	.2
	.1:
		sub	al, 0Ah ; A -> 0 + 'A'
		add	al, 'A'
	.2:
		mov	[gs:edi], ax ; 到这就可以直接写到显存中了。
		add	edi, 2

		mov	al, dl
		loop	.begin
		add	edi, 2

		pop	edx
		pop	ecx

		ret
; DispAL 结束-------------------------------------------------------------


; ------------------------------------------------------------------------
DispReturn:
	push	eax
	push	ebx
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	ebx
	pop	eax

	ret
; DispReturn 结束---------------------------------------------------------

SEG_BOOT32_LEN	equ	$ - LB_SEG_CODE32
; END of [SECTION .s32]


; 16 位代码段. 由 32 位代码段跳入, 跳出后到实模式
[SECTION .s16code]
ALIGN	32
[BITS	16]
LB_SEG_CODE16:
	; 跳回实模式:
	mov	ax, SELECTOR_NORMAL
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	mov	eax, cr0
	and	al, 11111110b
	mov	cr0, eax

LB_GO_BACK_TO_REAL:
	jmp	0:LB_REAL_ENTRY	; 段地址会在程序开始处被设置成正确的值

Code16Len	equ	$ - LB_SEG_CODE16

; END of [SECTION .s16code]

; LDT 
[SECTION .ldt]
ALIGN 32
LB_LDT:
	LB_LDT_DESC_CODEA: Descriptor 0, CODEA_LEN -1, DA_C + DA_32 ; 局部任务 A
LDT_LEN equ $ - LB_LDT

; 局部段表选择子
SELECTOR_LDT_CODEA equ LB_LDT_DESC_CODEA - LB_LDT + SA_TIL

; 局部任务A段
[SECTION .la]
ALIGN 32
[BITS 32]
LB_CODEA:
	mov ax, SELECTOR_VIDEO
	mov gs, ax 

	mov edi, (80 * 12) * 2 
	mov ah, 0Ch 
	mov al, 'L'
	mov [gs:edi], ax 

	jmp SELECTOR_RET_CODE16:0
CODEA_LEN equ $ - LB_CODEA
; End of [SECTION .la]

