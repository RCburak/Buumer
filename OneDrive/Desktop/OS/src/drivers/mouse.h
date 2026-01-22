#ifndef MOUSE_H
#define MOUSE_H

void mouse_init();
void mouse_handler(); // IDT için Interrupt fonksiyonu
void draw_mouse_cursor();

// Koordinatları Al
int get_mouse_x();
int get_mouse_y();
int get_mouse_left_button();

#endif