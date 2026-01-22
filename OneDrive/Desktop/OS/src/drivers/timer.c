#include "timer.h"
#include "ports.h"

unsigned int tick = 0;

void timer_handler() {
    tick++;
}

unsigned int get_tick_count() {
    return tick;
}

void init_timer(unsigned int frequency) {
    // 1193180 Hz / frekans = Bölen değeri
    unsigned int divisor = 1193180 / frequency;
    
    // Mode 3 (Kare Dalga)
    outb(0x43, 0x36);

    // Frekansı Low/High Byte olarak gönder
    unsigned char l = (unsigned char)(divisor & 0xFF);
    unsigned char h = (unsigned char)((divisor >> 8) & 0xFF);

    outb(0x40, l);
    outb(0x40, h);
}