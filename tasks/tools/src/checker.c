/*
 * checker -- задача T16.
 *
 * Пароль можно найти через `strings checker`, после чего запустить
 * программу с ним.  Флаг внедряется при запуске контейнера.
 */
#include <stdio.h>
#include <string.h>

static const char flag_marker[] = "flag{PLACEHOLDER_DO_NOT_SHIP}";
static const char password[] = "open-sesame";

/* Строка-подсказка, которую ожидает условие задачи. */
static const char hint[] = "Correct password: open-sesame";

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
        puts(flag_marker);
        return 0;
    }

    puts("Access denied");
    return 1;
}
