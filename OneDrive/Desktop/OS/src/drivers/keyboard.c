#include "keyboard.h"
#include "ports.h"

static char last_key = 0;
static int shift_pressed = 0;

static const char keymap_lower[] = {0,27,'1','2','3','4','5','6','7','8','9','0','-','=','\b','\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',0,'a','s','d','f','g','h','j','k','l',';','\'','`',0,'\\','z','x','c','v','b','n','m',',','.','/',0,'*',0,' '};
static const char keymap_upper[] = {0,27,'!','@','#','$','%','^','&','*','(',')','_','+','\b','\t','Q','W','E','R','T','Y','U','I','O','P','{','}','\n',0,'A','S','D','F','G','H','J','K','L',':','"','~',0,'|','Z','X','C','V','B','N','M','<','>','?',0,'*',0,' '};

void keyboard_handler() {
    unsigned char scancode = inb(0x60);
    if (scancode & 0x80) {
        if ((scancode-0x80) == 0x2A || (scancode-0x80) == 0x36) shift_pressed = 0;
        return;
    }
    if (scancode == 0x2A || scancode == 0x36) { shift_pressed = 1; return; }
    if (scancode < 58 && keymap_lower[scancode] != 0) {
        last_key = shift_pressed ? keymap_upper[scancode] : keymap_lower[scancode];
    }
}

char get_last_key() {
    char c = last_key;
    last_key = 0;
    return c;
}