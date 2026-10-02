# T14 "Что здесь работает?" -- поиск процессов и их аргументов.
#
# Состояние готовится на этапе сборки (stage prep): worker, launcher и
# файл с ключом создаются там же, где генерируется ключ.  Финальный образ
# наследует base; /opt/start запускается entrypoint'ом автоматически и сам
# поднимает worker от имени ctf.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
