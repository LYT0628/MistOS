#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


int main(int argc, char const *argv[])
{
  int fd;
  int fd_kernel;
  int c;
  char buf[512];

  fd_kernel = open("kernel.bin", O_WRONLY | O_CREAT, 0664); // 0664: type, auth(1(exe)+2(write)+4(read)) 

// boot16
  fd = open("boot16.bin", O_RDONLY);
  while(1){
    c = read(fd, buf, 512);
    if(c > 0){
      write(fd_kernel, buf, c);
    }else {
      break;
    }
  }
  close(fd);

// time to load kernel code is in real mode. in kvmtool, we need 0x1000<<4 offset.
  lseek(fd_kernel, 0x20000 - 0x10000 , SEEK_SET);

// boot32
  fd = open("boot32.bin", O_RDONLY);
  while(1){
    c = read(fd, buf, 512);
    if(c > 0){
      write(fd_kernel, buf, c);
    }else {
      break;
    }
  }
  close(fd);  

  return 0;
}
