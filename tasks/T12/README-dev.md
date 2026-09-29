# T12. Матрешка

**Тема:** вложенные архивы · **Сложность:** 🟡 · **Время:** 6–10 минут

## Условие для студента

> В домашнем каталоге лежит файл `challenge` **без расширения**. Он
> получился в результате архивации, внутри которой спрятан ещё один
> архив, а в нём — третий уровень с флагом.
>
> Разберите матрёшку и доберитесь до флага.

Имя файла известно.

## Состояние контейнера

```text
/home/ctf/
└── challenge   # gzip(stage1.tar)  [без расширения]
        └── stage1.tar
                └── stage2.zip
                        └── flag.txt   <- флаг
```

Пользователь: `ctf`, cwd: `/home/ctf`.

## Флаг

```text
flag{archives_in_archives}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`file`, `gunzip`/`gzip -d`, `tar`, `unzip`.

## Подсказки

1. Начните с `file challenge` — отсутствие расширения не мешает
   определить формат по содержимому.
2. Это gzip-поток. Разожмите его в файл и снова проверьте `file` —
   получится tar-архив. Посмотрите список файлов через `tar -tf`.
3. На каждом уровне повторяйте `file`, пока не дойдёте до `flag.txt`.

## Решение

```bash
cd /home/ctf
file challenge                       # gzip compressed data
gzip -dc challenge > stage1.tar
file stage1.tar                      # POSIX tar archive
tar -xf stage1.tar                   # появляется stage2.zip
file stage2.zip                      # Zip archive
unzip stage2.zip                     # появляется flag.txt
cat flag.txt
```

## Smoke test

```bash
docker run --rm linux-ctf/t12 test -f /home/ctf/challenge
docker run --rm linux-ctf/t12 bash -c \
    'file -b /home/ctf/challenge | grep -qi gzip'
docker run --rm linux-ctf/t12 bash -c '
    set -e
    cd "$(mktemp -d)"
    gzip -dc /home/ctf/challenge > stage1.tar
    tar -xf stage1.tar
    unzip -q stage2.zip
    grep -q "flag{" flag.txt'
```

Проверяется: файл существует, верхний уровень — gzip, и вся цепочка
`gzip -> tar -> zip` распаковывается до `flag.txt` с флагом.
