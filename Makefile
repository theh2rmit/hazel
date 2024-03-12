SRC_DIR = src
BUILD_DIR = build

SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

PROGRAM = $(BUILD_DIR)/kernel8.img

LLVM = /opt/homebrew/opt/llvm/bin
CFLAGS = --target=aarch64-elf -ffreestanding -O2 -Wall -Wextra

all: clean $(PROGRAM)

$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot.s
	$(LLVM)/clang $(CFLAGS) -c $^ -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(LLVM)/clang $(CFLAGS) -c $^ -o $@

$(PROGRAM): $(BUILD_DIR)/boot.o $(OBJS)
	$(LLVM)/ld.lld -m aarch64elf -nostdlib $^ -T linker.ld -o $(BUILD_DIR)/kernel8.elf
	$(LLVM)/llvm-objcopy -O binary $(BUILD_DIR)/kernel8.elf $@

run: $(PROGRAM)
	qemu-system-aarch64 -M raspi3b -serial stdio -kernel $^

clean:
	rm -rf $(BUILD_DIR)/*
