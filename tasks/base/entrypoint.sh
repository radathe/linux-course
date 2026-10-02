#!/bin/bash
# Runtime-entrypoint контейнера-задачи.
#
# Файлы задачи готовятся на этапе сборки, поэтому здесь нет запуска
# setup-скриптов.  Entrypoint:
#   1. при необходимости запускает фоновые процессы задачи (/opt/start);
#   2. сбрасывает привилегии до пользователя ctf и запускает shell.
#
# /opt/start -- необязательный исполняемый файл (обычно скомпилированный),
# который сам запускает процессы от имени ctf.  Флагов и ключей он не
# содержит.
set -euo pipefail

log() { printf '[init] %s\n' "$*" >&2; }

if [ -x /opt/start ]; then
    log "запуск фоновых процессов задачи"
    /opt/start || true
fi

run_as="${CHALLENGE_USER:-ctf}"
start_dir="${START_DIR:-/home/ctf}"

if [ "$(id -u)" -eq 0 ] && id "$run_as" >/dev/null 2>&1; then
    user_home="$(getent passwd "$run_as" | cut -d: -f6)"
    user_home="${user_home:-/home/$run_as}"
    cd "$start_dir" 2>/dev/null || cd "$user_home" || cd /

    # Необязательный DROP_GROUPS: запустить shell без перечисленных групп,
    # хотя в /etc/group пользователь в них состоит (задача T08).
    if [ -n "${DROP_GROUPS:-}" ]; then
        keep=""
        for g in $(id -G "$run_as"); do
            gname="$(getent group "$g" | cut -d: -f1)"
            drop=0
            for d in $DROP_GROUPS; do
                [ "$gname" = "$d" ] && drop=1
            done
            [ "$drop" -eq 0 ] && keep="${keep:+$keep,}$g"
        done

        if [ -n "$keep" ]; then
            exec setpriv --reuid "$run_as" --regid "$run_as" \
                --groups "$keep" -- \
                env HOME="$user_home" USER="$run_as" LOGNAME="$run_as" "$@"
        else
            exec setpriv --reuid "$run_as" --regid "$run_as" \
                --clear-groups -- \
                env HOME="$user_home" USER="$run_as" LOGNAME="$run_as" "$@"
        fi
    fi

    exec runuser -u "$run_as" -- \
        env HOME="$user_home" USER="$run_as" LOGNAME="$run_as" "$@"
fi

cd "$start_dir" 2>/dev/null || cd / || true
exec "$@"
