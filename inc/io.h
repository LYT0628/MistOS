#ifndef __IO_H__
#define __IO_H__


void io_hlt();
void io_cli();
void io_sti();
void io_stihlt();
int io_in8(int port);
int io_in16(int port);
int io_in32(int port);
void io_out8(int port, int data);
void io_out16(int port, int data);
void io_out32(int port, int data);
void write_mem8(int addr, int data);
#endif

