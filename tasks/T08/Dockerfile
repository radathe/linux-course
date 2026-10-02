# T08 "Чужой файл" -- права доступа и группы.
#
# Состояние (root:analysts 640) готовится на этапе сборки.  Финальный
# образ досоздаёт группу analysts с тем же GID и добавляет в неё ctf,
# но стартовая сессия запускается с DROP_GROUPS=analysts: чтобы прочитать
# файл, студент должен активировать группу через sg/newgrp.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /

# Тот же фиксированный GID, что и при сборке: без него владелец файла
# отображался бы числовым GID, а ctf не смог бы войти в группу.
RUN groupadd -g 2000 -f analysts \
    && usermod -aG analysts ctf

ENV START_DIR=/home/ctf
ENV DROP_GROUPS=analysts
WORKDIR /home/ctf
