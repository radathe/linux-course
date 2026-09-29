#!/bin/bash
# Runtime-инициализация итоговой задачи T26 "Маленький Linux CTF".
#
# Флаг собирается из восьми фрагментов:
#   part1 flag{    -- /opt/data/.part1
#   part2 linux_   -- глубоко вложенное дерево, part2.txt
#   part3 ctf_     -- /opt/backup.tar, part3.txt
#   part4 basics_  -- /opt/backup.tar, encoded.txt (hex)
#   part5 are_     -- патчится в /opt/tools/checker
#   part6 easier_  -- аргумент процесса /opt/worker (start-services.sh)
#   part7 together_ -- окружение процесса /opt/worker (start-services.sh)
#   part8 ok}      -- TCP-сервис 127.0.0.1:31337 (start-services.sh)
set -euo pipefail

PART1='flag{'
PART2='linux_'
PART3='ctf_'
PART4='basics_'

DATA=/opt/data
rm -rf "$DATA"
mkdir -p "$DATA"

# --- part1: подсказка и скрытый файл рядом с ней ---
cat > "$DATA/README" <<'EOF'
Добро пожаловать в итоговую задачу курса!

Флаг собран из нескольких фрагментов и разбросан по системе.
Первый фрагмент спрятан рядом с этим файлом, но обычный просмотр
каталога может его не показать — обратите внимание на скрытые имена.
EOF
printf '%s\n' "$PART1" > "$DATA/.part1"

# --- part2: глубоко вложенное дерево каталогов + подсказка про архив ---
DEEP="$DATA/deep/level1/level2/level3/level4/level5"
mkdir -p "$DEEP"
cat > "$DEEP/part2.txt" <<EOF
$PART2

Второй фрагмент найден.
Дальше пригодится резервная копия: рядом лежит архив с именем backup,
внутри него ещё два фрагмента.
EOF

# --- part3/part4: архив backup ---
tmp="$(mktemp -d)"
printf '%s\n' "$PART3" > "$tmp/part3.txt"
printf '%s' "$PART4" | xxd -p | tr -d '\n' > "$tmp/encoded.txt"
printf '\n' >> "$tmp/encoded.txt"
tar -C "$tmp" -cf /opt/backup.tar part3.txt encoded.txt
rm -rf "$tmp"

chmod -R a+rX "$DATA"
chmod 0644 /opt/backup.tar
chmod 0755 /opt

# --- part5: внедряем фрагмент в бинарник check26 ---
/usr/local/bin/patch_flag.py \
    'flag{PLACEHOLDER_DO_NOT_SHIP}' 'are_' /opt/tools/checker
chmod 0755 /opt/tools/checker /opt/worker

chown -R root:root "$DATA" /opt/backup.tar /opt/tools/checker /opt/worker
