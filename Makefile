
# Enigma
ENIGMA=./enigma
ENIGMA_SRC=$(ENIGMA)/src

fix_module_canvas:
	perl -pi -E 's/elm\_canvas\$$elm\_canvas/kradalby\$$elm\_enigma/g' $(ENIGMA)/canvas/src/Native/Canvas.js

fix_sass_bin_in_docker:
	docker-compose  run --entrypoint="bash -c" elm "/usr/local/bin/npm install --force node-sass elm"


# MIIC
MIIC=./miic
MIIC_SRC=$(MIIC)/src
ENV=$(MIIC)/env/bin
SHELL := /bin/bash
PYTHON=$(ENV)/python
PIP=$(ENV)/pip
MANAGE=$(PYTHON) manage.py

collect_static:
	$(MANAGE) collectstatic --noinput --clear --link

flake8:
	$(ENV)/flake8 ./src

dev:
	$(PIP) install -r $(MIIC)/requirements/dev.txt --upgrade

prod:
	$(PIP) install -r $(MIIC)requirements/prod.txt --upgrade

init:
	tar xJvf media.tar.xz --directory $(ENIGMA_SRC)
	tar xJvf postgres.tar.xz --directory $(ENIGMA_SRC)

env:
	virtualenv -p `which python3` $(ENV)

test:
	$(MANAGE) test

run:
	$(MANAGE) runserver 0.0.0.0:8000

freeze:
	mkdir -p $(MIIC)/requirements
	$(PIP) freeze > $(MIIC)/requirements/base.txt

createsuperuser:
	docker-compose run --entrypoint="bash -c" miic "./manage.py createsuperuser"

loaddata:
	docker-compose run --entrypoint="bash -c" miic "./manage.py loaddata 200916.json"

migrate:
	docker-compose run --entrypoint="bash -c" miic "./manage.py migrate"

makemigrations:
	docker-compose run --entrypoint="bash -c" miic "./manage.py makemigrations ${ARGS}"


# General
REPO=kradalby/enigma

sign:
	drone sign $(REPO)
