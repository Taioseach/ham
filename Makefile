BUILD_DIR=build

NASM=nasm
LINKER=ld
STRIP=strip

X86_64_FLAGS=-f elf64

$(BUILD_DIR)/x86_64/ham: $(BUILD_DIR)/x86_64/ham.o
	$(LINKER) -o $@ $^
	$(STRIP) $@

$(BUILD_DIR)/x86_64/ham.o: x86_64/ham.asm
	mkdir -p $(BUILD_DIR)/x86_64
	$(NASM) $(X86_64_FLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -rf build
