.data
    hardisk: .space 1024
    tmp_hardisk: .space 1024
    memory_slots: .long 1024

    operation_id: .space 4
    number_of_operations: .space 4
    number_of_files_to_add: .space 4
    descriptor: .space 4
    memory_size: .space 4

    poz_start: .space 4
    poz_stop: .space 4

    descriptor_to_be_relocated: .space 4

    printElementArray: .asciz "%d, "
    printEndLine: .asciz "\n"
    printAddDeleteTuple: .asciz "%d: (%d, %d)\n"
    printGetTuple: .asciz "(%d, %d)\n"
    formatScanf: .asciz "%d"
.text

add_element:
    push %ebp
    mov %esp, %ebp
    movl $-1, poz_start
    movl $-1, poz_stop
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
    push poz_stop
    push poz_start
    push 12(%ebp)
    push $printAddDeleteTuple
    call printf
    add $16, %esp
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
    push $printGetTuple
    call printf
    add $12, %esp

    pop %esi
    pop %ebp
    ret


df_get_element:
    push %ebp
    mov %esp, %ebp
    movl $-1, poz_start
    movl $-1, poz_stop
    push %esi
    mov 12(%ebp), %esi
    movl $0, %ecx
    movl $0, %edx
df_ge_search_trough_hardisk:
    cmp memory_slots, %ecx
    je df_exit_search
    xorl %eax, %eax
    movb (%esi, %ecx, 1), %al
    cmpb 8(%ebp), %al
    je df_found_element
    jmp df_not_found_element
df_found_element:
    cmpl $-1, poz_start
    jne df_skip_set_start
    movl %ecx, poz_start
df_skip_set_start:
    movl %ecx, poz_stop
df_not_found_element:
    inc %ecx
    jmp df_ge_search_trough_hardisk
df_exit_search:
    
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

    push $hardisk
    call print_hardisk
    add $4, %esp

    pop %esi
    pop %ebp
    ret

defragmentation:
    push %ebp
    mov %esp, %ebp
    movl $0, %ecx
    movl $0, %edx
    push %esi
    mov 8(%ebp), %esi
    push %edi
    mov $tmp_hardisk, %edi
    movb $0, descriptor_to_be_relocated
    push %ebx
    mov $8, %ebx
df_loop:
    cmp memory_slots, %ecx
    je exit_df_loop
    cmpb $0, (%esi, %ecx, 1)
    je df_skip_copy
    cmpb $0, descriptor_to_be_relocated
    je set_descriptor
    jmp chehck_descriptor
set_descriptor:
    xor %eax, %eax
    movb (%esi, %ecx, 1), %al
    movb %al, descriptor_to_be_relocated

    push %ecx
    push $hardisk
    push descriptor_to_be_relocated
    call df_get_element
    add $8, %esp
    pop %ecx

    xor %eax, %eax
    xor %edx, %edx
    movl poz_stop, %eax
    movl poz_start, %edx
    sub %edx, %eax
    xor %edx, %edx
    inc %eax
    mul %ebx
    push %ecx
    push $tmp_hardisk
    push descriptor_to_be_relocated
    push %eax
    call add_element
    add $12, %esp
    pop %ecx
    jmp df_skip_copy
chehck_descriptor:
    xor %eax, %eax
    movb (%esi, %ecx, 1), %al
    cmpb %al, descriptor_to_be_relocated
    je df_skip_copy
    jmp set_descriptor
df_skip_copy:
    inc %ecx
    jmp df_loop
exit_df_loop:
    movl $0, %ecx
df_asign:
    cmp memory_slots, %ecx
    je exit_df_asign
    xor %eax, %eax
    movb (%edi, %ecx, 1), %al
    movb %al, (%esi, %ecx, 1)
    inc %ecx
    jmp df_asign
exit_df_asign:
    pop %ebx
    pop %edi
    pop %esi
    pop %ebp
    ret


print_hardisk:
    push %ebp
    mov %esp, %ebp
    movl $0, %ecx
    push %esi
    mov 8(%ebp), %esi
    movl $0, descriptor
print_loop:
    cmp memory_slots, %ecx
    je exit_print_loop

    cmpb $0, (%esi, %ecx, 1)
    je skip_print
    cmpl $0, descriptor
    je set_print_descriptor
    jmp check_print_descriptor
set_print_descriptor:
    xor %eax, %eax
    movb (%esi, %ecx, 1), %al
    movb %al, descriptor

    push %ecx
    push $hardisk
    push descriptor
    call df_get_element
    add $8, %esp
    pop %ecx

    push %ecx
    push poz_stop
    push poz_start
    push descriptor
    push $printAddDeleteTuple
    call printf
    add $16, %esp
    pop %ecx

    jmp skip_print
check_print_descriptor:
    xor %eax, %eax
    movb (%esi, %ecx, 1), %al
    cmpb %al, descriptor
    je skip_print
    jmp set_print_descriptor
skip_print:

    inc %ecx
    jmp print_loop
exit_print_loop:
    pop %esi
    pop %ebp
    ret

.global main

main:
    push $number_of_operations
    push $formatScanf
    call scanf
    add $8, %esp
    movl $0, %ecx
loop_trough_input:
    cmp number_of_operations, %ecx
    je exit
    push %ecx
    push $operation_id
    push $formatScanf
    call scanf
    add $8, %esp
    pop %ecx
    cmpl $1, operation_id
    je perform_add
    jmp skip_add
perform_add:
    xor %edx, %edx
    push %ecx
    push %edx
    push $number_of_files_to_add
    push $formatScanf
    call scanf
    add $8, %esp
    pop %edx
    pop %ecx
    
loop_torugh_files_to_add:
    cmp number_of_files_to_add, %edx
    je skip_add
    
    push %ecx
    push %edx
    push $descriptor
    push $formatScanf
    call scanf
    add $8, %esp
    pop %edx
    pop %ecx

    push %ecx
    push %edx
    push $memory_size
    push $formatScanf
    call scanf
    add $8, %esp
    pop %edx
    pop %ecx

    push %ecx
    push %edx
    push $hardisk
    push descriptor
    push memory_size
    call add_element
    add $12, %esp
    pop %edx
    pop %ecx
    inc %edx
    jmp loop_torugh_files_to_add
skip_add:
    cmpl $2, operation_id
    je perform_get
    jmp skip_get
perform_get:
    push %ecx
    push $descriptor
    push $formatScanf
    call scanf
    add $8, %esp
    pop %ecx

    push %ecx
    push $hardisk
    push descriptor
    call get_element
    add $8, %esp
    pop %ecx
    
skip_get:
    cmpl $3, operation_id
    je perform_delete
    jmp skip_delete
perform_delete:
    push %ecx
    push $descriptor
    push $formatScanf
    call scanf
    add $8, %esp
    pop %ecx

    push %ecx
    push $hardisk
    push descriptor
    call delete_element
    add $8, %esp
    pop %ecx
skip_delete:
    cmpl $4, operation_id
    je perform_defragmentation
    jmp skip_defragmentation
perform_defragmentation:
    push %ecx
    push $hardisk
    call defragmentation
    add $4, %esp
    pop %ecx
skip_defragmentation:
    inc %ecx
    jmp loop_trough_input

exit:
    movl $1, %eax
    movl $0, %ebx
    int $0x80




