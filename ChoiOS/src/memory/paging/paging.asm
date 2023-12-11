[BITS 32]

section .asm

global paging_load_directory
global enable_paging

paging_load_directory:
    PUSH ebp
    MOV ebp, esp
    MOV eax, [ebp+8]
    MOV cr3, eax ; cr3 should contain the address to our page directory.
    POP ebp
    RET

enable_paging:
    PUSH ebp
    MOV ebp, esp
    MOV eax, cr0
    OR eax, 0x80000000 ; all that is needed to load CR3 with the address of PG and set paging (PG)
    MOV cr0, eax
    POP ebp
    RET