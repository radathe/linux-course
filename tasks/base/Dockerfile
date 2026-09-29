# base-linux-ctf -- общий базовый образ для практикума Linux/CTF.
#
# Образ содержит набор утилит, изучаемых в курсе, и непривилегированного
# пользователя ctf.  Задачи наследуются от него:
#
#     FROM linux-ctf/base:latest
#
# Сборка:
#
#     docker build -t linux-ctf/base:latest base
#
FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="base-linux-ctf" \
      org.opencontainers.image.description="Базовый образ для практических задач по Linux"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Утилиты, которые должны быть доступны студенту в большинстве задач.
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

# Непривилегированный пользователь, от имени которого работает студент.
RUN useradd --create-home --uid 1000 --shell /bin/bash ctf \
    && chmod 0755 /home/ctf

# Приветственный баннер с подсказкой про доступные инструменты.
RUN printf '%s\n' \
    '[base-linux-ctf] Осмотритесь: pwd, ls, cat, grep, find, file, strings ...' \
    > /etc/motd

# Утилита инъекции флага в бинарные файлы во время запуска контейнера.
# Позволяет не хранить реальный флаг в образе: в бинарник зашит только
# безобидный плейсхолдер, который заменяется при старте контейнера.
COPY patch_flag.py /usr/local/bin/patch_flag.py
RUN chmod 0755 /usr/local/bin/patch_flag.py

# Runtime-entrypoint: setup -> сервисы -> сброс привилегий -> shell.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

# Каталог для runtime-инициализации задачи и логов сервисов.
RUN mkdir -p /opt /var/log

# Стартовый каталог задачи (задачи могут переопределять через ENV).
ENV START_DIR=/home/ctf
WORKDIR /home/ctf

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-l"]
