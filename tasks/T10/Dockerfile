# T10 "Что внутри?" -- работа с zip-архивом.
#
# Архив собирается на этапе сборки в stage prep, поэтому ключ лежит внутри
# сжатого файла и не находится простым grep по образу.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
