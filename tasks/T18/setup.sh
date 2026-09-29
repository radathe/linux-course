#!/bin/bash
# Runtime-инициализация задачи T18 "Автоматизируй поиск".
#
# Создаём каталог с сотней текстовых файлов. Ровно в одном из них
# (выбирается случайно) есть строка TARGET и флаг.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{automation}}"

DATA_DIR=/opt/data

rm -rf "$DATA_DIR"
mkdir -p "$DATA_DIR"

target=$(( (RANDOM % 100) + 1 ))

for i in $(seq 1 100); do
    file=$(printf '%s/file_%03d.txt' "$DATA_DIR" "$i")

    if [ "$i" -eq "$target" ]; then
        cat > "$file" <<EOF
Отчёт №$i
Отдел: архив
Статус: обработано

TARGET
$TASK_FLAG
EOF
    else
        cat > "$file" <<EOF
Отчёт №$i
Отдел: архив
Статус: обработано

Обычная запись, искать здесь нечего.
EOF
    fi
done

# Данные доступны только на чтение.
chown -R root:root "$DATA_DIR"
chmod 0755 "$DATA_DIR"
chmod 0644 "$DATA_DIR"/*.txt
