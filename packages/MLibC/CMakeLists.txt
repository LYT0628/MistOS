

set(ASM_NASM_SOURCE_FILE_IO "io.asm")
set(ASM_NASM_OBJ_FILE_IO "io.o")

add_custom_command(
  OUTPUT ${ASM_NASM_OBJ_FILE_IO}
  COMMAND nasm -f elf64 -o ${ASM_NASM_OBJ_FILE_IO} ${ASM_NASM_SOURCE_FILE_IO}
  DEPENDS ${ASM_NASM_SOURCE_FILE_IO}
  COMMENT "编译nasm文件，生成汇编OBJ"
)

add_library(MLibC OBJECT string.c  ${ASM_NASM_OBJ_FILE_IO})
# add_library(MLibC string.c  ${ASM_NASM_OBJ_FILE_IO})