# T20 "Секрет процесса" -- окружение процессов и /proc/<PID>/environ.
FROM linux-ctf/base:latest

# ELF-пустышка worker из общего образа инструментов.  Сам по себе он
# ничего не делает и никогда не завершается.
COPY --from=linux-ctf/tools:latest /worker /opt/worker

COPY setup.sh /opt/setup.sh
RUN chmod 0755 /opt/setup.sh

COPY start-services.sh /opt/start-services.sh
RUN chmod 0755 /opt/start-services.sh

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
