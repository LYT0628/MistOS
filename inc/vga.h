#ifndef __VGA__
#define __VGA__
/**
 * @brief 
 * @param x 
 * @param y 
 * @param width 
 * @param height 
 * @param color
 * 0-黑 1-深蓝 2-苹果绿 3-松石绿
 * 4-橙红色 5-紫色 6-矿橙 7-浅冷灰
 * 8-鸽子灰 9-中蓝 10-草绿 
 * 11-蓝绿色 12-棕橙 13-洋紫
 * 14-柠檬黄 15-白 
 */
void drawSq(char *vram,int xsize, int x, int y, int width, int height, unsigned char color);
void drawAscii(char *vram,int xsize , int x, int y, char c, unsigned char color);
void drawStr_ascii(char *vram,int xsize , int x, int y, unsigned char *s, unsigned char color);
void drawCursor(char *vram, int xsize, int x, int y, char cursor_style[16][16]);
struct  BootInfo
{
  char cyls, leds, vmode, reserve;
  short scrnx, scrny;
  char *vram;
};


// char FONT_A[16]={
//   0x00, 0x18, 0x18, 0x18, 0x18, 0x24, 0x24, 0x24,
//   0x24, 0x7E, 0x42, 0x42, 0x42, 0xE7, 0x00, 0x00, // A 
// };
// char FONT_H[16]={
  // 0x00, 0x00, 0xC6, 0xC6, 0xC6, 0xC6, 0xFE, 0xC6,
  // 0xC6, 0xC6, 0xC6, 0xC6, 0x00, 0x00, 0x00, 0x00 // H
// };
#endif // __VGA__




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