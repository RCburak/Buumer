#include "idt.h"
#include "../drivers/ports.h"
#include "../drivers/keyboard.h"
#include "../drivers/mouse.h"
#include "../drivers/timer.h" // <--- EKLENDİ: Timer Başlık Dosyası

idt_gate_t idt[256];
idt_register_t idt_reg;
extern void* isr_stub_table[];
extern void idt_flush(uint32_t);

void irq_remap() {
    outb(0x20, 0x11); outb(0xA0, 0x11);
    outb(0x21, 0x20); outb(0xA1, 0x28);
    outb(0x21, 0x04); outb(0xA1, 0x02);
    outb(0x21, 0x01); outb(0xA1, 0x01);
    outb(0x21, 0x0);  outb(0xA1, 0x0);
}

void set_idt_gate(int n, uint32_t handler) {
    idt[n].low_offset = (uint16_t)((handler) & 0xFFFF);
    idt[n].selector = 0x08;
    idt[n].always0 = 0;
    idt[n].flags = 0x8E;
    idt[n].high_offset = (uint16_t)(((handler) >> 16) & 0xFFFF);
}

void init_idt() {
    idt_reg.base = (uint32_t)&idt;
    idt_reg.limit = 256 * sizeof(idt_gate_t) - 1;

    // Exceptionları (0-31) yükle
    for (int i = 0; i < 32; i++) {
        set_idt_gate(i, (uint32_t)isr_stub_table[i]);
    }
    
    irq_remap();

    // IRQ'ları yükle
    set_idt_gate(32, (uint32_t)isr_stub_table[32]); // Timer (IRQ 0)
    set_idt_gate(33, (uint32_t)isr_stub_table[33]); // Klavye (IRQ 1)
    set_idt_gate(44, (uint32_t)isr_stub_table[44]); // Mouse (IRQ 12)

    idt_flush((uint32_t)&idt_reg);
}

typedef struct {
    uint32_t ds; 
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax; 
    uint32_t int_no, err_code; 
    uint32_t eip, cs, eflags, useresp, ss; 
} registers_t;

// --- KESME YÖNETİCİSİ ---
void isr_handler(registers_t regs) {
    // IRQ 0: Timer
    if (regs.int_no == 32) {
        timer_handler(); // <--- EKLENDİ: Saatin çalışması için şart
    }

    // IRQ 1: Klavye
    if (regs.int_no == 33) {
        keyboard_handler();
    }
    
    // IRQ 12: Mouse
    if (regs.int_no == 44) {
        mouse_handler();
    }

    // PIC EOI (Sinyal alındı mesajı gönder)
    if (regs.int_no >= 40) outb(0xA0, 0x20); // Slave PIC
    outb(0x20, 0x20); // Master PIC
}