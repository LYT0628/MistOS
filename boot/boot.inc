; 
BOOT32_LBA  						      EQU 0x2 ; BOOT32 起始的逻辑扇区地址
BOOT32_LIMIT_N_SECTOR         EQU 0x2 ; BOOT32 所占磁盘个数(几个512字节)
BOOT32_LOGIC_ADDR   		      EQU 0x01000 ; BOOT32 加载的内存中的逻辑地址
BOOT32_PHYSICAL_ADDR   	      EQU 0x10000  ; BOOT32 加载到内存中的物理地址


HEADER64_LBA  						    EQU 0x4 ; BOOT32 起始的逻辑扇区地址
HEADER64_LIMIT_N_SECTOR       EQU 0x2 ; BOOT32 所占磁盘个数(几个512字节)
HEADER64_LOGIC_ADDR           EQU 0x02000 ; header64 初始加载到内存中的逻辑地址
HEADER64_PHYSICAL_ADDR        EQU 0x20000 ; header64 初始加载到内存中的物理地址


BOOT32_LIMIT 						EQU 0xFFFFF 




; 内存映像
Video_PHYSICAL_ADDR              EQU 0x8B00
