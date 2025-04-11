# Makefile

SRC_DIR = src
BUILD_DIR = build

SECTORS = 32
SIZE = $(shell echo $$(($(SECTORS)*512)))


BOOT_SRC = $(SRC_DIR)/bootloader.asm
LONG_SRC = $(SRC_DIR)/long_mode.asm
KERNEL_C_SRC = $(SRC_DIR)/kernel.c
KERNEL_ENTRY_SRC = $(SRC_DIR)/kernel_entry.asm

KERNEL_C_OBJ = $(BUILD_DIR)/kernel.o
KERNEL_ENTRY_OBJ = $(BUILD_DIR)/kernel_entry.o
# KERNEL_ELF = $(BUILD_DIR)/kernel.elf

BOOT_BIN = $(BUILD_DIR)/bootloader.bin
LONG_BIN = $(BUILD_DIR)/long_mode.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin

OS_IMAGE = $(BUILD_DIR)/os.img
LINKER_SRC = $(SRC_DIR)/linker.ld

KERNEL_SIZE = $(shell stat -c%s $(KERNEL_BIN))
KERNEL_SECTORS = $(shell echo $$(( ( $(KERNEL_SIZE) + 511 ) / 512 )))

ASM = nasm

CC = gcc
CFLAGS = -ffreestanding -mno-red-zone -m64 -c

LD = ld
LDFLAGS = -T $(LINKER_SRC) --oformat binary

QEMU = qemu-system-x86_64

# OC = objcopy
# OCFLAGS = -O binary

.PHONY: all clean run re setup

all: setup $(OS_IMAGE)

setup: $(BUILD_DIR)

$(BUILD_DIR):

$(BOOT_BIN): $(BOOT_SRC) $(KERNEL_BIN)
	mkdir -p $(BUILD_DIR)
	$(ASM) -f bin $< -o $@ -DKERNEL_SECTORS=$(KERNEL_SECTORS)

$(LONG_BIN): $(LONG_SRC)
	$(ASM) -f bin $< -o $@


# KERNEL BUILD
$(KERNEL_C_OBJ): $(KERNEL_C_SRC)
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $< -o $@

$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC)
	$(ASM) -f elf64 $< -o $@

$(KERNEL_BIN): $(KERNEL_C_OBJ) $(KERNEL_ENTRY_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^
# $(OC) $(OCFLAGS) $(KERNEL_ELF) $@

	
$(OS_IMAGE): $(BOOT_BIN) $(LONG_BIN) $(KERNEL_BIN)
	truncate -s $(SIZE) $@
	dd if=$(word 1, $^) of=$@ bs=512 count=1 conv=notrunc
	dd if=$(word 2, $^) of=$@ bs=512 seek=1 conv=notrunc
	dd if=$(word 3, $^) of=$@ bs=512 seek=3 conv=notrunc
	
run: $(OS_IMAGE)
	$(QEMU) -drive format=raw,file=$<

clean:
	rm -rf $(BUILD_DIR) $(OS_IMAGE)

re: clean run
