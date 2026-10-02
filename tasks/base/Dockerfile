# base-linux-ctf -- общий базовый образ практикума.
#
# Задачи готовятся на этапе сборки (multi-stage), поэтому во время запуска
# контейнера никакой скрипт инициализации не выполняется.  Base отвечает
# только за инструменты, пользователя ctf и сброс привилегий.
FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="base-linux-ctf" \
      org.opencontainers.image.description="Базовый образ для практических задач по Linux"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        coreutils findutils grep sed gawk \
        file less \
        tar gzip bzip2 xz-utils unzip zip \
        xxd binutils \
        procps psmisc util-linux \
        iproute2 iputils-ping \
        netcat-openbsd \
        curl wget \
        python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 1000 --shell /bin/bash ctf \
    && chmod 0755 /home/ctf

RUN printf '%s\n' \
    '[base-linux-ctf] Осмотритесь: pwd, ls, cat, grep, find, file ...' \
    > /etc/motd

# Точка входа: при необходимости запускает фоновые процессы задачи
# (/opt/start) и сбрасывает привилегии до ctf.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt /var/log

ENV START_DIR=/home/ctf
WORKDIR /home/ctf

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-l"]
