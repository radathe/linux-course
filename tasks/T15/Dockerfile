# T15 "Где настоящий вывод?" -- stdout и stderr.
#
# Состояние готовится на этапе сборки (stage prep): check компилируется
# там же, где генерируется ключ.  Файл ставится с правами 0111
# (execute-only), поэтому ключ нельзя достать через strings(1) или cat(1).
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
