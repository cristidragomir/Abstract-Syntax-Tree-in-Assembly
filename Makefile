CC=gcc
CFLAGS=-m32 -g
ASM=nasm
ASMFLAGS=-f elf32



build: ast.o ast_utils.o
	$(CC) $(CFLAGS) -o ast $^
ast.o: ast.asm
	$(ASM) $(ASMFLAGS) $< -o $@
run:
	./ast
clean: 
	rm ast ast.o
