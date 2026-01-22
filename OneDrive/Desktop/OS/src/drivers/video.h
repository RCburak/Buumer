#ifndef VIDEO_H
#define VIDEO_H

#define WIDTH 320
#define HEIGHT 200

// Renkler (VGA Palette)
#define COL_BLACK 0
#define COL_BLUE 1
#define COL_GREEN 2
#define COL_CYAN 3
#define COL_RED 4
#define COL_MAGENTA 5
#define COL_BROWN 6
#define COL_LIGHT_GRAY 7
#define COL_DARK_GRAY 8
#define COL_LIGHT_BLUE 9
#define COL_LIGHT_GREEN 10
#define COL_LIGHT_CYAN 11
#define COL_LIGHT_RED 12
#define COL_LIGHT_MAGENTA 13
#define COL_YELLOW 14
#define COL_WHITE 15

// UI Renkleri
#define COL_DESKTOP 1
#define COL_WINDOW_BG 7
#define COL_TITLE_BAR 9
#define COL_TITLE_TEXT 15

void init_video();
void clear_screen(unsigned char color);
void put_pixel(int x, int y, unsigned char color);
void draw_rect(int x, int y, int w, int h, unsigned char color);

// YENİ: Tamponu ekrana basan fonksiyon
void buffer_swap();

#endif