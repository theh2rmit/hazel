SRC_DIR = src
BUILD_DIR = build

SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

PROGRAM = $(BUILD_DIR)/kernel8.img

TOOLCHAIN = aarch64-linux-gnu-
AS = $(TOOLCHAIN)as
GCC = $(TOOLCHAIN)gcc
OBJCOPY = $(TOOLCHAIN)objcopy

CFLAGS = -ffreestanding -O2 -Wall -Wextra

all: clean $(PROGRAM)

$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot.s
	$(AS) -c $^ -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(GCC) $(CFLAGS) -c $^ -o $@

$(PROGRAM): $(BUILD_DIR)/boot.o $(OBJS)
	$(GCC) $(CFLAGS) -nostdlib -lgcc $^ -T linker.ld -o $(BUILD_DIR)/kernel8.elf
	$(OBJCOPY) -O binary $(BUILD_DIR)/kernel8.elf $@

run: $(PROGRAM)
	qemu-system-aarch64 -M raspi3b -serial stdio -kernel $^

clean:
	rm -rf $(BUILD_DIR)/*
