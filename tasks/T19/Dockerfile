# T19 "Что здесь работает?" -- поиск процессов и их аргументов.
FROM linux-ctf/base:latest

COPY --from=linux-ctf/tools:latest /worker /opt/worker
RUN chmod 0755 /opt/worker

COPY start-services.sh /opt/start-services.sh
RUN chmod 0755 /opt/start-services.sh

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
