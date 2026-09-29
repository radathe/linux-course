#!/usr/bin/env python3
"""TCP-сервис задачи T26 (часть 8).

Слушает 127.0.0.1:31337.  При каждом подключении сразу отдаёт
последний фрагмент флага: "ok}".
"""

import socket

HOST = "127.0.0.1"
PORT = 31337
BANNER = b"ok}\n"


def main():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((HOST, PORT))
    srv.listen(16)

    while True:
        conn, _addr = srv.accept()
        with conn:
            conn.sendall(BANNER)


if __name__ == "__main__":
    main()
