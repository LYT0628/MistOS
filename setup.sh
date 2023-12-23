
apt-get update  

apt install git \ # git is always needed
nasm \  # install nasm
build-essential  xorg-dev  \
libgtk2.0-dev vgabios bximage  # install dependencies for bochs

# install bochs
git clone https://github.com/LYT0628/bochs-2.4.5.git \
    && cd bochs-2.4.5 \
    && ./configure --enable-debugger --enable-disasm \
    && make && sudo make install 
rm -rf ./bochs-2.4.5