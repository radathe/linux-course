# D01. Собери окружение

**Тема:** Docker (локальная практика) · **Сложность:** 🟢 · **Время:** 15–25 минут

> Это **не** контейнер-задача практикума: готового образа нет, его
> собирает сам студент на своей машине.  В `Makefile` задача `D01`
> намеренно не входит в общий список.

## Условие для студента

> Вам выдан каталог `challenge/` с приложением на Flask:
> `server.py`, `requirements.txt` и заготовка `Dockerfile` с TODO.
>
> Доделайте `Dockerfile`, соберите образ, запустите из него контейнер
> и опубликуйте порт приложения на хост.
>
> Приложение слушает порт `5000` внутри контейнера.  После публикации
> команда
>
> ```bash
> curl http://localhost:8080
> ```
>
> должна вернуть строку `flag{docker_complete}`.

## Что дано

```text
D01/
├── challenge/            # рабочая копия студента
│   ├── Dockerfile        # заготовка с TODO (нужно доделать)
│   ├── server.py         # Flask-приложение
│   └── requirements.txt  # зависимости
└── solution/
    └── Dockerfile        # эталонное решение
```

`server.py`:

```python
from flask import Flask

app = Flask(__name__)


@app.route("/")
def index():
    return "flag{docker_complete}\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Приложение должно слушать `0.0.0.0`, иначе порт не будет доступен извне
контейнера.

## Закрепляемые понятия

* `docker build` — сборка **образа** из `Dockerfile` по контексту сборки;
* `docker run` — создание и запуск **контейнера** из образа;
* `docker images`, `docker ps` (в т. ч. `-a`), `docker stop` / `docker rm`;
* **образ** (слои, неизменяемость) vs **контейнер** (запущенный экземпляр);
* **порт контейнера** (`EXPOSE`, `5000`) vs **порт хоста** (`-p`), их
  связь через публикацию портов;
* проброс/публикация порта `-p 8080:5000` и обращение с хоста по
  `localhost:8080`.

## Подсказки

1. Базовый образ выберите с уже установленным Python, например
   `python:3.12-slim`.
2. Укажите рабочий каталог внутри образа (`WORKDIR`), например `/app`,
   и скопируйте туда оба файла приложения.
3. Зависимости ставятся из `requirements.txt`; используйте
   `pip install -r requirements.txt`.
4. В `Dockerfile` задокументируйте порт (`EXPOSE 5000`) — это подсказка
   человеку, а не правило публикации.
5. Публикация порта делается при **запуске** контейнера:
   `-p 8080:5000` означает «хост-порт `8080` → порт контейнера `5000`».
6. Проверяйте результат запросом к `localhost` **с хоста**, а не изнутри
   контейнера.
7. Если получили `Connection refused` или пустой ответ — проверьте,
   что приложение слушает `0.0.0.0` и что порты в `-p` перечислены в
   правильном порядке.
8. `docker ps` покажет, запущен ли контейнер и опубликован ли порт.

## Проверка

```bash
cd D01/challenge

# 1. Собрать образ
docker build -t d01-challenge .

# 2. Запустить контейнер, опубликовав порт
docker run -d --name d01 -p 8080:5000 d01-challenge

# 3. Проверить ответ
curl http://localhost:8080
# flag{docker_complete}

# 4. Посмотреть состояние
docker ps
docker images

# 5. Остановить и удалить
docker stop d01
docker rm d01
```

Эталонное решение (`solution/Dockerfile`) можно проверить так:

```bash
cd D01
docker build -f solution/Dockerfile -t d01-solution challenge
docker run --rm -d --name d01sol -p 8080:5000 d01-solution
curl http://localhost:8080     # flag{docker_complete}
docker stop d01sol
```

Критерий успеха: `curl http://localhost:8080` на хосте возвращает
`flag{docker_complete}`.

## Smoke test (для преподавателя)

```bash
# Только при наличии Docker-демона.
docker build -f solution/Dockerfile -t d01-solution challenge
docker run --rm -d --name d01-sol -p 18080:5000 d01-solution
sleep 2
curl -fsS http://localhost:18080 | grep -qx 'flag{docker_complete}'
docker stop d01-sol
```
