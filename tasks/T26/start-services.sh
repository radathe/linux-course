#!/bin/bash
# Запуск фоновых процессов и сервисов итоговой задачи T26.
set -euo pipefail

LOG=/var/log/task.log
touch "$LOG"
chmod 0644 "$LOG"

# --- part6: процесс worker с аргументом, содержащим фрагмент ---
runuser -u ctf -- /opt/worker --fragment easier_ >>"$LOG" 2>&1 &

# --- part7: процесс worker с переменной окружения, содержащей фрагмент ---
runuser -u ctf -- env SECRET=together_ /opt/worker >>"$LOG" 2>&1 &

# --- part8: TCP-сервис, отдающий последний фрагмент ---
nohup python3 /opt/server.py >>"$LOG" 2>&1 &

# Дать процессам и сервису время подняться.
sleep 1

exit 0
