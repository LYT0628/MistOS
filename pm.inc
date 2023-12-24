;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 段描述符，
; %0： 段基址
; $1:  段长
; $2: 各个属性
%macro DESCRIPTOR 3
	dw	%2 & 0FFFFh				; 段长1
	dw	%1 & 0FFFFh				; 段基址1
	db	(%1 >> 16) & 0FFh			; 段基址2
	dw	((%2 >> 8) & 0F00h) | (%3 & 0F0FFh)	; 属性1 + 段长2 + 属性2
	db	(%1 >> 24) & 0FFh			; 段基址3
%endmacro ; 共 8 字节



; 属性值1(低8位属性，从高位到低位)：
; P(1),DPI(2),S(1),TYPE(4)
; P: 存在位
; DPL： 特权级
; S： 描述符类型，1 表示代码段或数据段，0表示系统段
; TYPE: 段类型
;     对于代码段， 1_是否一致性代码_是否可读_是否访问过
;                1 表示代码段， 一致性代码即是否只能被特权级0的代码(内核)访问
;                是否访问由CPU控制，我们初始化为 0 即可 
;     对于数据段，0_是否向低地址拓展_是否可写_是否访问过
;                0 表示数据段
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 属性值2(高4位属性,从高位到低位)
; M(1),DB(1),L(1),SYS(1)
; M: 粒度，0 表示字节为单位， 1 表示 4KB 为单位
; DB：对于代码段，表示默认操作数的宽度，1表示32位，0表示16位
;     对于栈段, 0 表示使用寄存器SP作为栈指针， 1表示使用ESP作为栈指针
;     对于向下拓展的数据段，0表示段上限为 64KB， 1 表示段上限为4GB
; L: 长模式
; SYS: 是否系统软件专用


; 描述符类型
DA_32		EQU	4000h	;0100_0000B, BD = 1，表示 32 位段

; 特权级类型
DA_DPL0		EQU	  00h	; DPL = 0
DA_DPL1		EQU	  20h	; DPL = 1
DA_DPL2		EQU	  40h	; DPL = 2
DA_DPL3		EQU	  60h	; DPL = 3

; 存储段描述符类型
; 数据段
DA_DR		EQU	90h	; 存在的只读(R)数据段(D)类型值
DA_DRW		EQU	92h	; 存在的可读写(WR)数据段(D)属性值
DA_DRWA		EQU	93h	; 存在的已访问(A)可读写(RW)数据段(D)类型值
; 代码段
DA_C		EQU	98h	; is 1001_1000B. 存在的(P),只执行(不可读写)代码段(S=1 and TYPE=1000B),属性值
DA_CR		EQU	9Ah	; 存在的可执行可读(R)代码段(C)属性值
DA_CCO		EQU	9Ch	; 存在的只执行一致(C0,0表示特权级0)代码段(C)属性值
DA_CCOR		EQU	9Eh	; 存在的可执行可读(R)一致(C0)代码段(C)属性值

; 系统段描述符类型
DA_LDT		EQU	  82h	; 局部描述符表段类型值
DA_TaskGate	EQU	  85h	; 任务门类型值
DA_386TSS	EQU	  89h	; 可用 386 任务状态段类型值
DA_386CGate	EQU	  8Ch	; 386 调用门类型值
DA_386IGate	EQU	  8Eh	; 386 中断门类型值
DA_386TGate	EQU	  8Fh	; 386 陷阱门类型值


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 门
; usage: Gate Selector, Offset, DCount, Attr
;        Selector:  dw
;        Offset:    dd
;        DCount:    db
;        Attr:      db
%macro Gate 4
	dw	(%2 & 0FFFFh)				; 偏移1
	dw	%1					; 选择子
	dw	(%3 & 1Fh) | ((%4 << 8) & 0FF00h)	; 属性
	dw	((%2 >> 16) & 0FFFFh)			; 偏移2
%endmacro ; 共 8 字节



SA_RPL0		EQU	0	; ┓
SA_RPL1		EQU	1	; ┣ RPL
SA_RPL2		EQU	2	; ┃
SA_RPL3		EQU	3	; ┛

SA_TIG		EQU	0	; ┓TI
SA_TIL		EQU	4	; ┛

