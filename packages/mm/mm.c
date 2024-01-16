#include <stdint.h>
#include "mm.h"
#include "../lib/string.h"

uint8_t pages[MAX_PAGES];
 
void mm_init(){
  memset(pages, 0, MAX_PAGES);

  for (int i = 0; i < KERNEL_PAGE_NUM; i++)
  {
    pages[i] = 1;
  }
}