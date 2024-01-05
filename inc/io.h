#ifndef __IO_H__
#define __IO_H__


void io_hlt();
// #define io_hlt() \
// do {\
//   __asm__("hlt\n\t" \
//           "rep"); \
// }while(0)



#define write_mem8(addr, data) \
do{ \
__asm__("mov %0, %%ECX\n\t" \
        "mov %1, %%AL \n\t" \
        "mov %%AL, (%%EAX)\n\t" \
        "rep"\
        :\
        :"m"(addr),"m"(data)\
        :"ecx","eax"\
        ); \
}while(0) 

#endif

