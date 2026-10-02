# T07 "Где лежит ключ?" -- поиск файлов командой find.
#
# Состояние готовится на этапе сборки (stage prep); в финальный образ
# попадает только каталог /stage.  Внутри контейнера setup-скрипта нет.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
