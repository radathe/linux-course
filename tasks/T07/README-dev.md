# T07. Где лежит ключ?

**Тема:** поиск файлов · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> Флаг задачи зашифрован и лежит в файле `flag.enc` в вашем домашнем
> каталоге. Рядом — скрипт `decrypt.sh` и файл `README`.
>
> Чтобы расшифровать флаг, сначала нужно найти **ключ**: случайную
> hex-строку из 32 символов. Ключ спрятан где-то **вне** вашего
> домашнего каталога — поищите в `/opt/data`.
>
> Перебирать каталоги вручную не обязательно: воспользуйтесь поиском
> файлов. Найдя ключ, выполните:
>
> ```bash
> ./decrypt.sh <ключ>
> ```

Точный путь к файлу с ключом не сообщается.

## Состояние контейнера

```text
/home/ctf/
├── flag.enc          # зашифрованный флаг
├── decrypt.sh        # ./decrypt.sh <ключ>
├── README
└── hint.txt          # подсказка, где искать

/opt/data/
├── a/
│   └── note.txt
├── b/
│   └── old.txt
├── c/
│   └── archive/
│       └── key.txt   <- здесь ключ
└── d/
    └── readme.txt
```

Пользователь: `ctf`, cwd: `/home/ctf`.

## Флаг

```text
SSL{find_it}
```

Флаг не хранится в образе открытым текстом: он XOR-зашифрован
случайным ключом в `flag.enc`.  Ключ печатается в stdout на этапе
сборки и прячется в `/opt/data/c/archive/key.txt`.

## Ожидаемые навыки

`find`, `find -name`, `find -type f`, `cat`.

## Подсказки

1. Ключ не в домашнем каталоге — начните поиск с `/opt`.
2. Искать файл по имени удобно командой `find <каталог> -name '<имя>'`;
   ограничить поиск только файлами помогает `-type f`.
3. Файл с ключом называется `key.txt`; он лежит довольно глубоко, так
   что осмотр только верхнего уровня `/opt/data` ничего не даст.
4. Подсказка также лежит в `~/hint.txt`.

## Решение

```bash
find /opt/data -type f -name 'key.txt'
cat /opt/data/c/archive/key.txt
# <ключ>

cd ~
./decrypt.sh <ключ>
# SSL{find_it}
```

Либо одной строкой:

```bash
./decrypt.sh "$(grep -oE '[0-9a-f]{32}' /opt/data/c/archive/key.txt)"
```

## Smoke test

```bash
docker run --rm linux-ctf/t07 id -u
docker run --rm linux-ctf/t07 bash -c 'test -f /home/ctf/flag.enc && test -x /home/ctf/decrypt.sh'
docker run --rm linux-ctf/t07 bash -c \
  'test "$(find /opt/data -type f -name key.txt | wc -l)" = 1'
docker run --rm linux-ctf/t07 bash -c \
  'k=$(grep -oE "[0-9a-f]{32}" /opt/data/c/archive/key.txt); /home/ctf/decrypt.sh "$k" | grep -q "SSL{find_it}"'
docker run --rm linux-ctf/t07 bash -c 'grep -rn "SSL{" /home /opt /etc /usr 2>/dev/null && exit 1 || exit 0'
```

Проверяется: ключ лежит ровно в одном `key.txt` в дереве `/opt/data`,
он подходит к `flag.enc`, а плейнтекстовой строки `SSL{` в образе нет.
