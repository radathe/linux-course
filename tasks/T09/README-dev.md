# T09. Запусти программу

**Тема:** права на файл · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> Флаг задачи зашифрован и лежит в файле `flag.enc` в вашем домашнем
> каталоге. Рядом — скрипт `decrypt.sh` и файл `README`.
>
> Чтобы расшифровать флаг, сначала нужно найти **ключ**: случайную
> hex-строку из 32 символов. Ключ печатает программа `/opt/runme`, но
> сейчас её нельзя ни прочитать, ни запустить.
>
> Запустите программу, получите ключ и выполните:
>
> ```bash
> ./decrypt.sh <ключ>
> ```

Программа принадлежит вам, повышать привилегии не нужно.

## Состояние контейнера

```text
/home/ctf/
├── flag.enc          # зашифрованный флаг
├── decrypt.sh        # ./decrypt.sh <ключ>
├── README
└── hint.txt          # подсказка

/opt/
└── runme   # ctf:ctf, права 0000 (ни чтения, ни выполнения)
```

Пользователь: `ctf`, cwd: `/home/ctf`. Файл — скомпилированная
ELF-программа; ключ внутри хранится в XOR-закодированном виде и не
виден через `cat`/`strings` даже после выдачи права на чтение.

## Флаг

```text
SSL{execution_permission}
```

Флаг не хранится в образе открытым текстом: он XOR-зашифрован
случайным ключом в `flag.enc`.  Ключ печатается в stdout на этапе
сборки, XOR-кодируется байтом `0x5A` и зашивается в `/opt/runme`.

## Ожидаемые навыки

`ls -l`, `chmod u+x`, запуск программы `/opt/runme`, понимание бита `x`.

## Подсказки

1. Посмотрите на права: `ls -l /opt/runme`. Триада `000` не содержит
   ни `r`, ни `x`.
2. Файл принадлежит вам, поэтому право можно выдать самому:
   `chmod u+x /opt/runme`. `sudo` не нужен.
3. Читать файл бессмысленно: это бинарник, а ключ в нём закодирован —
   его выдаёт только сама программа при запуске.
4. Подсказка также лежит в `~/hint.txt`.

## Решение

```bash
ls -l /opt/runme
chmod u+x /opt/runme
/opt/runme
# <ключ>

cd ~
./decrypt.sh <ключ>
# SSL{execution_permission}
```

Либо одной строкой:

```bash
./decrypt.sh "$(chmod u+x /opt/runme && /opt/runme)"
```

## Smoke test

```bash
docker run --rm linux-ctf/t09 test -f /opt/runme
docker run --rm linux-ctf/t09 bash -c 'test "$(stat -c %A /opt/runme)" = "----------"'
docker run --rm linux-ctf/t09 bash -c 'cat /opt/runme >/dev/null 2>&1 && exit 1 || exit 0'
docker run --rm linux-ctf/t09 bash -c '/opt/runme >/dev/null 2>&1 && exit 1 || exit 0'
docker run --rm linux-ctf/t09 bash -c \
  'k=$(chmod u+x /opt/runme && /opt/runme); /home/ctf/decrypt.sh "$k" | grep -q "SSL{execution_permission}"'
docker run --rm linux-ctf/t09 bash -c 'grep -rn "SSL{" /home /opt /etc /usr 2>/dev/null && exit 1 || exit 0'
```

Проверяется: файл существует с правами `000`, не читается и не
исполняется, а после `chmod u+x` программа печатает ключ, который
подходит к `flag.enc`.
