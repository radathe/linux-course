#!/bin/bash
# Runtime-инициализация задачи T21 "Где настоящий вывод?".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{stderr_is_a_stream}}"

# Утилита диагностики.  Обычные сообщения идут в stdout, а флаг —
# в stderr.  На экране без перенаправления потоки сливаются, поэтому
# нужно разделить их самостоятельно.
cat > /opt/check <<EOF
#!/bin/bash
# Проверка состояния системы.
echo "Checking system..."
echo "No problems found."
echo "$TASK_FLAG" >&2
EOF

chmod 0755 /opt/check
chown ctf:ctf /opt/check
