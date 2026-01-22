@echo off
echo [1/4] Derleniyor...

if not exist build mkdir build

:: --- ASSEMBLY ---
nasm src/boot/start.asm -f elf -o build/start.o
nasm src/cpu/interrupts.asm -f elf -o build/interrupts.o

:: --- C FILES ---
gcc -m32 -ffreestanding -c src/kernel/kernel.c -o build/kernel.o
gcc -m32 -ffreestanding -c src/drivers/ports.c -o build/ports.o
gcc -m32 -ffreestanding -c src/drivers/video.c -o build/video.o
gcc -m32 -ffreestanding -c src/drivers/mouse.c -o build/mouse.o
gcc -m32 -ffreestanding -c src/drivers/keyboard.c -o build/keyboard.o
:: TIMER SÜRÜCÜSÜ (Eğer timer.c dosyan varsa bu satır gerekli)
gcc -m32 -ffreestanding -c src/drivers/timer.c -o build/timer.o

gcc -m32 -ffreestanding -c src/ui/gui.c -o build/gui.o
gcc -m32 -ffreestanding -c src/ui/window.c -o build/window.o
gcc -m32 -ffreestanding -c src/utils/math.c -o build/math.o
gcc -m32 -ffreestanding -c src/utils/string.c -o build/string.o
gcc -m32 -ffreestanding -c src/cpu/gdt.c -o build/gdt.o
gcc -m32 -ffreestanding -c src/cpu/idt.c -o build/idt.o

if %errorlevel% neq 0 goto error

:: --- LINKER ---
echo [2/4] Birlestiriliyor...
:: build/timer.o dosyasını buraya eklemeyi unutma
ld -m i386pe --image-base 0x100000 -T src/link.ld -o kernel.pe ^
    build/start.o build/interrupts.o ^
    build/kernel.o build/ports.o build/video.o build/mouse.o build/keyboard.o build/timer.o ^
    build/gui.o build/window.o build/math.o build/string.o build/gdt.o build/idt.o

if %errorlevel% neq 0 goto error

:: --- BINARY CONVERSION (FLAT BINARY) ---
echo [3/4] Binary'ye cevriliyor...
objcopy -O binary kernel.pe kernel.bin

echo [4/4] Baslatiliyor...
qemu-system-i386 -kernel kernel.bin

goto end

:error
echo [!!!] HATA OLUSTU.
pause
:end