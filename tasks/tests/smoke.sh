#!/usr/bin/env bash
# Smoke-тесты контейнеров практикума Linux/CTF.
#
# Для каждого образа запускается контейнер, выполняется runtime-инициализация
# (/opt/setup.sh и /opt/start-services.sh) и проверяется, что состояние
# задачи соответствует ожидаемому: файлы, права, пользователи, процессы,
# сервисы и флаги.
#
# Требуется запущенный Docker.  Перед запуском соберите образы:
#
#     cd tasks && make all
#     tests/smoke.sh
#
# Сетевые проверки выполняются при --network=none: сервисам достаточно
# loopback, как и в реальном запуске задачи.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NET=(--network none)

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf '  \033[32mok\033[0m   %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  \033[31mFAIL\033[0m %s\n' "$1"; }

# Запустить команду в контейнере после инициализации:
#   as_root <image> <command>  -- от root (проверка владельцев и прав)
#   as_user <image> <command>  -- от пользователя ctf (как студент)
as_root() { local img="$1"; shift; docker run --rm "${NET[@]}" -e CHALLENGE_USER=root "$img" bash -c "$*"; }
as_user() { local img="$1"; shift; docker run --rm "${NET[@]}" "$img" bash -c "$*"; }

# assert <описание> <команда...>
assert() {
    local desc="$1"; shift
    local out
    if out="$("$@" 2>&1)"; then
        pass "$desc"
    else
        fail "$desc"
        [ -n "$out" ] && printf '%s\n' "$out" | sed 's/^/       | /'
    fi
}

img_for() { printf 'linux-ctf/%s' "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"; }

task() {
    local t="$1" img
    img="$(img_for "$t")"
    printf '\n%s (%s)\n' "$t" "$img"
    if ! docker image inspect "$img" >/dev/null 2>&1; then
        fail "образ не собран (выполните: make $t)"
        return
    fi
    "smoke_$t" "$img"
}

# --------------------------------------------------------------------------
# T01--T03: файловая система
# --------------------------------------------------------------------------
smoke_T01() {
    local i="$1"
    assert "cwd = /home/ctf"                 as_user "$i" 'test "$(pwd)" = /home/ctf'
    assert "флаг в Documents/notes.txt"      as_root "$i" 'grep -q "flag{first_linux_steps}" /home/ctf/Documents/notes.txt'
}

smoke_T02() {
    local i="$1"
    assert "скрытый файл Documents/.secret"  as_root "$i" 'test -f /home/ctf/Documents/.secret'
    assert "флаг в Documents/.secret"        as_root "$i" 'grep -q "flag{hidden_note}" /home/ctf/Documents/.secret'
}

smoke_T03() {
    local i="$1"
    assert "cwd = /home/ctf/work"            as_user "$i" 'test "$(pwd)" = /home/ctf/work'
    assert "флаг в secret/flag.txt"          as_root "$i" 'grep -q "flag{relative_paths}" /home/ctf/secret/flag.txt'
}

# --------------------------------------------------------------------------
# T04--T06: просмотр и обработка текста
# --------------------------------------------------------------------------
smoke_T04() {
    local i="$1"
    assert "notes.txt содержит password=флаг" as_user "$i" 'grep -qx "password=flag{grep_basics}" notes.txt'
}

smoke_T05() {
    local i="$1"
    assert "server.log >= 2000 строк"        as_user "$i" 'test "$(wc -l < server.log)" -ge 2000'
    assert "строка ERROR с флагом"           as_user "$i" 'grep -q "\[ERROR\] flag{log_search}" server.log'
}

smoke_T06() {
    local i="$1"
    assert "флаг среди уникальных имён"      as_user "$i" 'cut -d: -f1 users.txt | sort | uniq | grep -qx "flag{text_pipeline}"'
}

# --------------------------------------------------------------------------
# T07--T08: поиск файлов
# --------------------------------------------------------------------------
smoke_T07() {
    local i="$1"
    assert "flag.txt в /opt/data/c/archive"  as_user "$i" 'test -f /opt/data/c/archive/flag.txt'
    assert "флаг в найденном файле"          as_user "$i" 'grep -q "flag{find_it}" /opt/data/c/archive/flag.txt'
}

smoke_T08() {
    local i="$1"
    assert "ровно один .txt >10k с TARGET"   as_user "$i" 'test "$(find /opt/data -type f -name "*.txt" -size +10k -exec grep -l TARGET {} + | wc -l)" -eq 1'
    assert "в подходящем файле есть флаг"    as_user "$i" 'grep -rl "flag{find_cleanup}" /opt/data | grep -q .'
}

# --------------------------------------------------------------------------
# T09--T10: права доступа
# --------------------------------------------------------------------------
smoke_T09() {
    local i="$1"
    assert "ctf состоит в группе analysts"   as_user "$i" 'id -Gn | tr " " "\n" | grep -qx analysts'
    assert "secret.txt: root:analysts 640"   as_root "$i" 'test "$(stat -c "%U:%G %a" /opt/data/secret.txt)" = "root:analysts 640"'
    assert "ctf читает secret.txt"           as_user "$i" 'grep -q "flag{groups_matter}" /opt/data/secret.txt'
}

smoke_T10() {
    local i="$1"
    assert "runme: ctf, права 644"           as_root "$i" 'test "$(stat -c "%U %a" /opt/runme)" = "ctf 644"'
    assert "после chmod u+x печатает флаг"   as_user "$i" 'chmod u+x /opt/runme && /opt/runme | grep -q "flag{execution_permission}"'
}

# --------------------------------------------------------------------------
# T11--T12: архивы
# --------------------------------------------------------------------------
smoke_T11() {
    local i="$1"
    assert "backup.zip содержит флаг"        as_user "$i" 'unzip -p backup.zip flag.txt | grep -q "flag{zip_basics}"'
}

smoke_T12() {
    local i="$1"
    assert "challenge -- gzip"               as_user "$i" 'file challenge | grep -qi gzip'
    assert "цепочка gzip->tar->zip->флаг"    as_user "$i" 'cd /tmp && gzip -dc /home/ctf/challenge | tar -xf - && unzip -o stage2.zip >/dev/null && grep -q "flag{archives_in_archives}" flag.txt'
}

# --------------------------------------------------------------------------
# T13--T14: кодировки
# --------------------------------------------------------------------------
smoke_T13() {
    local i="$1"
    assert "hex -> base64 -> флаг"           as_user "$i" 'xxd -r -p message.txt | sed "s/^The flag is: //" | base64 -d | grep -q "flag{hex_and_base64}"'
}

smoke_T14() {
    local i="$1"
    assert "message.txt декодируется в флаг" as_user "$i" 'base64 -d message.txt | grep -q "flag{base64_secret}"'
}

# --------------------------------------------------------------------------
# T15--T16: бинарные файлы
# --------------------------------------------------------------------------
smoke_T15() {
    local i="$1"
    assert "mystery -- ELF"                  as_user "$i" 'file mystery | grep -q ELF'
    assert "флаг виден через strings"        as_user "$i" 'strings mystery | grep -q "flag{strings_are_useful}"'
}

smoke_T16() {
    local i="$1"
    assert "checker сообщает пароль"         as_user "$i" 'strings checker | grep -q "Correct password: open-sesame"'
    assert "запуск с паролем даёт флаг"      as_user "$i" 'test "$(./checker open-sesame | tail -n1)" = "flag{simple_reverse}"'
}

# --------------------------------------------------------------------------
# T17--T18: Bash
# --------------------------------------------------------------------------
smoke_T17() {
    local i="$1"
    assert "secret.txt существует"           as_root "$i" 'grep -q "flag{bash_scripting}" /home/ctf/secret.txt'
    assert 'скрипт cat "$1" работает'        as_user "$i" 'printf "%s\n" "#!/bin/bash" "cat \"\$1\"" > /tmp/solve.sh && chmod +x /tmp/solve.sh && /tmp/solve.sh /home/ctf/secret.txt | grep -q "flag{bash_scripting}"'
}

smoke_T18() {
    local i="$1"
    assert "ровно один файл с TARGET"        as_user "$i" 'test "$(grep -l TARGET /opt/data/*.txt | wc -l)" -eq 1'
    assert "в этом файле есть флаг"          as_user "$i" 'grep -l "flag{automation}" /opt/data/*.txt | grep -q .'
}

# --------------------------------------------------------------------------
# T19--T22: процессы, окружение, потоки
# --------------------------------------------------------------------------
smoke_T19() {
    local i="$1"
    assert "запущено >=3 процесса worker"    as_user "$i" 'test "$(pgrep -c worker)" -ge 3'
    assert "флаг виден в аргументах"         as_user "$i" 'pgrep -af worker | grep -q "flag{process_argument}"'
}

smoke_T20() {
    local i="$1"
    assert "флаг в /proc/<PID>/environ"      as_user "$i" 'for p in $(pgrep worker); do tr "\0" "\n" < /proc/$p/environ 2>/dev/null | grep -q "SECRET=flag{environment_secret}" && exit 0; done; exit 1'
}

smoke_T21() {
    local i="$1"
    assert "stdout без флага"                as_user "$i" 'test "$(/opt/check 2>/dev/null)" = "$(printf "Checking system...\nNo problems found.")"'
    assert "флаг уходит в stderr"            as_user "$i" '/opt/check 2>&1 >/dev/null | grep -q "flag{stderr_is_a_stream}"'
}

smoke_T22() {
    local i="$1"
    assert "флаг в потоке TOKEN="            as_user "$i" '/opt/log-generator | grep "TOKEN=" | grep -q "flag{stream_processing}"'
}

# --------------------------------------------------------------------------
# T23--T25: сеть
# --------------------------------------------------------------------------
smoke_T23() {
    local i="$1"
    assert "localhost:31337 отдаёт флаг"     as_root "$i" 'nc -w2 127.0.0.1 31337 </dev/null | grep -q "flag{netcat_basics}"'
}

smoke_T24() {
    local i="$1"
    assert "/ возвращает 302"                as_root "$i" 'test "$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/)" = "302"'
    assert "/welcome указывает на /secret"   as_root "$i" 'curl -sL http://127.0.0.1:8080/ | grep -q "Try /secret"'
    assert "/secret отдаёт флаг"             as_root "$i" 'curl -s http://127.0.0.1:8080/secret | grep -q "flag{curl_basics}"'
}

smoke_T25() {
    local i="$1"
    assert "/admin без заголовка -- 403"     as_root "$i" 'test "$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/admin)" = "403"'
    assert "ответ содержит X-CTF-Hint"       as_root "$i" 'curl -si http://127.0.0.1:8080/admin | grep -qi "X-CTF-Hint: use-the-header"'
    assert "правильный заголовок даёт флаг"  as_root "$i" 'curl -s -H "X-CTF-Hint: use-the-header" http://127.0.0.1:8080/admin | grep -q "flag{custom_headers}"'
}

# --------------------------------------------------------------------------
# T26: итоговая
# --------------------------------------------------------------------------
smoke_T26() {
    local i="$1"
    assert "part1 в скрытом файле"           as_root "$i" 'grep -qx "flag{" /opt/data/.part1'
    assert "part2 в глубоком дереве"         as_root "$i" 'find /opt/data -name part2.txt -exec grep -qx "linux_" {} +'
    assert "part3 в архиве backup"           as_root "$i" 'tar -xf /opt/backup.tar -O part3.txt | grep -qx "ctf_"'
    assert "part4 hex-декодируется"          as_root "$i" 'tar -xf /opt/backup.tar -O encoded.txt | xxd -r -p | grep -qx "basics_"'
    assert "part5 выдаёт checker unlock-42"  as_root "$i" '/opt/tools/checker unlock-42 | grep -q "are_"'
    assert "part6 в аргументе процесса"      as_user "$i" 'pgrep -af worker | grep -q "easier_"'
    assert "part7 в окружении процесса"      as_user "$i" 'for p in $(pgrep worker); do tr "\0" "\n" < /proc/$p/environ 2>/dev/null | grep -q "SECRET=together_" && exit 0; done; exit 1'
    assert "part8 отдаёт TCP-сервис"         as_root "$i" 'nc -w2 127.0.0.1 31337 </dev/null | grep -q "ok}"'
}

# --------------------------------------------------------------------------
# D01: локальная практика (образ не собирается здесь)
# --------------------------------------------------------------------------
smoke_D01() {
    printf '\nD01 (локальная практика)\n'
    local base="$ROOT/D01"
    assert "есть challenge/Dockerfile"       test -f "$base/challenge/Dockerfile"
    assert "есть challenge/server.py"        test -f "$base/challenge/server.py"
    assert "есть challenge/requirements.txt" test -f "$base/challenge/requirements.txt"
    assert "есть solution/Dockerfile"        test -f "$base/solution/Dockerfile"
    assert "server.py отдаёт flag{docker_complete}" grep -q 'flag{docker_complete}' "$base/challenge/server.py"
}

# --------------------------------------------------------------------------
main() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        printf 'Docker недоступен. Запустите демон Docker и повторите.\n' >&2
        exit 2
    fi

    for t in $(seq -w 1 26); do
        task "T$t"
    done
    smoke_D01

    printf '\n----------------------------------------\n'
    printf 'Пройдено: %d, провалено: %d\n' "$PASS" "$FAIL"
    [ "$FAIL" -eq 0 ]
}

main "$@"
