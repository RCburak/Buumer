#include "../drivers/ports.h"
#include "../drivers/video.h"
#include "../drivers/mouse.h"
#include "../drivers/keyboard.h"
#include "../drivers/timer.h" // YENİ
#include "../ui/gui.h"
#include "../ui/theme.h"
#include "../cpu/gdt.h" 
#include "../cpu/idt.h" 
#include "../utils/string.h" // String fonksiyonları (strcmp vs.)

// Pencereler
Window win1 = { .x=40, .y=50, .w=200, .h=120, .title="Terminal", .dragging=0, .visible=1 };
Window win2 = { .x=180, .y=100, .w=100, .h=80, .title="Bilgi", .dragging=0, .visible=0 };

Icon icon1 = { .x=20, .y=20, .label="Terminal", .color=14, .target=&win1 };
Icon icon2 = { .x=20, .y=80, .label="Bilgi", .color=8, .target=&win2 };

char terminal_buffer[256] = ""; 
int buffer_index = 0;

// Basit Komut İşleyici
void execute_command(char* cmd) {
    if (strcmp(cmd, "yardim") == 0) {
        // Ekrana yazdırmak için basit bir hack: Buffer'ı değiştiriyoruz
        // Gerçek bir terminalde alt satıra geçilir ama şimdilik böyle idare edelim.
        // String kopyalama fonksiyonu utils/string.c içinde olmalı.
        strcpy(terminal_buffer, "Komutlar: yardim, temizle, kapat");
        buffer_index = strlen(terminal_buffer);
    } 
    else if (strcmp(cmd, "temizle") == 0) {
        for(int i=0; i<256; i++) terminal_buffer[i] = 0;
        buffer_index = 0;
    }
    else if (strcmp(cmd, "kapat") == 0) {
        outb(0x64, 0xFE); // CPU Reset (QEMU'da restart atar)
    }
}

// Havalı Arkaplan Çizimi
void draw_background() {
    // Düz renk yerine desen çizelim
    for (int y = 0; y < 200; y++) {
        for (int x = 0; x < 320; x++) {
            // X ve Y koordinatlarına göre renk üret (XOR deseni)
            // Bu "Alien Artifact" tarzı bir desen oluşturur.
            put_pixel(x, y, (x ^ y) & 0xFF ? COL_DESKTOP : COL_DARK_GRAY);
        }
    }
}

void draw_scene() {
    // 1. Arkaplan
    // clear_screen(COL_DESKTOP); // Eski düz renk
    draw_background(); // Yeni desenli arkaplan
    
    // 2. Masaüstü Elemanları
    draw_icon(&icon1);
    draw_icon(&icon2);
    
    // 3. Görev Çubuğu
    draw_rect(0, HEIGHT - 20, WIDTH, 20, COL_TASKBAR);
    draw_string("Baslat", 5, HEIGHT - 15, 15);

    // 4. Saat (Timer'dan gelen Tick bilgisini yaz)
    int time = get_tick_count() / 18; // Saniyeye çevir (yaklaşık)
    char time_str[16];
    itoa(time, time_str); // Sayıyı yazıya çevir
    draw_string("Sure:", 250, HEIGHT - 15, 15);
    draw_string(time_str, 290, HEIGHT - 15, 14); // Sarı renk
    
    // 5. Pencereler
    if (win2.visible) draw_window(&win2);
    if (win1.visible) {
        draw_window(&win1);
        draw_string("> ", win1.x + 5, win1.y + 25, 0); 
        draw_string(terminal_buffer, win1.x + 20, win1.y + 25, 0);
        // Yanıp sönen imleç (Timer ile mod alarak yapıyoruz)
        if ((get_tick_count() / 10) % 2 == 0) {
            draw_char('_', win1.x + 20 + (buffer_index * 8), win1.y + 25, 0);
        }
    }
}

void handle_keyboard() {
    char c = get_last_key(); 
    if (c != 0 && win1.visible) {
        if (c == '\b') { 
            if (buffer_index > 0) terminal_buffer[--buffer_index] = 0;
        }
        else if (c == '\n') { 
            // Enter'a basılınca komutu işle
            execute_command(terminal_buffer);
            // Komut işlendikten sonra buffer temizlenmeli mi? 
            // Şimdilik temizlemiyoruz ki kullanıcı cevabı görsün.
            // Ama buffer_index'i sıfırlamak yerine yeni satır mantığı lazım.
            // Basitlik için: Bir sonraki tuşta her şeyi silecek şekilde bırakalım:
            // (Bu kısım geliştirilebilir)
        }
        else if (buffer_index < 25) { // Taşmayı engelle
            terminal_buffer[buffer_index++] = c;
            terminal_buffer[buffer_index] = 0;
        }
        
        draw_scene();
        draw_mouse_cursor();
        buffer_swap(); 
    }
}

void process_dragging(Window* win, int mx, int my) {
    if (!win->visible) return;
    win->x = mx - (win->w / 2);
    win->y = my - 10;
}

void kmain() {
    init_gdt();
    init_idt();
    init_timer(50); // 50 Hz frekans (Saniyede 50 tık)
    __asm__ volatile("sti"); 
    
    init_video();
    mouse_init();
    
    draw_scene();
    buffer_swap();

    int old_mx = 0, old_my = 0, old_btn = 0;
    int old_tick = 0;

    while(1) {
        handle_keyboard();

        int mx = get_mouse_x();
        int my = get_mouse_y();
        int btn = get_mouse_left_button();
        int current_tick = get_tick_count();

        // Ekranı ne zaman güncelleyelim?
        // 1. Mouse hareket ettiyse
        // 2. Tıklandıysa
        // 3. Zaman değiştiyse (Saatin ilerlemesi için)
        if (mx != old_mx || my != old_my || btn != old_btn || current_tick != old_tick) {
            
            if (btn && !old_btn) { // İlk Tıklama
                if (mx >= icon1.x && mx <= icon1.x+32 && my >= icon1.y && my <= icon1.y+32) icon1.target->visible = 1;
                if (mx >= icon2.x && mx <= icon2.x+32 && my >= icon2.y && my <= icon2.y+32) icon2.target->visible = 1;
                
                if (win1.visible && mx >= win1.x+win1.w-14 && mx <= win1.x+win1.w-4 && my >= win1.y+4 && my <= win1.y+14) win1.visible = 0;
                if (win2.visible && mx >= win2.x+win2.w-14 && mx <= win2.x+win2.w-4 && my >= win2.y+4 && my <= win2.y+14) win2.visible = 0;

                if (win1.visible && mx >= win1.x && mx <= win1.x+win1.w && my >= win1.y && my <= win1.y+18) process_dragging(&win1, mx, my);
                else if (win2.visible && mx >= win2.x && mx <= win2.x+win2.w && my >= win2.y && my <= win2.y+18) process_dragging(&win2, mx, my);
            }
            else if (btn) { // Sürükleme
                 if (win1.visible && mx >= win1.x && mx <= win1.x+win1.w && my >= win1.y && my <= win1.y+18) process_dragging(&win1, mx, my);
                 if (win2.visible && mx >= win2.x && mx <= win2.x+win2.w && my >= win2.y && my <= win2.y+18) process_dragging(&win2, mx, my);
            }

            draw_scene();
            draw_mouse_cursor();
            buffer_swap();

            old_mx = mx; old_my = my; old_btn = btn; old_tick = current_tick;
        }
    }
}