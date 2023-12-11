#ifndef CONFIG_H
#define CONFIG_H

#define CHOIOS_TOTAL_INTERRUPT 512
#define KERNEL_CODE_SELECTOR 0x08
#define KERNEL_DATA_SELECTOR 0x10

// 100MB heap size
#define CHOIOS_HEAP_SIZE_BYTES 104857600 
#define CHOIOS_HEAP_BLOCK_SIZE 4096
#define CHOIOS_HEAP_ADDRESS 0x01000000
#define CHOIOS_HEAP_TABLE_ADDRESS 0x00007E00

#endif