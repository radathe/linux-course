#!/bin/bash
# Runtime-инициализация задачи T08 "Большая уборка".
#
# В /opt/data лежит много мусора: десятки маленьких файлов разных типов,
# несколько больших бинарных файлов и большие текстовые файлы. Ровно один
# файл подходит под условие: .txt, размер больше 10 КБ и содержит TARGET.
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{find_cleanup}}"

DATA=/opt/data

rm -rf "$DATA"
mkdir -p "$DATA"

# --- 1. Множество маленьких файлов разных типов и расширений ------------
exts=(txt log conf ini cfg md csv json xml yaml bak tmp dat bin sh)

for i in $(seq 1 75); do
    ext="${exts[$(( (i - 1) % ${#exts[@]} ))]}"
    f="$DATA/file_$(printf '%03d' "$i").$ext"
    case "$ext" in
        txt)  printf 'Заметка №%d.\nПолезной информации здесь нет.\n' "$i" > "$f" ;;
        log)  printf '[%02d:00] service started\n[%02d:01] service stopped\n' "$i" "$i" > "$f" ;;
        conf) printf 'max_workers = %d\nlogging = off\n' "$i" > "$f" ;;
        ini)  printf '[section%d]\nkey = value%d\n' "$i" "$i" > "$f" ;;
        cfg)  printf 'setting_%d=disabled\n' "$i" > "$f" ;;
        md)   printf '# Заголовок %d\n\nНебольшая заметка без секретов.\n' "$i" > "$f" ;;
        csv)  printf 'id,name,value\n%d,item%d,%d\n' "$i" "$i" "$((i * 7))" > "$f" ;;
        json) printf '{"id": %d, "ok": true}\n' "$i" > "$f" ;;
        xml)  printf '<item id="%d"/>\n' "$i" > "$f" ;;
        yaml) printf 'id: %d\nenabled: false\n' "$i" > "$f" ;;
        bak)  printf 'резервная копия %d\n' "$i" > "$f" ;;
        tmp)  printf 'tmp-%d\n' "$i" > "$f" ;;
        dat)  head -c "$((i * 13))" /dev/urandom > "$f" ;;
        bin)  head -c "$((i * 17))" /dev/urandom > "$f" ;;
        sh)   printf '#!/bin/bash\necho "скрипт %d"\n' "$i" > "$f" ;;
    esac
done

# --- 2. Несколько больших бинарных файлов -------------------------------
for b in 1 2 3; do
    head -c 20000 /dev/urandom > "$DATA/big_binary_$b.bin"
done

# --- 3. Большие текстовые .txt, не содержащие TARGET --------------------
for t in 1 2; do
    f="$DATA/report_draft_$t.txt"
    : > "$f"
    for line in $(seq 1 400); do
        printf 'Строка отчёта %d: значения, цифры и прочий шум.\n' "$line" >> "$f"
    done
done

# --- 4. Единственный подходящий файл: .txt, > 10 КБ, содержит TARGET ----
target="$DATA/otchet_cleanup.txt"
{
    printf 'Отчёт по большой уборке\n'
    printf '========================\n\n'
    for line in $(seq 1 300); do
        printf 'Строка %d: рабочие данные без метки.\n' "$line"
    done
} > "$target"
# Гарантируем, что файл заметно больше 10 КБ, даже при коротком тексте.
while [ "$(wc -c < "$target")" -le 12000 ]; do
    printf 'Дополнительная строка отчёта для набора объёма.\n' >> "$target"
done
printf '\nTARGET\nФлаг: %s\n' "$TASK_FLAG" >> "$target"

# --- 5. Права: содержимое должны читать все -----------------------------
chown -R root:root "$DATA"
chmod 0755 "$DATA"
find "$DATA" -type f -exec chmod 0644 {} +
