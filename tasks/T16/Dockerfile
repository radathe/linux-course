# T16 "Странная программа" -- анализ бинарника и поиск пароля.
FROM linux-ctf/base:latest

COPY --from=linux-ctf/tools:latest /checker /home/ctf/checker

COPY setup.sh /opt/setup.sh
RUN chmod 0755 /opt/setup.sh

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
