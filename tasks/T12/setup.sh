#!/bin/bash
# Runtime-инициализация задачи T12 "Матрешка".
#
# /home/ctf/challenge -- это gzip(stage1.tar). Внутри stage1.tar лежит
# stage2.zip, внутри которого -- flag.txt.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{archives_in_archives}}"

HOME_DIR=/home/ctf
CHALLENGE="$HOME_DIR/challenge"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# --- Внутренний уровень: flag.txt -> stage2.zip -------------------------
mkdir -p "$work/inner"
printf 'Флаг: %s\n' "$TASK_FLAG" > "$work/inner/flag.txt"
( cd "$work/inner" && zip -q "$work/stage2.zip" flag.txt )

# --- Средний уровень: stage2.zip -> stage1.tar --------------------------
( cd "$work" && tar -cf stage1.tar stage2.zip )

# --- Внешний уровень: stage1.tar -> gzip -> challenge -------------------
rm -f "$CHALLENGE"
gzip -c "$work/stage1.tar" > "$CHALLENGE"

chown ctf:ctf "$CHALLENGE"
chmod 0644 "$CHALLENGE"
