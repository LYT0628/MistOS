cmake_minimum_required(VERSION 3.22.1)


set(CMAKE_VERBOSE_MAKEFILE ON)


# set(CMAKE_CXX_STANDARD 11)
# set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_C_COMPILER "/usr/bin/gcc")  # 使用GCC编译器，保证平台独立性，在CC编译器下： code model kernel does not support PIC mode
set(CMAKE_C_FLAGS "-std=c11 \
				-fno-pic -mcmodel=kernel \
				-fno-stack-protector -fcf-protection=none \
				-nostdinc -fno-builtin")

enable_language(ASM_NASM) # 使能nasm编译
set(CMAKE_ASM_NASM_COMPILER "nasm") # nasm的指向，绝对路径或者环境变量
set(CMAKE_ASM_NASM_SOURCE_FILE_EXTENSIONS "asm") # 指定nasm文件拓展名
set(CMAKE_ASM_NASM_FLAGS "-f elf64") # 产生调试信息, 兼容x86_64
set(CMAKE_EXE_LINKER_FLAGS "-Ttext=0x50000")

project(MistOS  VERSION 0.0.1 LANGUAGES C)
add_executable(MistOS.elf init/main.c)


configure_file(MistOSConfig.h.in MistOSConfig.h)

target_include_directories(MistOS.elf PUBLIC
                           "${PROJECT_SOURCE_DIR}" 
                           "${PROJECT_SOURCE_DIR}/MLibC"
                           "${PROJECT_SOURCE_DIR}/MLibDraw"
                           )

add_subdirectory(MLibC)
target_link_libraries(MistOS.elf PUBLIC MLibC)
add_subdirectory(MLibDraw)
target_link_libraries(MistOS.elf PUBLIC MLibDraw)