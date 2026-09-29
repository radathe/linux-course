# T04. Нужная строка

**Тема:** поиск по содержимому файла · **Сложность:** 🟢 · **Время:** 3–5 минут

## Условие для студента

> В файле `notes.txt` среди множества строк спрятан пароль.
>
> Строка с флагом имеет вид `password=flag{...}`.
>
> Найдите её, не просматривая файл целиком вручную.

## Состояние контейнера

```text
/home/ctf/
└── notes.txt          <- 60-90 строк, среди них строка с флагом
```

Пользователь: `ctf`, cwd: `/home/ctf`.
В файле есть как строка с флагом, так и ложная строка
`Password rotation: 30 days`.

## Флаг

```text
flag{grep_basics}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`grep`, `grep -i`.

## Подсказки

1. В файле несколько тысяч символов — читать его целиком не нужно.
2. Поищите по слову `password` командой `grep`.
3. Обратите внимание на регистр: `grep password` и `grep -i password`
   дают разный результат.

## Решение

```bash
grep password notes.txt
```

Если искать без учёта регистра, найдётся ещё и ложная строка:

```bash
grep -i password notes.txt
```

Флаг — в строке `password=flag{grep_basics}`.

## Smoke test

```bash
docker run --rm linux-ctf/t04 id -u
docker run --rm linux-ctf/t04 test -f /home/ctf/notes.txt
docker run --rm linux-ctf/t04 grep -q 'password=flag{' /home/ctf/notes.txt
docker run --rm linux-ctf/t04 grep -q 'Password rotation: 30 days' /home/ctf/notes.txt
```

Проверяется: файл `notes.txt` существует, содержит строку с флагом и
ложную строку про ротацию паролей.
