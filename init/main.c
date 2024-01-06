#include "io.h"
#include "vga13.h"

int main(){
  int i;

  for(i=0xA0000; i<=0xAFFFF; i++){
    write_mem8(i, 0);
  }
  drawSq(20, 40, 200, 60,9);

  for(;;){
    io_hlt();
  }
}