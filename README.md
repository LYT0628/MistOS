# LiveOS

X86 OS

## Nasm Note

- `[]` , 表示间接寻址，即取出地址的值。
- ndisasm - o `<address> <bin_file> ： 反汇编`
- $ : 表示当前代码编译后的二进制代码地址
- `$$`: 表示一个section(Nasm 的特殊概念)
- `$-$$`:表示当前代码与程序开始处的相对距离
- times `<n> <expr>`：表示将语句重复 n 遍

## Bochs Note

- h : 打印帮助信息
- `b <adress> : 设置断点`
- info break : 显示所有断点
- c : continue ，运行到断点处
- s ： 单步执行， 不进入函数体
- n ： 下一步指令， 进入函数体
- r : 打印寄存器信息
- page `<address> : 打印地址所在的线性地址和物理地址的映射`
- trace-reg <on/off>: 每次执行都打印寄存器信息
- trace-mem `<on.off> : 每次执行都打印内存信息`
- x : 执行一步指令，显示内存
- print-stack : 查看堆栈信息
- xp `</nuf>` `<addr>`  :  查看物理地址内容。nuf  n 表示数字(十进制，表示查看的大小)， u表示 输出的显示进制（x,d,u,o,t,c,s,i 分别表示 hex, decimal, unsigned, octal, binary, char, asciiz, instr）， f  表示单位（b,h,w,g ， 表示byte, half-word（即字节）, word and giant word）
- x `</nuf>` `<addr>`  : 查看线性地址的内容， 格式同上
- u `<start_addr>` <end_addr> : 反汇编一段内存
- `trace on ` : 反汇编执行的每一条指令

## Qemu Note
