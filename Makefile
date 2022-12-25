NASM=nasm
LINKER=ld
STRIP=strip
RM=rm

X86_64_FLAGS=-f elf64

ham.x86_64: ham.x86_64.o
	$(LINKER) -o $@ $^
	$(STRIP) $@

ham.x86_64.o: x86_64/ham.asm
	$(NASM) $(X86_64_FLAGS) -o $@ $^

.PHONY: clean
clean:
	$(RM) -f *.o ham.x86_64
