/*
 * check26 -- часть 5 итоговой задачи T26.
 *
 * Строка "Correct code: ..." видна через strings.  При запуске с верным
 * кодом программа выводит очередной фрагмент флага.  Сам фрагмент
 * внедряется при запуске контейнера.
 */
#include <stdio.h>
#include <string.h>

static const char part_marker[] = "flag{PLACEHOLDER_DO_NOT_SHIP}";
static const char code[] = "unlock-42";

int main(int argc, char **argv)
{
    if (argc != 2) {
        printf("Usage: %s <code>\n", argv[0]);
        return 1;
    }

    if (strcmp(argv[1], code) == 0) {
        printf("Correct code: %s\n", part_marker);
        return 0;
    }

    puts("Wrong code");
    return 1;
}
