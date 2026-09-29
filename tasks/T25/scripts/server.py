#!/usr/bin/env python3
"""HTTP-сервис задачи T25 "Неправильный заголовок".

Слушает 127.0.0.1:8080.  Страница /admin защищена заголовком:

    * без заголовка X-CTF-Hint: use-the-header -> 403,
      причём ответ сам содержит заголовок X-CTF-Hint: use-the-header;
    * с правильным значением заголовка -> флаг.
"""

import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

FLAG = os.environ.get("TASK_FLAG", "flag{custom_headers}")
HINT_NAME = "X-CTF-Hint"
HINT_VALUE = "use-the-header"
HOST = "127.0.0.1"
PORT = 8080


class Handler(BaseHTTPRequestHandler):
    server_version = "ctf-web/1.0"

    def _send(self, status, body=b"", headers=None):
        self.send_response(status)
        for name, value in (headers or {}).items():
            self.send_header(name, value)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if body:
            self.wfile.write(body)

    def do_GET(self):
        path = urlparse(self.path).path

        if path == "/admin":
            provided = self.headers.get(HINT_NAME, "")
            if provided.strip() == HINT_VALUE:
                self._send(200, (FLAG + "\n").encode())
            else:
                self._send(
                    403,
                    b"Forbidden: missing or wrong header\n",
                    headers={HINT_NAME: HINT_VALUE},
                )
        elif path == "/":
            self._send(200, b"Welcome. Try /admin\n")
        else:
            self._send(404, b"Not Found\n")

    def log_message(self, fmt, *args):
        super().log_message(fmt, *args)


def main():
    server = HTTPServer((HOST, PORT), Handler)
    server.serve_forever()


if __name__ == "__main__":
    main()
