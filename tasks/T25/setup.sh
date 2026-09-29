#!/bin/bash
# Runtime-инициализация задачи T25 "Неправильный заголовок".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{custom_headers}}"

cat > /home/ctf/README.txt <<'EOF'
На этой машине запущен веб-сервис со страницей администратора.

Обычный запрос к ней отклоняется: серверу не нравится какой-то
заголовок запроса.  Внимательно читайте не только тело ответа,
но и его заголовки.
EOF

chown ctf:ctf /home/ctf/README.txt
chmod 0644 /home/ctf/README.txt

touch /var/log/task.log
chmod 0644 /var/log/task.log

: "$TASK_FLAG"
