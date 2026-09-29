#!/bin/bash
# Runtime-инициализация задачи T07 "Где лежит флаг?".
#
# В /opt/data создаётся дерево каталогов; флаг лежит в одном из них,
# остальные файлы -- отвлекающий текст.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{find_it}}"

DATA=/opt/data

rm -rf "$DATA"
mkdir -p "$DATA/a" "$DATA/b" "$DATA/c/archive" "$DATA/d"

cat > "$DATA/a/note.txt" <<'EOF'
Заметка
=======

Здесь лежат только черновики.
Флага в этом файле нет.
EOF

cat > "$DATA/b/old.txt" <<'EOF'
Старый файл
===========

Содержимое устарело и больше не используется.
EOF

cat > "$DATA/c/archive/flag.txt" <<EOF
$TASK_FLAG
EOF

cat > "$DATA/d/readme.txt" <<'EOF'
Прочитай меня
=============

Это отвлекающий файл.
Попробуй поискать по имени, а не перебирать каталоги вручную.
EOF

chown -R ctf:ctf "$DATA"
chmod -R a+rX "$DATA"
