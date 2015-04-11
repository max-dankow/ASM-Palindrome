.data

weak_flag:#флаг проверки слабых палиндромов
    .long 1#изначально нужно проверять 
     
len:#длинна введенной строки
    .long 0
    
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


/*******************************************************************
    %eax = left, %ebx = right, %ecx - адрес строки
*******************************************************************/
get_next_index:
    pushl %edx

    movl weak_flag, %edx
    cmp $0, %edx
    jne _weak_left
    
    incl %eax
    decl %ebx
    jmp _ret_get_index
  #следует проверять на слабый палиндром
_weak_left:
    incl %eax
    
    cmp %ebx, %eax
    jnl _ret_get_index
    
  #сравним символ строки с номером left c символами:
    movb (%ecx, %eax), %dl
  #пробел  
    cmpb $0x20, %dl
    je _weak_left
  #точка
    cmpb $0x2e, %dl
    je _weak_left
  #запятая
    cmpb $0x2c, %dl
    je _weak_left

_weak_right:
    decl %ebx

    cmp %ebx, %eax
    jnl _ret_get_index
    
  #сравним символ строки с номером right c символами:
    movb (%ecx, %ebx), %dl
  #пробел  
    cmpb $0x20, %dl
    je _weak_right
  #точка  
    cmpb $0x2e, %dl
    je _weak_right
  #запятая  
    cmpb $0x2c, %dl
    je _weak_right
    
_ret_get_index:
    popl %edx
    ret


/******************************************************************
    Проверяет строку, адрес которой записан в %eax, на палиндром. 
    Длина строки должна быть записана в %ebx
    Возвращает если палиндром -> 1, иначе -> 0
******************************************************************/
is_palindrome:
    pushl %ecx
    pushl %ebx
    pushl %edx
    
  #правый счетчик = длинна строки - 1  
    movl %ebx, right
    decl right
    
  #левый счетчик = 0
    movl $0, %ebx
    movl %ebx, left

    loop_begin:
        push %ecx
        
      #получим символ в строке с номером left, результат в %dl
        movl left, %ecx
        movb (%eax, %ecx), %dl
        
      #получим символ в строке с номером right, результат в %dh
        movl right, %ecx
        movb (%eax, %ecx), %dh
      
      #если не совпали, то строка не палиндром  
        cmpb %dl, %dh
        jne _fail_palindrome
        
      #получим следующий значащий символ
        pushl %eax
      
        movl %eax, %ecx
        movl left, %eax
        movl right, %ebx
        call get_next_index
        
        movl %eax, left
        movl %ebx, right
        
        popl %eax
        popl %ecx
      #продолжаем сравнение если left < right
        movl left, %ebx
        cmp right, %ebx
        jl loop_begin
  
  #успех, вернем 1  
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
    Считать строку по адресу (%eax) из stdin.
    В %eax помещает длину строки.
*******************************************************************/
read_str:
    pushl %edx
    pushl %ebx
    
    xorl %ebx, %ebx
    movl %eax, %edx
_read_char_loop:
    push %edx
    push %ebx
    
    pushl stdin
    call getc
    popl %ebx
    
    popl %ebx
    popl %edx
  
  #завершаем чтение, если  
  #встретили перевод строки
    cmpb $0x0a, %al
    je _end_read
  #или конец файла getc вернул -1
    cmpb $0xff, %al
    je _end_read
    
    movb %al, (%edx, %ebx)
    incl %ebx
    jmp _read_char_loop

_end_read:
  #размещаем в конце строки \0
    movb $0, %al
    movb %al, (%edx, %ebx) 
    
  #возвращаем длину строки
    mov %ebx, %eax
    
    popl %ebx
    popl %edx
    ret
#END OF read_str

main:
    movl %esp, %ebp #for correct debugging
_main_loop:
  #считать строку из stdin
    movl $str1, %eax
    call read_str
    movl %eax, len
    
    cmpl $0, %eax
    je _exit
    
    movl %eax, len
    
  #проверка на палиндром
    movl $str1, %eax
    movl len, %ebx
    call print_str
    call is_palindrome  
    call print_num
    
    jmp _main_loop
    
_exit:
  #выход из программы
    addl $4, %esp
    xorl %eax, %eax
    call exit
    
.bss

str1:
    .space 256
    
str2:
    .space 256
