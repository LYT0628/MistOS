00007C00  E92100            jmp 0x7c24
00007C03  0000              add [bx+si],al
00007C05  0000              add [bx+si],al
00007C07  0000              add [bx+si],al
00007C09  0000              add [bx+si],al
00007C0B  0014              add [si],dl
00007C0D  0000              add [bx+si],al
00007C0F  0000              add [bx+si],al
00007C11  98                cbw
00007C12  40                inc ax
00007C13  00FF              add bh,bh
00007C15  FF00              inc word [bx+si]
00007C17  800B92            or byte [bp+di],0x92
00007C1A  0000              add [bx+si],al
00007C1C  17                pop ss
00007C1D  0000              add [bx+si],al
00007C1F  0000              add [bx+si],al
00007C21  0000              add [bx+si],al
00007C23  008CC88E          add [si-0x7138],cl
00007C27  D88EC08E          fmul dword [bp-0x7140]
00007C2B  D0BC0001          sar byte [si+0x100],1
00007C2F  6631C0            xor eax,eax
00007C32  8CC8              mov ax,cs
00007C34  66C1E004          shl eax,byte 0x4
00007C38  6605807C0000      add eax,0x7c80
00007C3E  A30E7C            mov [0x7c0e],ax
00007C41  66C1E810          shr eax,byte 0x10
00007C45  A2107C            mov [0x7c10],al
00007C48  8826137C          mov [0x7c13],ah
00007C4C  6631C0            xor eax,eax
00007C4F  8CD8              mov ax,ds
00007C51  66C1E004          shl eax,byte 0x4
00007C55  6605047C0000      add eax,0x7c04
00007C5B  66A31E7C          mov [0x7c1e],eax
00007C5F  0F01161C7C        lgdt [0x7c1c]
00007C64  FA                cli
00007C65  E492              in al,0x92
00007C67  0C02              or al,0x2
00007C69  E692              out 0x92,al
00007C6B  0F20C0            mov eax,cr0
00007C6E  6683C801          or eax,byte +0x1
00007C72  0F22C0            mov cr0,eax
00007C75  66EA000000000800  jmp dword 0x8:0x0
00007C7D  0000              add [bx+si],al
00007C7F  0066B8            add [bp-0x48],ah
00007C82  1000              adc [bx+si],al
00007C84  8EE8              mov gs,ax
00007C86  BF7E07            mov di,0x77e
00007C89  0000              add [bx+si],al
00007C8B  B40C              mov ah,0xc
00007C8D  B050              mov al,0x50
00007C8F  65668907          mov [gs:bx],eax
00007C93  EBFE              jmp short 0x7c93
