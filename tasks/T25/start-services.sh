#!/bin/bash
# Запуск фоновых сервисов задачи T25 "Неправильный заголовок".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{custom_headers}}"
export TASK_FLAG

nohup python3 /opt/server.py >>/var/log/task.log 2>&1 &

# Дать серверу время открыть порт.
sleep 1
