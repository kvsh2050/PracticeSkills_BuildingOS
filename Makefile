ASM=nasm

BOOT_DIR=src/bootloader
KERNEL_DIR=src/kernel
BUILD_DIR=build

.PHONY: all clean

#BOOTLOADER
bootloader: $(BUILD_DIR)/main_floppy.img
$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/boot.bin
	cp $(BUILD_DIR)/boot.bin $(BUILD_DIR)/main_floppy.img
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img
	
$(BUILD_DIR)/boot.bin: $(BOOT_DIR)/boot.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(BOOT_DIR)/boot.asm -f bin -o $(BUILD_DIR)/boot.bin


#KERNEL



#CLEAN
clean:
	rm -rf $(BUILD_DIR)/main.bin
	rm -rf $(BUILD_DIR)/main_floppy.img
