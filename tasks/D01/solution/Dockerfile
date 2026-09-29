# D01 "Собери окружение" -- эталонное решение.
#
# Сборка (контекст -- каталог challenge):
#     docker build -f solution/Dockerfile -t d01-solution challenge
# Запуск с публикацией порта:
#     docker run --rm -p 8080:5000 d01-solution
FROM python:3.12-slim

WORKDIR /app

COPY server.py requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "server.py"]
