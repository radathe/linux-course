#!/bin/bash
# Runtime-инициализация задачи T01 "Осмотр комнаты".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{first_linux_steps}}"

HOME_DIR=/home/ctf
DOCS="$HOME_DIR/Documents"
DOWNLOADS="$HOME_DIR/Downloads"

rm -rf "$DOCS" "$DOWNLOADS"
mkdir -p "$DOCS" "$DOWNLOADS"

cat > "$DOCS/welcome.txt" <<'EOF'
Добро пожаловать на учебную Linux-машину!

Осмотритесь: узнайте, где вы находитесь и что вас окружает.
Полезные команды: pwd, ls, cd, cat.
EOF

cat > "$DOCS/notes.txt" <<EOF
Мои заметки
===========

Сегодня разбираемся с навигацией по файловой системе.
Домашний каталог, относительные и абсолютные пути, скрытые файлы.

$TASK_FLAG
EOF

cat > "$DOWNLOADS/image.txt" <<'EOF'
placeholder: здесь могло бы быть изображение.
Ничего интересного нет.
EOF

cat > "$HOME_DIR/readme.txt" <<'EOF'
Это домашний каталог пользователя ctf.
Флаг где-то рядом, но точно не в этом файле.
EOF

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
