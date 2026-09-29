# Сборка образов практикума Linux/CTF.
#
#   make base     - собрать общий базовый образ linux-ctf/base
#   make tools    - собрать образ с ELF-бинарниками linux-ctf/tools
#   make T01      - собрать задачу T01
#   make all      - собрать всё
#   make test     - запустить smoke-тесты
#   make clean    - удалить собранные образы

BASE_IMAGE  ?= linux-ctf/base:latest
TOOLS_IMAGE ?= linux-ctf/tools:latest

# D01 -- отдельная локальная практика по Docker: её образ собирает сам
# студент, поэтому в общий список задач она не входит.
TASKS := $(notdir $(wildcard T[0-9][0-9]))

.PHONY: all base tools test clean $(TASKS)

all: base tools $(TASKS)

base:
	docker build -t $(BASE_IMAGE) base

tools:
	docker build -t $(TOOLS_IMAGE) tools

$(TASKS): base tools
	docker build -t linux-ctf/$(shell echo $@ | tr 'A-Z' 'a-z') $@

test: base tools $(TASKS)
	tests/smoke.sh

clean:
	-docker image rm -f $(BASE_IMAGE) $(TOOLS_IMAGE)
	-docker image rm -f $$(docker images -q 'linux-ctf/t*') 2>/dev/null || true
