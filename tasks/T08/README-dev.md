# T08. Большая уборка

**Тема:** поиск файлов · **Сложность:** 🟢 · **Время:** 5–8 минут

## Условие для студента

> В каталоге `/opt/data` накопился беспорядок: десятки мелких файлов
> разных типов, большие бинарные файлы и большие текстовые отчёты.
>
> Найдите **единственный** текстовый файл (`.txt`), размер которого
> **больше 10 КБ** и в котором встречается слово `TARGET`. Внутри него
> лежит флаг.

Имя файла не сообщается.

## Состояние контейнера

```text
/opt/data/
├── file_001.txt … file_075.sh   # ~75 маленьких файлов разных типов
├── big_binary_1.bin … .3.bin    # большие бинарные файлы (~20 КБ)
├── report_draft_1.txt           # большой .txt без TARGET (> 10 КБ)
├── report_draft_2.txt           # большой .txt без TARGET (> 10 КБ)
└── otchet_cleanup.txt           # <- нужный файл: .txt, > 10 КБ, TARGET
```

Пользователь: `ctf`, cwd: `/home/ctf`. Каталог `/opt/data` доступен на
чтение всем.

## Флаг

```text
flag{find_cleanup}
```

Переопределяется переменной `TASK_FLAG`.

## Ожидаемые навыки

`find -type f -name "*.txt" -size +10k`, `grep -l`, `xargs`.

## Подсказки

1. Сначала отбросьте всё, что не является текстом: условие явно
   ограничивает тип файла расширением `.txt`.
2. У `find` есть фильтр по размеру: `-size +10k` отберёт файлы больше
   10 КБ. Осталось проверить содержимое через `grep -l`.
3. Чтобы передать найденные файлы в `grep`, удобно использовать
   `-exec ... {} +` или `xargs`.

## Решение

```bash
# Кандидаты: .txt, больше 10 КБ.
find /opt/data -type f -name '*.txt' -size +10k

# Среди них -- содержащие TARGET (он должен быть один).
find /opt/data -type f -name '*.txt' -size +10k -exec grep -l TARGET {} +

# Читаем найденный отчёт.
grep -h 'flag{' /opt/data/otchet_cleanup.txt
```

## Smoke test

```bash
docker run --rm linux-ctf/t08 test -d /opt/data
docker run --rm linux-ctf/t08 bash -c \
    'test "$(find /opt/data -type f -name "*.txt" -size +10k | wc -l)" -ge 1'
docker run --rm linux-ctf/t08 bash -c \
    'test "$(find /opt/data -type f -name "*.txt" -size +10k -exec grep -l TARGET {} + | wc -l)" -eq 1'
docker run --rm linux-ctf/t08 bash -c \
    'find /opt/data -type f -name "*.txt" -size +10k -exec grep -l TARGET {} + | xargs grep -q "flag{"'
```

Проверяется: каталог существует, есть хотя бы один большой `.txt`,
подходящий файл ровно один и в нём лежит флаг.
