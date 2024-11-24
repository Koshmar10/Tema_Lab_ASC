.data
    hardisk: .space 1024
    memory_slots: .long 1024
    formatPrintf: .ascii "%d, "
.text
.global main

main:
        ; initialize the hardisk
    lea hsrdisk, %esi ; adresa hardisk-ului
    movl $0, %eax ; valoaera de initializare
    movl $0, %ecx ; numarul de octeti de initializat
    movl $memory_slots, %edx ; adresa memoriei

initializare_hardisk:
    
    cmp %edx, %ecx  
    ; verific daca am ajuns la final
    je end_initializare_hardisk ; daca da ies din bucla
    mov %eax, (%esi, %ecx, 1) ; initializez fiecare slot din hardisk
    inc %ecx ; incrementez numarul de octeti
    jmp initializare_hardisk ; trec la urmatorul slot

end_initializare_hardisk:
afisare_hardisk:
    lea hardisk, %esi
    movl $0, %ecx
loop:
    cmp $memory_slots, %ecx
    je  end_loop
    push $formatScanf
    push (%esi, %ecx, 1)
    push %ecx
    call printf
    add $8, %esp
    pop %ecx
    inc %ecx
end_loop:
exit:
    movl $1, %eax
    movl $0, %ebx
    int $0x80




