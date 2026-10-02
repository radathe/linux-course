# T15. Где настоящий вывод?

**Тема:** stdout и stderr · **Сложность:** 🟢 · **Время:** 5–7 минут

## Условие для студента

> В каталоге `/opt` лежит программа `check`. Она что-то проверяет и
> печатает результат.  Кажется, всё в порядке — но где-то рядом есть
> **ключ**.
>
> Разберитесь, куда программа пишет свой вывод, найдите ключ и
> расшифруйте флаг:
>
> ```bash
> ./decrypt.sh <ключ>
> ```

Формат флага: `SSL{...}`.  Ключ — случайная hex-строка (32 символа).
Файл `check` имеет права `0111` (execute-only), поэтому прочитать его
через `cat`/`strings` нельзя — программу нужно именно запустить.

## Состояние контейнера

```text
/opt/
└── check             <- root:root, права 0111 (execute-only)

/home/ctf/
├── flag.enc          <- флаг, XOR-зашифрованный случайным ключом
├── decrypt.sh        <- ./decrypt.sh <ключ>
├── hint.txt
└── README
```

Пользователь: `ctf`, cwd: `/home/ctf`.  Программа печатает в stdout
строки `Checking system...` и `No problems found.`, а ключ — в stderr.

## Флаг

```text
SSL{stderr_is_a_stream}
```

Ключ генерируется случайно на этапе сборки и виден только в потоке
stderr работающей программы.

## Ожидаемые навыки

Различие потоков `stdout` и `stderr`, перенаправления `>`, `2>`, `2>&1`,
`|`, работа с правами на исполнение.

## Подсказки

1. Запустите программу и посмотрите на результат.
2. У программы два потока вывода. Обычные сообщения идут в stdout, но
   не всё, что печатает программа, видно там же, где `Checking system...`.
3. Перенаправьте потоки, чтобы увидеть всё: `/opt/check 2>&1 >/dev/null`.
4. Файл нельзя прочитать (`strings /opt/check` — отказ в доступе),
   поэтому ключ достаётся только запуском.

## Решение

```bash
/opt/check
# Checking system...
# No problems found.
# <в терминале ключ не виден среди stdout — он ушёл в stderr>

/opt/check 2>&1 >/dev/null
# <ключ>
./decrypt.sh <ключ>
# SSL{stderr_is_a_stream}
```

## Smoke test

```bash
docker run --rm linux-ctf/t15 test -x /opt/check
docker run --rm linux-ctf/t15 sh -c 'test "$(stat -c %a /opt/check)" = 111'
docker run --rm linux-ctf/t15 sh -c 'strings /opt/check 2>&1 | grep -q "SSL{" && exit 1 || exit 0'
docker run --rm linux-ctf/t15 sh -c 'key=$(/opt/check 2>&1 >/dev/null | grep -oE "[0-9a-f]{32}" | head -n1); cd /home/ctf && ./decrypt.sh "$key"'
docker run --rm linux-ctf/t15 grep -rq 'SSL{' /home /opt /etc /usr && exit 1 || exit 0
```

Проверяется: файл исполняемый, права `0111`, ключ через `strings` не
читается, но появляется в stderr при запуске, `./decrypt.sh` даёт нужный
флаг, а открытого флага нигде нет.
