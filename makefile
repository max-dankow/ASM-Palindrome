all:prog

prog:main.o
	ld main.o -o prog

main.o:main.s
	as main.s -o main.o

main.s:
