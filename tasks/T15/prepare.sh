#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T15 "Где настоящий вывод?".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
mkdir -p "$STAGE/opt"

# Генерируем зашифрованный флаг и получаем случайный ключ (32 hex-символа).
key="$(ctf-make-challenge 'SSL{stderr_is_a_stream}' "$STAGE")"

# Компилируем check, подставляя ключ открытым текстом.  Программа печатает
# обычные сообщения в stdout, а ключ -- в stderr.
sed "s/@KEY@/$key/" /src/check.c > /tmp/check.c
gcc -O0 -Wall -Wextra -o "$STAGE/opt/check" /tmp/check.c

# Ненавязчивая подсказка студенту.
cat > "$STAGE/home/ctf/hint.txt" <<'EOF'
У программы бывает несколько потоков вывода.  Не всё, что она печатает,
попадает туда, куда вы смотрите по умолчанию.
EOF

# Права и владельцы.  check -- execute-only (0111): запускать можно,
# читать (cat/strings) нельзя.  Поэтому здесь НЕТ chmod -R a+rX.
chown root:root "$STAGE/opt/check"
chmod 0111 "$STAGE/opt/check"
chown -R ctf:ctf "$STAGE/home/ctf"
