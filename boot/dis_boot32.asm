00010000  66B810008ED8      mov eax,0xd88e0010
00010006  8EC0              mov es,ax
00010008  0F0115            lgdt [di]
0001000B  F5                cmc
0001000C  0001              add [bx+di],al
0001000E  00E8              add al,ch
00010010  0200              add al,[bx+si]
00010012  0000              add [bx+si],al
00010014  EBFE              jmp short 0x14
00010016  66B810008EC0      mov eax,0xc08e0010
0001001C  BF0000            mov di,0x0
0001001F  0200              add al,[bx+si]
00010021  B80330            mov ax,0x3003
00010024  0300              add ax,[bx+si]
00010026  AB                stosw
00010027  050010            add ax,0x1000
0001002A  0000              add [bx+si],al
0001002C  B9FE01            mov cx,0x1fe
0001002F  0000              add [bx+si],al
00010031  31C0              xor ax,ax
00010033  AB                stosw
00010034  E2FD              loop 0x33
00010036  B80310            mov ax,0x1003
00010039  0200              add al,[bx+si]
0001003B  AB                stosw
0001003C  BF0010            mov di,0x1000
0001003F  0200              add al,[bx+si]
00010041  B9FE01            mov cx,0x1fe
00010044  0000              add [bx+si],al
00010046  31C0              xor ax,ax
00010048  AB                stosw
00010049  E2FD              loop 0x48
0001004B  B80320            mov ax,0x2003
0001004E  0200              add al,[bx+si]
00010050  AB                stosw
00010051  BF0020            mov di,0x2000
00010054  0200              add al,[bx+si]
00010056  B90002            mov cx,0x200
00010059  0000              add [bx+si],al
0001005B  B80330            mov ax,0x3003
0001005E  0200              add al,[bx+si]
00010060  AB                stosw
00010061  050010            add ax,0x1000
00010064  0000              add [bx+si],al
00010066  E2F8              loop 0x60
00010068  BF0030            mov di,0x3000
0001006B  0200              add al,[bx+si]
0001006D  B92000            mov cx,0x20
00010070  0000              add [bx+si],al
00010072  B80300            mov ax,0x3
00010075  0000              add [bx+si],al
00010077  AB                stosw
00010078  050010            add ax,0x1000
0001007B  0000              add [bx+si],al
0001007D  E2F8              loop 0x77
0001007F  EBFE              jmp short 0x7f
00010081  66B810008EC0      mov eax,0xc08e0010
00010087  BF0000            mov di,0x0
0001008A  0200              add al,[bx+si]
0001008C  B90004            mov cx,0x400
0001008F  0000              add [bx+si],al
00010091  31C0              xor ax,ax
00010093  B80701            mov ax,0x107
00010096  0200              add al,[bx+si]
00010098  AB                stosw
00010099  050010            add ax,0x1000
0001009C  0000              add [bx+si],al
0001009E  E2F8              loop 0x98
000100A0  66B810008EC0      mov eax,0xc08e0010
000100A6  BF0001            mov di,0x100
000100A9  0200              add al,[bx+si]
000100AB  B90000            mov cx,0x0
000100AE  1000              adc [bx+si],al
000100B0  31C0              xor ax,ax
000100B2  B80700            mov ax,0x7
000100B5  0000              add [bx+si],al
000100B7  AB                stosw
000100B8  050010            add ax,0x1000
000100BB  0000              add [bx+si],al
000100BD  E2F8              loop 0xb7
000100BF  B80000            mov ax,0x0
000100C2  0200              add al,[bx+si]
000100C4  0F22D8            mov cr3,eax
000100C7  0F20C0            mov eax,cr0
000100CA  0D0000            or ax,0x0
000100CD  00800F22          add [bx+si+0x220f],al
000100D1  C0EB00            shr bl,byte 0x0
000100D4  90                nop
000100D5  C3                ret
000100D6  B013              mov al,0x13
000100D8  B400              mov ah,0x0
000100DA  CD0A              int 0xa
000100DC  C3                ret
000100DD  0000              add [bx+si],al
000100DF  0000              add [bx+si],al
000100E1  0000              add [bx+si],al
000100E3  0000              add [bx+si],al
000100E5  0000              add [bx+si],al
000100E7  0000              add [bx+si],al
000100E9  009A2000          add [bp+si+0x20],bl
000100ED  FF                db 0xff
000100EE  FF00              inc word [bx+si]
000100F0  0000              add [bx+si],al
000100F2  92                xchg ax,dx
000100F3  0F0017            lldt [bx]
000100F6  00DD              add ch,bl
000100F8  0001              add [bx+di],al
000100FA  00                db 0x00
