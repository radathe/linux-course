/*
 * check -- задача T15 "Где настоящий вывод?".
 *
 * Обычные сообщения идут в stdout, ключ -- в stderr.  Файл ставится с
 * правами 0111 (execute-only), поэтому strings(1)/cat(1) ключ не видят.
 */
#include <stdio.h>

static const char key[] = "@KEY@";

int main(void)
{
    printf("Checking system...\n");
    printf("No problems found.\n");
    fprintf(stderr, "%s\n", key);

    return 0;
}
