
apt-get update  

apt install git \ 
nasm \ 
build-essential  xorg-dev  \
libgtk2.0-dev vgabios bximage  


git clone https://github.com/LYT0628/bochs-2.4.5.git \
    && cd bochs-2.4.5 \
    && ./configure --enable-debugger --enable-disasm  \
    && make && sudo make install 