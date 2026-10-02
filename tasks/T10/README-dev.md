# T10. Что внутри?

**Тема:** архивы · **Сложность:** 🟢 · **Время:** 3–5 минут

## Условие для студента

> Флаг задачи зашифрован и лежит в файле `flag.enc` в вашем домашнем
> каталоге. Рядом — скрипт `decrypt.sh` и файл `README`.
>
> Чтобы расшифровать флаг, сначала нужно найти **ключ**: случайную
> hex-строку из 32 символов. Ключ спрятан в архиве `backup.zip` в
> вашем домашнем каталоге.
>
> Загляните внутрь архива, найдите ключ и выполните:
>
> ```bash
> ./decrypt.sh <ключ>
> ```

Имя архива известно.

## Состояние контейнера

```text
/home/ctf/
├── backup.zip   # zip-архив: notes.txt, todo.txt, key.txt (ключ)
├── flag.enc     # зашифрованный флаг
├── decrypt.sh   # ./decrypt.sh <ключ>
└── README
```

Пользователь: `ctf`, cwd: `/home/ctf`. Архив доступен на чтение всем.

## Флаг

```text
SSL{zip_basics}
```

Флаг не хранится в образе открытым текстом: он XOR-зашифрован
случайным ключом в `flag.enc`.  Ключ печатается в stdout на этапе
сборки и кладётся в `key.txt` внутри `backup.zip`.

## Ожидаемые навыки

`file`, `unzip -l`, `unzip`, `cat`.

## Подсказки

1. Содержимое архива можно посмотреть, не распаковывая:
   `unzip -l backup.zip`.
2. Для распаковки используйте `unzip backup.zip` (при необходимости
   с `-d`, чтобы выбрать каталог). Отдельный файл удобно печатать
   без распаковки: `unzip -p backup.zip key.txt`.
3. Внутри три файла; ключ лежит в `key.txt`.

## Решение

```bash
file backup.zip
unzip -l backup.zip
unzip -p backup.zip key.txt
# <ключ>

cd ~
./decrypt.sh <ключ>
# SSL{zip_basics}
```

Либо одной командой:

```bash
./decrypt.sh "$(unzip -p backup.zip key.txt | grep -oE '[0-9a-f]{32}')"
```

## Smoke test

```bash
docker run --rm linux-ctf/t10 test -f /home/ctf/backup.zip
docker run --rm linux-ctf/t10 bash -c 'unzip -l /home/ctf/backup.zip | grep -q key.txt'
docker run --rm linux-ctf/t10 bash -c \
  'k=$(unzip -p /home/ctf/backup.zip key.txt | grep -oE "[0-9a-f]{32}"); /home/ctf/decrypt.sh "$k" | grep -q "SSL{zip_basics}"'
docker run --rm linux-ctf/t10 bash -c 'grep -rn "SSL{" /home /opt /etc /usr 2>/dev/null && exit 1 || exit 0'
```

Проверяется: архив на месте, является zip, содержит `key.txt`, а ключ
из архива подходит к `flag.enc`.
