# T15 "Что это вообще?" -- определение типа файла и поиск строк.
FROM linux-ctf/base:latest

COPY --from=linux-ctf/tools:latest /mystery /home/ctf/mystery

COPY setup.sh /opt/setup.sh
RUN chmod 0755 /opt/setup.sh

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
