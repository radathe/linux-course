#!/bin/bash
# Runtime-инициализация задачи T13 "Hex or Base64?".
#
# message.txt содержит hex-строку. Внутри hex -- текст
# "The flag is: <base64(флаг)>". Декодируется в два шага.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{hex_and_base64}}"

HOME_DIR=/home/ctf
OUT="$HOME_DIR/message.txt"

# 1. Base64 от флага (без переводов строк).
b64="$(printf '%s' "$TASK_FLAG" | base64 -w0)"

# 2. Человекочитаемый текст, который затем кодируем в hex.
text="The flag is: $b64"

# 3. hex-строка в файл.
printf '%s' "$text" | xxd -p | tr -d '\n' > "$OUT"
printf '\n' >> "$OUT"

chown ctf:ctf "$OUT"
chmod 0644 "$OUT"
