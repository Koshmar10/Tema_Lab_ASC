.data
    hardisk: .space 32
    memory_slots: .long 32
    printElementArray: .asciz "%d, "
    printEndLine: .asciz "\n"
.text

afisare_hardisk:
    push %ebp
    mov %esp, %ebp
    push %esi
    mov 12(%ebp), %esi
    xor %ecx, %ecx
afisare:
    cmp 8(%ebp), %ecx
    je  end_afisare
    movb (%esi, %ecx, 1), %al
    push %ecx
    push %eax
    push $printElementArray
    call printf
    add $8, %esp
    popl %ecx
    inc %ecx
    jmp afisare
end_afisare:
    pop %esi
    pop %ebp
    ret

.global main

main:
    lea hardisk, %esi
    movl $10, %ecx
    mov $5, (%esi, %ecx, 1)
    mov $4, %ecx
    mov $4, (%esi, %ecx, 1)
    mov $0, %esi
    pushl $hardisk
    pushl memory_slots
    call afisare_hardisk
    add $8, %esp

cont:
    push $printEndLine
    call printf
    add $4, %esp
exit:
    movl $1, %eax
    movl $0, %ebx
    int $0x80




