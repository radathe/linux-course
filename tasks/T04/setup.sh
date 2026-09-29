#!/bin/bash
# Runtime-инициализация задачи T04 "Нужная строка".
#
# Генерируется notes.txt из 60-90 отвлекающих строк.  Среди них ровно
# одна строка с флагом (password=flag{...}) и одна ложная строка про
# ротацию паролей, чтобы показать разницу между grep и grep -i.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{grep_basics}}"

HOME_DIR=/home/ctf
NOTES="$HOME_DIR/notes.txt"

total=$((RANDOM % 31 + 60))          # 60..90 отвлекающих строк
flag_at=$((RANDOM % total + 1))      # позиция строки с флагом
false_at=$((RANDOM % total + 1))     # позиция ложной строки
while [ "$false_at" -eq "$flag_at" ]; do
    false_at=$((RANDOM % total + 1))
done

tmp="$(mktemp)"
for i in $(seq 1 "$total"); do
    if [ "$i" -eq "$flag_at" ]; then
        printf 'password=%s\n' "$TASK_FLAG"
    elif [ "$i" -eq "$false_at" ]; then
        printf 'Password rotation: 30 days\n'
    else
        printf 'Заметка №%d: очередная строка для тренировки поиска.\n' "$i"
    fi
done > "$tmp"

mv "$tmp" "$NOTES"
chown ctf:ctf "$NOTES"
chmod 0644 "$NOTES"
