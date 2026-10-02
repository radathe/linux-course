#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T01 "Осмотр комнаты".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"

# Генерируем зашифрованный флаг и получаем случайный ключ.
key="$(ctf-make-challenge 'SSL{first_linux_steps}' "$STAGE")"

mkdir -p "$HOME_DIR/Documents" "$HOME_DIR/Downloads"

cat > "$HOME_DIR/Documents/welcome.txt" <<'EOF'
Добро пожаловать на учебную Linux-машину!

Осмотритесь: узнайте, где вы находитесь и что вас окружает.
Полезные команды: pwd, ls, cd, cat.
EOF

cat > "$HOME_DIR/Documents/notes.txt" <<EOF
Мои заметки
===========

Сегодня разбираемся с навигацией по файловой системе.

Ключ для расшифровки лежит здесь:

$key
EOF

cat > "$HOME_DIR/Downloads/image.txt" <<'EOF'
placeholder: здесь могло бы быть изображение.
Ничего интересного нет.
EOF

cat > "$HOME_DIR/readme.txt" <<'EOF'
Это домашний каталог пользователя ctf.
Ключ где-то рядом, но не в этом файле.
EOF

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
