# T05. Большой журнал

**Тема:** поиск в больших файлах · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> В файле `server.log` записаны события сервера.
>
> Среди них есть строка уровня `ERROR`, содержащая флаг.
>
> Найдите её и определите номер строки в файле.

## Состояние контейнера

```text
/home/ctf/
└── server.log         <- 2000+ строк INFO/WARN/ERROR
```

Пользователь: `ctf`, cwd: `/home/ctf`.
Ровно одна строка содержит флаг и уровень `[ERROR]`.

## Флаг

```text
flag{log_search}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`grep`, `grep -n`, `wc -l`, `less`.

## Подсказки

1. В журнале тысячи строк — открывать его целиком неудобно.
2. Отфильтруйте строки уровня `ERROR` и поищите строку с флагом вида
   `flag{...}`.
3. Флаг лежит в единственной строке, где уровень и флаг стоят рядом:
   `[ERROR] flag{...}`.

## Решение

```bash
wc -l server.log
grep -n 'flag{' server.log
```

Либо по уровню:

```bash
grep '\[ERROR\]' server.log | grep 'flag{'
```

## Smoke test

```bash
docker run --rm linux-ctf/t05 id -u
docker run --rm linux-ctf/t05 bash -c 'test $(wc -l < /home/ctf/server.log) -ge 2000'
docker run --rm linux-ctf/t05 bash -c '[ "$(grep -c "\[ERROR\] flag{" /home/ctf/server.log)" = 1 ]'
```

Проверяется: журнал содержит не менее 2000 строк и ровно одну строку
`[ERROR] flag{...}`.
