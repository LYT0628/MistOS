#include "io.h"
#include "vga13.h"

int main(){
  int i;

  drawSq(0, 0, SCREEN_SIZE_X, SCREEN_SIZE_Y,8); // 屏幕背景
  //显示具有分割线的状态栏 
  drawSq(0, SCREEN_SIZE_Y - 28, SCREEN_SIZE_X, 28,7); // 状态栏层数1
  drawSq(0, SCREEN_SIZE_Y - 27, SCREEN_SIZE_X, 27, 15); // 状态栏层数2，用来显示分割线
  drawSq(0, SCREEN_SIZE_Y - 26, SCREEN_SIZE_X,SCREEN_SIZE_Y, 7); // 状态栏层数3

  // 左下角的小凸起
  drawSq(3, SCREEN_SIZE_Y - 24, 56, 1, 15);
  drawSq(2, SCREEN_SIZE_Y - 24, 1, 20, 15);
  drawSq(3, SCREEN_SIZE_Y - 4, 56, 1, 7);
  drawSq(59, SCREEN_SIZE_Y - 23, 1, 20, 8);
  drawSq(2, SCREEN_SIZE_Y - 3, 57, 1, 0);
  drawSq(60, SCREEN_SIZE_Y - 24, 1, 31, 0);
  
  // 右下角的小方框
  drawSq(SCREEN_SIZE_X - 47 , SCREEN_SIZE_Y - 24, 43, 1, 8);
  drawSq(SCREEN_SIZE_X - 47, SCREEN_SIZE_Y - 23, 1, 19, 8);
  drawSq(SCREEN_SIZE_X - 47, SCREEN_SIZE_Y - 3, 43, 1, 0);
  drawSq(SCREEN_SIZE_X - 3, SCREEN_SIZE_Y - 24, 1, 21, 0);

  for(;;){
    io_hlt();
  }
}