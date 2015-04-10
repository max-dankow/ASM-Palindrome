all:prog

prog:main.s
	gcc main.s -o prog

main.s:
