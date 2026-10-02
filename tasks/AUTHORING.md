# Как устроены задачи (для авторов)

## Идея

- Состояние задачи готовится **на этапе сборки**, а не при запуске
  контейнера.  Никакого `setup.sh` внутри образа нет.
- Настоящий флаг **никогда не хранится в образе в открытом виде**.  Он
  XOR-шифруется случайным ключом; в `/home/ctf` лежат:
  - `flag.enc` — зашифрованный флаг (hex);
  - `decrypt.sh` — скрипт расшифровки: `./decrypt.sh <ключ>`;
  - `README` — пояснение.
- **Ключ** (случайная hex-строка, 16 байт) прячется в задаче так, чтобы
  его нашли с помощью изучаемого навыка.
- Итог: `grep -r 'SSL{' /` ничего не находит, а `cat /opt/setup.sh`
  невозможен — файла нет.

## Шаблон Dockerfile

```dockerfile
# Txx "..." -- <тема>.
FROM linux-ctf/buildtools:latest AS prep
WORKDIR /prep
COPY prepare.sh /prep/prepare.sh
RUN STAGE=/stage bash /prep/prepare.sh

FROM linux-ctf/base:latest
COPY --from=prep /stage/ /
ENV START_DIR=/home/ctf
WORKDIR /home/ctf
```

Файлы из `/stage` попадают в финальный образ с сохранением владельца и
прав.  Сборочные инструменты и плейнтекстовый флаг остаются в stage prep
и в финальный образ не входят.

## Шаблон prepare.sh

```bash
#!/bin/bash
# СБОРОЧНЫЙ скрипт задачи Txx.
set -euo pipefail

STAGE="${STAGE:-/stage}"

# 1. Зашифрованный флаг + случайный ключ (ключ печатается в stdout).
key="$(ctf-make-challenge 'SSL{...}' "$STAGE")"

# 2. Файлы задачи.  Ключ кладём туда, где его должен найти студент.
# ...

# 3. Права/владельцы.
chown -R ctf:ctf "$STAGE/home/ctf"
```

## Правила

1. **Никогда не записывать в `/stage` строку `SSL{`** (кроме самого
   `flag.enc`, где её нет, так как он зашифрован).  Приманки-«флаги»
   делать только искажёнными: `SLS{secret}`, `ssl{secret}`,
   `SSl{secret}`, `SSL[secret]`, `SSL(secret)`, `SSL-Secret`, `S5L{...}`
   — без `SSL{`.
2. Использовать ровно один вызов `ctf-make-challenge` с флагом задачи.
3. ELF-программы компилировать из `/src/*.c` (образ buildtools), заменяя
   `@KEY@`:
   - открытый ключ (для `strings`, задача T12):
     `sed "s/@KEY@/$key/" /src/mystery.c > /tmp/m.c && gcc -O0 -Wall -Wextra -o "$STAGE/home/ctf/mystery" /tmp/m.c`;
   - XOR-ключ (T09, T13): `enc="$(ctf-xor "$key" 5A)"`, затем
     `sed "s/@KEY@/$enc/" ...`.  Компилировать всегда с `-O0`.
4. Права и владельцы выставлять в `prepare.sh` явно.  После установки
   ограничительных прав (`0000`, `0111`) **не** вызывать
   `chmod -R a+rX`.
5. Каждая задача: `Dockerfile`, `prepare.sh`, `README-dev.md`.
6. `README-dev.md` оформлять как в T01: условие, состояние, флаг, навыки,
   ≥2 подсказки, решение, smoke test.  В условии объяснять, что нужно
   найти **ключ**, а затем выполнить `./decrypt.sh <ключ>`.
7. Проверять `bash -n prepare.sh`.

## Флаги и места, где прячется ключ

| ID  | Флаг                        | Где ключ |
|-----|-----------------------------|----------|
| T01 | `SSL{first_linux_steps}`    | `~/Documents/notes.txt` |
| T02 | `SSL{hidden_note}`          | `~/Documents/.secret` (скрытый) |
| T03 | `SSL{relative_paths}`       | `~/secret/key.txt`, cwd `~/work` |
| T04 | `SSL{grep_basics}`          | строка `password=<key>` в `~/notes.txt` |
| T05 | `SSL{log_search}`           | строка `[ERROR] <key>` в `~/server.log` |
| T06 | `SSL{text_pipeline}`        | одно из уникальных имён в `~/users.txt` |
| T07 | `SSL{find_it}`              | `/opt/data/c/archive/key.txt` |
| T08 | `SSL{groups_matter}`        | `/opt/data/secret.txt` (root:analysts 640) |
| T09 | `SSL{execution_permission}` | печатает `/opt/runme` после `chmod u+x` |
| T10 | `SSL{zip_basics}`           | `key.txt` внутри `~/backup.zip` |
| T11 | `SSL{base64_secret}`        | `~/message.txt` (base64 от ключа) |
| T12 | `SSL{strings_are_useful}`   | виден через `strings ~/mystery` |
| T13 | `SSL{simple_reverse}`       | печатает `~/checker` при пароле `open-sesame` |
| T14 | `SSL{process_argument}`     | в аргументах процесса `/opt/worker` |
| T15 | `SSL{stderr_is_a_stream}`   | в stderr программы `/opt/check` |

Дополнительно: для T07, T08, T09, T14, T15 в `/home/ctf/hint.txt` кладётся
ненавязчивая подсказка, где искать ключ.
