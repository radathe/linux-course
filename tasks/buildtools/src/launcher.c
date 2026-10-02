/*
 * launcher -- запуск фоновых процессов задачи T14.
 *
 * Читает ключ из /opt/.worker_key (доступен только root), запускает
 * процессы /opt/worker от имени ctf.  У одного из них ключ попадает в
 * аргументы командной строки -- его и должен найти студент.  Сам
 * launcher ключа не содержит.
 */
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define CTF_UID 1000
#define CTF_GID 1000

static void spawn(char *const argv[])
{
    pid_t pid = fork();

    if (pid == 0) {
        setsid();
        if (setgid(CTF_GID) != 0)
            _exit(126);
        if (setuid(CTF_UID) != 0)
            _exit(126);
        execv("/opt/worker", argv);
        _exit(127);
    }
}

int main(void)
{
    char key[256] = "";
    FILE *fh = fopen("/opt/.worker_key", "r");

    if (fh != NULL) {
        if (fgets(key, sizeof key, fh) != NULL)
            key[strcspn(key, "\n")] = '\0';
        fclose(fh);
    }

    if (key[0] != '\0') {
        char *args[] = {"/opt/worker", "--mode", "backup", "--secret", key, NULL};
        spawn(args);
    }

    char *backup[] = {"/opt/worker", "--mode", "backup", NULL};
    char *test[] = {"/opt/worker", "--mode", "test", NULL};
    spawn(backup);
    spawn(test);

    return 0;
}
