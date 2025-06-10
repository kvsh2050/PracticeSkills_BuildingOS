ASM=nasm

BOOT_DIR=src/bootloader
KERNEL_DIR=src/kernel
BUILD_DIR=build

.PHONY: all clean

#FLOPPY DISK IMAGE - sectors = 2880
floppy_img: $(BUILD_DIR)/main_floppy.img
$(BUILD_DIR)/main_floppy.img: bootloader kernel always
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880  
	mkfs.fat -F 12 -n "KOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

	

#BOOTLOADER
bootloader: $(BUILD_DIR)/boot.bin
$(BUILD_DIR)/boot.bin: $(BOOT_DIR)/boot.asm always
	$(ASM) $(BOOT_DIR)/boot.asm -f bin -o $(BUILD_DIR)/boot.bin


#KERNEL
kernel: $(BUILD_DIR)/kernel.bin always
$(BUILD_DIR)/kernel.bin: $(KERNEL_DIR)/main.asm
	$(ASM) $(KERNEL_DIR)/main.asm -f bin -o $(BUILD_DIR)/kernel.bin




always:
	mkdir -p $(BUILD_DIR)


#CLEAN
clean:
	rm -rf $(BUILD_DIR)/main.bin
	rm -rf $(BUILD_DIR)/main_floppy.img



#$(BUILD_DIR)/main_floppy.img: bootloader kernel always
#	cp $(BUILD_DIR)/boot.bin $(BUILD_DIR)/main_floppy.img
#	truncate -s 1440k $(BUILD_DIR)/main_floppy.img
#
# This one is for just loading the bootloader and making just bootloader into a floppy disk image
# For real floppy disk this is different
#