.data
test_str:
    .string "aba!aba"
    
len:
    .long 0
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
    pushl %edx
    
    movl len, %ebx
    movl %ebx, right
    decl right
    
    movl $50,  %ecx
    loop_begin:
        push %ecx
        /*
      #выведем счетчики left и right  
        push %eax
        
        movl left, %eax
        call print_num
        movl right, %eax
        call print_num

        pop %eax
        */
        
      #получим символ в строке с номером left, результат в %dl
        movl left, %ecx
        movb (%eax, %ecx), %dl
        
      #получим символ в строке с номером right, результат в %dh
        movl right, %ecx
        movb (%eax, %ecx), %dh
      
      #если не совпали, то строка не палиндром  
        cmpb %dl, %dh
        jne _fail_palindrome

        incl left
        decl right
        
        popl %ecx
        movl left, %ebx
        cmp right, %ebx
        jb loop_begin
    
    mov $1, %eax
    jmp _exit_palindrome
    
_fail_palindrome:
    mov $0, %eax
    popl %ecx
    
_exit_palindrome:
    popl %edx
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
    
  #считать строку из stdin
    movl $str1, %eax
    call read_str
    mov $0, %eax
    mov $str1, %ecx
  #узнаем размер считаной строки
_str_len:
    movb (%ecx, %eax), %bl
    cmp $0, %bl
    jne _not_zero
    jmp _str_len_end
_not_zero:
    incl %eax
    jmp _str_len
_str_len_end:
    call print_num  
    movl %eax, len
    
  #проверка на палиндром
    mov $str1, %eax
    call print_str
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
