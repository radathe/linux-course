#!/bin/bash
# Runtime-entrypoint контейнера-задачи.
#
# Порядок работы:
#   1. /opt/setup.sh          -- инициализация состояния задачи (root)
#   2. /opt/start-services.sh -- запуск фоновых сервисов/процессов (root)
#   3. сброс привилегий до пользователя ctf и запуск shell
#
# Скрипты setup.sh и start-services.sh опциональны.  Они выполняются от
# root, поэтому могут создавать пользователей, менять права владельца и
# запускать сервисы.  Студент получает непривилегированный shell.
set -euo pipefail

log() { printf '[init] %s\n' "$*" >&2; }

if [ -x /opt/setup.sh ]; then
    log "инициализация задачи (/opt/setup.sh)"
    /opt/setup.sh
fi

if [ -x /opt/start-services.sh ]; then
    log "запуск фоновых сервисов (/opt/start-services.sh)"
    /opt/start-services.sh
fi

run_as="${CHALLENGE_USER:-ctf}"
start_dir="${START_DIR:-/home/ctf}"

# Сбрасываем привилегии и запускаем shell/команду.  HOME выставляем
# явно, потому что runuser без --login сохраняет окружение root.
if [ "$(id -u)" -eq 0 ] && id "$run_as" >/dev/null 2>&1; then
    user_home="$(getent passwd "$run_as" | cut -d: -f6)"
    user_home="${user_home:-/home/$run_as}"
    cd "$start_dir" 2>/dev/null || cd "$user_home" || cd /
    exec runuser -u "$run_as" -- \
        env HOME="$user_home" USER="$run_as" LOGNAME="$run_as" "$@"
fi

cd "$start_dir" 2>/dev/null || cd / || true
exec "$@"
