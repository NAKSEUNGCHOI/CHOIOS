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

char* strcpy(char* dest, const char* src)
{
    char* res = dest;
    while (*src != 0)
    {
        *dest = *src;
        dest++;
        src++;
    }

    // this is necessary. as src is null terminated above, dest needs to be null terminated as well.
    *dest = 0x00;
    return res;
}

int toNumericDigit(char c)
{
    return c - 48;
}

bool isdigit(char c)
{
    return c >= 48 && c <= 57;
}