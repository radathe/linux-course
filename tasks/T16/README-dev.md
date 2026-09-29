# T16. Странная программа

**Тема:** анализ бинарников · **Сложность:** 🟢 · **Время:** 5–10 минут

## Условие для студента

> В домашнем каталоге есть программа `checker`. Она просит на вход
> какой-то пароль и без него флаг не показывает.
>
> Разберитесь, что это за программа, найдите пароль и получите флаг.

Формат флага: `flag{...}`.

## Состояние контейнера

```text
/home/ctf/
└── checker            <- исполняемый ELF-файл, проверяет пароль
```

Пользователь: `ctf`, cwd: `/home/ctf`. Файл исполняемый, владелец `ctf`.

Программа при неверном пароле печатает `Access denied`, при верном —
`Access granted!` и флаг.

## Флаг

```text
flag{simple_reverse}
```

Переопределяется переменной `TASK_FLAG`; в образе лежит только
плейсхолдер `flag{PLACEHOLDER_DO_NOT_SHIP}`, который заменяется
утилитой `patch_flag.py` при запуске контейнера.

## Ожидаемые навыки

`file`, `strings`, запуск программ с аргументами, базовые понятия
обратной разработки.

## Подсказки

1. Определите тип файла (`file`) и поищите читаемые строки (`strings`).
2. Среди строк программы есть подсказка вида
   `Correct password: ...` — это и есть пароль.
3. Передайте найденный пароль программе первым аргументом.

## Решение

```bash
file checker
strings checker | grep -i password
# Correct password: open-sesame
./checker open-sesame
# Access granted!
# flag{simple_reverse}
```

## Smoke test

```bash
docker run --rm linux-ctf/t16 test -x /home/ctf/checker
docker run --rm linux-ctf/t16 sh -c '/home/ctf/checker open-sesame | grep -q "flag{"'
docker run --rm linux-ctf/t16 sh -c 'strings /home/ctf/checker | grep -q "open-sesame"'
```

Проверяется: файл исполняемый, верный пароль выдаёт флаг, пароль
виден в строках бинарника.
