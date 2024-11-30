.data
    hardisk: .space 64
    memory_slots: .long 64
    line_lenght: .long 8

    id_file: .long 0
    lineIndex: .long 0
    colIndex: .long 0
    sequence_line: .long 0
    col_start: .long 0
    col_stop: .long 0
    conterZeroSequence: .long 0
    memory_to_be_occupied: .long 0

    descriptor: .space 4
    descriptor_size: .space 4


    formatEndLine: .asciz " \n"
    formatMatrixElement: .asciz "%d, "
    formatLineColTuple: .asciz "%d: (%d, %d)\n"
    formatAddStartStop: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatGetStartStop: .asciz "((%d, %d), (%d, %d))\n"

.text


add_element:
    push %ebp  
    mov %esp, %ebp
    
    movl $0, sequence_line
    movl $-1, col_start
    movl $-1, col_stop
    movl $0, colIndex
    movl $0, lineIndex
    movl $0, conterZeroSequence
    movl $0, memory_to_be_occupied

    push %esi
    mov 16(%ebp), %esi
    movl $0, %eax
    movl $0, %ecx
    movl $0, %edx
    push %ebx
    movl $8, %ebx
    movl 8(%ebp), %eax
    div %ebx
    cmp $0, %edx
    je skip_increment_size
    inc %eax
skip_increment_size:
    movl %eax, memory_to_be_occupied
    movl $0, %eax
    movl $0, %ecx
    movl $0, %edx
add_element_loop:
    cmpl memory_slots, %ecx
    je exit_add_element_loop
    cmpl %edx, line_lenght
    je increment_line
    jmp skip_increment_line
increment_line:
    movl $0, conterZeroSequence
    movl $-1, col_start
    movl $-1, col_stop
    movl lineIndex, %eax
    inc %eax
    movl %eax, lineIndex
    subl $8, %edx
skip_increment_line:
    push %ecx
    push %edx

    movl lineIndex, %eax
    movl $0, %edx
    mull line_lenght
    subl %eax, %ecx
    movl %ecx, colIndex

    pop %edx
    pop %ecx

    movl $0, %eax
    movb (%esi, %ecx, 1), %al
    cmp $0, %al
    je found_empty_slot
    movl $0, conterZeroSequence
    movl $0, sequence_line
    movl $-1, col_start
    movl $-1, col_stop
    jmp cont_add_element_loop
found_empty_slot:
    incl conterZeroSequence
    cmpl $1, conterZeroSequence
    jne skip_found_start
    movl colIndex, %ebx
    movl %ebx, col_start
    movl lineIndex, %ebx
    movl %ebx, sequence_line
skip_found_start:
    movl conterZeroSequence, %ebx
    cmpl %ebx, memory_to_be_occupied
    je found_end_sequence
    jmp cont_add_element_loop
found_end_sequence:
    movl colIndex, %ebx
    movl %ebx, col_stop
    movl lineIndex, %ebx
    movl %ebx, sequence_line
    jmp exit_add_element_loop


cont_add_element_loop:

    push %edx
    push %ecx

    pushl $0
    call fflush
    add $4, %esp

    pop %ecx
    pop %edx

    inc %edx
    inc %ecx
    jmp add_element_loop
exit_add_element_loop:

    movl sequence_line, %eax
    mull line_lenght
    addl col_start, %eax
    movl %eax, %ecx

    movl sequence_line, %eax
    mull line_lenght
    addl col_stop, %eax
    movl %eax, %edx

asign_loop:
    cmp %ecx, %edx
    jl exit_asign_loop
    
    movl $0, %eax
    movb (%esi, %ecx, 1), %al
    movb 12(%ebp), %al
    movb %al, (%esi, %ecx, 1)

    inc %ecx
    jmp asign_loop
exit_asign_loop:

    push col_stop
    push sequence_line
    push col_start
    push sequence_line
    push descriptor
    push $formatAddStartStop
    call printf
    add $24, %esp

    pop %ebx
    pop %esi
    pop %ebp
    ret

get_element:
    push %ebp
    mov %esp, %ebp
    push %esi
    mov 12(%ebp), %esi
    movl $0, lineIndex
    movl $0, sequence_line
    movl $-1, col_start
    movl $-1, col_stop

    push %ebx
    movl $0, %ebx
    movl $0, %edx
    movl $0, %ecx
get_element_loop:
    cmp memory_slots, %ecx
    je exit_get_element_loop
    cmp $8, %edx
    jne gt_skip_increment_line
    subl $8, %edx
    incl lineIndex
gt_skip_increment_line:
    
    push %ecx
    push %edx
    movl lineIndex, %eax
    movl $0, %edx
    mull line_lenght
    subl %eax, %ecx
    movl %ecx, colIndex
    pop %edx
    pop %ecx

    
    movl $0, %eax
    movb (%esi, %ecx, 1), %al
    cmpb 8(%ebp), %al
    jne not_found_element
    movl lineIndex, %ebx
    movl %ebx, sequence_line
    cmpl $-1, col_start
    jne gt_skip_start_assign
    movl colIndex, %ebx
    movl %ebx, col_start
gt_skip_start_assign:
    movl colIndex, %ebx
    movl %ebx, col_stop
not_found_element:
    inc %edx
    inc %ecx
    jmp get_element_loop
exit_get_element_loop:
    cmpl $0, 16(%ebp)
    je case_add
    cmpl $1, 16(%ebp)
    je case_get
    jmp get_exit
case_get:  
    push col_stop
    push sequence_line
    push col_start
    push sequence_line
    push $formatGetStartStop
    call printf
    add $20, %esp
    push $0
    call fflush
    add $4, %esp
    jmp get_exit
case_add:
    push col_stop
    push sequence_line
    push col_start
    push sequence_line
    push 8(%ebp)
    push $formatAddStartStop
    call printf
    add $24, %esp
    push $0
    call fflush
    add $4, %esp
get_exit:
    pop %ebx
    pop %esi
    pop %ebp
    ret

delete_element:
    push %ebp
    mov %esp, %ebp
    push %esi
    mov 12(%ebp), %esi
    movl $0, %ecx
delete_loop:
    cmp memory_slots, %ecx
    je exit_delete_loop
    movl $0, %eax
    movb (%esi, %ecx, 1), %al
    cmpb 8(%ebp), %al
    je remove_element
    jmp cont_delete_loop
remove_element:
    movb $0, (%esi, %ecx, 1)
cont_delete_loop:
    inc %ecx
    jmp delete_loop
exit_delete_loop:

    pop %esi
    pop %ebp
    ret







display_matrix:
    push %ebp
    mov %esp, %ebp
    push %esi
    mov 8(%ebp), %esi
    movl $0, %ecx
    movl $0, %edx
display_loop:
    cmp memory_slots, %ecx
    je exit_display_loop
    cmp $8, %edx
    je print_end_line
    jmp skip_print_end_line
print_end_line:
    push %ecx
    push $formatEndLine
    call printf
    add $4, %esp
    pop %ecx

    push %ecx
    pushl $0
    call fflush
    add $4, %esp
    pop %ecx

    movl $0, %edx
skip_print_end_line:
    movl $0, %eax
    movb (%esi, %ecx, 1), %al
    
    push %edx
    push %ecx
    push %eax
    push $formatMatrixElement
    call printf
    add $8, %esp
    pop %ecx
    pop %edx

    push %edx
    push %ecx
    pushl $0
    call fflush
    add $4, %esp
    pop %ecx
    pop %edx

    inc %edx
    inc %ecx
    jmp display_loop
exit_display_loop:
    push %ecx
    push $formatEndLine
    call printf
    add $4, %esp
    pop %ecx
    pop %esi
    pop %ebp
    ret

print_files:
    push %ebp
    mov %esp, %ebp
    push %esi
    mov 8(%ebp), %esi
    push %ebx

    movl $-1, id_file
    movl $-1, col_start
    movl $-1, col_stop
    movl $0, lineIndex
    movl $0, colIndex
    movl $0, sequence_line

    movl $0, %edx
    movl $0, %ecx
print_files_loop:
    cmp memory_slots, %ecx
    je exit_print_files_loop
    movl $0, %eax
    movb (%esi, %ecx, 1), %al
    cmp $0, %al
    je skip_display_element
    cmp %al, id_file
    je skip_display_element
    movl %eax, id_file
    push %ecx
    push $0
    push $hardisk
    push id_file
    call get_element
    add $12, %esp
    pop %ecx
skip_display_element:
    inc %ecx
    jmp print_files_loop
exit_print_files_loop:
    pop %ebx
    pop %esi
    pop %ebp
    ret




.global main

main:
    movl $3, descriptor
    movl $60, descriptor_size

    push $hardisk
    push descriptor
    push descriptor_size
    call add_element
    add $12, %esp

    movl $7, descriptor
    movl $25, descriptor_size

    push $hardisk
    push descriptor
    push descriptor_size
    call add_element
    add $12, %esp

    movl $9, descriptor
    movl $25, descriptor_size

    push $hardisk
    push descriptor
    push descriptor_size
    call add_element
    add $12, %esp


    push $hardisk
    call display_matrix
    add $4, %esp

    push $hardisk
    call print_files
    add $4, %esp

    push $hardisk
    push $7
    call delete_element
    add $8, %esp

    push $hardisk
    call display_matrix
    add $4, %esp
    push $hardisk
    call print_files
    add $4, %esp

exit:
    movl $1, %eax        
    xorl %ebx, %ebx      
    int $0x80

