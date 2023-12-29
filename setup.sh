
apt-get update  

# install dependencies for bochs
apt install git \ 
nasm \ 
build-essential  xorg-dev  \
libgtk2.0-dev vgabios bximage  

# install bochs
git clone https://github.com/LYT0628/bochs-2.4.5.git \
    && cd bochs-2.4.5 \
    && ./configure --enable-debugger --enable-disasm  \
    && make && sudo make install 

# install vhd write
git clone https://github.com/LYT0628/vhdw.git \
    && cd vhdw
    && sudo apt-get install python
    && pip install -r requirement.txt
    && make && sudo make install  
    
rm -rf ./bochs-2.4.5