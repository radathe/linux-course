# T03. Запутанный путь

**Тема:** относительные и абсолютные пути · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> Вы находитесь в рабочем каталоге `/home/ctf/work`.
>
> Ключ лежит в другом каталоге рядом с рабочим.
>
> Пользуйтесь относительными и абсолютными путями.  Команду `find`
> использовать нельзя.
>
> Найдите ключ (hex-строка из 32 символов) и расшифруйте флаг:
>
> ```bash
> cd /home/ctf
> ./decrypt.sh <ключ>
> ```

Точный путь к файлу с ключом не сообщается.

## Состояние контейнера

```text
/home/ctf/
├── work/              <- стартовый каталог (cwd)
│   ├── logs/
│   │   └── old.log
│   └── current.txt
├── secret/
│   └── key.txt        <- здесь ключ
├── flag.enc           <- зашифрованный флаг
├── decrypt.sh         <- ./decrypt.sh <ключ>
└── README
```

Пользователь: `ctf`, cwd: `/home/ctf/work`.

## Флаг

```text
SSL{relative_paths}
```

Флаг хранится в `flag.enc` в зашифрованном виде и становится виден
только после `./decrypt.sh <ключ>`.  Открытым текстом в образе его нет.

## Ожидаемые навыки

`pwd`, `ls`, `cd ..`, относительные и абсолютные пути, `cat`.

## Подсказки

1. Сначала посмотрите, где вы находитесь (`pwd`) и что вас окружает
   (`ls`).
2. Из `/home/ctf/work` можно подняться в `/home/ctf` командой `cd ..`.
3. Загляните в соседний с `work` каталог: ключ — строка из 32
   шестнадцатеричных цифр в текстовом файле внутри него.

## Решение

```bash
pwd
ls
cd ..
ls
cat secret/key.txt    # находим ключ (hex, 32 символа)
cd /home/ctf
./decrypt.sh <ключ>   # печатает SSL{relative_paths}
```

Тот же файл через абсолютный путь:

```bash
cat /home/ctf/secret/key.txt
```

## Smoke test

```bash
# стартовый каталог
docker run --rm linux-ctf/t03 bash -c 'test "$(pwd)" = /home/ctf/work'

# в образе нет открытого флага
docker run --rm linux-ctf/t03 bash -c \
  '! grep -rq "SSL{" /home /opt /etc /usr 2>/dev/null'

# ключ находится и расшифровывает флаг
docker run --rm linux-ctf/t03 bash -c \
  'cd /home/ctf && ./decrypt.sh \
     "$(grep -oE "^[0-9a-f]{32}$" /home/ctf/secret/key.txt)"' \
  | grep -qx 'SSL{relative_paths}'
```

Проверяется: стартовый каталог — `/home/ctf/work`, ключ лежит в
`/home/ctf/secret/key.txt`, открытого флага в образе нет, а
`./decrypt.sh` с найденным ключом печатает `SSL{relative_paths}`.
