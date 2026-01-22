#ifndef STRING_H
#define STRING_H

// Metin uzunluğu
int strlen(const char* str);
// Metin karşılaştırma (Eşitse 0 döner)
int strcmp(const char* s1, const char* s2);
// Metin kopyalama
void strcpy(char* dest, const char* src);
// Metin birleştirme
void strcat(char* dest, const char* src);
// Sayıyı metne çevirme (Integer to ASCII)
void itoa(int n, char* str);
// Metnin başını kontrol etme (Örn: "topla 5 10" -> "topla " ile başlıyor mu?)
int str_starts_with(const char* str, const char* prefix);
// Metni sayıya çevirme (ASCII to Integer)
int atoi(char* str);

#endif