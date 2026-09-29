#!/bin/bash
# Runtime-инициализация задачи T02 "Скрытая записка".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{hidden_note}}"

HOME_DIR=/home/ctf
DOCS="$HOME_DIR/Documents"
DOWNLOADS="$HOME_DIR/Downloads"

rm -rf "$DOCS" "$DOWNLOADS"
mkdir -p "$DOCS" "$DOWNLOADS"

cat > "$DOCS/report.txt" <<'EOF'
Отчёт по лабораторной работе
============================

Ход работы изложен в конспекте.
Итоговые измерения сведены в таблицу.
Ничего секретного здесь нет.
EOF

cat > "$DOCS/todo.txt" <<'EOF'
Список дел
==========

[ ] дочитать главу про файловую систему
[x] сделать лабораторную работу
[ ] разобрать каталоги
EOF

# Скрытый файл с настоящим флагом.
cat > "$DOCS/.secret" <<EOF
Служебная записка
=================

Этот файл не показывают при беглом осмотре каталога.

$TASK_FLAG
EOF

cat > "$DOWNLOADS/manual.txt" <<'EOF'
Краткое руководство
===================

Справку по любой команде можно получить так:

    man ls
    ls --help

Полный список файлов, включая скрытые, показывает ls -a.
EOF

cat > "$HOME_DIR/notes.txt" <<'EOF'
Личные заметки
==============

Иногда важное прячется там, куда не заглядывает беглый взгляд.
EOF

chown -R ctf:ctf "$HOME_DIR"
chmod -R a+rX "$HOME_DIR"
