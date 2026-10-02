# T02 "Скрытая записка" -- скрытые (dot-) файлы.
#
# Состояние готовится на этапе сборки (stage prep), в финальный образ
# попадают только подготовленные файлы.  Никакого setup-скрипта внутри.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
