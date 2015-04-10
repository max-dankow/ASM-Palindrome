.data
test_str:
    .string "aba!aba"
test_len:
    .long . - test_str - 2
msg:
    .asciz "Hello, world!\n"
    
format:
    .string "Num = %ld\n"
    
number:
    .long 10
    
left:
    .long 0
    
right:
    .long 0
    
.text
    .global main # entry point
    
/******************************************************************
    Выводит строку %eax в stdout
******************************************************************/
format_str:
    .string "%s\n"
print_str:
    pushl %eax
    pushl $format_str
    call printf

    popl %eax
    popl %eax
    ret
#END OF print_num 



/******************************************************************
    Выводит число %eax в stdout
******************************************************************/
format_str_num:
    .string "%d\n"
print_num:
    pushl %eax
    pushl $format_str_num
    call printf

    popl %eax
    popl %eax
    ret
#END OF print_num   


/******************************************************************
    Выводит символ %al в stdout
******************************************************************/
format_str_char:
    .string "%c\n"
print_char:
    pushw %ax
    pushl $format_str_char
    call printf

    popl %eax
    popw %ax
    ret
#END OF print_num  


/******************************************************************
    Проверяет строку, адрес которой записан в %eax, на палиндром.
******************************************************************/
is_palindrome:
    pushl %ecx
    pushl %ebx
    
    call print_str
    movl test_len, %ebx
    movl %ebx, right
    
    movl $50,  %ecx
    loop_begin:
        push %ecx
      #выведем счетчики left и right  
        push %eax
        
        movl left, %eax
        call print_num
        movl right, %eax
        call print_num

        pop %eax
        
        call print_str
        xorl %edx, %edx
        
        movl %eax, %ebx
        
        xorl %eax, %eax
        movl left, %ecx
        movb (%ebx, %ecx), %dl
        movb %dl, %al
    
        #call print_char
        
        xorl %eax, %eax
        movl right, %ecx
        movb (%ebx, %ecx), %dh
        movb %dh, %al
        #call print_char
        
        cmpb %dl, %dh
        jne _fail_palindrome
        
        mov %ebx, %eax

        incl left
        decl right
        
        popl %ecx
        movl left, %ebx 
        cmp right, %ebx
        #loop loop_begin 
        jbe loop_begin
    
    mov $1, %eax
    jmp _exit_palindrome
_fail_palindrome:
    mov $0, %eax
    popl %ecx
_exit_palindrome:
    popl %ebx
    popl %ecx
    
    ret
#END OF is_palindrome


/*******************************************************************
    Считать строку по адресу (%eax) из stdin
*******************************************************************/
format_str_in:
    .string "%s"
read_str:
    pushl %eax
    pushl $format_str_in
    call scanf

    popl %eax
    popl %eax
    ret
#END OF read_str

main:
    movl %esp, %ebp #for correct debugging
  #печать строки "Hello World!"
    movl $msg, %eax
    call print_str
    
  #считать строку из stdin
    movl $str1, %eax
    call read_str
    
  #проверка на палиндром
    mov $str1, %eax
    call is_palindrome  
    call print_num
    
  #выход из программы
    addl $4, %esp
    xorl %eax, %eax
    call exit
    
.bss

str1:
    .space 256
    
str2:
    .space 256

