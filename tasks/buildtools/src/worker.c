/*
 * worker -- долгоживущий процесс-пустышка для задачи T14.
 *
 * Просто спит, чтобы его можно было изучить через ps(1), pgrep(1) и
 * /proc.  Имя процесса совпадает с именем файла (worker).
 */
#include <unistd.h>

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    for (;;)
        sleep(3600);

    return 0;
}
