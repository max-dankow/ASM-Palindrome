all:prog

prog:main.o
	ld -dynamic-linker /lib/ld-linux.so.2 -o prog main.o -lc

main.o:main.s
	as -g main.s -o main.o

main.s:
