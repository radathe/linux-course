#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T13 "Странная программа".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"

# Генерируем зашифрованный флаг и получаем случайный ключ (32 hex-символа).
key="$(ctf-make-challenge 'SSL{simple_reverse}' "$STAGE")"

# Ключ зашиваем в программу в XOR-виде: strings(1) его не покажет.
# ctf-xor маскирует байты ключа, checker.c разбирает hex и печатает ключ.
enc="$(ctf-xor "$key" 5A)"
sed "s/@KEY@/$enc/" /src/checker.c > /tmp/checker.c
gcc -O0 -Wall -Wextra -o "$STAGE/home/ctf/checker" /tmp/checker.c

# Права и владельцы.
chown ctf:ctf "$STAGE/home/ctf/checker"
chmod 0755 "$STAGE/home/ctf/checker"
chown -R ctf:ctf "$STAGE/home/ctf"
