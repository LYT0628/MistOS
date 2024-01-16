#include "stdint.h"

void* memset(void* s, int8_t c, uint32_t n){
  char* tmp =s;
  while (n--)
  {
    *tmp ++ = c;
  }
  return s;
}