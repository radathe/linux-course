# T09 "Запусти программу" -- бит выполнения.
#
# Ключ зашит в ELF-программу /opt/runme в XOR-виде (сборка в stage prep).
# Файл принадлежит ctf:ctf, но ставится с правами 0000: студент должен
# сам выдать себе право на выполнение.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

ENV START_DIR=/home/ctf
WORKDIR /home/ctf
