[bits 32]
global _start
[extern _kmain]

; Linker'dan gelen adres etiketleri
extern _kernel_start
extern _kernel_data_end
extern _kernel_bss_end

section .multiboot
align 4
    dd 0x1BADB002              ; MAGIC
    dd 0x00010000              ; FLAGS (Adres bilgisi bizde!)
    dd -(0x1BADB002 + 0x00010000) ; CHECKSUM

    ; --- AOUT KLUDGE (Adresleri Etiketlerden Al) ---
    dd _kernel_start           ; header_addr
    dd _kernel_start           ; load_addr
    dd _kernel_data_end        ; load_end_addr
    dd _kernel_bss_end         ; bss_end_addr
    dd _start                  ; entry_addr

section .text
_start:
    ; Stack (Yığın) Ayarla
    mov esp, stack_top

    ; Kernel'i Başlat
    call _kmain

    ; İş biterse dur
    cli
hlt_loop:
    hlt
    jmp hlt_loop

section .bss
align 16
stack_bottom:
    resb 16384 ; 16 KB Stack
stack_top: