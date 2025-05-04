# Compilación del archivo main.asm en formato ELF de 32 bits
# Genera el archivo objeto main.o a partir del código ensamblador main.asm
#			nasm -f elf32 main.asm -o main.o
# Linkea el archivo objeto y crea el ejecutable 'main'
#			ld -m elf_i386 main.o -o main
all:
	nasm -f elf32 main.asm -o main.o
	ld -m elf_i386 main.o -o main

# Ejecución del programa después de compilarlo.
# Corre el ejecutable 'main' después de la compilación
#			./main
run: all
	./main

# Limpieza de los archivos generados (.o y ejecutable).
# Elimina archivos objeto (.o) y el ejecutable 'main' para limpiar el proyecto
#			rm -f *.o main
clean:
	rm -f *.o main
