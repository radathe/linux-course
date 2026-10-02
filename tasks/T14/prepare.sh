#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T14 "Что здесь работает?".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
mkdir -p "$STAGE/opt"

# Генерируем зашифрованный флаг и получаем случайный ключ (32 hex-символа).
key="$(ctf-make-challenge 'SSL{process_argument}' "$STAGE")"

# Компилируем worker и launcher.  Launcher на старте контейнера читает
# ключ из /opt/.worker_key и запускает worker от имени ctf, передавая
# ключ одним из аргументов командной строки.
gcc -O0 -Wall -Wextra -o "$STAGE/opt/worker" /src/worker.c
gcc -O0 -Wall -Wextra -o "$STAGE/opt/start"  /src/launcher.c

# Ключ в отдельном файле, который прочитает только root (launcher).
printf '%s\n' "$key" > "$STAGE/opt/.worker_key"

# Ненавязчивая подсказка студенту.
cat > "$STAGE/home/ctf/hint.txt" <<'EOF'
Иногда секреты не лежат в файлах.  Загляните в список запущенных
процессов: у некоторых программ параметры видны целиком.
EOF

# Права и владельцы.
chown root:root "$STAGE/opt/worker" "$STAGE/opt/start" "$STAGE/opt/.worker_key"
chmod 0755 "$STAGE/opt/worker" "$STAGE/opt/start"
chmod 0400 "$STAGE/opt/.worker_key"
chown -R ctf:ctf "$STAGE/home/ctf"
