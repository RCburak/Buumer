#include "video.h"
#include "ports.h"

// Gerçek VGA Belleği
unsigned char* video_memory = (unsigned char*)0xA0000;

// YENİ: Arka Plan Tamponu (Sanal Ekran)
// 320 * 200 = 64000 byte
unsigned char back_buffer[320 * 200];

// VGA Ayarları (Değişmedi)
unsigned char g_320x200x256[] = {
    0x63, 0x03, 0x01, 0x0F, 0x00, 0x0E, 0x5F, 0x4F, 0x50, 0x82, 0x54, 0x80, 0xBF, 0x1F,
    0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9C, 0x0E, 0x8F, 0x28, 0x40, 0x96,
    0xB9, 0xA3, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x05, 0x0F, 0xFF, 0x00, 0x01,
    0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
    0x41, 0x00, 0x0F, 0x00, 0x00
};

void write_regs(unsigned char *regs) {
    unsigned i;
    unsigned char temp;
    outb(0x3C2, *regs); regs++;
    for(i = 0; i < 5; i++) { outb(0x3C4, i); outb(0x3C5, *regs); regs++; }
    outb(0x3D4, 0x03); temp = inb(0x3D5); outb(0x3D5, temp | 0x80);
    outb(0x3D4, 0x11); temp = inb(0x3D5); outb(0x3D5, temp & ~0x80);
    regs[0x03] |= 0x80; regs[0x11] &= ~0x80;
    for(i = 0; i < 25; i++) { outb(0x3D4, i); outb(0x3D5, *regs); regs++; }
    for(i = 0; i < 9; i++) { outb(0x3CE, i); outb(0x3CF, *regs); regs++; }
    for(i = 0; i < 21; i++) { inb(0x3DA); outb(0x3C0, i); outb(0x3C0, *regs); regs++; }
    inb(0x3DA); outb(0x3C0, 0x20);
}

void init_video() {
    write_regs(g_320x200x256);
    clear_screen(0); // Başlangıçta ekranı temizle
}

// YENİ: Artık sanal tampona (back_buffer) yazıyoruz
void put_pixel(int x, int y, unsigned char color) {
    if (x >= 0 && x < 320 && y >= 0 && y < 200) {
        back_buffer[y * 320 + x] = color;
    }
}

// YENİ: Sanal tamponu temizler
void clear_screen(unsigned char color) {
    for (int i = 0; i < 320 * 200; i++) {
        back_buffer[i] = color;
    }
}

void draw_rect(int x, int y, int w, int h, unsigned char color) {
    for (int i = 0; i < h; i++) {
        for (int j = 0; j < w; j++) {
            put_pixel(x + j, y + i, color);
        }
    }
}

// YENİ: Sanal tamponu GERÇEK ekrana kopyalar (Tek seferde!)
void buffer_swap() {
    // 64.000 pikseli kopyala
    // İleride memcpy ile daha hızlı yapılabilir ama şimdilik döngü yeterli.
    for (int i = 0; i < 320 * 200; i++) {
        video_memory[i] = back_buffer[i];
    }
}