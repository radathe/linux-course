# T05. Большой журнал

**Тема:** поиск в больших файлах · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> В файле `server.log` записаны события сервера.
>
> Среди них есть ровно одна строка уровня `ERROR`, содержащая ключ:
> `[ERROR] <ключ>`, где `<ключ>` — hex-строка из 32 символов.
>
> Найдите её и определите номер строки в файле, а затем расшифруйте флаг:
>
> ```bash
> cd /home/ctf
> ./decrypt.sh <ключ>
> ```

## Состояние контейнера

```text
/home/ctf/
├── server.log         <- 2000+ строк INFO/WARN/ERROR
├── flag.enc           <- зашифрованный флаг
├── decrypt.sh         <- ./decrypt.sh <ключ>
└── README
```

Пользователь: `ctf`, cwd: `/home/ctf`.
Ровно одна строка содержит ключ и уровень `[ERROR]`; остальные строки —
обычные записи `INFO`/`WARN`/`ERROR`.

## Флаг

```text
SSL{log_search}
```

Флаг хранится в `flag.enc` в зашифрованном виде и становится виден
только после `./decrypt.sh <ключ>`.  Открытым текстом в образе его нет.

## Ожидаемые навыки

`grep`, `grep -n`, `wc -l`, `less`.

## Подсказки

1. В журнале тысячи строк — открывать его целиком неудобно.
2. Отфильтруйте строки уровня `ERROR`.
3. Нужная строка — единственная, где `[ERROR]` стоит рядом с
   hex-строкой из 32 символов.  Номер строки подскажет `grep -n`.

## Решение

```bash
wc -l server.log
grep -nE '^\[ERROR\] [0-9a-f]{32}$' server.log
# например: 1234:[ERROR] <ключ>
cd /home/ctf
./decrypt.sh <ключ>        # печатает SSL{log_search}
```

Либо по уровню:

```bash
grep '\[ERROR\]' server.log | grep -E '[0-9a-f]{32}'
```

## Smoke test

```bash
# не менее 2000 строк
docker run --rm linux-ctf/t05 bash -c \
  'test "$(wc -l < /home/ctf/server.log)" -ge 2000'

# ровно одна строка [ERROR] <hex>
docker run --rm linux-ctf/t05 bash -c \
  '[ "$(grep -cE "^\[ERROR\] [0-9a-f]{32}$" /home/ctf/server.log)" = 1 ]'

# в образе нет открытого флага
docker run --rm linux-ctf/t05 bash -c \
  '! grep -rq "SSL{" /home /opt /etc /usr 2>/dev/null'

# ключ находится и расшифровывает флаг
docker run --rm linux-ctf/t05 bash -c \
  'cd /home/ctf && ./decrypt.sh \
     "$(grep -E "^\[ERROR\] [0-9a-f]{32}$" server.log | awk "{print \$2}")"' \
  | grep -qx 'SSL{log_search}'
```

Проверяется: журнал содержит не менее 2000 строк, ровно одну строку
`[ERROR] <hex>`, открытого флага в образе нет, а `./decrypt.sh` с
найденным ключом печатает `SSL{log_search}`.
