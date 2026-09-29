#!/bin/bash
# Запуск фоновых процессов задачи T20 "Секрет процесса".
#
# Все процессы выполняются от имени ctf: только так студент сможет
# прочитать /proc/<PID>/environ.  Секрет передаётся исключительно через
# переменную окружения SECRET и не попадает ни в аргументы (cmdline),
# ни в файлы, ни в готовый образ.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{environment_secret}}"

# Процессы-приманки: работают от имени ctf, но без секрета.
for _ in 1 2 3; do
    nohup runuser -u ctf -- /opt/worker >>/var/log/task.log 2>&1 &
done

# Настоящий процесс: SECRET попадает только в окружение процесса.
nohup runuser -u ctf -- env SECRET="$TASK_FLAG" /opt/worker \
    >>/var/log/task.log 2>&1 &

# Дать процессам время появиться в таблице процессов.
sleep 1
