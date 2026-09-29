#!/bin/bash
# Runtime-инициализация задачи T24 "Исследуй веб-сервис".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{curl_basics}}"

cat > /home/ctf/README.txt <<'EOF'
На этой машине запущен небольшой веб-сервис.

Он слушает только локальный адрес, поэтому обратиться к нему можно
прямо из контейнера.  Изучите его ответы и найдите флаг.

Подсказка: один из запросов приведёт к перенаправлению.
EOF

chown ctf:ctf /home/ctf/README.txt
chmod 0644 /home/ctf/README.txt

# Общий лог сервисов задачи.
touch /var/log/task.log
chmod 0644 /var/log/task.log

# Флаг сервису передаётся через окружение в start-services.sh.
# Значение по умолчанию дублируем здесь для наглядности.
: "$TASK_FLAG"
