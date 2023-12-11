section .asm

extern int21h_handler
extern no_interrupt_handler

global int21h
global no_interrupt
global idt_load
global enable_interrupts
global disable_interrupts

enable_interrupts:
    ; Enable interrupts
    STI
    RET

disable_interrupts:
    CLI
    RET

idt_load:
    PUSH ebp
    MOV ebp, esp

    MOV ebx, [ebp+8] ; writing just ebp is going to point to the base pointer we just pushed.
                     ; ebp+4 is going to point to the return address of the function caller.
                     ; ebp+8 is going to point to the first argument passed to the function.
    lidt [ebx]

    POP ebp
    RET

int21h:
    CLI
    PUSHAD
    CALL int21h_handler
    POPAD
    STI
    IRET

no_interrupt:
    CLI
    PUSHAD
    CALL no_interrupt_handler
    POPAD
    STI
    IRET