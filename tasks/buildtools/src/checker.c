/*
 * checker -- задача T13 "Странная программа".
 *
 * Пароль виден через strings(1).  Ключ в открытом виде не хранится:
 * он зашит в XOR-виде и печатается только при верном пароле.
 */
#include <stdio.h>
#include <string.h>

#define KEY_MASK 0x5A

static const char key_enc[] = "@KEY@";
static const char password[] = "open-sesame";
static const char hint[] = "Correct password: open-sesame";

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

/* key_enc -- hex от (ключ ^ 0x5A): разбираем по байту, снимаем XOR и
 * печатаем исходный ключ снова в hex-виде. */
static void print_key(void)
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
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        printf("Usage: %s <password>\n", argv[0]);
        return 1;
    }

    if (argc > 100)
        puts(hint);

    if (strcmp(argv[1], password) == 0) {
        puts("Access granted!");
        print_key();
        return 0;
    }

    puts("Access denied");
    return 1;
}
