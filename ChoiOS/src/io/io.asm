section .asm

global insb
global insw
global outb
global outw

insb:
    PUSH ebp
    MOV ebp, esp

    XOR eax, eax
    MOV edx, [ebp+8]
    IN al, dx

    POP ebp
    RET

insw:
    PUSH ebp
    MOV ebp, esp

    XOR eax, eax
    MOV edx, [ebp+8]
    IN ax, dx

    POP ebp
    RET

outb:
    PUSH ebp
    MOV ebp, esp
    
    MOV eax, [ebp+12]
    MOV edx, [ebp+8]
    OUT dx, al

    POP ebp
    RET

outw:
    PUSH ebp
    MOV ebp, esp

    MOV eax, [ebp+12]
    MOV edx, [ebp+8]
    OUT dx, ax

    POP ebp
    RET