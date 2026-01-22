#ifndef TIMER_H
#define TIMER_H

void init_timer(unsigned int frequency);
void timer_handler();
unsigned int get_tick_count();

#endif