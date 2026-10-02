# T13. Странная программа

**Тема:** анализ бинарников · **Сложность:** 🟢 · **Время:** 5–10 минут

## Условие для студента

> В домашнем каталоге есть программа `checker`. Она просит на вход
> какой-то пароль и без него ничего не показывает.
>
> Разберитесь, что это за программа, найдите пароль, а затем получите
> **ключ** — программа напечатает его при верном пароле.  После этого
> расшифруйте флаг:
>
> ```bash
> ./decrypt.sh <ключ>
> ```

Формат флага: `SSL{...}`.  Пароль виден в строках программы; сам ключ в
открытом виде внутри не хранится, а замаскирован.

## Состояние контейнера

```text
/home/ctf/
├── checker            <- исполняемый ELF, проверяет пароль
├── flag.enc           <- флаг, XOR-зашифрованный случайным ключом
├── decrypt.sh         <- ./decrypt.sh <ключ>
└── README
```

Пользователь: `ctf`, cwd: `/home/ctf`.  Файл `checker` исполняемый
(0755), владелец `ctf`.  При неверном пароле программа печатает
`Access denied`, при верном — `Access granted!` и ключ.

## Флаг

```text
SSL{simple_reverse}
```

Ключ генерируется случайно на этапе сборки и в бинарник попадает уже
XOR-замаскированным (маска `0x5A`), поэтому `strings` показывает только
пароль.

## Ожидаемые навыки

`file`, `strings`, запуск программ с аргументами, базовые понятия
обратной разработки.

## Подсказки

1. Определите тип файла (`file`) и поищите читаемые строки (`strings`).
2. Среди строк программы есть подсказка вида
   `Correct password: ...` — это и есть пароль.
3. Передайте найденный пароль программе первым аргументом — она
   напечатает ключ (32 hex-символа).
4. Ключ в открытом виде в бинарнике не лежит: при неверном пароле
   ничего не выводится.

## Решение

```bash
file checker
strings checker | grep -i password
# Correct password: open-sesame
./checker open-sesame
# Access granted!
# <ключ>
./decrypt.sh <ключ>
# SSL{simple_reverse}
```

## Smoke test

```bash
docker run --rm linux-ctf/t13 test -x /home/ctf/checker
docker run --rm linux-ctf/t13 sh -c 'strings /home/ctf/checker | grep -q "open-sesame"'
docker run --rm linux-ctf/t13 sh -c 'strings /home/ctf/checker | grep -q "SSL{" && exit 1 || exit 0'
docker run --rm linux-ctf/t13 sh -c 'key=$(/home/ctf/checker open-sesame | tail -n1); cd /home/ctf && ./decrypt.sh "$key"'
docker run --rm linux-ctf/t13 grep -rq 'SSL{' /home /opt /etc /usr && exit 1 || exit 0
```

Проверяется: файл исполняемый, пароль виден в строках, верный пароль
выдаёт ключ, `./decrypt.sh` даёт нужный флаг, а открытого флага нигде нет.
