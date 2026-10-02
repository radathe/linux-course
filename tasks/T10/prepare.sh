#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T10 "Что внутри?".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"

# Генерируем зашифрованный флаг и получаем случайный ключ.
key="$(ctf-make-challenge 'SSL{zip_basics}' "$STAGE")"

mkdir -p "$HOME_DIR"

# Собираем архив во временном каталоге, чтобы внутри лежали короткие
# относительные имена (notes.txt, todo.txt, key.txt).
work="$(mktemp -d)"
cat > "$work/notes.txt" <<'EOF'
Заметки о резервном копировании
===============================
Копии снимаются раз в сутки и складываются сюда.
EOF

cat > "$work/todo.txt" <<'EOF'
Сделать:
- проверить свободное место
- удалить старые копии
EOF

# Ключ — внутри архива, в файле key.txt.
cat > "$work/key.txt" <<EOF
Ключ для расшифровки:

$key
EOF

( cd "$work" && zip -q "$HOME_DIR/backup.zip" notes.txt todo.txt key.txt )
rm -rf "$work"

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
