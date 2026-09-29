#!/bin/bash
# Запуск фоновых процессов задачи T19 "Что здесь работает?".
#
# Несколько одинаковых процессов /opt/worker запускаются с разными
# аргументами; у одного из них в аргументах есть флаг. Процессы
# работают от имени ctf, чтобы студент мог читать их командные строки
# через ps(1) и pgrep(1).
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{process_argument}}"

LOG=/var/log/task.log
touch "$LOG"

runuser -u ctf -- nohup /opt/worker --mode backup --secret "$TASK_FLAG" \
    >>"$LOG" 2>&1 &
runuser -u ctf -- nohup /opt/worker --mode backup \
    >>"$LOG" 2>&1 &
runuser -u ctf -- nohup /opt/worker --mode test \
    >>"$LOG" 2>&1 &

# Дать процессам появиться в таблице процессов.
sleep 1
