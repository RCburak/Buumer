#include "mouse.h"
#include "ports.h"
#include "video.h"

int mouse_x = 160, mouse_y = 100;
int mouse_cycle = 0;
unsigned char mouse_byte[3];
int mouse_left_button = 0;

void mouse_wait(unsigned char type) {
    int timeout = 100000;
    if (type == 0) while (timeout--) { if ((inb(0x64) & 1) == 1) return; }
    else while (timeout--) { if ((inb(0x64) & 2) == 0) return; }
}

void mouse_write(unsigned char a_write) {
    mouse_wait(1); outb(0x64, 0xD4);
    mouse_wait(1); outb(0x60, a_write);
}

unsigned char mouse_read() {
    mouse_wait(0); return inb(0x60);
}

void mouse_init() {
    unsigned char _status;
    mouse_wait(1); outb(0x64, 0xA8);
    mouse_wait(1); outb(0x64, 0x20);
    mouse_wait(0); _status = (inb(0x60) | 2);
    mouse_wait(1); outb(0x64, 0x60);
    mouse_wait(1); outb(0x60, _status);
    mouse_write(0xF6); mouse_read();
    mouse_write(0xF4); mouse_read();
}

void mouse_handler() {
    unsigned char status = inb(0x64);
    if (!(status & 0x20)) return;
    unsigned char mouse_in = inb(0x60);

    if (mouse_cycle == 0) {
        if ((mouse_in & 0x08) == 0x08) { mouse_byte[0] = mouse_in; mouse_cycle++; }
    } else if (mouse_cycle == 1) {
        mouse_byte[1] = mouse_in; mouse_cycle++;
    } else if (mouse_cycle == 2) {
        mouse_byte[2] = mouse_in; mouse_cycle = 0;
        int dx = (char)mouse_byte[1];
        int dy = (char)mouse_byte[2];
        mouse_x += dx; mouse_y -= dy;
        if (mouse_x < 0) mouse_x = 0;
        if (mouse_y < 0) mouse_y = 0;
        if (mouse_x >= 315) mouse_x = 315;
        if (mouse_y >= 195) mouse_y = 195;
        mouse_left_button = (mouse_byte[0] & 0x01);
    }
}

void draw_mouse_cursor() {
    int cursor[5][5] = {{1,1,1,1,1},{1,1,0,0,0},{1,0,1,0,0},{1,0,0,1,0},{1,0,0,0,1}};
    for(int y=0; y<5; y++) for(int x=0; x<5; x++) if(cursor[y][x]) put_pixel(mouse_x+x, mouse_y+y, 15);
}

int get_mouse_x() { return mouse_x; }
int get_mouse_y() { return mouse_y; }
int get_mouse_left_button() { return mouse_left_button; }