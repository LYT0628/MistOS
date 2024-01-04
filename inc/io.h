#define io_hlt \
do {\
  __asm__("hlt\n\t" \
          "rep"); \
}while(0)