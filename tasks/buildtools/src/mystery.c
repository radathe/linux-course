/*
 * mystery -- задача T12 "Что это вообще?".
 *
 * Ключ лежит в бинарнике открытым текстом: его находят через strings(1).
 * Компилируется с -O0, чтобы компилятор не свернул строки в константы.
 */
#include <stdio.h>

static const char key[] = "@KEY@";
static const char decoy_one[] = "SLS{this_is_a_decoy}";
static const char decoy_two[] = "debug: build id 0xC0FFEE";

int main(int argc, char **argv)
{
    puts("mystery: обычная программа. Кажется, здесь нечего искать.");

    if (argc > 1000) {
        puts(key);
        puts(decoy_one);
        puts(decoy_two);
    }

    (void)argv;
    return 0;
}
