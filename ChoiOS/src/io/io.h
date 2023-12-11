#ifndef IO_H
#define IO_H

// read one byte from given port
unsigned char insb(unsigned short port); 
// read word
unsigned short insw(unsigned short port);

// output one byte to the port
void outb(unsigned short port, unsigned char val);
// output two bytes to the port.
void outw(unsigned short port, unsigned short val);

#endif