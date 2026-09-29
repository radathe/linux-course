# linux-ctf/tools -- сборка небольших ELF-бинарников, используемых задачами.
#
# Бинарники содержат только плейсхолдер флага; реальный флаг внедряется
# при запуске контейнера через /usr/local/bin/patch_flag.py.
#
# Сборка:
#
#     docker build -t linux-ctf/tools:latest tools
#
FROM debian:bookworm-slim AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY src/ /src/

RUN set -eux; \
    mkdir -p /out; \
    gcc -O2 -Wall -Wextra -o /out/worker  /src/worker.c; \
    gcc -O0 -Wall -Wextra -o /out/mystery /src/mystery.c; \
    gcc -O0 -Wall -Wextra -o /out/checker /src/checker.c; \
    gcc -O2 -Wall -Wextra -o /out/check26 /src/check26.c

# Итоговый образ содержит только готовые бинарники.
FROM scratch
COPY --from=build /out/ /
