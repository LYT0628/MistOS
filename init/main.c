#include "io.h"
#include "mistos.h"
#include "vga.h"
extern char cursor_normal[16][16];

int main(){
  int i;
  char *vram;
  int xsize, ysize;
  struct BootInfo *binfo;
  
  binfo = BOOT_INFO;
  xsize = binfo->scrnx;
  ysize = binfo->scrny;
  vram = binfo->vram;

  drawSq(vram, xsize,0, 0, xsize, ysize,8); // 屏幕背景
  //显示具有分割线的状态栏 
  drawSq(vram, xsize,0, ysize - 28, xsize, 28,7); // 状态栏层数1
  drawSq(vram, xsize,0, ysize - 27, xsize, 27, 15); // 状态栏层数2，用来显示分割线
  drawSq(vram, xsize,0, ysize - 26, xsize,ysize, 7); // 状态栏层数3

  // 左下角的小凸起
  drawSq(vram, xsize,3, ysize - 24, 56, 1, 15);
  drawSq(vram, xsize,2, ysize - 24, 1, 20, 15);
  drawSq(vram, xsize,3, ysize - 4, 56, 1, 7);
  drawSq(vram, xsize,59, ysize - 23, 1, 20, 8);
  drawSq(vram, xsize,2, ysize - 3, 57, 1, 0);
  drawSq(vram, xsize,60, ysize - 24, 1, 31, 0);
  
  // 右下角的小方框
  drawSq(vram, xsize,xsize - 47 , ysize - 24, 43, 1, 8);
  drawSq(vram, xsize,xsize - 47, ysize - 23, 1, 19, 8);
  drawSq(vram, xsize,xsize - 47, ysize - 3, 43, 1, 0);
  drawSq(vram, xsize,xsize - 3, ysize - 24, 1, 21, 0);


  drawStr_ascii(vram, xsize, 10, 10, "AHHA", 15);
  drawCursor(vram, xsize, 60, 60, cursor_normal);
  for(;;){
    io_hlt();
  }
}