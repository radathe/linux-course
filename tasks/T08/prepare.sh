#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи T08 "Чужой файл".
#
# Выполняется на этапе сборки в builder-stage.  Готовит файлы в /stage,
# откуда они копируются в финальный образ.  В контейнере этого скрипта нет.
set -euo pipefail

STAGE="${STAGE:-/stage}"
HOME_DIR="$STAGE/home/ctf"
DATA="$STAGE/opt/data"

# Группа с ФИКСИРОВАННЫМ GID: тот же GID создаётся в финальном образе,
# иначе владелец secret.txt не отобразился бы как root:analysts.
groupadd -g 2000 -f analysts

# Генерируем зашифрованный флаг и получаем случайный ключ.
key="$(ctf-make-challenge 'SSL{groups_matter}' "$STAGE")"

mkdir -p "$DATA" "$HOME_DIR"

# Ключ лежит в файле, доступном только группе analysts.
cat > "$DATA/secret.txt" <<EOF
$key
EOF

cat > "$DATA/draft.txt" <<'EOF'
Черновик отчёта. Ничего секретного.
EOF

cat > "$DATA/todo.txt" <<'EOF'
Список дел:
- проверить права доступа
- разобраться с группами
EOF

cat > "$DATA/stats.txt" <<'EOF'
Статистика за неделю: 42, 17, 256, 8.
EOF

cat > "$HOME_DIR/hint.txt" <<'EOF'
Подсказка
=========
Файл /opt/data/secret.txt вам не принадлежит, но читать его
разрешено некоторой группе.

Посмотрите владельца и права файла, затем проверьте, в каких
группах вы состоите. Возможно, группу нужно активировать в текущей
сессии.
EOF

# Секретный файл: root:analysts, 640 (чтение владельцу и группе).
chown root:analysts "$DATA/secret.txt"
chmod 640 "$DATA/secret.txt"

# Отвлекающие файлы доступны всем.
chown root:root "$DATA/draft.txt" "$DATA/todo.txt" "$DATA/stats.txt"
chmod 644 "$DATA/draft.txt" "$DATA/todo.txt" "$DATA/stats.txt"
chmod 755 "$DATA"

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
