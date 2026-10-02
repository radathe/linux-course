#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T07 "Где лежит ключ?".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"
DATA="$STAGE/opt/data"

# Генерируем зашифрованный флаг и получаем случайный ключ.
key="$(ctf-make-challenge 'SSL{find_it}' "$STAGE")"

mkdir -p "$DATA/a" "$DATA/b" "$DATA/c/archive" "$DATA/d" "$HOME_DIR"

cat > "$DATA/a/note.txt" <<'EOF'
Заметка A
=========
Ничего важного: обычный список дел.
- купить хлеб
- помыть посуду
EOF

cat > "$DATA/b/old.txt" <<'EOF'
Старый черновик
===============
Здесь когда-то был пароль, но его давно стёрли.
EOF

# Ключ лежит в глубине дерева.
cat > "$DATA/c/archive/key.txt" <<EOF
Ключ для расшифровки:

$key
EOF

cat > "$DATA/d/readme.txt" <<'EOF'
Это каталог с данными. Ключ где-то рядом, но не в этом файле.
EOF

cat > "$HOME_DIR/hint.txt" <<'EOF'
Подсказка
=========
Ключ лежит НЕ в домашнем каталоге. Загляните в /opt.

Перебирать каталоги вручную не нужно — вам поможет поиск файлов
(например, команда find).
EOF

# Домашний каталог принадлежит ctf; /opt/data — системные данные.
chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"

chown -R root:root "$DATA"
chmod -R a+rX "$DATA"
