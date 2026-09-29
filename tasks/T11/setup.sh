#!/bin/bash
# Runtime-инициализация задачи T11 "Что внутри?".
#
# /home/ctf/backup.zip -- обычный zip-архив, внутри которого лежит флаг.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{zip_basics}}"

HOME_DIR=/home/ctf
ARCHIVE="$HOME_DIR/backup.zip"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

printf 'Это резервная копия рабочих заметок.\n' > "$work/notes.txt"
printf 'Список дел:\n- разобрать архив\n- найти флаг\n' > "$work/todo.txt"
printf 'Поздравляю, архив вскрыт!\nФлаг: %s\n' "$TASK_FLAG" > "$work/flag.txt"

rm -f "$ARCHIVE"
( cd "$work" && zip -q "$ARCHIVE" notes.txt todo.txt flag.txt )

chown ctf:ctf "$ARCHIVE"
chmod 0644 "$ARCHIVE"
