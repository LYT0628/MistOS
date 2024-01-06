#include "vga13.h"


void drawSq(int x, int y, int width, int height, unsigned char color){
  char *vram = VRAM13;
  int x0 = x, y0 = y;
  int x1 = x + width, y1 = y + height;

  for(int i = y0; i< y1; i++){ // col
    for(int j= x0; j< x1; j++){
      vram[i*SCREEN_SIZE_X + j] = color;
    }
  }

}

// void palette_init(){
//   static unsigned char table_rgb[16 * 3] = {
//     0x00, 0x00, 0x00, //0. 黑 
//     0xFF, 0x00, 0x00, //1. 亮红
//     0x00, 0xFF, 0x00, //2. 亮绿
//     0xFF, 0xFF, 0x00, //3. 亮黄
//     0x00, 0x00, 0xFF, //4. 亮蓝
//     0xFF, 0x00, 0xFF, //5. 亮紫
//     0x00, 0xFF, 0xFF, //6. 浅亮蓝
//     0xFF, 0xFF, 0xFF, //7. 白
//     0xC6, 0xC6, 0xC6, //8. 亮灰
//     0x84, 0x00, 0x00, //9. 暗红
//     0x00, 0x84, 0x00, //10. 暗绿
//     0x84, 0x84, 0x00, //11. 暗黄
//     0x00, 0x00, 0x84, //12. 暗青
//     0x84, 0x00, 0x84, //13. 暗紫
//     0x00, 0x84, 0x84, //14. 浅暗蓝
//     0x84, 0x84, 0x84  //15. 暗灰
//   };
//   set_palette(0,15, table_rgb);
// }

// void set_palette(int start, int end, unsigned char* rgb){
//   int i;

//   io_cli();
//   io_out8(0x03C8, start);
//   for(i = start; i<= end; i++){
//     io_out8(0x03C9,rgb[0]/4);
//     io_out8(0x03C9,rgb[1]/4);
//     io_out8(0x03C9,rgb[2]/4);
//     rgb +=3;
//   }
//   io_sti();
// }