#include "gui.h"

// İleride çoklu pencere sistemi yaparsak burayı kullanacağız.
// Şimdilik sadece örnek bir fonksiyon bırakıyorum.

void init_window_manager() {
    // Pencere yöneticisi başlatıldığında yapılacaklar
    // Örn: Arkaplanı temizle, görev çubuğunu hazırla...
}

// Pencerenin içinde mi tıklandı?
int is_inside_window(Window* win, int mx, int my) {
    return (mx >= win->x && mx <= win->x + win->w &&
            my >= win->y && my <= win->y + win->h);
}