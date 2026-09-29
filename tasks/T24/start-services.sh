#!/bin/bash
# Запуск фоновых сервисов задачи T24 "Исследуй веб-сервис".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{curl_basics}}"
export TASK_FLAG

nohup python3 /opt/server.py >>/var/log/task.log 2>&1 &

# Дать серверу время открыть порт.
sleep 1
