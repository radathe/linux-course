#!/bin/bash
# Runtime-инициализация задачи T03 "Запутанный путь".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{relative_paths}}"

HOME_DIR=/home/ctf
WORK="$HOME_DIR/work"
SECRET="$HOME_DIR/secret"
LOGS="$WORK/logs"

rm -rf "$WORK" "$SECRET"
mkdir -p "$LOGS" "$SECRET"

cat > "$SECRET/flag.txt" <<EOF
$TASK_FLAG
EOF

cat > "$WORK/current.txt" <<'EOF'
Текущая задача
==============

Вы находитесь в рабочем каталоге.
Нужные данные лежат в соседнем каталоге, а не в этом файле.
EOF

cat > "$LOGS/old.log" <<'EOF'
2024-01-01 09:00:00 INFO  запуск обработки
2024-01-01 09:00:01 WARN  обнаружена устаревшая запись
2024-01-01 09:00:02 INFO  обработка завершена
EOF

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
