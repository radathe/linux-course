# T08. Чужой файл

**Тема:** права доступа и группы · **Сложность:** 🟡 · **Время:** 6–10 минут

## Условие для студента

> Флаг задачи зашифрован и лежит в файле `flag.enc` в вашем домашнем
> каталоге. Рядом — скрипт `decrypt.sh` и файл `README`.
>
> Чтобы расшифровать флаг, сначала нужно найти **ключ**: случайную
> hex-строку из 32 символов. Ключ лежит в файле `/opt/data/secret.txt`,
> который вам не принадлежит. Читать его разрешено группе `analysts`.
>
> Получите ключ, затем выполните:
>
> ```bash
> ./decrypt.sh <ключ>
> ```

Повышать привилегии не нужно.

## Состояние контейнера

```text
/home/ctf/
├── flag.enc          # зашифрованный флаг
├── decrypt.sh        # ./decrypt.sh <ключ>
├── README
└── hint.txt          # подсказка

/opt/data/
├── secret.txt   # root:analysts, права 640, содержит ключ
├── draft.txt    # отвлекающий
├── todo.txt     # отвлекающий
└── stats.txt    # отвлекающий
```

Пользователь `ctf` **числится** в группе `analysts` в `/etc/group`, но
стартовый shell запускается без неё. Поэтому сразу `cat` не работает:
группу нужно активировать в текущей сессии. Повышения привилегий
(владельца/`sudo`) это не требует — группа уже принадлежит `ctf`.

## Флаг

```text
SSL{groups_matter}
```

Флаг не хранится в образе открытым текстом: он XOR-зашифрован
случайным ключом в `flag.enc`.  Ключ печатается в stdout на этапе
сборки и кладётся в `/opt/data/secret.txt`.

## Ожидаемые навыки

`id`, `groups`, `getent group`, `ls -l`, `sg`, `newgrp`, `grep`.

## Подсказки

1. Посмотрите на владельца и права файла:
   `ls -l /opt/data/secret.txt`. Триада `640` означает чтение для
   владельца и для группы.
2. Проверьте членство: `id`, `groups`, `getent group analysts`.
   В `/etc/group` вы состоите в `analysts`, но текущая сессия её не
   имеет.
3. Группу можно активировать командой `sg analysts` или
   `newgrp analysts` (пароль не потребуется, так как вы уже участник
   группы).
4. Подсказка также лежит в `~/hint.txt`.

## Решение

```bash
ls -l /opt/data/secret.txt        # root analysts ... -rw-r-----
getent group analysts             # analysts:x:2000:ctf
id                                # в сессии analysts пока нет
cat /opt/data/secret.txt          # Permission denied

sg analysts -c 'grep -oE "[0-9a-f]{32}" /opt/data/secret.txt'
# <ключ>

cd ~
./decrypt.sh <ключ>
# SSL{groups_matter}
```

Либо через новую сессию:

```bash
newgrp analysts
cat /opt/data/secret.txt
exit
```

## Smoke test

```bash
docker run --rm linux-ctf/t08 bash -c 'getent group analysts | grep -qw ctf'
docker run --rm linux-ctf/t08 bash -c 'test "$(stat -c %U:%G /opt/data/secret.txt)" = "root:analysts"'
docker run --rm linux-ctf/t08 bash -c 'test "$(stat -c %a /opt/data/secret.txt)" = "640"'
docker run --rm linux-ctf/t08 bash -c 'cat /opt/data/secret.txt && exit 1 || exit 0'
docker run --rm linux-ctf/t08 bash -c \
  'k=$(sg analysts -c "grep -oE \"[0-9a-f]{32}\" /opt/data/secret.txt"); /home/ctf/decrypt.sh "$k" | grep -q "SSL{groups_matter}"'
docker run --rm linux-ctf/t08 bash -c 'grep -rn "SSL{" /home /opt /etc /usr 2>/dev/null && exit 1 || exit 0'
```

Проверяется: `ctf` числится в группе `analysts` (GID 2000), файл
существует с владельцем `root:analysts` и правами `640`, напрямую не
читается, но ключ доступен после активации группы (`sg`/`newgrp`), и
подходит к `flag.enc`.
