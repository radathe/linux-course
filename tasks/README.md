# Практикум Linux/CTF в Docker

Набор изолированных практических заданий по Linux для вводного курса по
информационной безопасности.  Каждая задача — отдельный Docker-образ и
отдельный контейнер.  Студент получает непривилегированный shell
пользователя `ctf` и решает задачу, исследуя файловую систему, процессы,
сервисы и т. п.

> Здесь находятся **только исходники** задач: Dockerfile, скрипты
> инициализации и вспомогательные файлы.  Готовые образы собираются
> командой `docker build`/`make` (см. ниже).

## Структура

```text
tasks/
├── base/            # общий базовый образ linux-ctf/base
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── patch_flag.py
├── tools/           # общий образ с ELF-бинарниками linux-ctf/tools
│   ├── Dockerfile
│   └── src/
├── T01/ ... T26/    # задачи практикума
├── D01/             # отдельная локальная задача по Docker
├── tests/           # smoke-тесты
├── Makefile
└── README.md
```

Типовая задача:

```text
Txx/
├── Dockerfile       # сборка образа (FROM linux-ctf/base или linux-ctf/tools)
├── setup.sh         # runtime-инициализация: файлы, права, генерация флага
├── start-services.sh# (опционально) запуск фоновых сервисов/процессов
├── files/           # (опционально) статические файлы
├── scripts/         # (опционально) вспомогательные программы
└── README-dev.md    # условие, флаг, подсказки, решение, smoke test
```

## Список задач

| ID  | Название               | Тема                    | Флаг по умолчанию |
|-----|------------------------|-------------------------|-------------------|
| T01 | Осмотр комнаты         | файловая система        | `flag{first_linux_steps}` |
| T02 | Скрытая записка        | скрытые файлы           | `flag{hidden_note}` |
| T03 | Запутанный путь        | пути, `.` и `..`        | `flag{relative_paths}` |
| T04 | Нужная строка          | grep                    | `flag{grep_basics}` |
| T05 | Большой журнал         | grep -n                 | `flag{log_search}` |
| T06 | Лишние данные          | sort / uniq / cut       | `flag{text_pipeline}` |
| T07 | Где лежит флаг?        | find                    | `flag{find_it}` |
| T08 | Большая уборка         | find по свойствам       | `flag{find_cleanup}` |
| T09 | Чужой файл             | группы и права          | `flag{groups_matter}` |
| T10 | Запусти программу      | chmod, бит `x`          | `flag{execution_permission}` |
| T11 | Что внутри?            | zip                     | `flag{zip_basics}` |
| T12 | Матрешка               | вложенные архивы        | `flag{archives_in_archives}` |
| T13 | Hex or Base64?         | hex + base64            | `flag{hex_and_base64}` |
| T14 | Испорченное сообщение  | распознавание base64    | `flag{base64_secret}` |
| T15 | Что это вообще?        | file, strings           | `flag{strings_are_useful}` |
| T16 | Странная программа     | strings + запуск        | `flag{simple_reverse}` |
| T17 | Первый скрипт          | bash-скрипт             | `flag{bash_scripting}` |
| T18 | Автоматизируй поиск    | циклы и условия         | `flag{automation}` |
| T19 | Что здесь работает?    | процессы и аргументы    | `flag{process_argument}` |
| T20 | Секрет процесса        | переменные окружения    | `flag{environment_secret}` |
| T21 | Где настоящий вывод?   | stdout / stderr         | `flag{stderr_is_a_stream}` |
| T22 | Обработай поток        | конвейеры               | `flag{stream_processing}` |
| T23 | Подключись к сервису   | nc                      | `flag{netcat_basics}` |
| T24 | Исследуй веб-сервис    | curl, редиректы         | `flag{curl_basics}` |
| T25 | Неправильный заголовок | HTTP-заголовки          | `flag{custom_headers}` |
| T26 | Маленький Linux CTF    | итоговая                | `flag{linux_ctf_basics_are_easier_together_ok}` |
| D01 | Собери окружение       | Docker (локально)       | `flag{docker_complete}` |

`D01` — отдельная локальная практика: готового challenge-образа нет, его
собирает сам студент из `D01/challenge/`. Поэтому в `Makefile` задача
`D01` не входит, а её эталонное решение лежит в `D01/solution/Dockerfile`.

## Сборка

Сначала собираются базовые образы, затем задачи.

```bash
cd tasks

make base          # docker build -t linux-ctf/base:latest base
make tools         # docker build -t linux-ctf/tools:latest tools

make T01           # docker build -t linux-ctf/t01 T01
make all           # собрать всё (base + tools + все задачи)
```

Каждую задачу можно собрать и вручную:

```bash
docker build -t linux-ctf/base:latest  base
docker build -t linux-ctf/tools:latest tools
docker build -t linux-ctf/t01          T01
```

## Запуск

```bash
docker run --rm -it linux-ctf/t01
```

Студент сразу попадает в рабочий каталог задачи (обычно `/home/ctf`).
Кнопка/механика «перезапустить задачу» — это просто создание нового
контейнера: состояние инициализируется заново.

Рекомендуемые ограничения (учебная платформа выставляет их сама):

```bash
docker run --rm -it \
    --memory=256m --cpus=0.5 --pids-limit=256 \
    --network=none \
    --security-opt=no-new-privileges \
    linux-ctf/t01
```

`--network=none` оставляет доступным `localhost` — этого достаточно для
сетевых задач (T23–T25), сервисы которых слушают внутри контейнера.
Docker-сокет хоста монтировать нельзя; privileged-режим не требуется.

## Флаги

Флаг имеет вид `flag{...}` и уникален для каждой задачи.

По умолчанию флаг **генерируется при запуске контейнера** в `setup.sh`.
Платформа может переопределить его переменной окружения:

```bash
docker run --rm -it -e TASK_FLAG='flag{...}' linux-ctf/t01
```

Скрипты используют конструкцию `${TASK_FLAG:-flag{default}}`, поэтому
реальный флаг удобно не хранить в образе, а подставлять в runtime.

Для бинарных задач (T15, T16, T26) реальный флаг внедряется в ELF уже
при старте контейнера утилитой `patch_flag.py`: в самом бинарнике на
этапе сборки лежит только плейсхолдер `flag{PLACEHOLDER_DO_NOT_SHIP}`.

## Жизненный цикл контейнера

```text
создание контейнера
        ↓
/opt/setup.sh          (root: файлы, права, генерация флага)
        ↓
/opt/start-services.sh (root: фоновые процессы и сервисы)
        ↓
сброс привилегий до ctf
        ↓
интерактивный shell
        ↓
проверка флага
        ↓
удаление контейнера
```

Точка входа описана в `base/entrypoint.sh`.

## Тесты

```bash
tasks/tests/smoke.sh
```

Скрипт собирает образы и проверяет, что контейнер запускается, нужные
пользователи/файлы/права/процессы/сервисы присутствуют и флаг находится
там, где ожидается.  Требуется запущенный Docker.
