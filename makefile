# 用法:
# make FILE=xxx.coe
# 例如: make FILE=testac.coe
# 会生成:
#   build/xxx_small.coe  (小端序coe)
#   build/xxx.bin		(二进制bin)
#   xxx.asm			  (反汇编文件, 与原coe同目录)
# make clean 清理build目录和生成的asm文件

# 需要转换的coe文件路径, 例如 testac.coe
FILE ?= testac.coe

# 文件名和目录
BASENAME := $(basename $(notdir $(FILE)))
DIR := $(dir $(FILE))
BUILD_DIR := build

# 目标文件
SMALL_COE := $(BUILD_DIR)/$(BASENAME)_small.coe
BIN := $(BUILD_DIR)/$(BASENAME).bin
ASM := $(DIR)$(BASENAME).asm

.PHONY: all clean

all: $(ASM)

# 1. 转换为小端coe
$(SMALL_COE): $(FILE) | $(BUILD_DIR)
	python convert_small.py $< > $@

# 2. 转换为bin
$(BIN): $(SMALL_COE)
	# 使用xxd将小端coe转为二进制bin
	xxd -r -p $< $@

# 3. 反汇编
$(ASM): $(BIN)
	# 使用riscv64-unknown-elf-objdump反汇编bin文件
	riscv64-unknown-elf-objdump -D -b binary -m riscv:rv64 -M no-aliases $< > $@

# 创建build目录
$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
	[ -z "$(FILE)" ] || rm -