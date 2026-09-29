#!/usr/bin/env python3
"""TCP-сервер задачи T23 "Подключись к сервису".

Слушает 127.0.0.1:31337.  При каждом подключении отправляет приветствие
и флаг, после чего закрывает соединение.  Сервер обслуживает несколько
подключений подряд (бесконечный цикл accept).

Флаг берётся из переменной окружения TASK_FLAG, поэтому он не хранится
в исходнике сервера и не виден в списке аргументов процесса.
"""

import os
import socket

HOST = "127.0.0.1"
PORT = 31337
FLAG = os.environ.get("TASK_FLAG", "flag{netcat_basics}")


def serve_forever():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as srv:
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((HOST, PORT))
        srv.listen(5)
        while True:
            conn, _ = srv.accept()
            try:
                reply = b"Welcome!\n" + FLAG.encode("utf-8") + b"\n"
                conn.sendall(reply)
            finally:
                conn.close()


if __name__ == "__main__":
    serve_forever()
