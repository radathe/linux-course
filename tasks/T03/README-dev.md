# T03. Запутанный путь

**Тема:** относительные и абсолютные пути · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> Вы находитесь в рабочем каталоге `/home/ctf/work`.
>
> Флаг лежит в другом каталоге рядом с рабочим.
>
> Пользуйтесь относительными и абсолютными путями. Команду `find`
> использовать нельзя.

Точный путь к файлу с флагом не сообщается.

## Состояние контейнера

```text
/home/ctf/
├── work/              <- стартовый каталог (cwd)
│   ├── logs/
│   │   └── old.log
│   └── current.txt
└── secret/
    └── flag.txt       <- здесь флаг
```

Пользователь: `ctf`, cwd: `/home/ctf/work`.

## Флаг

```text
flag{relative_paths}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`pwd`, `ls`, `cd ..`, относительные и абсолютные пути, `cat`.

## Подсказки

1. Сначала посмотрите, где вы находитесь (`pwd`) и что вас окружает
   (`ls`).
2. Из `/home/ctf/work` можно подняться в `/home/ctf` командой `cd ..`.
3. Загляните в соседний с `work` каталог; флаг лежит в текстовом файле
   внутри него.

## Решение

```bash
pwd
ls
cd ..
ls
cd secret
cat flag.txt
```

Тот же результат через абсолютный путь:

```bash
cat /home/ctf/secret/flag.txt
```

## Smoke test

```bash
docker run --rm linux-ctf/t03 id -u
docker run --rm linux-ctf/t03 bash -c 'test -f /home/ctf/secret/flag.txt'
docker run --rm linux-ctf/t03 grep -q 'flag{' /home/ctf/secret/flag.txt
```

Проверяется: пользователь `ctf` существует, флаг лежит в
`/home/ctf/secret/flag.txt`, стартовый каталог — `/home/ctf/work`.
