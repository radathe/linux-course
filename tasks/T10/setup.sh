#!/bin/bash
# Runtime-инициализация задачи T10 "Запусти программу".
#
# /opt/runme -- скрипт с флагом, принадлежит ctf:ctf, но без права на
# выполнение (права 644). Достаточно выдать право и запустить.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{execution_permission}}"

cat > /opt/runme <<EOF
#!/bin/bash
# Небольшая программа проверки. Просто печатает флаг.
echo "Проверка пройдена!"
echo "Флаг: $TASK_FLAG"
EOF

chown ctf:ctf /opt/runme
chmod 0644 /opt/runme
