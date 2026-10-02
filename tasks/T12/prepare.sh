#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T12 "Что это вообще?".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"

# Генерируем зашифрованный флаг и получаем случайный ключ (32 hex-символа).
key="$(ctf-make-challenge 'SSL{strings_are_useful}' "$STAGE")"

# Компилируем mystery, подставляя ключ открытым текстом.  Строка видна
# через strings(1); компилируем с -O0, чтобы компилятор её не свернул.
sed "s/@KEY@/$key/" /src/mystery.c > /tmp/mystery.c
gcc -O0 -Wall -Wextra -o "$STAGE/home/ctf/mystery" /tmp/mystery.c

# Права и владельцы.
chown ctf:ctf "$STAGE/home/ctf/mystery"
chmod 0755 "$STAGE/home/ctf/mystery"
chown -R ctf:ctf "$STAGE/home/ctf"
