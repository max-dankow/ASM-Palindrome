.text
    .globl _start
_start:

  #завершение программы
    mov $1, %eax
    mov $0, %ebx
    int $0x80
