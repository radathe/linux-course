# T14. Что здесь работает?

**Тема:** процессы · **Сложность:** 🟢 · **Время:** 5–7 минут

## Условие для студента

> В системе работают несколько фоновых процессов. Один из них запущен с
> секретным параметром — в этом параметре **ключ**.
>
> Разберитесь, какие процессы запущены и с какими аргументами, найдите
> ключ и расшифруйте флаг:
>
> ```bash
> ./decrypt.sh <ключ>
> ```

Формат флага: `SSL{...}`.  Ключ — случайная hex-строка (32 символа).

## Состояние контейнера

Один из процессов запускается с ключом в аргументах:

```text
/opt/worker --mode backup --secret <ключ>
/opt/worker --mode backup
/opt/worker --mode test
```

```text
/opt/
├── worker            <- долгоживущий процесс-пустышка
├── start             <- launcher: читает ключ и запускает worker от ctf
└── .worker_key       <- root:root, права 0400 (студенту не читается)

/home/ctf/
├── flag.enc          <- флаг, XOR-зашифрованный случайным ключом
├── decrypt.sh        <- ./decrypt.sh <ключ>
├── hint.txt
└── README
```

Пользователь: `ctf`, cwd: `/home/ctf`.  Процессы `worker` работают от
имени `ctf`, чтобы студент мог читать их командные строки через
`ps(1)`/`pgrep(1)`.  Сам launcher ключа не содержит — он берёт его из
`/opt/.worker_key`, доступного только root.

## Флаг

```text
SSL{process_argument}
```

Ключ генерируется случайно на этапе сборки, хранится в
`/opt/.worker_key` и передаётся процессу аргументом.

## Ожидаемые навыки

`ps`, `ps aux`, `pgrep`, чтение командной строки процесса, при желании —
`/proc/<pid>/cmdline`.

## Подсказки

1. Посмотрите список процессов: `ps aux` или `ps -ef`.
2. Найдите процессы по имени: `pgrep -a worker`.
3. Обратите внимание на аргументы процессов — ключ передан отдельным
   параметром командной строки `--secret`.
4. Нужен именно процесс с `--secret`: остальные запущены без ключа.

## Решение

```bash
ps aux | grep worker
# или
pgrep -af worker
# /opt/worker --mode backup --secret <ключ>
./decrypt.sh <ключ>
# SSL{process_argument}
```

Через `/proc`:

```bash
cat /proc/$(pgrep -f 'mode backup --secret' | head -n1)/cmdline | tr '\0' ' '
```

## Smoke test

```bash
docker run --rm linux-ctf/t14 sh -c 'test "$(pgrep -c worker)" -ge 3'
docker run --rm linux-ctf/t14 sh -c 'pgrep -af worker | grep -q -- "--secret"'
docker run --rm linux-ctf/t14 sh -c 'key=$(pgrep -af worker | grep -- "--secret" | grep -oE "[0-9a-f]{32}" | head -n1); cd /home/ctf && ./decrypt.sh "$key"'
docker run --rm linux-ctf/t14 sh -c 'test ! -r /opt/.worker_key'
docker run --rm linux-ctf/t14 grep -rq 'SSL{' /home /opt /etc /usr && exit 1 || exit 0
```

Проверяется: запущено не меньше трёх процессов `worker`, у одного из
них в аргументах есть ключ, `./decrypt.sh` даёт нужный флаг, файл
`/opt/.worker_key` студенту недоступен, а открытого флага нигде нет.
