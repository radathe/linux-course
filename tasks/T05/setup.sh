#!/bin/bash
# Runtime-инициализация задачи T05 "Большой журнал".
#
# Генерируется server.log не менее чем из 2000 строк уровней
# INFO/WARN/ERROR.  Ровно одна строка содержит флаг и уровень ERROR.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{log_search}}"

HOME_DIR=/home/ctf
LOG="$HOME_DIR/server.log"

total=$((RANDOM % 1000 + 2000))      # 2000..2999 строк
flag_at=$((RANDOM % total + 1))      # позиция строки с флагом
base_ts=$(date -u +%s)

levels=(INFO WARN ERROR)
messages=(
    "обработка запроса /api/v1/users"
    "обработка запроса /api/v1/orders"
    "соединение установлено"
    "соединение закрыто"
    "кэш обновлён"
    "запись сохранена"
    "плановое обслуживание"
    "повторная попытка подключения"
    "проверка целостности завершена"
    "таймаут ожидания ответа"
)

tmp="$(mktemp)"
for i in $(seq 1 "$total"); do
    ts=$(date -u -d "@$((base_ts + i))" '+%Y-%m-%d %H:%M:%S')
    if [ "$i" -eq "$flag_at" ]; then
        printf '%s [ERROR] %s\n' "$ts" "$TASK_FLAG"
    else
        lvl=${levels[RANDOM % ${#levels[@]}]}
        msg=${messages[RANDOM % ${#messages[@]}]}
        printf '%s [%s] %s\n' "$ts" "$lvl" "$msg"
    fi
done > "$tmp"

mv "$tmp" "$LOG"
chown ctf:ctf "$LOG"
chmod 0644 "$LOG"
