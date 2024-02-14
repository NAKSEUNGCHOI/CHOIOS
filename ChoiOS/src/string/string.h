#ifndef STRING_H
#define STRING_H
#include <stdbool.h>

int strlen(const char* ptr);
int strnlen(const char* ptr, int max);
int toNumericDigit(char c);
bool isdigit(char c);

#endif