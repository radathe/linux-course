# T23 "Подключись к сервису" -- работа с сетевыми сервисами (netcat).
FROM linux-ctf/base:latest

COPY scripts/server.py /opt/server.py
RUN chmod 0755 /opt/server.py

COPY setup.sh /opt/setup.sh
RUN chmod 0755 /opt/setup.sh

COPY start-services.sh /opt/start-services.sh
RUN chmod 0755 /opt/start-services.sh

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
