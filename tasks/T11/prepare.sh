#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T11 "Испорченное сообщение".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"

# Генерируем зашифрованный флаг и получаем случайный ключ.
key="$(ctf-make-challenge 'SSL{base64_secret}' "$STAGE")"

mkdir -p "$HOME_DIR"

# Ключ кодируем в текстовый вид одной строкой (base64 от hex-строки).
printf '%s' "$key" | base64 > "$HOME_DIR/message.txt"

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
