.data
    hardisk: .space 32
    memory_slots: .long 32
    descriptor: .long 2
    memory_size: .long 25
    poz_start: .space 4
    poz_stop: .space 4

    printElementArray: .asciz "%d, "
    printEndLine: .asciz "\n"
    printTuple: .asciz "(%d, %d)\n"
.text

add_element:
    push %ebp
    mov %esp, %ebp
    push %eax
    movl 8(%ebp), %eax
    push %esi
    mov 16(%ebp), %esi
    push %ebx
    mov $8, %ebx
    mov $0, %edx
    div %ebx
    cmp $0, %edx
    je skip_increment_size
    inc %eax
skip_increment_size:
    movl $0, %ecx
    movl $0, %edx
loop_trough_hardisk:
    cmp $memory_slots, %ecx
    je exit_loop
    xor %ebx, %ebx
    movb (%esi, %ecx, 1), %bl
    cmp $0, %bl
    je found_empty_slot
    jmp not_found_empty_slot
found_empty_slot:
    cmpl $-1, poz_start
    jne skip_set_poz_start
    movl %ecx, poz_start
    movl $0, %edx
skip_set_poz_start:
    inc %edx
    cmp %eax, %edx
    je set_poz_stop
    jmp cont_loop
set_poz_stop:
    movl %ecx, poz_stop
    jmp exit_loop
not_found_empty_slot:
    movl $-1, poz_start
    movl $0, %edx
cont_loop:
    inc %ecx
    jmp loop_trough_hardisk
exit_loop:
    movl poz_start, %ecx
    movl poz_stop, %edx
asign_id_loop:
    cmpl %edx, %ecx
    jg exit_asign_id_loop
    xor %eax, %eax
    movb 12(%ebp), %al
    movb %al, (%esi, %ecx, 1)
    inc %ecx
    jmp asign_id_loop
exit_asign_id_loop:
    pop %ebx
    pop %esi
    pop %eax
    pop %ebp
    ret


get_element:
    push %ebp
    mov %esp, %ebp
    movl $-1, poz_start
    movl $-1, poz_stop
    push %esi
    mov 12(%ebp), %esi
    movl $0, %ecx
    movl $0, %edx
ge_search_trough_hardisk:
    cmp memory_slots, %ecx
    je exit_search
    xorl %eax, %eax
    movb (%esi, %ecx, 1), %al
    cmpb 8(%ebp), %al
    je found_element
    jmp not_found_element
found_element:
    cmpl $-1, poz_start
    jne skip_set_start
    movl %ecx, poz_start
skip_set_start:
    movl %ecx, poz_stop
not_found_element:
    inc %ecx
    jmp ge_search_trough_hardisk
exit_search:
    push poz_stop
    push poz_start
    push $printTuple
    call printf
    add $12, %esp

    pop %esi
    pop %ebp
    ret

delete_element:
    push %ebp
    mov %esp, %ebp
    push %esi
    mov 12(%ebp), %esi
    movl $0, %ecx
de_search_trough_hardisk:
    cmp memory_slots, %ecx
    je exit_de_search_trough_hardisk
    xorl %eax, %eax
    movb (%esi, %ecx, 1), %al
    cmpb 8(%ebp), %al
    je de_found_element
    jmp de_not_found_element
de_found_element:
    movb $0, (%esi, %ecx, 1)
de_not_found_element:
    inc %ecx
    jmp de_search_trough_hardisk
exit_de_search_trough_hardisk:
    pop %esi
    pop %ebp
    ret


print_hardisk:
    push %ebp
    mov %esp, %ebp
    push %esi
    mov 12(%ebp), %esi
    xorl %ecx, %ecx
print_loop:
    cmp 8(%ebp), %ecx
    je  end_print
    xorl %eax, %eax
    movb (%esi, %ecx, 1), %al
    push %ecx
    push %eax
    push $printElementArray
    call printf
    add $8, %esp

    pushl $0
    call fflush
    add $4, %esp

    popl %ecx
    inc %ecx
    jmp print_loop
end_print:
    push $printEndLine
    call printf
    add $4, %esp
    pop %esi
    pop %ebp
    ret

.global main

main:

    

    movb $3, descriptor
    push $hardisk
    push descriptor
    push memory_size
    call add_element
    add $12, %esp
    
    movb $5, descriptor
    movb $100, memory_size
    push $hardisk
    push descriptor
    push memory_size
    call add_element
    add $12, %esp

    push $hardisk
    push $5
    call delete_element
    add $8, %esp   

    push $hardisk
    push memory_slots
    call print_hardisk
    add $8, %esp

    push $hardisk
    push $0
    call get_element
    add $8, %esp    
        

cont:
    push $printEndLine
    call printf
    add $4, %esp
exit:
    movl $1, %eax
    movl $0, %ebx
    int $0x80




