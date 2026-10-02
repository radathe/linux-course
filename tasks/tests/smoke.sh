#!/usr/bin/env bash
# Smoke-тесты контейнеров практикума Linux/CTF (T01--T15).
#
# Новая схема: состояние готовится на этапе сборки, открытого флага в
# образе нет.  Для каждого образа проверяется, что
#   * в файлах нет строки SSL{ и нет /opt/setup.sh;
#   * ключ находится штатным для задачи способом;
#   * ./decrypt.sh <ключ> возвращает ожидаемый флаг;
#   * специфичные для задачи свойства (права, группы, процессы) на месте.
#
# Требуется запущенный Docker.  Перед запуском соберите образы:
#     cd tasks && make all
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NET=(--network none)

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf '  \033[32mok\033[0m   %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  \033[31mFAIL\033[0m %s\n' "$1"; }

as_root() { local img="$1"; shift; docker run --rm "${NET[@]}" -e CHALLENGE_USER=root "$img" bash -c "$*"; }
as_user() { local img="$1"; shift; docker run --rm "${NET[@]}" "$img" bash -c "$*"; }

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

# assert_decrypt <описание> <образ> <ожидаемый флаг> <команда получения ключа>
assert_decrypt() {
    local desc="$1" img="$2" exp="$3" keycmd="$4"
    local remote out errf
    errf="$(mktemp)"
    remote="key=\$($keycmd); cd /home/ctf; ./decrypt.sh \"\$key\""
    # stdout -- только результат decrypt; служебный stderr ([init] ...) отдельно.
    if out="$(as_user "$img" "$remote" 2>"$errf")"; then
        if [ "$out" = "$exp" ]; then
            pass "$desc"
        else
            fail "$desc (получено: $out, ожидалось: $exp)"
        fi
    else
        fail "$desc"
        [ -n "$out" ] && printf '%s\n' "$out" | sed 's/^/       | /'
        [ -s "$errf" ] && sed 's/^/       | /' "$errf"
    fi
    rm -f "$errf"
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
    assert "нет открытого флага (SSL{)" as_user "$img" 'test -z "$(grep -rl "SSL{" /home /opt /etc /usr 2>/dev/null)"'
    assert "нет /opt/setup.sh"           as_user "$img" 'test ! -e /opt/setup.sh'
    "smoke_$t" "$img"
}

# --------------------------------------------------------------------------
smoke_T01() {
    assert_decrypt "ключ из Documents/notes.txt" "$1" 'SSL{first_linux_steps}' \
        "grep -oE '[0-9a-f]{32}' /home/ctf/Documents/notes.txt | head -1"
}

smoke_T02() {
    assert_decrypt "ключ из Documents/.secret" "$1" 'SSL{hidden_note}' \
        "grep -oE '[0-9a-f]{32}' /home/ctf/Documents/.secret | head -1"
}

smoke_T03() {
    assert_decrypt "ключ из secret/key.txt" "$1" 'SSL{relative_paths}' \
        "grep -oE '[0-9a-f]{32}' /home/ctf/secret/key.txt | head -1"
}

smoke_T04() {
    assert_decrypt "ключ из строки password=" "$1" 'SSL{grep_basics}' \
        "grep -oE '[0-9a-f]{32}' /home/ctf/notes.txt | head -1"
}

smoke_T05() {
    assert_decrypt "ключ из строки [ERROR]" "$1" 'SSL{log_search}' \
        "grep -oE '[0-9a-f]{32}' /home/ctf/server.log | head -1"
}

smoke_T06() {
    assert_decrypt "ключ среди уникальных имён" "$1" 'SSL{text_pipeline}' \
        "cut -d: -f1 /home/ctf/users.txt | sort -u | grep -E '^[0-9a-f]{32}$' | head -1"
}

smoke_T07() {
    assert "key.txt существует"          as_user "$1" 'test -f /opt/data/c/archive/key.txt'
    assert "подсказка в домашнем каталоге" as_user "$1" 'test -f /home/ctf/hint.txt'
    assert_decrypt "ключ из c/archive/key.txt" "$1" 'SSL{find_it}' \
        "grep -oE '[0-9a-f]{32}' /opt/data/c/archive/key.txt | head -1"
}

smoke_T08() {
    assert "ctf числится в analysts"     as_user "$1" 'getent group analysts | grep -qw ctf'
    assert "secret.txt root:analysts 640" as_user "$1" 'test "$(stat -c "%U:%G %a" /opt/data/secret.txt)" = "root:analysts 640"'
    assert "напрямую не читается"        as_user "$1" 'cat /opt/data/secret.txt >/dev/null 2>&1 && exit 1 || exit 0'
    assert_decrypt "ключ после sg analysts" "$1" 'SSL{groups_matter}' \
        "sg analysts -c \"grep -oE '[0-9a-f]{32}' /opt/data/secret.txt | head -1\""
}

smoke_T09() {
    assert "runme права 000"             as_user "$1" 'test "$(stat -c %A /opt/runme)" = "----------"'
    assert "файл не исполняется"         as_user "$1" '/opt/runme >/dev/null 2>&1 && exit 1 || exit 0'
    assert_decrypt "runme печатает ключ" "$1" 'SSL{execution_permission}' \
        "chmod u+x /opt/runme; /opt/runme | grep -oE '[0-9a-f]{32}' | head -1"
}

smoke_T10() {
    assert_decrypt "ключ из backup.zip" "$1" 'SSL{zip_basics}' \
        "unzip -p /home/ctf/backup.zip key.txt | grep -oE '[0-9a-f]{32}' | head -1"
}

smoke_T11() {
    assert_decrypt "ключ из message.txt" "$1" 'SSL{base64_secret}' \
        "base64 -d /home/ctf/message.txt | grep -oE '[0-9a-f]{32}' | head -1"
}

smoke_T12() {
    assert "mystery -- ELF"              as_user "$1" 'file /home/ctf/mystery | grep -q ELF'
    assert_decrypt "ключ виден через strings" "$1" 'SSL{strings_are_useful}' \
        "strings /home/ctf/mystery | grep -oE '[0-9a-f]{32}' | head -1"
}

smoke_T13() {
    assert "пароль виден в strings"      as_user "$1" 'strings /home/ctf/checker | grep -q "Correct password: open-sesame"'
    assert "настоящий ключ не виден в strings" as_user "$1" \
        'key=$(/home/ctf/checker open-sesame | grep -oE "[0-9a-f]{32}" | head -1); ! strings /home/ctf/checker | grep -q "$key"'
    assert_decrypt "checker печатает ключ" "$1" 'SSL{simple_reverse}' \
        "/home/ctf/checker open-sesame | grep -oE '[0-9a-f]{32}' | head -1"
}

smoke_T14() {
    assert "запущено >=3 процесса worker" as_user "$1" 'test "$(pgrep -c worker)" -ge 3'
    assert_decrypt "ключ в аргументах процесса" "$1" 'SSL{process_argument}' \
        "pgrep -af worker | grep -oE '[0-9a-f]{32}' | head -1"
}

smoke_T15() {
    assert "stdout без ключа"            as_user "$1" 'test -z "$(/opt/check 2>/dev/null | grep -oE "[0-9a-f]{32}")"'
    assert "ключ недоступен через strings" as_user "$1" 'strings /opt/check >/dev/null 2>&1 && exit 1 || exit 0'
    assert_decrypt "ключ из stderr"      "$1" 'SSL{stderr_is_a_stream}' \
        "/opt/check 2>&1 >/dev/null | grep -oE '[0-9a-f]{32}' | head -1"
}

# --------------------------------------------------------------------------
main() {
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        printf 'Docker недоступен. Запустите демон Docker и повторите.\n' >&2
        exit 2
    fi

    local tasks=("$@")
    if [ "${#tasks[@]}" -eq 0 ]; then
        for n in $(seq -w 1 15); do tasks+=("T$n"); done
    fi
    for t in "${tasks[@]}"; do
        task "$t"
    done

    printf '\n----------------------------------------\n'
    printf 'Пройдено: %d, провалено: %d\n' "$PASS" "$FAIL"
    [ "$FAIL" -eq 0 ]
}

main "$@"
