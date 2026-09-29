# T01. Осмотр комнаты

**Тема:** файловая система · **Сложность:** 🟢 · **Время:** 3–5 минут

## Условие для студента

> Вы впервые подключились к Linux-машине.
>
> Найдите файл с флагом.
>
> Флаг находится в одном из каталогов текущего пользователя.

Имя файла и точный путь не сообщаются.

## Состояние контейнера

```text
/home/ctf/
├── Documents/
│   ├── welcome.txt
│   └── notes.txt      <- здесь флаг
├── Downloads/
│   └── image.txt
└── readme.txt
```

Пользователь: `ctf`, cwd: `/home/ctf`.

## Флаг

```text
flag{first_linux_steps}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`pwd`, `ls`, `cd`, `cat`.

## Подсказки

1. Сначала определите, где вы находитесь.
2. Посмотрите содержимое текущего каталога (`ls`), затем загляните в
   подкаталоги.
3. Флаг — это строка вида `flag{...}` внутри одного из текстовых файлов.

## Решение

```bash
pwd
ls
cd Documents
ls
cat notes.txt
```

## Smoke test

```bash
docker run --rm linux-ctf/t01 id -u
docker run --rm linux-ctf/t01 bash -c 'test -f /home/ctf/Documents/notes.txt'
docker run --rm linux-ctf/t01 grep -q 'flag{' /home/ctf/Documents/notes.txt
```

Проверяется: пользователь `ctf` существует, `cwd` — `/home/ctf`,
флаг лежит в `Documents/notes.txt`.
