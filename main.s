.data

weak_flag:#флаг проверки слабых палиндромов
    .long 0#изначально не нужно проверять 
     
len:#длинна введенной строки
    .long 0
    
static_limit:#максималтная длина строки, которую допускается хранить в статической памяти
    .long 0x400#по условию 1 кб
    
dynamic_flag:#показывает где сейчас находится строка, в статической или динамической памяти
    .long 0#изначально в статической
    
buf_size:#размер динамического буфера
    .long 0x2000#по умолчанию 8 кб
    
left:
    .long 0
    
right:
    .long 0
    
owerflow_msg:
    .string "ERROR: Buffer owerflow."
    
arg_msg:
    .string "ERROR: Wrong parameters."
    
move_msg:
    .string "Moved to dynamic buffer."
    
key:
    .string "-w"
    
env_name:
    .string "MAX_BUF"
            
current_str:
    .space 0x400
    
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


/*******************************************************************
    Передвигает счетчики %eax (left) и %ebx (right) 
    на следующий значащий символ строки с адресом %ecx.
*******************************************************************/
get_next_index:
    pushl %edx
    pushl %ecx

    movl weak_flag, %edx
    cmp $1, %edx
    je _weak_left
    
    incl %eax
    decl %ebx
    jmp _ret_get_index
  #передвинем счетчик left до слудующего значещего символа
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
  #зап_ret_get_indexятая
    cmpb $0x2c, %dl
    je _weak_left
    
  #передвинем счетчик right до слудующего значещего символа
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
    popl %ecx
    popl %edx
    ret
#END of get_next_index

/******************************************************************
    Проверяет строку, адрес которой записан в %eax, на палиндром. 
    Длина строки должна быть записана в %ebx
    Если палиндром, то возвращает 1, иначе 0
******************************************************************/
is_palindrome:
    pushl %ecx
    pushl %ebx
    
  #инициализиуем счетчики left и right 
    movl %ebx, right
    movl $-1, %ebx
    movl %ebx, left
    
  #получим первые значащие символы
    pushl %eax
      
    movl %eax, %ecx
    movl left, %eax
    movl right, %ebx
    call get_next_index
        
    movl %eax, left
    movl %ebx, right
        
    popl %eax

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
        
      #получим следующие значащие символы
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
    popl %ebx
    popl %ecx
    ret
#END OF is_palindrome


/*******************************************************************
    Считывает строку по адресу (%eax) из stdin.
    В %eax возвращает длину строки. 
    В %edx помещает адрес считаной строки
*******************************************************************/
read_str:
    pushl %ebx
    pushl %ecx
    
    movl $0, %ebx
    movl %ebx, dynamic_flag
    
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
    je _end_read_success
  #или конец файла (getc вернул -1)
    cmpb $0xff, %al
    je _end_read_EOF
    
    movb %al, (%edx, %ebx)
    incl %ebx
    
  #если превысили стат. лимит...
    cmp static_limit, %ebx
    jle _stay
    
  #и если мы еще в статичской памяти...
    movl dynamic_flag, %eax
    cmp $1, %eax
    je _check_dynamic_limit    
    
  #то пора переезжать в динамическую память
  #вызываем malloc(buf_size)
    pushl %edx
    pushl buf_size
    call malloc
    pop %edx
    pop %edx
    
  #переместим в буфер то, что уже считали  
    pushl %ebx
    pushl %edx
    pushl %eax
    call memcpy
    popl %eax
    popl %edx
    popl %ebx
  
  #обновим адрес строки, установим флаг 'строка в динамическом буфере'  
    movl %eax, %edx
    movl $1, %eax
    movl %eax, dynamic_flag 
    
  #печатаем уведомление о 'переезде'
    movl $move_msg, %eax
    pushl %edx
    pushl %ebx
    call print_str
    popl %ebx
    popl %edx
    
    jmp _stay
  #проверка на переполение динамического буфера  
_check_dynamic_limit:
    cmpl buf_size, %ebx
    jle _stay
  #случилось переполнение динамического буфера  
  #освободим память
    pushl %edx
    call free
    popl %edx
    
  #выводим сообщение о переполнении
    movl $owerflow_msg, %eax
    call print_str
    jmp _end_read_EOF
_stay:
    jmp _read_char_loop

_end_read_success:
  #размещаем в конце строки \0
    movb $0, %al
    movb %al, (%edx, %ebx) 
    
  #возвращаем длину строки
    mov %ebx, %eax
    jmp _exit_read
    
_end_read_EOF:
    mov $-1, %eax
    
_exit_read:
    popl %ecx
    popl %ebx
    ret
#END OF read_str


/*******************************************************************
    Основная программа
*******************************************************************/
main:
    movl %esp, %ebp #for correct debugging
    
  #ищем MAX_BUF среди переменных окружения  
    movl 12(%ebp), %ebx
    
  #%edx счетчик,  пробегающий все строки-переменные окружения
    movl $-4, %edx
_loop_find_env:
    addl $4, %edx
    
  #получаем очередную строку
    movl (%ebx, %edx), %eax
    
  #если NULL, то завершаем поиск -> MAX_BUF не найден  
    cmpl $0, %eax
    je _args
    
  #сравниваем с "MAX_BUF"
    pushl %ebx
    pushl %edx
    
    pushl $7
    pushl %eax
    pushl $env_name
    call strncmp
    popl %edx
    popl %edx
    popl %edx
    
    popl %edx
    popl %ebx
    
    cmpl $0, %eax
    jne _loop_find_env
    
  #нашли переменную MAX_BUF  
    mov (%ebx, %edx), %eax
    
  #получаем ее значение
    addl $8, %eax
    pushl %eax
    call atoi
    popl %ebx
    movl %eax, buf_size

_args:
  #получем параметры командной строки
    movl 4(%ebp), %eax
    cmp $1, %eax
    je _main_loop
    
    cmp $2, %eax
    jg _wrong_arg
    
  #сравниваем параметр с -w
    movl 8(%ebp), %eax
    pushl $key
    push 4(%eax)
    call strcmp
    
    popl %ebx
    popl %ebx
    
    cmp $0, %eax
    jne _wrong_arg
    
  #выставляем флаг слабого палиндрома в состояние "нужно искать"
    movl $1, %eax
    movl %eax, weak_flag
    jmp _main_loop
    
_wrong_arg:
    movl $arg_msg, %eax
    call print_str
    jmp _exit
    
_main_loop:
  #читаем строку из stdin
    movl $current_str, %eax
    call read_str
    movl %eax, len
    
    cmpl $-1, %eax
    je _exit
    
    movl %eax, len
    
  #проверка на палиндром
    movl %edx, %eax
    movl len, %ebx
    pushl %edx
    call print_str
    call is_palindrome
    call print_num
    popl %edx
    
  #если использовался буфер...
    mov dynamic_flag, %eax
    cmpl $1, %eax
    jne _continue_main
    
  #то вызываем free
    pushl %edx
    call free
    popl %edx
    
_continue_main:
    jmp _main_loop
    
_exit:
   #для наглядности напечатаем размер динамического буфера
    movl buf_size, %eax
    call print_num
    
    xorl %eax, %eax
    call exit
