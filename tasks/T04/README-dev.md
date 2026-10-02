# T04. Нужная строка

**Тема:** поиск по содержимому файла · **Сложность:** 🟢 · **Время:** 3–5 минут

## Условие для студента

> В файле `notes.txt` среди множества строк спрятан ключ.
>
> Строка с ключом имеет вид `password=<ключ>`, где `<ключ>` — hex-строка
> из 32 символов.
>
> Найдите её, не просматривая файл целиком вручную, а затем расшифруйте
> флаг:
>
> ```bash
> cd /home/ctf
> ./decrypt.sh <ключ>
> ```

## Состояние контейнера

```text
/home/ctf/
├── notes.txt          <- 60-90 отвлекающих строк, среди них ключ
├── flag.enc           <- зашифрованный флаг
├── decrypt.sh         <- ./decrypt.sh <ключ>
└── README
```

Пользователь: `ctf`, cwd: `/home/ctf`.
В файле есть как строка с ключом (`password=<hex>`), так и ложная строка
`Password rotation: 30 days`.

## Флаг

```text
SSL{grep_basics}
```

Флаг хранится в `flag.enc` в зашифрованном виде и становится виден
только после `./decrypt.sh <ключ>`.  Открытым текстом в образе его нет.

## Ожидаемые навыки

`grep`, `grep -i`.

## Подсказки

1. В файле несколько десятков строк — читать его целиком не нужно.
2. Поищите по слову `password` командой `grep`.
3. Обратите внимание на регистр: `grep password` и `grep -i password`
   дают разный результат.  Ключ — значение после знака `=`.

## Решение

```bash
grep password notes.txt
# password=<ключ>          <- нужная строка, берём значение после '='
cd /home/ctf
./decrypt.sh <ключ>        # печатает SSL{grep_basics}
```

Если искать без учёта регистра, найдётся ещё и ложная строка:

```bash
grep -i password notes.txt
# Password rotation: 30 days
# password=<ключ>
```

## Smoke test

```bash
# 60-90 отвлекающих строк + 2 служебные
docker run --rm linux-ctf/t04 bash -c \
  'test "$(wc -l < /home/ctf/notes.txt)" -ge 62'
docker run --rm linux-ctf/t04 bash -c \
  'test "$(wc -l < /home/ctf/notes.txt)" -le 92'

# ровно одна строка password=<hex> и ровно одна ложная
docker run --rm linux-ctf/t04 bash -c \
  '[ "$(grep -cE "^password=[0-9a-f]{32}$" /home/ctf/notes.txt)" = 1 ]'
docker run --rm linux-ctf/t04 bash -c \
  '[ "$(grep -c "^Password rotation: 30 days$" /home/ctf/notes.txt)" = 1 ]'

# в образе нет открытого флага
docker run --rm linux-ctf/t04 bash -c \
  '! grep -rq "SSL{" /home /opt /etc /usr 2>/dev/null'

# ключ находится и расшифровывает флаг
docker run --rm linux-ctf/t04 bash -c \
  'cd /home/ctf && ./decrypt.sh "$(grep "^password=" notes.txt | cut -d= -f2)"' \
  | grep -qx 'SSL{grep_basics}'
```

Проверяется: файл содержит 60-90 отвлекающих строк, ровно одну строку
`password=<hex>` и ложную строку про ротацию паролей, открытого флага в
образе нет, а `./decrypt.sh` с найденным ключом печатает
`SSL{grep_basics}`.
