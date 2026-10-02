#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T09 "Запусти программу".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"

# Генерируем зашифрованный флаг и получаем случайный ключ.
key="$(ctf-make-challenge 'SSL{execution_permission}' "$STAGE")"

mkdir -p "$STAGE/opt" "$HOME_DIR"

# Ключ зашиваем в программу в XOR-виде: strings(1) его не покажет.
# Компилируем с -O0, чтобы компилятор не свернул строку в константу.
enc="$(ctf-xor "$key" 5A)"
sed "s/@KEY@/$enc/" /src/runme.c > /tmp/runme.c
gcc -O0 -Wall -Wextra -o "$STAGE/opt/runme" /tmp/runme.c

# Программа принадлежит студенту, но прав нет вовсе: ни чтения, ни
# выполнения.  chmod -R a+rX ниже на /opt не распространяется.
chown ctf:ctf "$STAGE/opt/runme"
chmod 0000 "$STAGE/opt/runme"
chmod 0755 "$STAGE/opt"

cat > "$HOME_DIR/hint.txt" <<'EOF'
Подсказка
=========
Ключ печатает программа в /opt, но у неё сейчас нет прав на запуск.

Посмотрите на её права и подумайте, кто владелец файла: возможно,
право можно выдать себе самому.
EOF

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
