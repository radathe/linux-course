# T11. Что внутри?

**Тема:** архивы · **Сложность:** 🟢 · **Время:** 3–5 минут

## Условие для студента

> В вашем домашнем каталоге лежит архив `backup.zip`. Внутри — несколько
> файлов, один из которых содержит флаг.
>
> Распакуйте архив и найдите флаг.

Имя архива известно.

## Состояние контейнера

```text
/home/ctf/
└── backup.zip   # zip-архив: notes.txt, todo.txt, flag.txt (флаг)
```

Пользователь: `ctf`, cwd: `/home/ctf`.

## Флаг

```text
flag{zip_basics}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`file`, `unzip -l`, `unzip`, `cat`.

## Подсказки

1. Содержимое архива можно посмотреть, не распаковывая:
   `unzip -l backup.zip`.
2. Для распаковки используйте `unzip backup.zip` (при необходимости
   с `-d`, чтобы выбрать каталог).

## Решение

```bash
file backup.zip
unzip -l backup.zip
unzip backup.zip
cat flag.txt
```

## Smoke test

```bash
docker run --rm linux-ctf/t11 test -f /home/ctf/backup.zip
docker run --rm linux-ctf/t11 bash -c \
    'unzip -l /home/ctf/backup.zip | grep -q flag.txt'
docker run --rm linux-ctf/t11 bash -c \
    'cd "$(mktemp -d)" && unzip -q /home/ctf/backup.zip && grep -q "flag{" flag.txt'
```

Проверяется: архив на месте и является zip, внутри есть `flag.txt`
с флагом.
