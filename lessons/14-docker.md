Docker

Docker - это инструмент для запуска приложений в изолированной среде, называемой контейнером. Контейнер использует ядро операционной системы хоста, но имеет собственную файловую систему, процессы, сетевые настройки и другие ограниченные ресурсы.

Docker часто используется в разработке и администрировании, а в CTF особенно полезен для развёртывания задач. Например, организаторы могут подготовить Docker-образ с уязвимым веб-приложением и запускать из него отдельный контейнер для каждого участника.



Образ и контейнер

Docker-образ содержит всё необходимое для запуска приложения: файловую систему, программы, библиотеки и настройки.

Контейнер — это конкретный запущенный экземпляр образа.

Один образ можно использовать для создания множества контейнеров. Контейнеры будут запускать одну и ту же программу, но работать изолированно друг от друга.



Получение образа

Docker может загружать готовые образы из Docker Hub и других registry.

Например:

> docker pull ubuntu

После этого локально появится образ Ubuntu.

Посмотреть имеющиеся образы:

> docker images

Пример:

REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
ubuntu       latest    ...            ...            ...
nginx        latest    ...            ...            ...

Удалить ненужный образ:

> docker rmi ubuntu



Запуск контейнера

Для запуска контейнера используется:

> docker run ubuntu

Однако такой контейнер может сразу завершиться, если запущенная внутри него программа закончила работу.

Например:

> docker run ubuntu echo "Hello"

Результат:

Hello

Здесь происходят следующие действия:

ubuntu image
     ↓
создаётся container
     ↓
запускается echo
     ↓
echo завершается
     ↓
container завершается



Интеракитивный контейнер

Часто нужно не просто запустить одну команду, а получить shell внутри контейнера.

Для этого используются параметры -i и -t:

> docker run -it ubuntu bash

После этого появляется shell внутри контейнера:

root@a1b2c3d4:/#

Теперь можно использовать уже знакомые команды, например:

root@a1b2c3d4:/# whoami
root

Здесь важно понимать, что root — это пользователь внутри контейнера, а не автоматически root на хост-системе.

Можно представить контейнер как отдельную небольшую Linux-среду:

ваш компьютер
└── Docker
     └── container
          └── Linux userspace
               └── Bash

При этом контейнер не является полноценной виртуальной машиной: он использует ядро хостовой системы.



Просмотр контейнеров

Посмотреть запущенные контейнеры:

> docker ps

Например:

CONTAINER ID   IMAGE    COMMAND   STATUS       PORTS
a1b2c3d4       ubuntu   "bash"    Up 2 minutes

Посмотреть все контейнеры, в том числе остановленные:

> docker ps -a

Это важно, потому что завершившийся контейнер обычно не исчезает автоматически.

Запустить уже существующий контейнер:

> docker start a1b2c3d4

Остановить:

> docker stop a1b2c3d4

Удалить:

> docker rm a1b2c3d4



Dockerfile

Готовые образы удобны, но часто необходимо создать собственный.

Для этого используется файл Dockerfile.

Dockerfile содержит инструкции, из которых Docker строит образ.

Простейший пример:

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y python3

COPY hello.py /hello.py

CMD ["python3", "/hello.py"]

Здесь:

FROM  - исходный образ
RUN   - выполнить команду при сборке
COPY  - скопировать файл в образ
CMD   - команда по умолчанию при запуске контейнера



Создание собственного образа

Пусть рядом находятся:

project/
├── Dockerfile
└── hello.py

Содержимое hello.py:

> print("Hello from Docker!")

Dockerfile:

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y python3

COPY hello.py /hello.py

CMD ["python3", "/hello.py"]

Собрать образ:

> docker build -t my-python-app .

Здесь:

-t my-python-app - имя создаваемого образа
.                - текущий каталог как build context

После сборки

> docker images

может показать:

REPOSITORY      TAG       IMAGE ID
my-python-app   latest    ...



Запуск собственного образа

Теперь можно создать контейнер:

> docker run my-python-app

Результат:

Hello from Docker!

Получается полный цикл:

Dockerfile
    ↓
docker build
    ↓
Docker image
    ↓
docker run
    ↓
Docker container
    ↓
запуск приложения



Фоновый запуск

Если приложение должно работать в фоне, используется параметр -d:

> docker run -d nginx

Docker вернёт идентификатор контейнера:

a1b2c3d4...

Проверить:

> docker ps

Остановить контейнер:

> docker stop a1b2c3d4



Полезный минимальный набор команд

Для начала работы с Docker достаточно знать:

docker pull IMAGE
docker images

docker run IMAGE
docker run -it IMAGE bash
docker run -d IMAGE

docker ps
docker ps -a

docker start CONTAINER
docker stop CONTAINER
docker rm CONTAINER

docker exec -it CONTAINER bash

docker build -t IMAGE .
docker rmi IMAGE
