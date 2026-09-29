#!/bin/bash
# Runtime-инициализация задачи T14 "Испорченное сообщение".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{base64_secret}}"

HOME_DIR=/home/ctf

# Сообщение кодируется в текстовое представление, чтобы студент
# восстановил исходную строку и нашёл в ней флаг.
printf '%s' "SECRET:password=${TASK_FLAG}" \
    | base64 -w 0 > "$HOME_DIR/message.txt"

printf '\n' >> "$HOME_DIR/message.txt"

chown ctf:ctf "$HOME_DIR/message.txt"
chmod 0644 "$HOME_DIR/message.txt"
