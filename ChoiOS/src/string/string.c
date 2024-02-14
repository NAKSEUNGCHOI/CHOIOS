#include "string.h"

int strlen(const char* ptr)
{
    int i = 0;
    // increment until ptr is equal to the null terminator.
    while (*ptr != 0)
    {
        i++;
        ptr += 1;
    }
    return i;
}

int strnlen(const char* ptr, int max)
{
    int i = 0;
    for (i = 0; i < max; i++)
    {
        if (ptr[i] == 0)
            break;
    }
    return i;
}

int toNumericDigit(char c)
{
    return c - 48;
}

bool isdigit(char c)
{
    return c >= 48 && c <= 57;
}