#!/bin/bash
# Runtime-инициализация задачи T09 "Чужой файл".
#
# Файл /opt/data/secret.txt принадлежит root:analysts и доступен только
# на чтение группе analysts. Пользователь ctf добавлен в эту группу, поэтому
# читает файл без повышения привилегий.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{groups_matter}}"

DATA=/opt/data

# --- 1. Группа analysts и членство ctf в ней ----------------------------
groupadd -f analysts
usermod -aG analysts ctf

# Проверяем, что ctf действительно состоит в группе.
if ! id -Gn ctf | tr ' ' '\n' | grep -qx analysts; then
    printf 'T09: пользователь ctf не добавлен в группу analysts\n' >&2
    exit 1
fi

# --- 2. Файл с флагом: root:analysts, права 640 -------------------------
rm -rf "$DATA"
mkdir -p "$DATA"

printf 'Служебная записка отдела аналитики.\nФлаг: %s\n' "$TASK_FLAG" > "$DATA/secret.txt"
chown root:analysts "$DATA/secret.txt"
chmod 0640 "$DATA/secret.txt"

# --- 3. Отвлекающие файлы, доступные всем -------------------------------
printf 'Черновик отчёта. Ничего секретного.\n' > "$DATA/draft.txt"
printf 'Список задач на неделю.\n' > "$DATA/todo.txt"
printf 'Публичная статистика: 42.\n' > "$DATA/stats.txt"
chown root:root "$DATA/draft.txt" "$DATA/todo.txt" "$DATA/stats.txt"
chmod 0644 "$DATA/draft.txt" "$DATA/todo.txt" "$DATA/stats.txt"

# Сам каталог должен позволять вход и чтение имён файлов.
chown root:root "$DATA"
chmod 0755 "$DATA"
