OUTPUT_FORMAT("pe-i386")
ENTRY(_start)

SECTIONS
{
    . = 0x00100000;

    /* Kernel Başlangıcı */
    _kernel_start = .;

    .text : {
        *(.multiboot)
        *(.text)
    }

    .data : { *(.data) }
    
    /* Yüklenecek verinin sonu (Kod + Veri) */
    _kernel_data_end = .;

    .bss : { *(.bss) }

    /* BSS Sonu (Sıfırlanacak alanın sonu) */
    _kernel_bss_end = .;
}