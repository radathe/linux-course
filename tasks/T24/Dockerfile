# T24 "Исследуй веб-сервис" -- знакомство с HTTP-сервисом внутри контейнера.
FROM linux-ctf/base:latest

COPY setup.sh /opt/setup.sh
RUN chmod 0755 /opt/setup.sh

COPY start-services.sh /opt/start-services.sh
RUN chmod 0755 /opt/start-services.sh

COPY scripts/server.py /opt/server.py

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
