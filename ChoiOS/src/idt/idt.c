#include "idt.h"
#include "config.h"
#include "kernel.h"
#include "memory/memory.h"
#include "io/io.h"

struct idt_desc idt_descriptors[CHOIOS_TOTAL_INTERRUPT];
struct idtr_desc idtr_descriptor;

// function protype from idt.asm so that our c file knows how to talk with it.
extern void idt_load(struct idtr_desc* ptr); // load idt using asm
extern void int21h();
extern void no_interrupt();

void int21h_handler()
{
    print("Keyboard pressed!\n");
}

void no_interrupt_handler()
{
    outb(0x20, 0x20);
}

void idt_zero()
{
    print("Divide by zero error\n");
}

void idt_set(int interrupt_no, void* address)
{
    struct idt_desc* desc = &idt_descriptors[interrupt_no];
    desc->offset_1 = (uint32_t) address & 0x0000ffff;
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0x00;
    desc->typeattr = 0xEE;
    desc->offset_2 = (uint32_t) address >> 16;
}

void idt_init()
{
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;

    for (int i = 0; i < CHOIOS_TOTAL_INTERRUPT; i++)
    {
        idt_set(i, no_interrupt);
    }

    idt_set(0, idt_zero);
    idt_set(0x21, int21h);

    // Load the interrupt descriptor table from idt.asm
    idt_load(&idtr_descriptor);
}