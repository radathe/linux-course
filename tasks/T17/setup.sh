#!/bin/bash
# Runtime-инициализация задачи T17 "Первый скрипт".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{bash_scripting}}"

HOME_DIR=/home/ctf

cat > "$HOME_DIR/secret.txt" <<EOF
Это файл с секретом. Не показывайте его содержимое никому.

$TASK_FLAG
EOF

chown ctf:ctf "$HOME_DIR/secret.txt"
chmod 0644 "$HOME_DIR/secret.txt"
