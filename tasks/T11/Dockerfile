# T11 "Испорченное сообщение" -- кодирование данных.
#
# message.txt собирается на этапе сборки: ключ кодируется в текстовый вид.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
