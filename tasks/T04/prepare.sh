#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T04 "Нужная строка".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"

# Генерируем зашифрованный флаг и получаем случайный ключ (hex, 32 символа).
key="$(ctf-make-challenge 'SSL{grep_basics}' "$STAGE")"

# 60-90 отвлекающих строк + ровно одна строка с ключом и одна ложная.
total=$((62 + RANDOM % 31))          # всего строк: 62..92
real_at=$((1 + RANDOM % total))       # позиция строки "password=<ключ>"
false_at=$((1 + RANDOM % total))      # позиция ложной строки
while [ "$false_at" -eq "$real_at" ]; do
    false_at=$((1 + RANDOM % total))
done

{
    echo "Служебные заметки"
    echo "================="
    echo
    for i in $(seq 1 "$total"); do
        if [ "$i" -eq "$real_at" ]; then
            echo "password=$key"
        elif [ "$i" -eq "$false_at" ]; then
            echo "Password rotation: 30 days"
        else
            echo "запись $i: обычная строка, ничего интересного"
        fi
    done
} > "$HOME_DIR/notes.txt"

# Права и владельцы.
chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
