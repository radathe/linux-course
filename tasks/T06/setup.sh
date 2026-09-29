#!/bin/bash
# Runtime-инициализация задачи T06 "Лишние данные".
#
# Генерируется users.txt со строками "имя:роль".  Часть имён повторяется,
# одно из имён -- сам флаг, поэтому после cut | sort | uniq он попадает
# в итоговый список уникальных имён.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{text_pipeline}}"

HOME_DIR=/home/ctf
USERS="$HOME_DIR/users.txt"

names=(alice bob carol dave erin frank grace heidi ivan judy mallory oscar peggy trent victor walter)
roles=(admin user guest developer operator readonly)

total=$((RANDOM % 41 + 60))          # 60..100 строк
flag_at=$((RANDOM % total + 1))      # позиция строки с флагом-именем

tmp="$(mktemp)"
for i in $(seq 1 "$total"); do
    if [ "$i" -eq "$flag_at" ]; then
        printf '%s:admin\n' "$TASK_FLAG"
    else
        n=${names[RANDOM % ${#names[@]}]}
        r=${roles[RANDOM % ${#roles[@]}]}
        printf '%s:%s\n' "$n" "$r"
    fi
done > "$tmp"

mv "$tmp" "$USERS"
chown ctf:ctf "$USERS"
chmod 0644 "$USERS"
