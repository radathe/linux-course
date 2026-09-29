# T13. Hex or Base64?

**Тема:** кодирование данных · **Сложность:** 🟡 · **Время:** 5–8 минут

## Условие для студента

> В домашнем каталоге лежит файл `message.txt`. В нём записана длинная
> строка из шестнадцатеричных символов.
>
> Декодируйте её: сначала из hex, затем — то, что получится, из Base64.
> Флаг спрятан на втором уровне.

Имя файла известно, содержимое скрыто.

## Состояние контейнера

```text
/home/ctf/
└── message.txt   # hex-строка от "The flag is: <base64(флаг)>"
```

Открытым текстом флаг в файле не хранится: это hex-представление строки
`The flag is: <base64(флаг)>`. Пользователь: `ctf`, cwd: `/home/ctf`.

## Флаг

```text
flag{hex_and_base64}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`file`, `head`, `xxd -r -p`, `base64 -d`.

## Подсказки

1. Длина строки кратна двум, а символы — только `0-9a-f`: это hex.
   Переведите её обратно в байты через `xxd -r -p`.
2. После первого декодирования получится человекочитаемый текст вида
   `The flag is: <нечто>`. Это `<нечто>` и есть Base64.
3. Декодируйте Base64 командой `base64 -d` (или `base64 --decode`).

## Решение

```bash
cd /home/ctf
head -c 80 message.txt; echo       # видим hex
xxd -r -p message.txt > decoded.txt   # "The flag is: <base64>"
cat decoded.txt
# достаём base64-часть и декодируем
sed 's/^The flag is: //' decoded.txt | base64 -d
echo
```

## Smoke test

```bash
docker run --rm linux-ctf/t13 test -f /home/ctf/message.txt
docker run --rm linux-ctf/t13 bash -c \
    'xxd -r -p /home/ctf/message.txt | grep -q "^The flag is: "'
docker run --rm linux-ctf/t13 bash -c \
    'xxd -r -p /home/ctf/message.txt | sed "s/^The flag is: //" | base64 -d | grep -q "flag{"'
```

Проверяется: файл существует, первый уровень — hex от `The flag is: ...`,
второй уровень — Base64, декодируется до флага.
