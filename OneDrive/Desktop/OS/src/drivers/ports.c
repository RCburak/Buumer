#include "ports.h"

unsigned char inb(unsigned short port) {
    unsigned char result;
    __asm__("inb %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

void outb(unsigned short port, unsigned char data) {
    __asm__("outb %1, %0" : : "dN" (port), "a" (data));
}