# T26 "Маленький Linux CTF" -- итоговая задача курса.
#
# Флаг собран из восьми фрагментов, спрятанных в файлах, архиве,
# бинарнике, процессах и сетевом сервисе.
FROM linux-ctf/base:latest

# Бинарники из общего образа linux-ctf/tools.
COPY --from=linux-ctf/tools:latest /check26 /opt/tools/checker
COPY --from=linux-ctf/tools:latest /worker  /opt/worker

COPY setup.sh /opt/setup.sh
RUN chmod 0755 /opt/setup.sh

COPY start-services.sh /opt/start-services.sh
RUN chmod 0755 /opt/start-services.sh

COPY scripts/server.py /opt/server.py

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
