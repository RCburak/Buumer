#ifndef GUI_H
#define GUI_H

typedef struct {
    int x, y;
    int w, h;
    char* title;
    int dragging;
    int visible; 
} Window;

typedef struct {
    int x, y;       
    int color;      
    char* label;    
    Window* target; 
} Icon;

// Fonksiyon Tanımları
void draw_window(Window* win);
void draw_icon(Icon* icon);
void draw_string(char* s, int x, int y, unsigned char color);
void draw_char(char c, int x, int y, unsigned char color);

#endif