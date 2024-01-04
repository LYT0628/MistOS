// #include "io.h"

int main(){
  __asm__("hlt\n\t"
          "rep");

// 还不明白怎么解决汇编地址重定位的问题，所以做不到调用汇编函数, 直接用内联汇编也不行
// fin:
//   io_hlt();
//   goto fin;
}