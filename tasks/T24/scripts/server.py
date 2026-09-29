#!/usr/bin/env python3
"""HTTP-сервис задачи T24 "Исследуй веб-сервис".

Слушает 127.0.0.1:8080 и отдаёт:
    /        -> 302 перенаправление на /welcome
    /welcome -> "Welcome!\n\nTry /secret\n"
    /secret  -> флаг
"""

import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

FLAG = os.environ.get("TASK_FLAG", "flag{curl_basics}")
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

        if path == "/":
            self._send(302, headers={"Location": "/welcome"})
        elif path == "/welcome":
            self._send(200, b"Welcome!\n\nTry /secret\n")
        elif path == "/secret":
            self._send(200, (FLAG + "\n").encode())
        else:
            self._send(404, b"Not Found\n")

    def log_message(self, fmt, *args):
        # Аккуратный лог в /var/log/task.log через stdout/stderr.
        super().log_message(fmt, *args)


def main():
    server = HTTPServer((HOST, PORT), Handler)
    server.serve_forever()


if __name__ == "__main__":
    main()
