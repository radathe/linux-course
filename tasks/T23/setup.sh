#!/bin/bash
# Runtime-инициализация задачи T23 "Подключись к сервису".
set -euo pipefail

# Сервер запускается из start-services.sh; здесь только выставляем права.
chmod 0755 /opt/server.py
