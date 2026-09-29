#!/bin/bash
# Runtime-инициализация задачи T20 "Секрет процесса".
set -euo pipefail

HOME_DIR=/home/ctf

# Бинарник worker из образа инструментов должен быть исполняемым.
chmod 0755 /opt/worker

cat > "$HOME_DIR/README.txt" <<'EOF'
Задача: Секрет процесса
=======================

В системе работает несколько процессов worker.
У одного из них в окружении есть секрет — это и есть флаг.

Изучите список процессов и переменные окружения:
    ps aux
    pgrep -a worker
    tr '\0' '\n' < /proc/<PID>/environ

Обратите внимание: содержимое /proc/<PID>/environ доступно только
владельцу процесса.
EOF

chown ctf:ctf "$HOME_DIR/README.txt"
chmod 0644 "$HOME_DIR/README.txt"
