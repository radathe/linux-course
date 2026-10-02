# Практикум Linux/CTF в Docker

Набор изолированных практических заданий по Linux для вводного курса по
информационной безопасности.  Каждой задаче соответствует **свой
Docker-образ**.  Студент получает непривилегированный shell пользователя
`ctf` и решает задачу, исследуя файловую систему, права, архивы,
бинарники, процессы и потоки ввода-вывода.

> Здесь — **только исходники**.  Образы собираются локально командами
> `make`/`docker build`.

Инструкция для студентов по загрузке и запуску готовых образов —
[`STUDENT-GUIDE.md`](STUDENT-GUIDE.md).

## Как устроены задачи

* Состояние задачи готовится **на этапе сборки** (multi-stage), а не при
  запуске контейнера.  Внутри образа **нет** `setup.sh` и любого другого
  скрипта инициализации.
* Настоящий флаг **не хранится в образе в открытом виде**.  Он
  XOR-шифруется случайным ключом; в `/home/ctf` лежат:
  * `flag.enc` — зашифрованный флаг;
  * `decrypt.sh` — расшифровка: `./decrypt.sh <ключ>`;
  * `README` — пояснение.
* **Ключ** (случайная hex-строка) спрятан в задаче так, что его находят
  с помощью изучаемого навыка (`grep`, `find`, `strings`, `unzip`,
  `chmod`, `ps`, перенаправление `stderr` и т. д.).

Поэтому `grep -r 'SSL{' /` ничего не находит, а открыть «скрипт
инициализации» невозможно — его нет.

Подробности и шаблоны — в [`AUTHORING.md`](AUTHORING.md).

## Структура

```text
tasks/
├── base/            # linux-ctf/base: инструменты, пользователь ctf, entrypoint
├── buildtools/      # linux-ctf/buildtools: gcc + генератор зашифрованного флага
│   ├── ctf-make-challenge
│   ├── ctf-xor
│   └── src/         # C-исходники вспомогательных программ
├── T01/ … T15/      # задачи (Dockerfile, prepare.sh, README-dev.md)
├── tests/smoke.sh
├── Makefile
└── README.md
```

## Список задач

| ID  | Название               | Тема                     | Флаг по умолчанию            |
|-----|------------------------|--------------------------|------------------------------|
| T01 | Осмотр комнаты         | файловая система         | `SSL{first_linux_steps}`     |
| T02 | Скрытая записка        | скрытые файлы            | `SSL{hidden_note}`           |
| T03 | Запутанный путь        | пути, `.` и `..`         | `SSL{relative_paths}`        |
| T04 | Нужная строка          | grep                     | `SSL{grep_basics}`           |
| T05 | Большой журнал         | grep -n                  | `SSL{log_search}`            |
| T06 | Лишние данные          | cut / sort / uniq        | `SSL{text_pipeline}`         |
| T07 | Где лежит ключ?        | find                     | `SSL{find_it}`               |
| T08 | Чужой файл             | группы и права           | `SSL{groups_matter}`         |
| T09 | Запусти программу      | chmod, бит `x`           | `SSL{execution_permission}`  |
| T10 | Что внутри?            | zip                      | `SSL{zip_basics}`            |
| T11 | Испорченное сообщение  | распознавание base64     | `SSL{base64_secret}`         |
| T12 | Что это вообще?        | file, strings            | `SSL{strings_are_useful}`    |
| T13 | Странная программа     | strings + запуск         | `SSL{simple_reverse}`        |
| T14 | Что здесь работает?    | процессы и аргументы     | `SSL{process_argument}`      |
| T15 | Где настоящий вывод?   | stdout / stderr          | `SSL{stderr_is_a_stream}`    |

Флаги в таблице — ожидаемые ответы (для проверки платформой).  В самих
образах их нет: там только `flag.enc`, зашифрованный случайным ключом.

## Сборка

```bash
cd tasks

make base          # linux-ctf/base
make buildtools    # linux-ctf/buildtools (нужен задачам на этапе сборки)
make T01           # linux-ctf/t01
make all           # base + buildtools + все задачи
```

Вручную:

```bash
docker build -t linux-ctf/base:latest        base
docker build -t linux-ctf/buildtools:latest  buildtools
docker build -t linux-ctf/t01                T01
```

## Запуск

```bash
docker run --rm -it linux-ctf/t01
```

Студент попадает в рабочий каталог задачи (обычно `/home/ctf`).
«Перезапустить задачу» — создать новый контейнер.

Рекомендуемые ограничения:

```bash
docker run --rm -it \
    --memory=256m --cpus=0.5 --pids-limit=256 \
    --network=none \
    linux-ctf/t01
```

## Проверка решения

Ожидаемый флаг каждой задачи — в таблице выше.  Студент получает его,
найдя ключ и выполнив `./decrypt.sh <ключ>`.

## Готовые архивы образов

```bash
cd tasks
mkdir -p dist
for t in $(seq -w 1 15); do
    docker save "linux-ctf/t${t}:latest" -o "dist/linux-ctf-t${t}.tar"
done
( cd dist && sha256sum linux-ctf-t*.tar > SHA256SUMS )
```

Каталог `dist/` исключён из git и предназначен для раздачи
(`docker load -i` описан в [STUDENT-GUIDE.md](STUDENT-GUIDE.md)).

## Тесты

```bash
tasks/tests/smoke.sh
```

Для каждого образа проверяется: отсутствие открытого флага и
`/opt/setup.sh`, нахождение ключа штатным способом и корректная
расшифровка, а также специфичные свойства (права, группы, процессы).
