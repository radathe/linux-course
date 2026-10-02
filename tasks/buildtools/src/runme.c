/*
 * runme -- задача T09 "Запусти программу".
 *
 * Ключ зашит в XOR-виде (см. ctf-xor): @KEY@ -- hex от (ключ ^ 0x5A).
 * Программа разбирает hex, снимает XOR и печатает ключ в hex-виде,
 * поэтому strings(1) исходный ключ не показывает.
 * Компилируется с -O0 (runtime-строка не должна сворачиваться).
 */
#include <stdio.h>

#define KEY_MASK 0x5A

static const char key_enc[] = "@KEY@";

static int hexval(char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    return -1;
}

int main(void)
{
    int i;

    for (i = 0; key_enc[i] != '\0' && key_enc[i + 1] != '\0'; i += 2) {
        int hi = hexval(key_enc[i]);
        int lo = hexval(key_enc[i + 1]);

        if (hi < 0 || lo < 0)
            break;

        printf("%02x", (unsigned)((hi << 4 | lo) ^ KEY_MASK));
    }
    putchar('\n');

    return 0;
}
