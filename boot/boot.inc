;--------------------------------------------------------------------------------------------------------
; load 部分代码将由 BIOS 读入到 7C00h 的位置。然后,它会将 boot16 加载到 70000h 的位置，距离拓展BIOS数据区有 
; 10000h(64KB) 的空间。然后，boot16 将加载 boot32 到 10000h 的位置，将 header64 加载到20000h的位置，boot32
; 留有 64KB 的空间，从 20000h 到 80000h 的 64KB * 5 大小的空间都属于 header64。boot16 和 boot32 在运行之后就没用了，
; boot16 的空间将属于header64，用来作为内核堆栈。 启动时，实模式向 BIOS 查询的信息将保存到 8200h 往后的位置。
; 
;--------------------------------------------------------------------------------------
; Boot16
BOOT16_LBA                   EQU 0x2 ; BOOT16 起始的逻辑扇区地址
BOOT16_LIMIT_N_SECTOR        EQU 0x2 ; BOOT16 占据的扇区个数
BOOT16_END_C                 EQU 0x0 
BOOT16_END_H                 EQU 0x1 
BOOT16_END_S                 EQU 0x18
BOOT16_LOGIC_ADDR            EQU 0x07000 ; BOOT16 加载到内存中的逻辑地址
BOOT16_PHYSICAL_ADDR         EQU 0x70000 ; BOOT16 加载到内存中的物理地址

; Boot32 
BOOT32_LBA  						      EQU 0x2 ; BOOT32 起始的逻辑扇区地址
BOOT32_LIMIT_N_SECTOR         EQU 0x2 ; BOOT32 所占磁盘个数(几个512字节)
BOOT32_LOGIC_ADDR   		      EQU 0x01000 ; BOOT32 加载的内存中的逻辑地址
BOOT32_PHYSICAL_ADDR   	      EQU 0x10000  ; BOOT32 加载到内存中的物理地址

; Header64
HEADER64_LBA  						    EQU 0x4 ; BOOT32 起始的逻辑扇区地址
HEADER64_LIMIT_N_SECTOR       EQU 0x2 ; BOOT32 所占磁盘个数(几个512字节)
HEADER64_LOGIC_ADDR           EQU 0x05000 ; header64 初始加载到内存中的逻辑地址
HEADER64_PHYSICAL_ADDR        EQU 0x50000 ; header64 初始加载到内存中的物理地址



; BOOT_INFO
CYLS                   EQU 0x8200 ; 设置启动区 
LEDS                   EQU 0x8201 
VMODES                 EQU 0x8202 ; 关于颜色数目的信息
SCRNX                  EQU 0x8204 ; 分辨率的x 
SCRNY                  EQU 0x8206 ; 分辨率的y
VRAM_GRAPH             EQU 0x8208 ; 图形模式下显存的起始地址

; 内存映像
Video_PHYSICAL_ADDR              EQU 8B00h
VIDEO_PHYSICAL_ADDR              EQU 8B00h
