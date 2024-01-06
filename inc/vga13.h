#ifndef __VGA13__
#define __VGA13__
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
void drawSq(int x, int y, int width, int height, unsigned char color);

#define SCREEN_SIZE_X  320
#define SCREEN_SIZE_Y  200
#define VRAM13 (char *)0xA0000

#endif