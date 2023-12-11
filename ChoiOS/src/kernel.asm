[BITS 32]

global _start
extern kernel_main

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    MOV ax, DATA_SEG
    MOV ds, ax
    MOV es, ax
    MOV fs, ax
    MOV gs, ax
    MOV ss, ax
    MOV ebp, 0x00200000
    MOV esp, ebp

    ; EABLE the A20 LINE
    IN al, 0x92
    OR al, 2
    OUT 0x92, al

    ; Remap the master PIC
    MOV al, 00010001b ; this will put the PIC into an initialization mode
    OUT 0x20, al      ; Tell master PIC

    MOV al, 0x20      ; Interrupt 0x20 is where master ISR should start
    OUT 0x21, al

    MOV al, 00000001b
    OUT 0x21, al
    ; End remap of the master PIC

    CALL kernel_main ; this calls kernel_main function in C

    jmp $

; This solves any alignment issue associated with kernel.asm and object files created by C.
; Our C compiler uses 16 bytes by default, so we need to make kernel 512 bytes 
; 512 % 16 = 0.
; we times it to force to make it 512 bytes.
times 512-($ - $$) db 0 