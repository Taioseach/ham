NASM=nasm
LINKER=ld
STRIP=strip

X86_64_FLAGS=-f elf64

ham: ham.o
	$(LINKER) -o $@ $^
	$(STRIP) $@

ham.o: x86_64.asm
	$(NASM) $(X86_64_FLAGS) -o $@ $^

