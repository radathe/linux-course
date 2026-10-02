#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T05 "Большой журнал".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"

# Генерируем зашифрованный флаг и получаем случайный ключ (hex, 32 символа).
key="$(ctf-make-challenge 'SSL{log_search}' "$STAGE")"

# Не менее 2000 строк; ровно одна строка "[ERROR] <ключ>" в случайной позиции.
total=$((2000 + RANDOM % 500))        # 2000..2499 строк
real_at=$((1 + RANDOM % total))
levels=(INFO WARN ERROR)

{
    for i in $(seq 1 "$total"); do
        if [ "$i" -eq "$real_at" ]; then
            echo "[ERROR] $key"
        else
            lvl="${levels[$((RANDOM % ${#levels[@]}))]}"
            printf '[%s] request #%d handled by worker, status=%d\n' \
                "$lvl" "$i" "$((RANDOM % 500))"
        fi
    done
} > "$HOME_DIR/server.log"

# Права и владельцы.
chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
