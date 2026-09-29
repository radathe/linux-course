# T07. Где лежит флаг?

**Тема:** поиск файлов · **Сложность:** 🟢 · **Время:** 4–6 минут

## Условие для студента

> Флаг спрятан где-то в каталоге `/opt/data`.
>
> Внутри — несколько подкаталогов и текстовых файлов.
>
> Найдите файл с флагом и прочитайте его. Перебирать каталоги вручную
> не нужно — воспользуйтесь поиском.

## Состояние контейнера

```text
/opt/data/
├── a/
│   └── note.txt
├── b/
│   └── old.txt
├── c/
│   └── archive/
│       └── flag.txt    <- здесь флаг
└── d/
    └── readme.txt
```

Пользователь: `ctf`, cwd: `/home/ctf`.

## Флаг

```text
flag{find_it}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`find`, `find -name`, `find -type f`.

## Подсказки

1. Искать файл по имени удобно командой `find`, указав каталог поиска.
2. Можно искать по точному имени (`-name 'flag.txt'`) или по маске
   (`-name '*flag*'`).
3. Ограничить поиск только файлами (а не каталогами) помогает `-type f`.

## Решение

```bash
find /opt/data -type f -name 'flag.txt'
cat /opt/data/c/archive/flag.txt
```

Либо поиск по маске:

```bash
find /opt/data -type f -name '*flag*'
```

## Smoke test

```bash
docker run --rm linux-ctf/t07 id -u
docker run --rm linux-ctf/t07 bash -c 'test -f /opt/data/c/archive/flag.txt'
docker run --rm linux-ctf/t07 grep -q 'flag{' /opt/data/c/archive/flag.txt
docker run --rm linux-ctf/t07 bash -c '[ "$(find /opt/data -type f -name "flag.txt" | wc -l)" = 1 ]'
```

Проверяется: флаг лежит в `/opt/data/c/archive/flag.txt`, и это
единственный файл с таким именем в дереве.
