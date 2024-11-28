.data
    hardisk: .space 64
    memory_slots: .long 64

    formatEndLine: .asciz " \n"
    formatMatrixElement: .asciz "%d, "

.text

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


.global main

main:

    push $hardisk
    call display_matrix
    add $4, %esp

exit:
    movl $1, %eax        
    xorl %ebx, %ebx      
    int $0x80

