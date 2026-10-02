# Сборка образов практикума Linux/CTF.
#
#   make base        - общий базовый образ linux-ctf/base
#   make buildtools  - сборочный образ linux-ctf/buildtools (gcc + генератор)
#   make T01         - образ задачи T01
#   make all         - собрать всё
#   make test        - smoke-тесты
#   make clean       - удалить собранные образы

BASE_IMAGE       ?= linux-ctf/base:latest
BUILDTOOLS_IMAGE ?= linux-ctf/buildtools:latest

TASKS := $(notdir $(wildcard T[0-9][0-9]))

.PHONY: all base buildtools test clean $(TASKS)

all: base buildtools $(TASKS)

base:
	docker build -t $(BASE_IMAGE) base

buildtools: base
	docker build -t $(BUILDTOOLS_IMAGE) buildtools

$(TASKS): buildtools
	docker build -t linux-ctf/$(shell echo $@ | tr 'A-Z' 'a-z') $@

test: base buildtools $(TASKS)
	tests/smoke.sh

clean:
	-docker image rm -f $(BASE_IMAGE) $(BUILDTOOLS_IMAGE)
	-docker image rm -f $$(docker images -q 'linux-ctf/t*') 2>/dev/null || true
