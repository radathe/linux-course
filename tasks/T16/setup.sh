#!/bin/bash
# Runtime-инициализация задачи T16 "Странная программа".
#
# В бинарник /home/ctf/checker на этапе сборки зашит только плейсхолдер;
# реальный флаг внедряется здесь во время запуска контейнера.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{simple_reverse}}"

HOME_DIR=/home/ctf
BIN="$HOME_DIR/checker"

/usr/local/bin/patch_flag.py \
    'flag{PLACEHOLDER_DO_NOT_SHIP}' "$TASK_FLAG" "$BIN"

chown ctf:ctf "$BIN"
chmod 0755 "$BIN"
