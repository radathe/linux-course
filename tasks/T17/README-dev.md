# T17. Первый скрипт

**Тема:** bash-скрипты · **Сложность:** 🟢 · **Время:** 5–10 минут

## Условие для студента

> В домашнем каталоге лежит файл `secret.txt` с флагом.
>
> Напишите bash-скрипт `solve.sh`, который принимает имя файла первым
> аргументом и печатает его содержимое. Запустите его для `secret.txt`
> и получите флаг.
>
> Например, если скрипт запущен как `./solve.sh secret.txt`, он должен
> вывести содержимое `secret.txt`.

Формат флага: `flag{...}`.

## Состояние контейнера

```text
/home/ctf/
└── secret.txt         <- файл с флагом
```

Пользователь: `ctf`, cwd: `/home/ctf`. Никаких готовых скриптов нет —
`solve.sh` студент создаёт сам.

## Флаг

```text
flag{bash_scripting}
```

Переопределяется переменной `TASK_FLAG` и записывается в `secret.txt`
в `setup.sh`.

## Ожидаемые навыки

Создание файла скрипта, строка `#!/bin/bash`, права на исполнение
(`chmod +x`), позиционные параметры (`$1`), команда `cat`.

## Подсказки

1. Скрипт начинается со строки `#!/bin/bash`; не забудьте сделать его
   исполняемым (`chmod +x solve.sh`).
2. Первый аргумент командной строки доступен внутри скрипта как `$1`.
3. Для вывода содержимого файла используйте `cat "$1"`.

## Решение

Создайте файл `solve.sh`:

```bash
#!/bin/bash
cat "$1"
```

Затем:

```bash
chmod +x solve.sh
./solve.sh secret.txt
# ... flag{bash_scripting}
```

## Smoke test

```bash
docker run --rm linux-ctf/t17 test -f /home/ctf/secret.txt
docker run --rm linux-ctf/t17 grep -q 'flag{' /home/ctf/secret.txt
docker run --rm -i linux-ctf/t17 sh -c '
  printf "%s\n" "#!/bin/bash" "cat \"\$1\"" > /tmp/solve.sh
  chmod +x /tmp/solve.sh
  /tmp/solve.sh /home/ctf/secret.txt | grep -q "flag{"'
```

Проверяется: `secret.txt` существует и содержит флаг; скрипт,
читающий файл по `$1`, выводит флаг.
