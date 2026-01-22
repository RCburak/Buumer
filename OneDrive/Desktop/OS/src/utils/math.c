#ifndef MATH_C
#define MATH_C

// Mutlak Değer
int abs(int value) {
    return (value < 0) ? -value : value;
}

// Minimum
int min(int a, int b) {
    return (a < b) ? a : b;
}

// Maksimum
int max(int a, int b) {
    return (a > b) ? a : b;
}

#endif