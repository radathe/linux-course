# T12 "Что это вообще?" -- определение типа файла и поиск строк.
#
# Состояние готовится на этапе сборки (stage prep): бинарник компилируется
# там же, где генерируется ключ, поэтому в финальный образ попадают только
# готовые файлы.  Никакого setup-скрипта внутри нет.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
