# linux-ctf/buildtools -- образ только для ЭТАПА СБОРКИ задач.
#
# Содержит gcc и утилиты подготовки зашифрованного флага.  Используется
# как первый (builder) stage в Dockerfile задач:
#
#     FROM linux-ctf/buildtools:latest AS prep
#     ...
#     FROM linux-ctf/base:latest
#     COPY --from=prep /stage/ /
#
# В финальные образы этот слой не попадает, поэтому плейнтекстовый флаг и
# сборочные инструменты студенту недоступны.
FROM linux-ctf/base:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

COPY ctf-make-challenge /usr/local/bin/ctf-make-challenge
COPY ctf-xor /usr/local/bin/ctf-xor
RUN chmod 0755 /usr/local/bin/ctf-make-challenge /usr/local/bin/ctf-xor

# Исходники вспомогательных программ (компилируются в задачах с ключом).
COPY src/ /src/
