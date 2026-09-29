# T09. Чужой файл

**Тема:** права доступа и группы · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> В каталоге `/opt/data` лежит файл `secret.txt`, который вам не
> принадлежит. Читать его разрешено группе `analysts`.
>
> Получите флаг из `secret.txt`. Повышать привилегии не нужно.

Имя файла известно, но владелец и права скрыты.

## Состояние контейнера

```text
/opt/data/
├── secret.txt   # root:analysts, права 640, содержит флаг
├── draft.txt    # отвлекающий
├── todo.txt     # отвлекающий
└── stats.txt    # отвлекающий
```

Пользователь `ctf` состоит в группе `analysts` (дополнительная группа).
Обычные отвлекающие файлы доступны всем.

## Флаг

```text
flag{groups_matter}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`id`, `ls -l`, `groups`, `cat`.

## Подсказки

1. Посмотрите на владельца и права файла: `ls -l /opt/data/secret.txt`.
   Триада `640` означает чтение для владельца и для группы.
2. Проверьте, в каких группах вы состоите: `id` или `groups`.
3. Если ваша группа совпадает с группой файла, чтения достаточно —
   никаких `sudo` не требуется.

## Решение

```bash
ls -l /opt/data/secret.txt   # root analysts ... -rw-r-----
id                            # ... groups=...,analysts
cat /opt/data/secret.txt
```

## Smoke test

```bash
docker run --rm linux-ctf/t09 bash -c 'id -Gn ctf | grep -qw analysts'
docker run --rm linux-ctf/t09 bash -c 'test -f /opt/data/secret.txt'
docker run --rm linux-ctf/t09 bash -c \
    'test "$(stat -c %U:%G /opt/data/secret.txt)" = "root:analysts"'
docker run --rm linux-ctf/t09 bash -c \
    'test "$(stat -c %a /opt/data/secret.txt)" = "640"'
docker run --rm linux-ctf/t09 grep -q 'flag{' /opt/data/secret.txt
```

Проверяется: `ctf` входит в группу `analysts`, файл существует с
владельцем `root:analysts` и правами `640`, и `ctf` может его прочитать
(команды выполняются уже от имени `ctf`).
