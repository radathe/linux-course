#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T06 "Лишние данные".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"

# Генерируем зашифрованный флаг и получаем случайный ключ (hex, 32 символа).
key="$(ctf-make-challenge 'SSL{text_pipeline}' "$STAGE")"

roles=(admin user guest developer operator auditor analyst)

# Реальные имена и приманки, похожие на флаг.  ВНИМАНИЕ: ни одна приманка
# не должна содержать подстроку "SSL{".
names=(
    alice bob carol dave erin frank grace heidi ivan judy
    mallory niaj oscar peggy trent victor walter zoe
    'SLS{secret}' 'ssl{secret}' 'SSl{secret}' 'SSL[secret]'
    'SSL(secret)' 'SSL-Secret' 'S5L{secret}' 'SSl{SeCreT}'
    'SSL_secret' 'ssL{secret}' 'SL5{secret}'
)

pool=()
for n in "${names[@]}"; do
    for r in "${roles[@]}"; do
        pool+=("$n:$r")
    done
done

# 250-400 строк; ключ добавляется ровно один раз как «имя».
total=$((250 + RANDOM % 151))
key_at=$((1 + RANDOM % total))

{
    for i in $(seq 1 "$total"); do
        if [ "$i" -eq "$key_at" ]; then
            echo "$key:service"
        else
            echo "${pool[$((RANDOM % ${#pool[@]}))]}"
        fi
    done
} > "$HOME_DIR/users.txt"

# Права и владельцы.
chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
