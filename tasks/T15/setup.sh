#!/bin/bash
# Runtime-инициализация задачи T15 "Что это вообще?".
#
# В бинарник /home/ctf/mystery на этапе сборки зашит только плейсхолдер;
# реальный флаг внедряется здесь во время запуска контейнера.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{strings_are_useful}}"

HOME_DIR=/home/ctf
BIN="$HOME_DIR/mystery"

/usr/local/bin/patch_flag.py \
    'flag{PLACEHOLDER_DO_NOT_SHIP}' "$TASK_FLAG" "$BIN"

chown ctf:ctf "$BIN"
chmod 0755 "$BIN"
