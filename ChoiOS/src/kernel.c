#include "kernel.h"
#include <stddef.h>
#include <stdint.h>
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include "memory/paging/paging.h"
#include "string/string.h"
#include "fs/file.h"
#include "disk/disk.h"
#include "fs/pparser.h"
#include "disk/streamer.h"

uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char(char c, char color) 
{
    // shift the color to the left by 8 bit then c in the low 8 bits.
    // the reason is that x86 uses little endiness. 
    return (color << 8) | c;
}

void terminal_putchar(int x, int y, char c, char color)
{
    video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(c, color);
}

void terminal_writechar(char c, char color)
{
    if (c == '\n')
    {
        terminal_row += 1;
        terminal_col = 0;
        return;
    }
    terminal_putchar(terminal_col, terminal_row, c, color);
    terminal_col += 1;
    if (terminal_col >= VGA_WIDTH)
    {
        terminal_col = 0;
        terminal_row += 1;
    }
}

void terminal_initialize()
{
    // Create a pointer to this absolute memory.
    video_mem = (uint16_t*)(0xB8000);
    terminal_row = 0;
    terminal_col = 0;

    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            terminal_putchar(x, y, ' ', 0);
        }
    }
}

void print(const char* str)
{
    size_t len = strlen(str);
    for (int i = 0; i < len; i++)
    {
        terminal_writechar(str[i], 15);
    }
}

static struct paging_4gb_chunk* kernel_chunk = 0;

void panic(const char* msg)
{
    print(msg);
    while(1) {}
}

void kernel_main()
{
    terminal_initialize();   
    // x86 uses little endiness so you need to change the locations. 
    print("Hello World!\ntest");

    // testing panic
    // panic("The system cannot continue! ERROR!");

    // initialize our heap.
    kheap_init();

    // initialize file system
    fs_init();

    // search and initialize the disk
    disk_search_and_init();

    // Initialize the interrupt descriptor table
    idt_init();

    // setup paging
    kernel_chunk = paging_new_4gb(PAGING_IS_WRITABLE | PAGING_IS_PRESENT | PAGING_ACCESS_FROM_ALL);

    // switch to kernel paging chunk
    paging_switch(paging_4gb_chunk_get_directory(kernel_chunk));

    // char* ptr = kzalloc(4096);
    // // this makes the virtual address 0x1000 point to the physical address of ptr (whatever it returns. i.g 0x1000000)
    // paging_set(paging_4gb_chunk_get_directory(kernel_chunk), (void*)0x1000, (uint32_t) ptr | PAGING_ACCESS_FROM_ALL | PAGING_IS_PRESENT | PAGING_IS_WRITABLE);
 
    // enable paging
    enable_paging();

    // so if you set ptr2 to 0x1000, it will essentially point to 0x1000000
    // This is because ptr has been set to the 0x100000 (for example) using a virtual address 0x1000 above.
    // Therefore, both ptr and ptr2 print AB.
    // char* ptr2 = (char*) 0x1000;
    // ptr2[0] = 'A';
    // ptr2[1] = 'B';
    // print(ptr2);

    // print(ptr);
    
    // Enable the system interrupts
    enable_interrupts();
    
    /* test path parser */
    // struct path_root* root_path = pathparser_parse("0:/bin/shell.exe", NULL);

    // if (root_path)
    // {

    // }
    /* test stream */
    // struct disk_stream* stream = diskstreamer_new(0);
    // diskstreamer_seek(stream, 0x201);
    // unsigned char c = 0;
    // diskstreamer_read(stream, &c, 1);
    // char buff[20];
    // strcpy(buff, "Nakseung Choi");
    
    int fd = fopen("0:/hello.txt", "r");
    if (fd)
    {
        struct file_stat s;
        fstat(fd, &s);
        fclose(fd);
        print("testing\n");
        // print("We opened hello.txt\n");
        // char buf[14];
        // fseek(fd, 2, SEEK_SET);
        // fread(buf, 11, 1, fd);
        // buf[13] = 0x00;
        // print(buf);
    }
    
    while (1) {}
    /* test heap */
    // void* ptr = kmalloc(50);
    // void* ptr2 = kmalloc(5000);
    // void* ptr3 = kmalloc(5600);
    // kfree(ptr);
    // void* ptr4 = kmalloc(50);
    // if (ptr || ptr2 || ptr3 || ptr4)
    // {
    // }

    
}