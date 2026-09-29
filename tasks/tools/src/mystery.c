/*
 * mystery -- "неизвестный бинарник" для задачи T15.
 *
 * Реальный флаг внедряется при запуске контейнера: setup.sh заменяет
 * плейсхолдер ниже через patch_flag.py.  Плейсхолдер намеренно длиннее
 * любого используемого флага.
 */
#include <stdio.h>

static const char flag_marker[] = "flag{PLACEHOLDER_DO_NOT_SHIP}";

/* Приманки, чтобы вывод strings не был тривиальным ответом. */
static const char decoy_one[] = "flag{this_is_a_decoy_do_not_submit}";
static const char decoy_two[] = "debug: build id 0xC0FFEE";

int main(int argc, char **argv)
{
    puts("mystery: обычная программа. Кажется, здесь нечего искать.");

    if (argc > 1000) {
        /* Практически недостижимо; нужно, чтобы строки остались в бинарнике. */
        puts(flag_marker);
        puts(decoy_one);
        puts(decoy_two);
    }

    (void)argv;
    return 0;
}
