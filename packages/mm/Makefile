ROOT_DIR:=..
BOOT_DIR:=$(ROOT_DIR)/boot

INCLUDE_DIR:=$(ROOT_DIR)/inc
SRCS:=$(wildcard *.c)
OBJS:=$(subst .c,.o,$(SRC))

CFLAGS=-std=c11 -I$(INCLUDE_DIR) \
				-fno-pic -mcmodel=kernel \
				-fno-stack-protector -fcf-protection=none \
				-nostdinc -fno-builtin
LDFLAGS=-s
