#!/usr/bin/env python3
"""Инъекция runtime-флага в бинарные файлы на месте.

Использование:
    patch_flag.py <marker> <flag> <file> [file ...]

Каждое вхождение <marker> заменяется на <flag>.  Маркер должен быть не
короче флага; остаток добивается NUL-байтами, поэтому общий размер файла
(а значит и все смещения внутри него) не меняется.

Это позволяет не хранить реальный флаг в образе: в бинарник на этапе
сборки зашит только безобидный плейсхолдер, а сам флаг записывается при
запуске контейнера.
"""

import sys


def main(argv):
    if len(argv) < 4:
        print(__doc__, file=sys.stderr)
        return 2

    marker = argv[1].encode()
    flag = argv[2].encode()

    if len(flag) > len(marker):
        print("patch_flag.py: маркер должен быть не короче флага",
              file=sys.stderr)
        return 3

    replacement = flag + b"\x00" * (len(marker) - len(flag))

    status = 0
    for path in argv[3:]:
        try:
            with open(path, "rb") as handle:
                data = handle.read()
        except OSError as exc:
            print(f"patch_flag.py: не удалось прочитать {path}: {exc}",
                  file=sys.stderr)
            status = 1
            continue

        if marker not in data:
            print(f"patch_flag.py: маркер не найден в {path}",
                  file=sys.stderr)
            status = 1
            continue

        with open(path, "wb") as handle:
            handle.write(data.replace(marker, replacement))

    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv))
